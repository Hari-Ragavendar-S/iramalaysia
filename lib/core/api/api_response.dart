class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message ?? 'Success',
      statusCode: statusCode ?? 200,
      metadata: metadata,
    );
  }

  factory ApiResponse.error({
    String? error,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error ?? 'Unknown error occurred',
      message: message,
      statusCode: statusCode ?? 500,
      metadata: metadata,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final success = json['success'] ?? true;
      final data = json['data'];
      
      return ApiResponse<T>(
        success: success,
        data: data != null && fromJsonT != null ? fromJsonT(data) : data,
        message: json['message']?.toString(),
        error: json['error']?.toString(),
        statusCode: json['status_code'] ?? json['statusCode'],
        metadata: json['metadata'],
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: 'Failed to parse response: $e',
        statusCode: 500,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'status_code': statusCode,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, error: $error, statusCode: $statusCode)';
  }
}

// Pagination Response
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['items'] ?? json['data'] ?? [];
    final items = (itemsJson as List)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      items: items,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? json['perPage'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}