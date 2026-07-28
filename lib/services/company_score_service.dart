import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

class CompanyScoreException implements Exception {
  CompanyScoreException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CompanyScoreService {
  static final CompanyScoreService instance = CompanyScoreService._();
  CompanyScoreService._();

  Future<List<CompanyScoreResult>> fetchThisMonth() async {
    final auth = SupabaseAuthService.instance;
    await _ensureAuthReady(auth);

    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) {
      throw CompanyScoreException(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    try {
      final rows = await client
          .from('company_scores')
          .select()
          .eq('profile_id', userId)
          .order('created_at', ascending: false);

      final list = <CompanyScoreResult>[];
      for (final row in rows as List) {
        final result = CompanyScoreResult.fromJson(
          Map<String, dynamic>.from(row as Map),
        );
        if (_isSameSaoPauloMonth(result.createdAt)) {
          list.add(result);
        }
      }
      return list;
    } catch (e) {
      debugPrint('CompanyScoreService.fetchThisMonth: $e');
      throw CompanyScoreException(
        _extractCatchError(e) ?? 'Erro ao carregar score',
      );
    }
  }

  Future<CompanyScoreResult?> fetchLatestThisMonth() async {
    final list = await fetchThisMonth();
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<CompanyScoreResult> calculate({
    required String cnpj,
    required Map<String, String> answers,
    String? companyName,
  }) async {
    final auth = SupabaseAuthService.instance;
    await _ensureAuthReady(auth);

    final client = auth.client;
    if (client == null) {
      throw CompanyScoreException(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    final digits = cnpj.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) {
      throw CompanyScoreException('CNPJ inválido');
    }

    final name = companyName?.trim();
    try {
      final response = await client.functions.invoke(
        'calculate-company-score',
        body: {
          'cnpj': digits,
          'answers': answers,
          if (name != null && name.isNotEmpty) 'companyName': name,
        },
        headers: {
          'Authorization': 'Bearer ${auth.currentJwt}',
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw CompanyScoreException('Erro ao calcular score');
      }

      final map = Map<String, dynamic>.from(data);
      if (map['code'] == 'PLAN_LIMIT_REACHED') {
        throw CompanyScoreException(
          map['error'] as String? ??
              'Limite do plano atingido para score de empresas',
        );
      }

      return CompanyScoreResult.fromJson(map);
    } on CompanyScoreException {
      rethrow;
    } catch (e) {
      debugPrint('CompanyScoreService.calculate: $e');
      throw CompanyScoreException(
        _extractFunctionError(e) ?? 'Erro ao calcular score',
      );
    }
  }

  Future<void> _ensureAuthReady(SupabaseAuthService auth) async {
    try {
      await auth.ensureReadyForOrders();
    } on StateError catch (e) {
      throw CompanyScoreException(e.message);
    }
  }

  bool _isSameSaoPauloMonth(String createdAtIso) {
    final created = DateTime.tryParse(createdAtIso);
    if (created == null) return false;
    final nowSp = DateTime.now().toUtc().add(const Duration(hours: -3));
    final createdSp = created.toUtc().add(const Duration(hours: -3));
    return nowSp.year == createdSp.year && nowSp.month == createdSp.month;
  }

  String? _extractFunctionError(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      if (details is Map) {
        if (details['code'] == 'PLAN_LIMIT_REACHED') {
          return details['error'] as String? ??
              'Limite do plano atingido para score de empresas';
        }
        if (details['error'] is String) {
          return details['error'] as String;
        }
      }
      if (details is String && details.trim().isNotEmpty) {
        return details;
      }
    }
    return _extractCatchError(e);
  }

  String? _extractCatchError(Object e) {
    final message = e.toString();
    if (message.contains('CompanyScoreException')) {
      return message.replaceFirst('CompanyScoreException: ', '');
    }
    return null;
  }
}
