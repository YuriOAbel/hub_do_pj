import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/consulted_company_model.dart';
import 'package:consulta_cnpj_new/services/local_cnpj_storage_service.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

class ConsultedCompaniesException implements Exception {
  ConsultedCompaniesException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ConsultedCompaniesService {
  static final ConsultedCompaniesService instance =
      ConsultedCompaniesService._();
  ConsultedCompaniesService._();

  static const _localSyncedKey = 'consulted_companies_local_synced';

  Future<ConsultedCompanyModel?> upsertFromCnpj(CnpjModel company) async {
    final auth = SupabaseAuthService.instance;
    try {
      await auth.ensureReadyForOrders();
    } catch (e) {
      debugPrint('ConsultedCompaniesService.upsertFromCnpj auth: $e');
      return null;
    }

    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) return null;

    final digits = (company.cnpj ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return null;

    final companyName = (company.nome ?? '').trim();
    if (companyName.isEmpty) return null;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    try {
      final row = await client
          .from('consulted_companies')
          .upsert(
            {
              'profile_id': userId,
              'cnpj_digits': digits,
              'company_name': companyName,
              'situacao': company.situacao,
              'fantasia': company.fantasia,
              'metadata': company.toJson(),
              'last_consulted_at': nowIso,
              'updated_at': nowIso,
            },
            onConflict: 'profile_id,cnpj_digits',
          )
          .select(
            'id, profile_id, cnpj_digits, company_name, situacao, fantasia, '
            'metadata, last_consulted_at, created_at, updated_at',
          )
          .single();

      return _rowToModel(Map<String, dynamic>.from(row as Map));
    } catch (e) {
      debugPrint('ConsultedCompaniesService.upsertFromCnpj: $e');
      return null;
    }
  }

  Future<List<ConsultedCompanyModel>> listWithOrders() async {
    final auth = SupabaseAuthService.instance;
    try {
      await auth.ensureReadyForOrders();
    } on StateError catch (e) {
      throw ConsultedCompaniesException(e.message);
    }

    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) {
      throw ConsultedCompaniesException(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    try {
      final rows = await client
          .from('consulted_companies')
          .select(
            'id, profile_id, cnpj_digits, company_name, situacao, fantasia, '
            'metadata, last_consulted_at, created_at, updated_at, '
            'orders(id, user_id, guest_email, guest_phone, product_id, '
            'selected_product_ids, total_cents, cnpj, company_name, address, '
            'status, payment_status, created_at, updated_at)',
          )
          .eq('profile_id', userId)
          .order('last_consulted_at', ascending: false);

      return (rows as List<dynamic>)
          .whereType<Map>()
          .map((row) => _rowToModel(Map<String, dynamic>.from(row)))
          .toList();
    } catch (e) {
      debugPrint('ConsultedCompaniesService.listWithOrders: $e');
      throw ConsultedCompaniesException(
        'Ops, tivemos um problema... tente novamente',
      );
    }
  }

  /// One-shot upsert of local historic items into Supabase.
  Future<void> syncFromLocalHistoryIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_localSyncedKey) == true) return;

      final local = await LocalHistoryService.instance.getAll();
      for (final item in local) {
        await upsertFromCnpj(item);
      }

      await prefs.setBool(_localSyncedKey, true);
    } catch (e) {
      debugPrint('ConsultedCompaniesService.syncFromLocalHistoryIfNeeded: $e');
    }
  }

  ConsultedCompanyModel _rowToModel(Map<String, dynamic> row) {
    final metadataRaw = row['metadata'];
    final metadata = metadataRaw is Map
        ? Map<String, dynamic>.from(metadataRaw)
        : <String, dynamic>{};

    final ordersRaw = row['orders'];
    final orders = <CndOrderModel>[];
    if (ordersRaw is List) {
      for (final item in ordersRaw) {
        if (item is! Map) continue;
        orders.add(CndOrderModel.fromJson(_orderRowToApiJson(item)));
      }
    }

    return ConsultedCompanyModel(
      id: row['id'] as String,
      profileId: (row['profile_id'] ?? row['profileId']) as String,
      cnpjDigits: (row['cnpj_digits'] ?? row['cnpjDigits']) as String,
      companyName: (row['company_name'] ?? row['companyName']) as String,
      situacao: row['situacao'] as String?,
      fantasia: row['fantasia'] as String?,
      metadata: metadata,
      lastConsultedAt: _asIsoString(
            row['last_consulted_at'] ?? row['lastConsultedAt'],
          ) ??
          DateTime.now().toIso8601String(),
      createdAt: _asIsoString(row['created_at'] ?? row['createdAt']) ??
          DateTime.now().toIso8601String(),
      updatedAt: _asIsoString(row['updated_at'] ?? row['updatedAt']),
      orders: orders,
    );
  }

  Map<String, dynamic> _orderRowToApiJson(Map<dynamic, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    return {
      'id': map['id'],
      'userId': map['user_id'] ?? map['userId'],
      'guestEmail': map['guest_email'] ?? map['guestEmail'] ?? '',
      'guestPhone': map['guest_phone'] ?? map['guestPhone'],
      'productId': map['product_id'] ?? map['productId'],
      'selectedProductIds':
          map['selected_product_ids'] ?? map['selectedProductIds'],
      'totalCents': map['total_cents'] ?? map['totalCents'],
      'cnpj': map['cnpj'] ?? '',
      'companyName': map['company_name'] ?? map['companyName'] ?? '',
      'address': map['address'],
      'status': map['status'] ?? 'em_analise',
      'paymentStatus': map['payment_status'] ?? map['paymentStatus'] ?? 'pending',
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
}
