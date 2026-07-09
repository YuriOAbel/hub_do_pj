import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';

class CnpjSearchService {
  static final CnpjSearchService instance = CnpjSearchService._();
  CnpjSearchService._();

  static const _baseUrl = 'https://www.receitaws.com.br/v1/';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<CnpjModel> getByCnpj(String cnpj) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('cnpj/$cnpj');
      final data = response.data;
      if (data == null) throw CnpjNotFoundException();
      if (data['status'] == 'ERROR') {
        throw CnpjSearchException(data['message'] as String? ?? 'Erro na consulta');
      }
      return CnpjModel.fromJson(data).copyWith(
        dtSave: DateTime.now().toIso8601String(),
      );
    } on DioException catch (e) {
      debugPrint('CnpjSearchService.getByCnpj: $e');
      if (e.response?.statusCode == 404) throw CnpjNotFoundException();
      throw CnpjSearchException('Falha ao consultar CNPJ');
    }
  }
}
