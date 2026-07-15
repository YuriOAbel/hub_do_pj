import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/services/home_tutorial_service.dart';

part 'home_tutorial_provider.g.dart';

@riverpod
class HomeTutorial extends _$HomeTutorial {
  @override
  Future<bool> build() => HomeTutorialService.instance.hasSeenTutorial();

  Future<void> markSeen() async {
    await HomeTutorialService.instance.markTutorialSeen();
    state = const AsyncData(true);
  }
}
