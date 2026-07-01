import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../config/ai_config.dart';
import '../exceptions/ai_exceptions.dart';

/// Type alias pour un tenseur d'entrée TFLite : `[batch, height, width, channels]`.
typedef InputTensor = List<List<List<List<double>>>>;

/// Prétraite les images avant inférence TensorFlow Lite.
///
/// Pipeline : décodage → redimensionnement → normalisation → conversion tensor.
class ImageProcessor {
  ImageProcessor({AiConfig config = const AiConfig()}) : _config = config;

  final AiConfig _config;

  /// Prétraite une image à partir de bytes bruts (JPEG, PNG, etc.).
  InputTensor preprocessFromBytes(Uint8List imageBytes) {
    _validateBytes(imageBytes);
    final decoded = _decodeImage(imageBytes);
    return _buildTensor(decoded);
  }

  /// Prétraite une image à partir d'un fichier local.
  Future<InputTensor> preprocessFromFile(File imageFile) async {
    if (!await imageFile.exists()) {
      throw InvalidImageException(
        'Le fichier image n\'existe pas: ${imageFile.path}',
      );
    }

    final bytes = await imageFile.readAsBytes();
    return preprocessFromBytes(bytes);
  }

  void _validateBytes(Uint8List imageBytes) {
    if (imageBytes.isEmpty) {
      throw const InvalidImageException('Les bytes de l\'image sont vides.');
    }
  }

  img.Image _decodeImage(Uint8List imageBytes) {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        throw const InvalidImageException(
          'Format d\'image non reconnu ou fichier corrompu.',
        );
      }
      if (decoded.width == 0 || decoded.height == 0) {
        throw const InvalidImageException(
          'L\'image a des dimensions nulles.',
        );
      }
      return decoded;
    } on InvalidImageException {
      rethrow;
    } catch (e) {
      throw InvalidImageException('Erreur lors du décodage de l\'image.', e);
    }
  }

  InputTensor _buildTensor(img.Image image) {
    final resized = img.copyResize(
      image,
      width: _config.inputWidth,
      height: _config.inputHeight,
      interpolation: img.Interpolation.linear,
    );

    final batch = List.generate(1, (_) {
      return List.generate(_config.inputHeight, (y) {
        return List.generate(_config.inputWidth, (x) {
          final pixel = resized.getPixel(x, y);
          return List.generate(_config.inputChannels, (c) {
            final channelValue = switch (c) {
              0 => pixel.r,
              1 => pixel.g,
              2 => pixel.b,
              _ => 0.0,
            };
            return (channelValue - _config.normalizeMean) / _config.normalizeStd;
          });
        });
      });
    });

    return batch;
  }
}
