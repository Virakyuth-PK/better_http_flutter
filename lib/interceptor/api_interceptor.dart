import 'package:http/http.dart' as http;
import 'interceptor_client.dart';

class ApiInterceptor implements ResponseInterceptor {
  final Function(http.StreamedResponse response) unauthorizedHandler;

  ApiInterceptor({required this.unauthorizedHandler});

  @override
  Future<http.StreamedResponse> interceptResponse(
      http.StreamedResponse response) async {
    // Handle response data, error, etc.
    final statusCode = response.statusCode;

    switch (statusCode) {
      case 401:
        return unauthorizedHandler(response);
      default:
        return response;
    }
  }

  Future<http.StreamedResponse> _retryRequest(
      http.BaseRequest originalRequest) async {
    if (originalRequest is http.Request) {
      final newRequest =
          http.Request(originalRequest.method, originalRequest.url);

      newRequest.headers.addAll(originalRequest.headers);
      newRequest.body = originalRequest.body;
      newRequest.encoding = originalRequest.encoding;

      return await http.Client().send(newRequest);
    } else if (originalRequest is http.StreamedRequest) {
      final newRequest =
          http.StreamedRequest(originalRequest.method, originalRequest.url);

      newRequest.headers.addAll(originalRequest.headers);
      await originalRequest.finalize().pipe(newRequest.sink);

      return await http.Client().send(newRequest);
    } else {
      throw ArgumentError(
          'Unsupported request type: ${originalRequest.runtimeType}');
    }
  }
}
