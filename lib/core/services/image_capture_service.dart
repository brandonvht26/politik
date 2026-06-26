import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:image_picker/image_picker.dart';

/// Service responsible for capturing a photo and validating that it is
/// sharp enough using a Laplacian variance algorithm.
class ImageCaptureService {
  ImageCaptureService._();

  static final ImagePicker _picker = ImagePicker();
  static final ImageQualityValidator _validator = ImageQualityValidator(
    config: QualityConfig.photoCapture,
  );

  /// Opens the camera, validates image sharpness and returns the file path.
  ///
  /// Throws if the user cancels the capture or if the image is blurry.
  static Future<String> captureAndValidatePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) {
      throw Exception('No se tomó ninguna foto.');
    }

    final bytes = await photo.readAsBytes();
    final result = await _validator.validate(bytes);

    if (!result.isValid) {
      throw Exception(
        'La imagen está borrosa, por favor tómala de nuevo.',
      );
    }

    return photo.path;
  }
}
