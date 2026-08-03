import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase/supabase.dart';
import 'package:consulta_cnpj_new/core/config/support_config.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_address_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/payments_service.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

class CndOrdersException implements Exception {
  CndOrdersException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ActiveOrderExistsException extends CndOrdersException {
  ActiveOrderExistsException(this.order)
      : super('Já existe um pedido vigente para este CNPJ');
  final CndOrderModel order;
}

class PlanLimitReachedException extends CndOrdersException {
  PlanLimitReachedException({
    String message = 'Limite do plano atingido para este produto',
    this.suggestedTier = 2,
  }) : super(message);
  final int suggestedTier;
}

class CndOrdersService {
  static final CndOrdersService instance = CndOrdersService._();
  CndOrdersService._();

  static const _catalogAsset = 'assets/config/cnd_certificates.json';

  CndCatalogModel? _catalog;

  Future<CndCatalogModel> loadCatalog() async {
    if (_catalog != null) return _catalog!;
    try {
      final raw = await rootBundle.loadString(_catalogAsset);
      _catalog = CndCatalogModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return _catalog!;
    } catch (e) {
      debugPrint('CndOrdersService.loadCatalog: $e');
      rethrow;
    }
  }

  CndAddressModel addressFromCnpj(CnpjModel cnpj, {String? phone}) {
    return CndAddressModel(
      cep: _formatCep(cnpj.cep ?? ''),
      logradouro: cnpj.logradouro ?? '',
      numero: cnpj.numero ?? '',
      complemento: cnpj.complemento,
      bairro: cnpj.bairro ?? '',
      cidade: cnpj.municipio ?? '',
      uf: cnpj.uf ?? '',
      telefone: phone,
    );
  }

