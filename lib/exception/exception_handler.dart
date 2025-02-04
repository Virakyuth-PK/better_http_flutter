import 'dart:async';
import 'dart:io';
import 'package:better_widget_flutter/better_snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'exception.dart';

class ExceptionHandler {
  static BaseException handle(dynamic error) {
    if (error is http.Response || error is ApiException) {
      if (error.body == null) {
        switch (error.statusCode) {
          case 400:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Bad Request"));
          case 401:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Unauthorised Request"));
          case 403:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Request Forbidden"));
          case 404:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Request Not Found"));
          case 409:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Request Conflict"));
          case 408:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Request Timeout"));
          case 422:
            return ApiException(
                statusCode: error.statusCode, message: "Un-processable Entity");
          case 500:
            return ApiException(
                statusCode: error.statusCode, message: "Internal Server Error");
          case 501:
            return ApiException(
                statusCode: error.statusCode,
                message: "Server Not Implemented");
          case 502:
            return ApiException(
                statusCode: error.statusCode, message: "Service Unavailable");
          case 503:
            return ApiException(
                statusCode: error.statusCode, message: "Service Unavailable");
          case 504:
            return ApiException(
                statusCode: error.statusCode, message: "Gate Way Time Out");
          case 204:
            return ApiException(
                statusCode: error.statusCode, message: "No Content");
          default:
            return ApiException(
                statusCode: error.statusCode,
                message: getErrorMessage(error.body, "Response Unknown"));
        }
      } else {
        return ApiException(
            statusCode: error.statusCode,
            message: getErrorMessage(error.body, "Error"));
      }
    } else if (error is SocketException ||
        error is http.ClientException ||
        error is TimeoutException) {
      return NetworkException(
        message: "No internet connection",
      );
    } else {
      // For other types of errors, include the actual error message
      return AppException(message: error.toString());
    }
  }

  static String getErrorMessage(dynamic data, String defaultMessage) {
    String error = defaultMessage;
    if (data is Map?) {
      if (data?["message"] is String) {
        error = data?["message"];
      } else if (data?["Message"] is String) {
        error = data?["Message"];
      } else if (data?["detail"] is String) {
        error = data?["detail"];
      }
    }
    betterSnackBar(
        title: "Error", message: error, isError: true);
    return error;
  }
}
