import '../entities/entities.dart';

abstract class AuthenticationUseCase {
  Future<AccountEntity> auth(AuthenticationParams params);
}

class AuthenticationParams {
  final String email;
  final String password;

  AuthenticationParams({
    required this.email,
    required this.password,
  });
}
