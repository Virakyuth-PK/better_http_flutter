import 'package:better_utils_flutter/better_utils_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// #region InterceptorClient
/// Custom HTTP client with support for request and response interceptors,
/// as well as logging requests and responses with cURL command generation for easy debugging.
class InterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final RequestInterceptor? requestInterceptor;
  final ResponseInterceptor? responseInterceptor;

  /// Constructor for [InterceptorClient].
  ///
  /// Parameters:
  /// - `_inner` (http.Client): The underlying HTTP client used to make requests.
  /// - `requestInterceptor` (RequestInterceptor?): Optional interceptor to modify outgoing requests.
  /// - `responseInterceptor` (ResponseInterceptor?): Optional interceptor to modify incoming responses.
  InterceptorClient(this._inner,
      {this.requestInterceptor, this.responseInterceptor});

  /// Sends an HTTP request, applying request and response interceptors if provided, and logs the request and response.
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Intercept the request if interceptor is provided
    if (requestInterceptor != null) {
      request = await requestInterceptor!.interceptRequest(request);
    }

    // Log the request
    if (kDebugMode) {
      _logRequest(request);
    }

    // Send the request and get the response
    final response = await _inner.send(request);

    // Log the response
    if (kDebugMode) {
      _logResponse(response, request);
    }

    // Intercept the response if interceptor is provided
    if (responseInterceptor != null) {
      return responseInterceptor!.interceptResponse(response);
    }

    return response;
  }

  /// #region _logRequest
  /// Logs the HTTP request details, including the generated cURL command for debugging.
  void _logRequest(http.BaseRequest request) {
    betterPrettyLog(
      message: 'Log Request 🇰🇭🛫'
          '\nRequest: ${request.method} ${request.url}'
          '\nHeaders: ${request.headers}'
          '\nBody: ${request is http.Request ? (request).body : 'Streamed'}'
          '\n\n',
      customMessage1LineEnd:
          '\n📎 🛜 curlCommand: ${_generateCurlCommand(request)}',
    );
  }

  /// #endregion

  /// #region _generateCurlCommand
  /// Generates a cURL command equivalent for the given HTTP request.
  ///
  /// Parameters:
  /// - `request` (http.BaseRequest): The HTTP request to generate a cURL command for.
  ///
  /// Returns:
  /// - A [String] representing the cURL command that replicates the HTTP request.
  String _generateCurlCommand(http.BaseRequest request) {
    // Start the cURL command with the method and URL
    String curlCommand = 'curl -X ${request.method} \'${request.url}\'';

    // Add headers to the cURL command
    request.headers.forEach((key, value) {
      curlCommand += ' -H "$key: $value"';
    });

    // Check if the request is a MultipartRequest (for form-data)
    if (request is http.MultipartRequest) {
      // Add each field and file part to the cURL command
      request.fields.forEach((key, value) {
        curlCommand += ' -F "$key=$value"';
      });

      for (final file in request.files) {
        curlCommand += ' -F "${file.field}=@${file.filename}"';
      }
    }
    // Add the body if the request is of type http.Request and not Multipart
    else if (request is http.Request && request.body.isNotEmpty) {
      curlCommand += ' -d \'${request.body}\'';
    }

    return curlCommand;
  }

  /// #endregion

  /// #region _logResponse
  /// Logs the HTTP response details, including status and headers.
  ///
  /// Parameters:
  /// - `response` (http.StreamedResponse): The HTTP response to log.
  void _logResponse(http.StreamedResponse response, http.BaseRequest request) {
    betterPrettyLog(
      message: 'Log Response 🇰🇭🛬'
          '\nRequest: ${response.request?.method} ${response.request?.url}'
          '\nHeaders: ${response.headers}'
          '\nResponse Status: ${response.statusCode} ${response.reasonPhrase}',
      customMessage1LineEnd:
          '\n📎 🛜 curlCommand: ${_generateCurlCommand(request)}',
    );
  }

  /// #endregion
}

/// #endregion

/// #region RequestInterceptor
/// Interface for defining a request interceptor.
abstract class RequestInterceptor {
  /// Method to intercept and modify the outgoing HTTP request.
  ///
  /// Parameters:
  /// - `request` (http.BaseRequest): The original HTTP request.
  ///
  /// Returns:
  /// - A [Future] of [http.BaseRequest] which could be modified before sending.
  Future<http.BaseRequest> interceptRequest(http.BaseRequest request);
}

/// #endregion

/// #region ResponseInterceptor
/// Interface for defining a response interceptor.
abstract class ResponseInterceptor {
  /// Method to intercept and modify the incoming HTTP response.
  ///
  /// Parameters:
  /// - `response` (http.StreamedResponse): The original HTTP response.
  ///
  /// Returns:
  /// - A [Future] of [http.StreamedResponse] which could be modified before returning.
  Future<http.StreamedResponse> interceptResponse(
      http.StreamedResponse response);
}

/// #endregion
