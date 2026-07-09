import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:consulta_cnpj_new/domain/models/nome_model.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';

class CompanyNameSearchService {
  static final CompanyNameSearchService instance = CompanyNameSearchService._();
  CompanyNameSearchService._();

  static const _baseUrl = 'http://api.consultarempresas.com.br:8888/';

  Dio? _dio;
  String? _appVersion;

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'App-Version': _appVersion},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
  }

  Future<List<NomeModel>> searchByName(String term) async {
    await init();
    try {
      final response = await _dio!.get<dynamic>('cnpj/$term');
      final data = response.data;
      if (data is! List) return [];
      return data
          .map((e) => NomeModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      debugPrint('CompanyNameSearchService.searchByName: $e');
      throw CnpjSearchException('Falha na busca por nome');
    }
  }
}
