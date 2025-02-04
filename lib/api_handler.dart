import 'dart:async';
import 'dart:convert';
import 'package:better_utils_flutter/better_utils_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'exception/exception.dart';
import 'exception/exception_handler.dart';
import 'http_client.dart';
import 'interceptor/api_interceptor.dart';
import 'interceptor/interceptor_client.dart';
import 'method.dart';
import 'paging.dart';
import 'typedefs.dart';

//region Document IF NEED PAGINATION
/// IF NEED PAGINATION Copy class below from here ||||
/// class Paging<T> {
///   List<T>? data;
///   int? pageNo;
///   int? pageSize;
///   int? totalPages;
///   int? totalRecords;
///
///   Paging({
///     this.data,
///     this.pageNo,
///     this.pageSize,
///     this.totalPages,
///     this.totalRecords,
///   });
///
///   @override
///   String toString() {
///     return 'Paging{data: $data, pageNo: $pageNo, pageSize: $pageSize, totalPage: $totalPages, totalRecords: $totalRecords}';
///   }
///
///   factory Paging.fromMap(Map<String, dynamic> data, {required Type type}) {
///     return Paging(
///       data: (data['data'] as List<dynamic>)
///           .map<T>((e) => factoryDataList(type, e))
///           .toList(),
///       pageNo: data['pageNo'] as int?,
///       pageSize: data['pageSize'] as int?,
///       totalPages: data['totalPages'] as int?,
///       totalRecords: data['totalRecords'] as int?,
///     );
///   }
///
///   static final _dataFactory = <Type, dynamic Function(Map<String, dynamic>)>{
///     CategoryResponse: CategoryResponse.fromJson,
///   };
///
///   static factoryDataList(Type type, data) {
///     if (data is String || data is num || data is bool) {
///       return data;
///     }
///     return _dataFactory[type]?.call(data);
///   }
/// } ||||| till here
//endregion
class ApiHandler<T> {
  final T Function(dynamic value) converter;
  final String method;
  final Map<String, String>? customHeaders;

  ApiHandler({
    required this.method,
    required this.converter,
    this.customHeaders,
  });

  //region Method
  factory ApiHandler.get({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.GET);

  factory ApiHandler.post({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.POST);

  factory ApiHandler.put({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.PUT);

  factory ApiHandler.patch({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.PATCH);

  factory ApiHandler.delete({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.DELETE);

  factory ApiHandler.head({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.HEAD);

  factory ApiHandler.options({
    required T Function(dynamic value) converter,
  }) =>
      ApiHandler<T>(converter: converter, method: Method.OPTIONS);

  //endregion

  Future<T?> execute({
    required OnComplete<T> onComplete,
    OnFail? onFail,
    Future<void> Function()? onFinished,
    bool isAuthenticated =
        true, // Condition to switch between authenticated and normal client,
    required String endPoint,
    JSON? body, // Parameter for JSON body
    JSON? formData, // Parameter for multipart form data
    JSON? queryParams, // Parameter for URL query parameters
  }) async {
    final client = isAuthenticated
        ? AuthHttpClient(
            InterceptorClient(
              http.Client(),
              responseInterceptor: Get.find<ApiInterceptor>(),
            ),
            customHeaders: customHeaders,
          )
        : NormalHttpClient(InterceptorClient(http.Client()));

    try {
      //region Set Up Body
      http.BaseRequest request = http.Request(method, Uri.parse(endPoint));

      if (body != null) {
        request = http.Request(method, Uri.parse(endPoint))
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);
      } else if (formData != null) {
        final multipartRequest =
            http.MultipartRequest(method, Uri.parse(endPoint))
              ..headers['Content-Type'] = 'multipart/form-data';
        formData.forEach((key, value) async {
          betterLog(message: "value: ${value.runtimeType.toString()}");
          if (value.runtimeType == List<XFile>) {
            for (final file in value) {
              var resultFile =
                  await http.MultipartFile.fromPath(key, file.path);
              betterPrettyLog(
                  message: "resultFile: ${resultFile.runtimeType.toString()}");
              multipartRequest.files.add(resultFile);
            }
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        });

        request = multipartRequest;
      }
      if (queryParams != null) {
        final uri = Uri.parse(endPoint).replace(queryParameters: queryParams);
        request = http.Request(method, uri);
      }
      //endregion

      //region request
      http.StreamedResponse response =
          await client.send(request).timeout(const Duration(minutes: 1));
      final responseBody = await _streamToByte(response.stream);
      if (responseBody.isEmpty) {
        if (onFail != null) {
          return await onFail(ExceptionHandler.handle(
              ApiException(statusCode: response.statusCode, message: "")));
        } else {
          throw Exception(response);
        }
      }

      final jsonResponse = jsonDecode(responseBody);
      betterPrettyLog(
          message: "jsonResponse type: ${jsonResponse.runtimeType}"
              "\njsonResponse: $jsonResponse"
              "\nconverter: $converter");
      //endregion

      if (response.statusCode != 200) {
        if (onFail != null) {
          await onFail(ExceptionHandler.handle(ApiException(
              statusCode: response.statusCode,
              message: "",
              body: jsonResponse)));
        } else {
          throw Exception(response);
        }
      } else {
        final T data = converter(jsonResponse);
        return await onComplete(data);
      }
    } catch (error, stack) {
      betterLog(message: "$error\n$stack");
      if (onFail != null) {
        await onFail(ExceptionHandler.handle(error));
      } else {
        ExceptionHandler.handle(error);
      }
    } finally {
      client.close(); // Close the client when finished
      if (onFinished != null) {
        await onFinished();
      }
    }
    return null;
  }

  Future<String> _streamToByte(Stream<List<int>> stream) async {
    final bytes = <int>[];

    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }

    return utf8.decode(bytes);
  }
}
