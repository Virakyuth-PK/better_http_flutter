import 'dart:async';
import 'exception/exception.dart';

typedef JSON = Map<String, dynamic>;
typedef OnComplete<T> = FutureOr<T?> Function(T data);
typedef OnFail = Function(BaseException error);
