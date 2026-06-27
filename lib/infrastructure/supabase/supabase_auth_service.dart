import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/auth/auth_port.dart';

/// Adaptador Supabase para `AuthPort`.
/// Usa email/senha — base suficiente para o M4.
final class SupabaseAuthService implements AuthPort {
  final SupabaseClient _client;

  const SupabaseAuthService(this._client);

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  String? get currentUserId => _client.auth.currentUser?.id;
}
