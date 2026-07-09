import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';

@freezed
class PlanModel with _$PlanModel {
  const factory PlanModel({
    required String id,
    required String title,
    required String priceText,
    @Default(false) bool isSelected,
    String? trialInfoText,
  }) = _PlanModel;
}

enum PaywallOrigin { home, result, favorite, share, maps, contact }
