import 'package:http/http.dart' as http;

import 'interceptor/interceptor_client.dart';

class AuthHttpClient extends http.BaseClient {
  final InterceptorClient _interceptorClient;
  final Map<String, String>? customHeaders;

  AuthHttpClient(
    this._interceptorClient, {
    this.customHeaders,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final customHeaders = this.customHeaders;
    if (customHeaders != null) {
      customHeaders.entries.map((entry) {
        request.headers[entry.key] = entry.value;
      });
    }

    return _interceptorClient.send(request);
  }
}

class NormalHttpClient extends http.BaseClient {
  final InterceptorClient _interceptorClient;

  NormalHttpClient(this._interceptorClient);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _interceptorClient.send(request);
  }
}
