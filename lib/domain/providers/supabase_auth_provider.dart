import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

part 'supabase_auth_provider.g.dart';

@riverpod
class SupabaseAuth extends _$SupabaseAuth {
  @override
  Future<void> build() async {
    await SupabaseAuthService.instance.initialize();
  }

  bool get isAuthenticated => SupabaseAuthService.instance.isAuthenticated;

  String? get userId => SupabaseAuthService.instance.userId;

  String get currentJwt => SupabaseAuthService.instance.currentJwt;
}
