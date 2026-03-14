import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/review_model.dart';

import 'dart:io';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getProductReviews(int productId, int page, int limit);
  Future<ReviewModel> createReview(Map<String, dynamic> body);
  Future<String> uploadMedia(File file);
}

@LazySingleton(as: ReviewRemoteDataSource)
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio client;

  ReviewRemoteDataSourceImpl(this.client);

  @override
  Future<List<ReviewModel>> getProductReviews(int productId, int page, int limit) async {
    final response = await client.get('/review/product/$productId', queryParameters: {
      'page': page,
      'limit': limit,
    });
    
    // API response is likely { data: [...reviews], total: X } or [...]
    // Assuming Standard API Wrapper where dio interceptor returns data object
    final List<dynamic> jsonList = response.data['data'] ?? response.data;
    return jsonList.map((json) => ReviewModel.fromJson(json)).toList();
  }

  @override
  Future<ReviewModel> createReview(Map<String, dynamic> body) async {
    final response = await client.post('/review', data: body);
    return ReviewModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<String> uploadMedia(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    
    // Fallback to /upload or /media/upload based on common API structures
    final response = await client.post('/media/images/upload', data: formData);
    return response.data['url'] ?? response.data['data']['url'];
  }
}
