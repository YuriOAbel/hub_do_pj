import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:consulta_cnpj_new/domain/models/financial_card_model.dart';

class FinancialCardsService {
  static final FinancialCardsService instance = FinancialCardsService._();
  FinancialCardsService._();

  static const _baseUrl = 'http://api.consultarempresas.com.br:8888/';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<List<FinancialCardModel>> fetchCards() async {
    try {
      final response = await _dio.post<List<dynamic>>('/cards');
      final data = response.data ?? [];
      return data
          .map((e) =>
              FinancialCardModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      debugPrint('FinancialCardsService.fetchCards: $e');
      return [];
    }
  }
}
