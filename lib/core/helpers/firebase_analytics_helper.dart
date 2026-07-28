import 'package:consulta_cnpj_new/services/firebase_service.dart';

class FirebaseAnalyticsHelper {
  FirebaseAnalyticsHelper._();
  static final FirebaseAnalyticsHelper instance = FirebaseAnalyticsHelper._();

  final _firebase = FirebaseService.instance;

  Future<void> logPesquisouCnpj() =>
      _firebase.logEvent(eventKey: 'pesquisou_cnpj');
  Future<void> logPesquisouRazao() =>
      _firebase.logEvent(eventKey: 'pesquisou_razao');
  Future<void> logSucessoPesquisouCnpj() =>
      _firebase.logEvent(eventKey: 'sucesso_pesquisou_cnpj');
  Future<void> logSucessoPesquisouRazao() =>
      _firebase.logEvent(eventKey: 'sucesso_pesquisou_razao');
  Future<void> logFavorito() => _firebase.logEvent(eventKey: 'favorito');
  Future<void> logCompartilhou() =>
      _firebase.logEvent(eventKey: 'compartilhou');
  Future<void> logAbriuMaps() => _firebase.logEvent(eventKey: 'abriu_maps');
  Future<void> logConsultouHistorico() =>
      _firebase.logEvent(eventKey: 'consultou_historico');
  Future<void> logConsultouFavorito() =>
      _firebase.logEvent(eventKey: 'consultou_favorito');
  Future<void> logConsultaAvancada() =>
      _firebase.logEvent(eventKey: 'consulta_avancada');
  Future<void> logContato() => _firebase.logEvent(eventKey: 'contato');
  Future<void> logTelefone() => _firebase.logEvent(eventKey: 'telefone');
  Future<void> logEnviarEmail() =>
      _firebase.logEvent(eventKey: 'enviar_email');
  Future<void> logWhats() => _firebase.logEvent(eventKey: 'whats');
  Future<void> logClicouDesbloqueioPremium() =>
      _firebase.logEvent(eventKey: 'clicou_desbloqueio_premium');
  Future<void> logAvaliou() => _firebase.logEvent(eventKey: 'avaliou');
  Future<void> logSalvarProspecacao() =>
      _firebase.logEvent(eventKey: 'salvar_prospecacao');

  Future<void> logOnboardingStarted() =>
      _firebase.logEvent(eventKey: 'onboarding_started');
  Future<void> logOnboardingCompleted() =>
      _firebase.logEvent(eventKey: 'onboarding_completed');
  Future<void> logOnboardingOccupation(String occupation) =>
      _firebase.logEvent(
        eventKey: 'onboarding_occupation',
        parameters: {'occupation': occupation},
      );
  Future<void> logOnboardingInterests(String interests) => _firebase.logEvent(
        eventKey: 'onboarding_interests',
        parameters: {'interests': interests},
      );
  Future<void> logOnboardingCompanyInfos(String infos) => _firebase.logEvent(
        eventKey: 'onboarding_company_infos',
        parameters: {'infos': infos},
      );
  Future<void> logOnboardingRating(int stars) => _firebase.logEvent(
        eventKey: 'onboarding_rating',
        parameters: {'stars': stars},
      );
  Future<void> logOnboardingRatingSkipped() =>
      _firebase.logEvent(eventKey: 'onboarding_rating_skipped');
  Future<void> logOnboardingFeedback() =>
      _firebase.logEvent(eventKey: 'onboarding_feedback');
  Future<void> logOnboardingPaywallSkipped() =>
      _firebase.logEvent(eventKey: 'onboarding_paywall_skipped');
  Future<void> logInAppReviewRequested() =>
      _firebase.logEvent(eventKey: 'in_app_review_requested');

  Future<void> logTutorialComplete() =>
      _firebase.logEvent(eventKey: 'tutorial_complete');

  Future<void> logViewItemList({
    required String itemListId,
    required String itemListName,
  }) =>
      _firebase.logEvent(
        eventKey: 'view_item_list',
        parameters: {
          'item_list_id': itemListId,
          'item_list_name': itemListName,
        },
      );

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
  }) =>
      _firebase.logEvent(
        eventKey: 'view_item',
        parameters: {
          'item_id': itemId,
          'item_name': itemName,
        },
        items: [
          {'item_id': itemId, 'item_name': itemName},
        ],
      );

  Future<void> logViewCart({required String origin}) => _firebase.logEvent(
        eventKey: 'view_cart',
        parameters: {'origin': origin},
      );

  Future<void> logAddToCart({
    required double value,
    required String currency,
    required String itemId,
    required String itemName,
  }) =>
      _firebase.logEvent(
        eventKey: 'add_to_cart',
        parameters: {
          'value': value,
          'currency': currency,
          'item_id': itemId,
          'item_name': itemName,
        },
        items: [
          {
            'item_id': itemId,
            'item_name': itemName,
            'price': value,
            'currency': currency,
          },
        ],
      );

  Future<void> logBeginCheckout({
    required double value,
    required String currency,
    required String itemId,
    required String itemName,
  }) =>
      _firebase.logEvent(
        eventKey: 'begin_checkout',
        parameters: {
          'value': value,
          'currency': currency,
          'item_id': itemId,
          'item_name': itemName,
        },
        items: [
          {
            'item_id': itemId,
            'item_name': itemName,
            'price': value,
            'currency': currency,
          },
        ],
      );

  Future<void> logPurchase({
    required double value,
    required String currency,
    required String transactionId,
    required String itemId,
    required String itemName,
  }) =>
      _firebase.logEvent(
        eventKey: 'purchase',
        parameters: {
          'value': value,
          'currency': currency,
          'transaction_id': transactionId,
          'item_id': itemId,
          'item_name': itemName,
        },
        items: [
          {
            'item_id': itemId,
            'item_name': itemName,
            'price': value,
            'currency': currency,
          },
        ],
      );
}
