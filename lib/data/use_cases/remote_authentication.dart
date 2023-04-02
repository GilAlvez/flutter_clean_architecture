// Domain
import '../../domain/entities/entities.dart';
import '../../domain/exceptions/exceptions.dart';
import '../../domain/use_cases/use_cases.dart';

// Data
import '../http/http.dart';
import '../models/models.dart';

class RemoteAuthentication implements AuthenticationUseCase {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    required this.httpClient,
    required this.url,
  });

  @override
  Future<AccountEntity> auth(AuthenticationParams params) async {
    try {
      final response = await httpClient.request(
        url: url,
        method: 'post',
        body: RemoteAuthenticationParams.fromDomain(params).toJson(),
      );

      return RemoteAccountModel.fromJson(response).toEntity();
    } on HttpError catch (error) {
      if (error == HttpError.unauthorized) {
        throw DomainError.invalidCredentials;
      }

      throw DomainError.unexpected;
    }
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;

  RemoteAuthenticationParams({
    required this.email,
    required this.password,
  });

  factory RemoteAuthenticationParams.fromDomain(AuthenticationParams params) {
    return RemoteAuthenticationParams(email: params.email, password: params.password);
  }

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
