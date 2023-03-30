import '../entities/entities.dart';

abstract class AuthenticationUseCase {
  Future<AccountEntity> execute({
    required String email,
    required String password,
  });
}
