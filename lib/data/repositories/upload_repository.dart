import 'dart:io';
import 'dart:convert';
import '../services/upload_service.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class UploadRepository {
  final UploadService _uploadService = UploadService();

  // Image Upload
  Future<ApiResponse<UploadResponse>> uploadImage({
    required File imageFile,
    ProgressCallback? onProgress,
  }) async {
    final response = await _uploadService.uploadImage(
      imageFile: imageFile,
      onProgress: onProgress,
    );

    // Convert Map<String, dynamic> to UploadResponse
    if (response.success && response.data != null) {
      final uploadResponse = UploadResponse.fromJson(response.data!);
      await _cacheUploadedFile(uploadResponse);
      
      return ApiResponse<UploadResponse>.success(
        data: uploadResponse,
        message: response.message,
      );
    }

    return ApiResponse<UploadResponse>.error(error: response.error ?? 'Upload failed');
  }

  // Document Upload
  Future<ApiResponse<UploadResponse>> uploadDocument({
    required File documentFile,
    ProgressCallback? onProgress,
  }) async {
    final response = await _uploadService.uploadDocument(
      documentFile: documentFile,
      onProgress: onProgress,
    );

    // Convert Map<String, dynamic> to UploadResponse
    if (response.success && response.data != null) {
      final uploadResponse = UploadResponse.fromJson(response.data!);
      await _cacheUploadedFile(uploadResponse);
      
      return ApiResponse<UploadResponse>.success(
        data: uploadResponse,
        message: response.message,
      );
    }

    return ApiResponse<UploadResponse>.error(error: response.error ?? 'Upload failed');
  }

  // Multiple Files Upload
  Future<List<ApiResponse<UploadResponse>>> uploadMultipleImages({
    required List<File> imageFiles,
    ProgressCallback? onProgress,
  }) async {
    final responses = <ApiResponse<UploadResponse>>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final response = await uploadImage(
        imageFile: imageFiles[i],
        onProgress: onProgress != null
            ? (sent, total) => onProgress(
                  sent + (i * total),
                  total * imageFiles.length,
                )
            : null,
      );
      responses.add(response);
    }

    return responses;
  }

  Future<List<ApiResponse<UploadResponse>>> uploadMultipleDocuments({
    required List<File> documentFiles,
    ProgressCallback? onProgress,
  }) async {
    final responses = <ApiResponse<UploadResponse>>[];

    for (int i = 0; i < documentFiles.length; i++) {
      final response = await uploadDocument(
        documentFile: documentFiles[i],
        onProgress: onProgress != null
            ? (sent, total) => onProgress(
                  sent + (i * total),
                  total * documentFiles.length,
                )
            : null,
      );
      responses.add(response);
    }

    return responses;
  }

  // Cached Data Management
  Future<List<UploadResponse>?> getCachedUploadedFiles() async {
    final uploadsData = await SecureStorage.read('uploaded_files');
    if (uploadsData != null) {
      try {
        final List<dynamic> uploadsList = jsonDecode(uploadsData);
        return uploadsList.map((json) => UploadResponse.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('uploaded_files');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheUploadedFile(UploadResponse uploadResponse) async {
    final cachedFiles = await getCachedUploadedFiles() ?? [];
    cachedFiles.add(uploadResponse);
    
    // Keep only last 50 uploads to prevent excessive storage
    if (cachedFiles.length > 50) {
      cachedFiles.removeRange(0, cachedFiles.length - 50);
    }
    
    final uploadsJson = cachedFiles.map((upload) => upload.toJson()).toList();
    await SecureStorage.write('uploaded_files', jsonEncode(uploadsJson));
  }

  Future<void> clearCachedUploads() async {
    await SecureStorage.delete('uploaded_files');
  }

  // Upload Categories
  List<String> getImageCategories() {
    return [
      'profile',
      'id_proof',
      'payment_proof',
      'event_image',
      'pod_image',
      'performance_image',
      'other',
    ];
  }

  List<String> getDocumentCategories() {
    return [
      'id_document',
      'license',
      'certificate',
      'contract',
      'receipt',
      'other',
    ];
  }

  // File Validation
  bool isValidImageFile(File file) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final fileName = file.path.toLowerCase();
    return allowedExtensions.any((ext) => fileName.endsWith(ext));
  }

  bool isValidDocumentFile(File file) {
    final allowedExtensions = ['.pdf', '.doc', '.docx', '.txt', '.jpg', '.jpeg', '.png'];
    final fileName = file.path.toLowerCase();
    return allowedExtensions.any((ext) => fileName.endsWith(ext));
  }

  bool isValidFileSize(File file, {int maxSizeMB = 10}) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  String getFileName(File file) {
    return file.path.split('/').last;
  }

  int getFileSizeInMB(File file) {
    final fileSizeInBytes = file.lengthSync();
    return (fileSizeInBytes / (1024 * 1024)).round();
  }

  // Upload Helpers
  Future<ApiResponse<UploadResponse>> uploadProfileImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
    );
  }

  Future<ApiResponse<UploadResponse>> uploadIdProofImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
    );
  }

  Future<ApiResponse<UploadResponse>> uploadPaymentProofImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
    );
  }

  Future<ApiResponse<UploadResponse>> uploadEventImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
    );
  }

  Future<ApiResponse<UploadResponse>> uploadPodImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
    );
  }

  Future<ApiResponse<UploadResponse>> uploadPerformanceImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
    );
  }

  // Batch Upload with Error Handling
  Future<BatchUploadResult> uploadBatch({
    required List<File> files,
    required String category,
    bool isDocument = false,
    ProgressCallback? onProgress,
  }) async {
    final successfulUploads = <UploadResponse>[];
    final failedUploads = <BatchUploadError>[];
    int totalFiles = files.length;
    int completedFiles = 0;

    for (final file in files) {
      try {
        // Validate file
        if (isDocument && !isValidDocumentFile(file)) {
          failedUploads.add(BatchUploadError(
            fileName: getFileName(file),
            error: 'Invalid document file type',
          ));
          continue;
        }

        if (!isDocument && !isValidImageFile(file)) {
          failedUploads.add(BatchUploadError(
            fileName: getFileName(file),
            error: 'Invalid image file type',
          ));
          continue;
        }

        if (!isValidFileSize(file)) {
          failedUploads.add(BatchUploadError(
            fileName: getFileName(file),
            error: 'File size exceeds 10MB limit',
          ));
          continue;
        }

        // Upload file
        final response = isDocument
            ? await uploadDocument(
                documentFile: file,
                onProgress: onProgress != null
                    ? (sent, total) {
                        final overallProgress = 
                            (completedFiles * total + sent) / (totalFiles * total);
                        onProgress((overallProgress * total).toInt(), total);
                      }
                    : null,
              )
            : await uploadImage(
                imageFile: file,
                onProgress: onProgress != null
                    ? (sent, total) {
                        final overallProgress = 
                            (completedFiles * total + sent) / (totalFiles * total);
                        onProgress((overallProgress * total).toInt(), total);
                      }
                    : null,
              );

        if (response.success && response.data != null) {
          successfulUploads.add(response.data!);
        } else {
          failedUploads.add(BatchUploadError(
            fileName: getFileName(file),
            error: response.error ?? 'Upload failed',
          ));
        }
      } catch (e) {
        failedUploads.add(BatchUploadError(
          fileName: getFileName(file),
          error: e.toString(),
        ));
      }

      completedFiles++;
    }

    return BatchUploadResult(
      successfulUploads: successfulUploads,
      failedUploads: failedUploads,
      totalFiles: totalFiles,
    );
  }

  // Upload History
  Future<List<UploadResponse>> getUploadHistory({
    String? category,
    int limit = 20,
  }) async {
    final cachedFiles = await getCachedUploadedFiles() ?? [];
    
    if (category != null) {
      return cachedFiles
          .where((upload) => upload.category == category)
          .take(limit)
          .toList();
    }
    
    return cachedFiles.take(limit).toList();
  }

  Future<List<UploadResponse>> getRecentUploads({int limit = 10}) async {
    final cachedFiles = await getCachedUploadedFiles() ?? [];
    return cachedFiles.reversed.take(limit).toList();
  }

  // Upload Statistics
  Future<UploadStats> getUploadStats() async {
    final cachedFiles = await getCachedUploadedFiles() ?? [];
    
    final imageUploads = cachedFiles.where((upload) => 
        upload.fileType?.startsWith('image/') == true).length;
    final documentUploads = cachedFiles.length - imageUploads;
    
    final totalSize = cachedFiles.fold<int>(0, (sum, upload) => 
        sum + (upload.fileSize ?? 0));
    
    return UploadStats(
      totalUploads: cachedFiles.length,
      imageUploads: imageUploads,
      documentUploads: documentUploads,
      totalSizeBytes: totalSize,
    );
  }
}

