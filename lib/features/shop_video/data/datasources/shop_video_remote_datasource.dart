import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/shop_video_comment_model.dart';
import '../models/shop_video_model.dart';

abstract class ShopVideoRemoteDataSource {
  Future<List<ShopVideoModel>> getShopVideos({int page = 1, int limit = 10, int? shopId});
  Future<ShopVideoModel> getShopVideoDetail(int id);
  Future<ShopVideoModel> createShopVideo({
    required Uint8List videoBytes,
    required String fileName,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  });
  Future<ShopVideoModel> updateShopVideo(int id, Map<String, dynamic> data);
  Future<void> deleteShopVideo(int id);
  Future<void> toggleLike(int videoId);
  Future<List<ShopVideoCommentModel>> getComments(int videoId, {int page = 1, int limit = 20});
  Future<ShopVideoCommentModel> addComment(int videoId, {required String content, int? parentId});
}

/// Exception chuyên biệt cho lỗi parse dữ liệu từ API
class VideoDataParsingException implements Exception {
  final String message;
  final dynamic rawData;

  VideoDataParsingException(this.message, [this.rawData]);

  @override
  String toString() => 'VideoDataParsingException: $message';
}

@LazySingleton(as: ShopVideoRemoteDataSource)
class ShopVideoRemoteDataSourceImpl implements ShopVideoRemoteDataSource {
  final Dio client;

  ShopVideoRemoteDataSourceImpl(this.client);

  /// Parse an toàn một ShopVideoModel từ JSON response
  /// Nếu parse thất bại, log lỗi chi tiết và throw exception có ý nghĩa
  ShopVideoModel _parseVideoModel(dynamic rawJson) {
    try {
      final json = rawJson as Map<String, dynamic>;
      return ShopVideoModel.fromJson(json);
    } on TypeError catch (e) {
      developer.log(
        'Lỗi parse video data: $e',
        name: 'ShopVideoDataSource',
        error: e,
      );
      developer.log(
        'Raw response data: $rawJson',
        name: 'ShopVideoDataSource',
      );
      throw VideoDataParsingException(
        'Dữ liệu video từ server không đúng định dạng: $e',
        rawJson,
      );
    }
  }

  /// Parse an toàn một danh sách ShopVideoModel từ JSON response
  List<ShopVideoModel> _parseVideoList(dynamic rawData) {
    try {
      final List<dynamic> data = rawData is List ? rawData : (rawData['data'] ?? rawData);
      return data.map((e) => _parseVideoModel(e)).toList();
    } on TypeError catch (e) {
      developer.log(
        'Lỗi parse danh sách video: $e',
        name: 'ShopVideoDataSource',
        error: e,
      );
      throw VideoDataParsingException(
        'Dữ liệu danh sách video từ server không đúng định dạng: $e',
        rawData,
      );
    }
  }

  @override
  Future<List<ShopVideoModel>> getShopVideos({int page = 1, int limit = 10, int? shopId}) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (shopId != null) query['shopId'] = shopId;
    
    final response = await client.get('/shop-video', queryParameters: query);
    final rawData = response.data['data'] ?? response.data;
    return _parseVideoList(rawData);
  }

  @override
  Future<ShopVideoModel> getShopVideoDetail(int id) async {
    final response = await client.get('/shop-video/$id');
    return _parseVideoModel(response.data['data'] ?? response.data);
  }

  @override
  Future<ShopVideoModel> createShopVideo({
    required Uint8List videoBytes,
    required String fileName,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  }) async {
    final formDataMap = <String, dynamic>{
      'video': MultipartFile.fromBytes(videoBytes, filename: fileName),
    };

    if (caption != null) formDataMap['caption'] = caption;
    if (thumbnailUrl != null) formDataMap['thumbnailUrl'] = thumbnailUrl;
    if (productIds != null && productIds.isNotEmpty) {
      formDataMap['productIds'] = productIds.toString(); 
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await client.post(
      '/shop-video',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return _parseVideoModel(response.data['data'] ?? response.data);
  }

  @override
  Future<ShopVideoModel> updateShopVideo(int id, Map<String, dynamic> data) async {
    final response = await client.put('/shop-video/$id', data: data);
    return _parseVideoModel(response.data['data'] ?? response.data);
  }

  @override
  Future<void> deleteShopVideo(int id) async {
    await client.delete('/shop-video/$id');
  }

  @override
  Future<void> toggleLike(int videoId) async {
    await client.post('/shop-video/$videoId/like');
  }

  @override
  Future<List<ShopVideoCommentModel>> getComments(int videoId, {int page = 1, int limit = 20}) async {
    final response = await client.get('/shop-video/$videoId/comments', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final List<dynamic> data = response.data['data'] ?? response.data;
    try {
      return data.map((e) => ShopVideoCommentModel.fromJson(e)).toList();
    } on TypeError catch (e) {
      developer.log(
        'Lỗi parse comments: $e',
        name: 'ShopVideoDataSource',
        error: e,
      );
      throw VideoDataParsingException(
        'Dữ liệu bình luận từ server không đúng định dạng: $e',
        data,
      );
    }
  }

  @override
  Future<ShopVideoCommentModel> addComment(int videoId, {required String content, int? parentId}) async {
    final data = <String, dynamic>{'content': content};
    if (parentId != null) data['parentId'] = parentId;

    final response = await client.post('/shop-video/$videoId/comments', data: data);
    try {
      return ShopVideoCommentModel.fromJson(response.data['data'] ?? response.data);
    } on TypeError catch (e) {
      developer.log(
        'Lỗi parse comment response: $e',
        name: 'ShopVideoDataSource',
        error: e,
      );
      throw VideoDataParsingException(
        'Dữ liệu bình luận từ server không đúng định dạng: $e',
        response.data,
      );
    }
  }
}
