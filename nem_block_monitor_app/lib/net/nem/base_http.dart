
import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseHttp {
  Uri baseUri;
  BaseHttp(final this.baseUri);

  Future<T> get<T>(Function factory, String path) async {
    final uri = baseUri.replace(path: path);

    final response = await http.get(uri);
    final decoded = jsonDecode(response.body);

    return factory(decoded) as T;
  }

  Future<T> post<T>(Function factory, String path, Map<String, dynamic> body) async {
    final uri = baseUri.replace(path: path);

    final encoded = jsonEncode(body);

    final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json'
        },
        body: encoded);

    print(response.body);
    final decoded = jsonDecode(response.body);

    return factory(decoded) as T;
  }
}