// Helper Classes
class UploadResponse {
  final String? id;
  final String? fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? category;
  final DateTime? uploadedAt;

  UploadResponse({
    this.id,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.category,
    this.uploadedAt,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      id: json['id'],
      fileName: json['file_name'] ?? json['fileName'],
      fileUrl: json['file_url'] ?? json['fileUrl'],
      fileType: json['file_type'] ?? json['fileType'],
      fileSize: json['file_size'] ?? json['fileSize'],
      category: json['category'],
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.parse(json['uploaded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'category': category,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }
}

class BatchUploadResult {
  final List<UploadResponse> successfulUploads;
  final List<BatchUploadError> failedUploads;
  final int totalFiles;

  BatchUploadResult({
    required this.successfulUploads,
    required this.failedUploads,
    required this.totalFiles,
  });

  bool get hasErrors => failedUploads.isNotEmpty;
  bool get allSuccessful => failedUploads.isEmpty;
  int get successCount => successfulUploads.length;
  int get failureCount => failedUploads.length;
}

class BatchUploadError {
  final String fileName;
  final String error;

  BatchUploadError({
    required this.fileName,
    required this.error,
  });
}

class UploadStats {
  final int totalUploads;
  final int imageUploads;
  final int documentUploads;
  final int totalSizeBytes;

  UploadStats({
    required this.totalUploads,
    required this.imageUploads,
    required this.documentUploads,
    required this.totalSizeBytes,
  });

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);
  double get averageFileSizeMB => totalUploads > 0 ? totalSizeMB / totalUploads : 0;
}

typedef ProgressCallback = void Function(int sent, int total);