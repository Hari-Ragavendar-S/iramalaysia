import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/constants/app_constants.dart';

class UploadService {
  final ApiClient _apiClient = ApiClient.instance;

  // Upload Image
  Future<ApiResponse<Map<String, dynamic>>> uploadImage({
    required File imageFile,
    ProgressCallback? onProgress,
  }) async {
    // Validate file
    final validationResult = _validateImageFile(imageFile);
    if (!validationResult.isValid) {
      return ApiResponse.error(error: validationResult.error);
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: path.basename(imageFile.path),
      ),
    });

    return await _apiClient.upload<Map<String, dynamic>>(
      ApiEndpoints.uploadImage,
      formData: formData,
      onSendProgress: onProgress,
    );
  }

  // Upload Document
  Future<ApiResponse<Map<String, dynamic>>> uploadDocument({
    required File documentFile,
    ProgressCallback? onProgress,
  }) async {
    // Validate file
    final validationResult = _validateDocumentFile(documentFile);
    if (!validationResult.isValid) {
      return ApiResponse.error(error: validationResult.error);
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        documentFile.path,
        filename: path.basename(documentFile.path),
      ),
    });

    return await _apiClient.upload<Map<String, dynamic>>(
      ApiEndpoints.uploadDocument,
      formData: formData,
      onSendProgress: onProgress,
    );
  }

  // Upload Profile Image
  Future<ApiResponse<Map<String, dynamic>>> uploadProfileImage({
    required File imageFile,
    ProgressCallback? onProgress,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      onProgress: onProgress,
    );
  }

  // Upload ID Proof
  Future<ApiResponse<Map<String, dynamic>>> uploadIdProof({
    required File idProofFile,
    ProgressCallback? onProgress,
  }) async {
    // ID proof can be either image or document
    final extension = path.extension(idProofFile.path).toLowerCase();
    
    if (AppConstants.allowedImageTypes.contains(extension.substring(1))) {
      return await uploadImage(
        imageFile: idProofFile,
        onProgress: onProgress,
      );
    } else if (AppConstants.allowedDocumentTypes.contains(extension.substring(1))) {
      return await uploadDocument(
        documentFile: idProofFile,
        onProgress: onProgress,
      );
    } else {
      return ApiResponse.error(
        error: 'Invalid file type. Allowed types: ${[...AppConstants.allowedImageTypes, ...AppConstants.allowedDocumentTypes].join(', ')}',
      );
    }
  }

  // Upload Payment Proof
  Future<ApiResponse<Map<String, dynamic>>> uploadPaymentProof({
    required String bookingId,
    required File proofFile,
    String? notes,
    ProgressCallback? onProgress,
  }) async {
    // Validate file
    final validationResult = _validateImageFile(proofFile);
    if (!validationResult.isValid) {
      return ApiResponse.error(error: validationResult.error);
    }

    final formData = FormData.fromMap({
      'booking_id': bookingId,
      'file': await MultipartFile.fromFile(
        proofFile.path,
        filename: path.basename(proofFile.path),
      ),
      if (notes != null) 'notes': notes,
    });

    return await _apiClient.upload<Map<String, dynamic>>(
      ApiEndpoints.paymentProofUpload,
      formData: formData,
      onSendProgress: onProgress,
    );
  }

  // Upload Event Image
  Future<ApiResponse<Map<String, dynamic>>> uploadEventImage({
    required File imageFile,
    ProgressCallback? onProgress,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      onProgress: onProgress,
    );
  }

  // Upload Pod Image
  Future<ApiResponse<Map<String, dynamic>>> uploadPodImage({
    required File imageFile,
    ProgressCallback? onProgress,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      onProgress: onProgress,
    );
  }

  // Batch upload images
  Future<List<ApiResponse<Map<String, dynamic>>>> uploadMultipleImages({
    required List<File> imageFiles,
    ProgressCallback? onProgress,
  }) async {
    final results = <ApiResponse<Map<String, dynamic>>>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      
      final result = await uploadImage(
        imageFile: file,
        onProgress: onProgress != null 
            ? (sent, total) {
                // Calculate overall progress
                final fileProgress = sent / total;
                final overallProgress = (i + fileProgress) / imageFiles.length;
                onProgress((overallProgress * total).round(), total);
              }
            : null,
      );
      
      results.add(result);
      
      // Stop if any upload fails
      if (!result.success) {
        break;
      }
    }
    
    return results;
  }

  // Private validation methods
  FileValidationResult _validateImageFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      return FileValidationResult(false, 'File does not exist');
    }

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > AppConstants.maxFileSize) {
      final maxSizeMB = AppConstants.maxFileSize / (1024 * 1024);
      return FileValidationResult(false, 'File size exceeds ${maxSizeMB.toStringAsFixed(1)}MB limit');
    }

    // Check file extension
    final extension = path.extension(file.path).toLowerCase().substring(1);
    if (!AppConstants.allowedImageTypes.contains(extension)) {
      return FileValidationResult(false, 'Invalid file type. Allowed types: ${AppConstants.allowedImageTypes.join(', ')}');
    }

    return FileValidationResult(true, null);
  }

  FileValidationResult _validateDocumentFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      return FileValidationResult(false, 'File does not exist');
    }

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > AppConstants.maxFileSize) {
      final maxSizeMB = AppConstants.maxFileSize / (1024 * 1024);
      return FileValidationResult(false, 'File size exceeds ${maxSizeMB.toStringAsFixed(1)}MB limit');
    }

    // Check file extension
    final extension = path.extension(file.path).toLowerCase().substring(1);
    if (!AppConstants.allowedDocumentTypes.contains(extension)) {
      return FileValidationResult(false, 'Invalid file type. Allowed types: ${AppConstants.allowedDocumentTypes.join(', ')}');
    }

    return FileValidationResult(true, null);
  }

  // Utility methods
  bool isImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase().substring(1);
    return AppConstants.allowedImageTypes.contains(extension);
  }

  bool isDocumentFile(File file) {
    final extension = path.extension(file.path).toLowerCase().substring(1);
    return AppConstants.allowedDocumentTypes.contains(extension);
  }

  bool isValidFileSize(File file) {
    return file.lengthSync() <= AppConstants.maxFileSize;
  }

  String getFileSizeDisplay(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String getMaxFileSizeDisplay() {
    final maxSizeMB = AppConstants.maxFileSize / (1024 * 1024);
    return '${maxSizeMB.toStringAsFixed(1)} MB';
  }
}

class FileValidationResult {
  final bool isValid;
  final String? error;

  FileValidationResult(this.isValid, this.error);
}