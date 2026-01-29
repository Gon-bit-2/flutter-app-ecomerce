import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';

abstract class CommonRemoteDataSource {
  Future<String> uploadFile(XFile file);
}

@LazySingleton(as: CommonRemoteDataSource)
class CommonRemoteDataSourceImpl implements CommonRemoteDataSource {
  final DioClient dioClient;

  CommonRemoteDataSourceImpl(this.dioClient);

  @override
  Future<String> uploadFile(XFile file) async {
    final bytes = await file.readAsBytes();
    // Ensure filename is just the name, not a full path
    String fileName = file.name;
    if (fileName.contains('/') || fileName.contains('\\')) {
      fileName = fileName.split(RegExp(r'[/\\]')).last;
    }

    // Ensure proper mime type based on extension
    // Server regex: /image\/(jpg|jpeg|png|webp)/
    String extension = '';
    if (fileName.contains('.')) {
      extension = fileName.split('.').last.toLowerCase();
    }

    MediaType mediaType;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        mediaType = MediaType('image', 'jpeg');
        break;
      case 'png':
        mediaType = MediaType('image', 'png');
        break;
      case 'webp':
        mediaType = MediaType('image', 'webp');
        break;
      default:
        // Default lookup or fallback
        mediaType = MediaType('image', 'jpeg');
        break;
    }

    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: mediaType,
      ),
    });

    // Assuming endpoint is /media/images/upload based on API_LIST.md (Wait, API_LIST says /media/images/upload ?)
    // Let's re-verify API_LIST endpoint for upload.
    // Previous code used '/upload'. API_LIST says: `POST /media/images/upload`
    // I should probably fix the endpoint too while I am here.

    final response = await dioClient.post(
      '/media/images/upload',
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      String? resultUrl;
      // Check API_LIST for response format? Not clearly defined structure but usually data or direct.
      // Assuming structure based on other endpoints: { data: { url: ... } }
      if (data is Map) {
        if (data['data'] != null) {
          if (data['data'] is Map && data['data']['url'] != null) {
            resultUrl = data['data']['url'];
          } else if (data['data'] is String) {
            resultUrl = data['data']; // If data is the url
          }
        } else if (data['url'] != null) {
          resultUrl = data['url'];
        }
      }

      if (resultUrl != null) {
        if (!resultUrl.startsWith('http')) {
          if (resultUrl.startsWith('/')) {
            return '${AppConstants.baseUrl}$resultUrl';
          } else {
            return '${AppConstants.baseUrl}/$resultUrl';
          }
        }
        return resultUrl;
      }
      return data.toString();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
