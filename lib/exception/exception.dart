import '../typedefs.dart';

abstract class BaseException implements Exception {
  int? statusCode;
  String? message;
  JSON? body;

  BaseException(this.statusCode, this.message, {this.body});

  @override
  String toString() {
    Object? message = this.message;
    return "$runtimeType: $message";
  }
}

class NetworkException extends BaseException {
  NetworkException({int? statusCode, String? message})
      : super(statusCode, message);
}

class ApiException extends BaseException {
  ApiException({
    int? statusCode,
    JSON? body,
    String? message,
  }) : super(
          statusCode,
          message,
          body: body,
        );
}

class CacheException extends BaseException {
  CacheException(int? statusCode, String? message) : super(statusCode, message);
}

class AppException extends BaseException {
  AppException({int? statusCode, String? message}) : super(statusCode, message);
}
