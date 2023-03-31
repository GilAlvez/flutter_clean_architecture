import '../entities/entities.dart';

abstract class AuthenticationUseCase {
  Future<AccountEntity> execute(AuthenticationParams params);
}

class AuthenticationParams {
  final String email;
  final String password;

  AuthenticationParams({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
