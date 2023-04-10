import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter_clean_architecture/data/http/http.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'http_adapter_test.mocks.dart';

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);

  @override
  Future<Map<String, dynamic>> request({
    required String url,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final jsonHeaders = {'content-type': 'application/json', 'accept': 'application/json'};
    final jsonBody = body != null ? jsonEncode(body) : null;

    final response = await client.post(
      Uri.parse(url),
      headers: jsonHeaders,
      body: jsonBody,
    );

    return jsonDecode(response.body);
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

      when(
        client.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(jsonEncode(bodyMock), 200),
      );

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
      final bodyMock = {'anyKey': 'anyValue'};

      when(
        client.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(jsonEncode(bodyMock), 200),
      );

      // Act
      await sut.request(url: url, method: 'post');

      // Expect
      verify(client.post(
        any,
        headers: anyNamed('headers'),
      ));
    });

    test('should return data when status code 200', () async {
      // Arrange
      final bodyMock = {'anyKey': 'anyValue'};

      when(
        client.post(any, headers: anyNamed('headers')),
      ).thenAnswer(
        (_) async => Response(jsonEncode(bodyMock), 200),
      );

      // Act
      final response = await sut.request(url: url, method: 'post');

      // Expect
      expect(response, bodyMock);
    });
  });
}
