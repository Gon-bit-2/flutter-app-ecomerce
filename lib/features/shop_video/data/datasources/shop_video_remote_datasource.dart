import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/shop_video_comment_model.dart';
import '../models/shop_video_model.dart';

abstract class ShopVideoRemoteDataSource {
  Future<List<ShopVideoModel>> getShopVideos({int page = 1, int limit = 10, int? shopId});
  Future<ShopVideoModel> getShopVideoDetail(int id);
  Future<ShopVideoModel> createShopVideo({
    required File video,
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

@LazySingleton(as: ShopVideoRemoteDataSource)
class ShopVideoRemoteDataSourceImpl implements ShopVideoRemoteDataSource {
  final Dio client;

  ShopVideoRemoteDataSourceImpl(this.client);

  @override
  Future<List<ShopVideoModel>> getShopVideos({int page = 1, int limit = 10, int? shopId}) async {
    final query = {'page': page, 'limit': limit};
    if (shopId != null) query['shopId'] = shopId;
    
    final response = await client.get('/shop-video', queryParameters: query);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((e) => ShopVideoModel.fromJson(e)).toList();
  }

  @override
  Future<ShopVideoModel> getShopVideoDetail(int id) async {
    final response = await client.get('/shop-video/$id');
    return ShopVideoModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<ShopVideoModel> createShopVideo({
    required File video,
    String? caption,
    String? thumbnailUrl,
    List<int>? productIds,
  }) async {
    String fileName = video.path.split('/').last;
    final formDataMap = <String, dynamic>{
      'video': await MultipartFile.fromFile(video.path, filename: fileName),
    };

    if (caption != null) formDataMap['caption'] = caption;
    if (thumbnailUrl != null) formDataMap['thumbnailUrl'] = thumbnailUrl;
    if (productIds != null && productIds.isNotEmpty) {
      // Dựa theo API_LIST, chuyển array thành string format
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

    return ShopVideoModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<ShopVideoModel> updateShopVideo(int id, Map<String, dynamic> data) async {
    final response = await client.put('/shop-video/$id', data: data);
    return ShopVideoModel.fromJson(response.data['data'] ?? response.data);
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
    return data.map((e) => ShopVideoCommentModel.fromJson(e)).toList();
  }

  @override
  Future<ShopVideoCommentModel> addComment(int videoId, {required String content, int? parentId}) async {
    final data = <String, dynamic>{'content': content};
    if (parentId != null) data['parentId'] = parentId;

    final response = await client.post('/shop-video/$videoId/comments', data: data);
    return ShopVideoCommentModel.fromJson(response.data['data'] ?? response.data);
  }
}
