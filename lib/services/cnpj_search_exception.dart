class CnpjSearchException implements Exception {
  CnpjSearchException(this.message);
  final String message;
}

class CnpjNotFoundException extends CnpjSearchException {
  CnpjNotFoundException() : super('CNPJ não encontrado');
}

/// Limit hit that should open upgrade sheet → paywall with [suggestedTier].
class PlanLimitException implements Exception {
  PlanLimitException({
    required this.message,
    required this.suggestedTier,
    this.suggestedPlanTitle,
  });

  final String message;
  final int suggestedTier;
  final String? suggestedPlanTitle;

  @override
  String toString() => message;
}

class CnpjDailyLimitException extends PlanLimitException {
  CnpjDailyLimitException({
    super.suggestedPlanTitle,
  }) : super(
          message: suggestedPlanTitle == null
              ? 'Você atingiu o limite desta operação. '
                  'Para continuar, faça a assinatura de um plano superior.'
              : 'Você atingiu o limite desta operação. '
                  'Para continuar, faça a assinatura do plano $suggestedPlanTitle.',
          suggestedTier: 1,
        );
}

class ScoreCnpjLimitException extends PlanLimitException {
  ScoreCnpjLimitException({
    required super.suggestedTier,
    super.suggestedPlanTitle,
  }) : super(
          message: suggestedPlanTitle == null
              ? 'Você atingiu o limite desta operação. '
                  'Para continuar, faça a assinatura de um plano superior.'
              : 'Você atingiu o limite desta operação. '
                  'Para continuar, faça a assinatura do plano $suggestedPlanTitle.',
        );
}

class EmitPlanLimitException extends PlanLimitException {
  EmitPlanLimitException({
    required super.suggestedTier,
    super.suggestedPlanTitle,
  }) : super(
          message: suggestedPlanTitle == null
              ? 'Você atingiu o limite desta operação. '
                  'Para continuar, faça a assinatura de um plano superior.'
              : 'Você atingiu o limite desta operação. '
                  'Para continuar, faça a assinatura do plano $suggestedPlanTitle.',
        );
}
