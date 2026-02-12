import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/cloudinary_config.dart';

class CloudinaryDatasource {
  final Dio _dio = Dio();

  Future<String> uploadImage(XFile imageFile, String userId) async {
    final bytes = await imageFile.readAsBytes();
    final extension = imageFile.name.split('.').last;
    final base64Image = 'data:image/$extension;base64,${base64Encode(bytes)}';

    for (final preset in CloudinaryConfig.fallbackPresets) {
      try {
        final formData = FormData.fromMap({
          'file': base64Image,
          'upload_preset': preset,
          'folder': CloudinaryConfig.folder,
          'public_id':
              'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        });

        final response = await _dio.post(
          CloudinaryConfig.uploadUrl,
          data: formData,
        );

        if (response.statusCode == 200) {
          return response.data['secure_url'] as String;
        }
      } catch (_) {
        continue;
      }
    }

    throw Exception('Falha ao fazer upload da imagem. Nenhum preset funcionou.');
  }
}
