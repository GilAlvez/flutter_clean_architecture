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
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    await client.post(
      Uri.parse(url),
      headers: headers,
    );
  }
}

@GenerateNiceMocks([MockSpec<Client>()])
void main() {
  group(HttpAdapter, () {
    test('should call post with corret values', () async {
      // Arrange
      final client = MockClient();
      final sut = HttpAdapter(client);
      final url = faker.internet.httpUrl();

      // Act
      await sut.request(url: url, method: 'post');

      // Expect
      verify(client.post(
        Uri.parse(url),
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
      ));
    });
  });
}
