/// Porta de autenticação — pertence à camada de aplicação.
/// O domínio não precisa saber de autenticação; quem orquestra casos de uso
/// recebe esta interface por injeção de dependência.
abstract interface class AuthPort {
  /// Lança [AuthException] em caso de credenciais inválidas.
  Future<void> signIn({required String email, required String password});

  /// Lança [AuthException] se o e-mail já estiver cadastrado.
  Future<void> signUp({required String email, required String password});

  Future<void> signOut();

  /// Retorna null quando não há sessão ativa.
  String? get currentUserId;
}
