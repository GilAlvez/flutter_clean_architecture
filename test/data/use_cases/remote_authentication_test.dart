import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Domain
import 'package:flutter_clean_architecture/domain/use_cases/use_cases.dart';
import 'package:flutter_clean_architecture/domain/exceptions/exceptions.dart';

// Data
import 'package:flutter_clean_architecture/data/http/http.dart';
import 'package:flutter_clean_architecture/data/use_cases/use_cases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;

  PostExpectation mockRequest() {
    return when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    ));
  }

  Map mockValidData() => {'accessToken': faker.guid.guid(), 'name': faker.person.name()};

  void mockHttpData(Map data) {
    return mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    return mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
    mockHttpData(mockValidData());
  });

  test('should call HttpClient with correct values', () async {
    // Arrange

    // Act
    await sut.auth(params);

    // Assert
    verify(httpClient.request(
      url: url,
      method: 'post',
      body: {
        'email': params.email,
        'password': params.password,
      },
    ));
  });

  test('should throw UnexpectedError if HttpClient return 400', () async {
    // Arrange
    mockHttpError(HttpError.badRequest);

    // Act
    final future = sut.auth(params);

    // Assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 404', () async {
    // Arrange
    mockHttpError(HttpError.notFound);

    // Act
    final future = sut.auth(params);

    // Assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 500', () async {
    // Arrange
    mockHttpError(HttpError.serverError);

    // Act
    final future = sut.auth(params);

    // Assert
    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw InvalidCredentialsError if HttpClient return 401', () async {
    // Arrange
    mockHttpError(HttpError.unauthorized);

    // Act
    final future = sut.auth(params);

    // Assert
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('should return Account if HttpClient return 200', () async {
    // Arrange
    final validData = mockValidData();
    mockHttpData(validData);

    // Act
    final account = await sut.auth(params);

    // Assert
    expect(account.token, validData['accessToken']);
  });

  test('should throw UnexpectedError if HttpClient return 200 with invalid data', () async {
    // Arrange
    mockHttpData({'invalidKey': 'invalidValue'});

    // Act
    final future = sut.auth(params);

    // Assert
    expect(future, throwsA(DomainError.unexpected));
  });
}
