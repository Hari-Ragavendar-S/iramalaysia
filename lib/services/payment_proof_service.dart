import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class PaymentProofService {
  static final ApiService _apiService = ApiService();
  
  // Upload payment proof for pod booking
  static Future<Map<String, dynamic>> uploadPaymentProof({
    required String bookingId,
    required File file,
    String? notes,
    Function(int, int)? onProgress,
  }) async {
    try {
      final additionalData = <String, dynamic>{};
      if (notes != null) additionalData['notes'] = notes;

      final response = await _apiService.uploadFile(
        ApiConfig.uploadPaymentProof(bookingId),
        file,
        fieldName: 'file',
        additionalData: additionalData,
        onSendProgress: onProgress != null 
            ? (int sent, int total) => onProgress(sent, total)
            : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Payment proof uploaded successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload payment proof',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
  
  // Get payment status for booking
  static Future<Map<String, dynamic>> getPaymentStatus(String bookingId) async {
    try {
      final response = await _apiService.get('/payment-proof/booking/$bookingId/status');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get payment status',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Get all payment proofs (admin)
  static Future<Map<String, dynamic>> getAllPaymentProofs({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        '/admin/payment-proofs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['items'] ?? response.data,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load payment proofs',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Update payment proof status (admin)
  static Future<Map<String, dynamic>> updatePaymentProofStatus({
    required String paymentProofId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put(
        '/admin/payment-proofs/$paymentProofId/status',
        data: {
          'status': status,
          'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Payment proof status updated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update payment proof status',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Get payment proof details
  static Future<Map<String, dynamic>> getPaymentProofDetails(String paymentProofId) async {
    try {
      final response = await _apiService.get('/payment-proof/$paymentProofId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load payment proof details',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Delete payment proof
  static Future<Map<String, dynamic>> deletePaymentProof(String paymentProofId) async {
    try {
      final response = await _apiService.delete('/payment-proof/$paymentProofId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Payment proof deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete payment proof',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Helper method to extract error messages
  static String _getErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}