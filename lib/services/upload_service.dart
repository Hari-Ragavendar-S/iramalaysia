import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class UploadService {
  static final ApiService _apiService = ApiService();

  // Upload image
  static Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    String? category,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final additionalData = <String, dynamic>{};
      if (category != null) additionalData['category'] = category;
      if (description != null) additionalData['description'] = description;

      final response = await _apiService.uploadFile(
        ApiConfig.uploadImage,
        imageFile,
        fieldName: 'file',
        additionalData: additionalData,
        onSendProgress: onProgress != null 
            ? (int sent, int total) => onProgress(sent, total)
            : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Image uploaded successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload image',
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

  // Upload document
  static Future<Map<String, dynamic>> uploadDocument({
    required File documentFile,
    String? documentType,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final additionalData = <String, dynamic>{};
      if (documentType != null) additionalData['document_type'] = documentType;
      if (description != null) additionalData['description'] = description;

      final response = await _apiService.uploadFile(
        ApiConfig.uploadDocument,
        documentFile,
        fieldName: 'file',
        additionalData: additionalData,
        onSendProgress: onProgress != null 
            ? (int sent, int total) => onProgress(sent, total)
            : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Document uploaded successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload document',
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

  // Upload multiple files
  static Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<File> files,
    String? category,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final results = <Map<String, dynamic>>[];
      
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final isImage = _isImageFile(file);
        
        final result = isImage 
            ? await uploadImage(
                imageFile: file,
                category: category,
                description: description,
                onProgress: onProgress,
              )
            : await uploadDocument(
                documentFile: file,
                documentType: category,
                description: description,
                onProgress: onProgress,
              );
        
        results.add({
          'index': i,
          'filename': file.path.split('/').last,
          'result': result,
        });
      }

      final successCount = results.where((r) => r['result']['success'] == true).length;
      
      return {
        'success': successCount == files.length,
        'message': successCount == files.length 
            ? 'All files uploaded successfully'
            : '$successCount of ${files.length} files uploaded successfully',
        'data': results,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred during batch upload',
      };
    }
  }

  // Get uploaded files
  static Future<Map<String, dynamic>> getUploadedFiles({
    int page = 1,
    int limit = 20,
    String? category,
    String? fileType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (fileType != null && fileType.isNotEmpty) queryParams['file_type'] = fileType;

      final response = await _apiService.get(
        '/upload/files',
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
          'message': 'Failed to load uploaded files',
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

  // Delete uploaded file
  static Future<Map<String, dynamic>> deleteFile(String fileId) async {
    try {
      final response = await _apiService.delete('/upload/files/$fileId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'File deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete file',
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

  // Get file URL
  static String getFileUrl(String filename) {
    return '${ApiConfig.uploadsUrl}/$filename';
  }

  // Check if file is an image
  static bool _isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Validate file size (max 10MB)
  static bool validateFileSize(File file, {double maxSizeMB = 10.0}) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }

  // Validate image file
  static bool validateImageFile(File file) {
    return _isImageFile(file) && validateFileSize(file, maxSizeMB: 5.0);
  }

  // Validate document file
  static bool validateDocumentFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];
    return allowedExtensions.contains(extension) && validateFileSize(file);
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