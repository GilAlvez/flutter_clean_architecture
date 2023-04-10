import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'http_adapter_test.mocks.dart';

class HttpAdapter {
  final Client client;

  HttpAdapter(this.client);

  Future<void> request({
    required String url,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final jsonHeaders = {'content-type': 'application/json', 'accept': 'application/json'};
    final jsonBody = body != null ? jsonEncode(body) : null;

    await client.post(
      Uri.parse(url),
      headers: jsonHeaders,
      body: jsonBody,
    );
  }
}

@GenerateNiceMocks([MockSpec<Client>()])
void main() {
  late MockClient client;
  late String url;
  late HttpAdapter sut;

  setUp(() {
    client = MockClient();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
  });

  group(HttpAdapter, () {
    test('should call post with corret values', () async {
      // Arrange
      final bodyMock = {'anyKey': 'anyValue'};

      // Act
      await sut.request(url: url, method: 'post', body: bodyMock);

      // Expect
      verify(client.post(
        Uri.parse(url),
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(bodyMock),
      ));
    });

    test('should call post without body', () async {
      // Arrange
      // Act
      await sut.request(url: url, method: 'post');

      // Expect
      verify(client.post(
        any,
        headers: anyNamed('headers'),
      ));
    });
  });
}