  Future<CndOrderModel> createOrder({
    required CnpjModel company,
    required String guestEmail,
    required String guestPhone,
    required String productKind,
  }) async {
    final auth = SupabaseAuthService.instance;
    await _ensureAuthReady(auth);

    final catalog = await loadCatalog();
    final productId = catalog.resolveProductId(productKind);
    final phoneDigits = guestPhone.replaceAll(RegExp(r'\D'), '');
    final address = addressFromCnpj(
      company,
      phone: phoneDigits.isEmpty ? null : phoneDigits,
    );

    final companyName = (company.nome ?? '').trim();
    if (companyName.isEmpty) {
      throw CndOrdersException('Razão social não encontrada para este CNPJ');
    }
    if (address.logradouro.trim().isEmpty ||
        address.numero.trim().isEmpty ||
        address.bairro.trim().isEmpty ||
        address.cidade.trim().isEmpty ||
        address.uf.trim().isEmpty) {
      throw CndOrdersException(
        'Endereço incompleto no cadastro da empresa. Não é possível continuar.',
      );
    }

    final payload = <String, dynamic>{
      'productId': productId,
      'cnpj': _formatCnpj(company.cnpj ?? ''),
      'companyName': companyName,
      'guestEmail': guestEmail.trim(),
      'address': address.toJson(),
      if (phoneDigits.isNotEmpty) 'guestPhone': phoneDigits,
    };

    final client = auth.client;
    if (client == null) {
      throw CndOrdersException('Sessão inválida. Reabra o app e tente novamente.');
    }

    try {
      final response = await client.functions.invoke(
        'create-order',
        body: payload,
        headers: {
          'Authorization': 'Bearer ${auth.currentJwt}',
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw CndOrdersException('Erro ao criar pedido');
      }

      final map = Map<String, dynamic>.from(data);
      if (map['code'] == 'ACTIVE_ORDER_EXISTS' && map['order'] is Map) {
        throw ActiveOrderExistsException(
          CndOrderModel.fromJson(
            Map<String, dynamic>.from(map['order'] as Map),
          ),
        );
      }
      if (map['code'] == 'PLAN_LIMIT_REACHED') {
        throw PlanLimitReachedException(
          message: map['error'] as String? ??
              'Limite do plano atingido para este produto',
          suggestedTier: (map['suggestedTier'] as num?)?.toInt() ?? 2,
        );
      }

      return CndOrderModel.fromJson(map);
    } on CndOrdersException {
      rethrow;
    } catch (e) {
      debugPrint('CndOrdersService.createOrder: $e');
      final active = _extractActiveOrder(e);
      if (active != null) throw ActiveOrderExistsException(active);
      if (_isPlanLimit(e)) {
        throw PlanLimitReachedException(
          message: _extractFunctionError(e) ??
              'Limite do plano atingido para este produto',
          suggestedTier: _extractSuggestedTier(e),
        );
      }
      throw CndOrdersException(
        _extractFunctionError(e) ?? 'Erro ao criar pedido',
      );
    }
  }

  /// Legacy alias — creates the default CND package order.
  Future<CndOrderModel> createPackageOrder({
    required CnpjModel company,
    required String guestEmail,
    required String guestPhone,
  }) async {
    final catalog = await loadCatalog();
    return createOrder(
      company: company,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      productKind: catalog.defaultKind,
    );
  }

  /// Lists every order for the authenticated user (any product kind).
  Future<List<CndOrderModel>> listOrdersForCurrentUser() async {
    final auth = SupabaseAuthService.instance;
    await _ensureAuthReady(auth);

    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) {
      throw CndOrdersException(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    try {
      final rows = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .whereType<Map>()
          .map((row) => CndOrderModel.fromJson(_rowToApiJson(row)))
          .toList();
    } catch (e) {
      debugPrint('CndOrdersService.listOrdersForCurrentUser: $e');
      throw CndOrdersException(
        _extractCatchError(e) ?? 'Erro ao carregar pedidos',
      );
    }
  }

  Future<CndOrderModel> markOrderPaid(
    String orderId, {
    String? paymentId,
  }) async {
    final auth = SupabaseAuthService.instance;
    await _ensureAuthReady(auth);

    final client = auth.client;
    if (client == null || auth.userId == null) {
      throw CndOrdersException(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    try {
      final resolvedPaymentId =
          await PaymentsService.instance.ensureRevenueCatPaymentId(
        preferredPaymentId: paymentId,
      );
      if (resolvedPaymentId == null || resolvedPaymentId.isEmpty) {
        throw CndOrdersException(
          'Pagamento não vinculado. Tente novamente em instantes.',
        );
      }

      final response = await client.functions.invoke(
        'mark-order-paid',
        body: {
          'orderId': orderId,
          'paymentId': resolvedPaymentId,
        },
        headers: {
          'Authorization': 'Bearer ${auth.currentJwt}',
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw CndOrdersException('Erro ao confirmar pagamento do pedido');
      }

      await PaymentsService.instance
          .deactivateConsumablePayment(resolvedPaymentId);

      return CndOrderModel.fromJson(Map<String, dynamic>.from(data));
    } on CndOrdersException {
      rethrow;
    } catch (e) {
      debugPrint('CndOrdersService.markOrderPaid: $e');
      final limitMsg = _extractPlanLimitError(e);
      if (limitMsg != null) {
        throw CndOrdersException(limitMsg);
      }
      throw CndOrdersException(
        _extractFunctionError(e) ??
            _extractCatchError(e) ??
            'Erro ao confirmar pagamento do pedido',
      );
    }
  }

  Future<CndOrderModel> getOrder({required String id}) async {
    final auth = SupabaseAuthService.instance;
    await _ensureAuthReady(auth);

    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) {
      throw CndOrdersException(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    try {
      final row = await client
          .from('orders')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        throw CndOrdersException('Pedido não encontrado');
      }

      return CndOrderModel.fromJson(_rowToApiJson(row));
    } on CndOrdersException {
      rethrow;
    } catch (e) {
      debugPrint('CndOrdersService.getOrder: $e');
      throw CndOrdersException(
        _extractCatchError(e) ?? 'Erro ao carregar pedido',
      );
    }
  }

  Future<void> _ensureAuthReady(SupabaseAuthService auth) async {
    try {
      await auth.ensureReadyForOrders();
    } on StateError catch (e) {
      throw CndOrdersException(e.message);
    }
  }

  String whatsappUrl({String? text}) {
    final fromEnv = SupportConfig.phoneDigits;
    final number = fromEnv.isNotEmpty
        ? fromEnv
        : (_catalog?.whatsappNumber ?? '');
    if (number.isEmpty) return '';
    final uri = Uri.https('wa.me', '/$number', {
      if (text != null && text.isNotEmpty) 'text': text,
    });
    return uri.toString();
  }

  Map<String, dynamic> _rowToApiJson(Map<dynamic, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    return {
      'id': map['id'],
      'userId': map['user_id'] ?? map['userId'],
      'guestEmail': map['guest_email'] ?? map['guestEmail'],
      'guestPhone': map['guest_phone'] ?? map['guestPhone'],
      'productId': map['product_id'] ?? map['productId'],
      'selectedProductIds':
          map['selected_product_ids'] ?? map['selectedProductIds'],
      'totalCents': map['total_cents'] ?? map['totalCents'],
      'cnpj': map['cnpj'],
      'companyName': map['company_name'] ?? map['companyName'],
      'address': map['address'],
      'status': map['status'],
      'paymentStatus': map['payment_status'] ?? map['paymentStatus'],
      'createdAt':
          _asIsoString(map['created_at'] ?? map['createdAt']) ??
          DateTime.now().toIso8601String(),
      'updatedAt': _asIsoString(map['updated_at'] ?? map['updatedAt']),
    };
  }

  String? _asIsoString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }

  String? _extractFunctionError(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      if (details is Map && details['error'] is String) {
        return details['error'] as String;
      }
      if (details is String && details.trim().isNotEmpty) {
        return details;
      }
    }
    return _extractCatchError(e);
  }

  String? _extractPlanLimitError(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      if (details is Map && details['code'] == 'PLAN_LIMIT_REACHED') {
        return details['error'] as String? ??
            'Limite do plano atingido para este produto';
      }
    }
    return null;
  }

  bool _isPlanLimit(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      return details is Map && details['code'] == 'PLAN_LIMIT_REACHED';
    }
    return false;
  }

  int _extractSuggestedTier(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      if (details is Map && details['suggestedTier'] is num) {
        return (details['suggestedTier'] as num).toInt();
      }
    }
    return 2;
  }

  CndOrderModel? _extractActiveOrder(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      if (details is Map &&
          details['code'] == 'ACTIVE_ORDER_EXISTS' &&
          details['order'] is Map) {
        return CndOrderModel.fromJson(
          Map<String, dynamic>.from(details['order'] as Map),
        );
      }
    }
    return null;
  }

  String? _extractCatchError(Object e) {
    final message = e.toString();
    if (message.contains('CndOrdersException')) {
      return message.replaceFirst('CndOrdersException: ', '');
    }
    return null;
  }

  String _formatCnpj(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw;
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.'
        '${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
  }

  String _formatCep(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return raw;
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }
}
