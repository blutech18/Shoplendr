import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Service for optimizing images before upload
class ImageOptimizer {
  // Configuration constants
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int thumbnailSize = 400;
  static const int quality = 85;
  static const int maxFileSizeKB = 2048; // 2MB

  /// Optimize image for upload
  /// Returns optimized image bytes and metadata
  static Future<Map<String, dynamic>> optimizeImage({
    required Uint8List imageBytes,
    String? fileName,
    bool generateThumbnail = true,
    int? customMaxWidth,
    int? customMaxHeight,
    int? customQuality,
  }) async {
    try {
      final startTime = DateTime.now();
      final originalSize = imageBytes.length;

      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final originalWidth = image.width;
      final originalHeight = image.height;

      // Calculate new dimensions
      final maxW = customMaxWidth ?? maxWidth;
      final maxH = customMaxHeight ?? maxHeight;
      final dimensions = _calculateDimensions(
        originalWidth,
        originalHeight,
        maxW,
        maxH,
      );

      // Resize image if needed
      if (dimensions['width']! < originalWidth ||
          dimensions['height']! < originalHeight) {
        image = img.copyResize(
          image,
          width: dimensions['width'],
          height: dimensions['height'],
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress image
      final qual = customQuality ?? quality;
      Uint8List optimizedBytes;

      if (fileName?.toLowerCase().endsWith('.png') ?? false) {
        // PNG compression
        optimizedBytes = Uint8List.fromList(img.encodePng(image, level: 6));
      } else {
        // JPEG compression (default)
        optimizedBytes = Uint8List.fromList(img.encodeJpg(image, quality: qual));
      }

      // If still too large, reduce quality further
      if (optimizedBytes.length > maxFileSizeKB * 1024) {
        optimizedBytes = await _compressFurther(
          image,
          targetSizeKB: maxFileSizeKB,
        );
      }

      // Generate thumbnail if requested
      Uint8List? thumbnailBytes;
      if (generateThumbnail) {
        thumbnailBytes = await _generateThumbnail(image);
      }

      final endTime = DateTime.now();
      final processingTime = endTime.difference(startTime).inMilliseconds;

      return {
        'optimized_bytes': optimizedBytes,
        'thumbnail_bytes': thumbnailBytes,
        'original_size': originalSize,
        'optimized_size': optimizedBytes.length,
        'thumbnail_size': thumbnailBytes?.length ?? 0,
        'original_width': originalWidth,
        'original_height': originalHeight,
        'optimized_width': image.width,
        'optimized_height': image.height,
        'compression_ratio':
            ((1 - (optimizedBytes.length / originalSize)) * 100).toStringAsFixed(1),
        'processing_time_ms': processingTime,
      };
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      rethrow;
    }
  }

  /// Optimize image from file path
  static Future<Map<String, dynamic>> optimizeImageFromPath({
    required String filePath,
    bool generateThumbnail = true,
    int? customMaxWidth,
    int? customMaxHeight,
    int? customQuality,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileName = filePath.split('/').last;

    return await optimizeImage(
      imageBytes: bytes,
      fileName: fileName,
      generateThumbnail: generateThumbnail,
      customMaxWidth: customMaxWidth,
      customMaxHeight: customMaxHeight,
      customQuality: customQuality,
    );
  }

  /// Optimize multiple images in batch
  static Future<List<Map<String, dynamic>>> optimizeBatch({
    required List<Uint8List> imageBytesList,
    bool generateThumbnails = true,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final bytes in imageBytesList) {
      try {
        final result = await optimizeImage(
          imageBytes: bytes,
          generateThumbnail: generateThumbnails,
        );
        results.add(result);
      } catch (e) {
        debugPrint('Error in batch optimization: $e');
        results.add({
          'error': e.toString(),
          'optimized_bytes': bytes, // Return original on error
        });
      }
    }

    return results;
  }

  /// Generate thumbnail from image
  static Future<Uint8List> _generateThumbnail(img.Image image) async {
    // Calculate thumbnail dimensions maintaining aspect ratio
    final dimensions = _calculateDimensions(
      image.width,
      image.height,
      thumbnailSize,
      thumbnailSize,
    );

    // Resize to thumbnail size
    final thumbnail = img.copyResize(
      image,
      width: dimensions['width'],
      height: dimensions['height'],
      interpolation: img.Interpolation.linear,
    );

    // Compress thumbnail
    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
  }

  /// Compress image further to meet target size
  static Future<Uint8List> _compressFurther(
    img.Image image,
    {required int targetSizeKB}
  ) async {
    int currentQuality = 80;
    Uint8List compressed = Uint8List.fromList(
      img.encodeJpg(image, quality: currentQuality),
    );

    // Reduce quality until target size is met
    while (compressed.length > targetSizeKB * 1024 && currentQuality > 20) {
      currentQuality -= 10;
      compressed = Uint8List.fromList(
        img.encodeJpg(image, quality: currentQuality),
      );
    }

    // If still too large, reduce dimensions
    if (compressed.length > targetSizeKB * 1024) {
      const scaleFactor = 0.8;
      final resized = img.copyResize(
        image,
        width: (image.width * scaleFactor).round(),
        height: (image.height * scaleFactor).round(),
      );
      compressed = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
    }

    return compressed;
  }

  /// Calculate new dimensions maintaining aspect ratio
  static Map<String, int> _calculateDimensions(
    int originalWidth,
    int originalHeight,
    int maxWidth,
    int maxHeight,
  ) {
    if (originalWidth <= maxWidth && originalHeight <= maxHeight) {
      return {'width': originalWidth, 'height': originalHeight};
    }

    final widthRatio = maxWidth / originalWidth;
    final heightRatio = maxHeight / originalHeight;
    final ratio = widthRatio < heightRatio ? widthRatio : heightRatio;

    return {
      'width': (originalWidth * ratio).round(),
      'height': (originalHeight * ratio).round(),
    };
  }

  /// Validate image before optimization
  static Future<bool> validateImage(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return false;

      // Check minimum dimensions
      if (image.width < 100 || image.height < 100) {
        debugPrint('Image too small: ${image.width}x${image.height}');
        return false;
      }

      // Check maximum dimensions
      if (image.width > 10000 || image.height > 10000) {
        debugPrint('Image too large: ${image.width}x${image.height}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating image: $e');
      return false;
    }
  }

  /// Get image metadata without optimization
  static Future<Map<String, dynamic>> getImageMetadata(
    Uint8List imageBytes,
  ) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      return {
        'width': image.width,
        'height': image.height,
        'size_bytes': imageBytes.length,
        'size_kb': (imageBytes.length / 1024).toStringAsFixed(2),
        'size_mb': (imageBytes.length / (1024 * 1024)).toStringAsFixed(2),
        'aspect_ratio': (image.width / image.height).toStringAsFixed(2),
      };
    } catch (e) {
      debugPrint('Error getting image metadata: $e');
      rethrow;
    }
  }

  /// Convert image to different format
  static Future<Uint8List> convertFormat({
    required Uint8List imageBytes,
    required String targetFormat, // 'jpg', 'png', 'webp'
    int quality = 85,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      switch (targetFormat.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        case 'png':
          return Uint8List.fromList(img.encodePng(image));
        case 'webp':
          // WebP support requires additional package
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        default:
          throw Exception('Unsupported format: $targetFormat');
      }
    } catch (e) {
      debugPrint('Error converting image format: $e');
      rethrow;
    }
  }

  /// Crop image to square (for profile pictures)
  static Future<Uint8List> cropToSquare(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final size = image.width < image.height ? image.width : image.height;
      final x = (image.width - size) ~/ 2;
      final y = (image.height - size) ~/ 2;

      final cropped = img.copyCrop(image, x: x, y: y, width: size, height: size);
      return Uint8List.fromList(img.encodeJpg(cropped, quality: quality));
    } catch (e) {
      debugPrint('Error cropping image: $e');
      rethrow;
    }
  }

  /// Add watermark to image
  static Future<Uint8List> addWatermark({
    required Uint8List imageBytes,
    required String watermarkText,
    int opacity = 128,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Draw watermark text (simple implementation)
      // For production, use a proper text rendering library
      final watermarked = img.drawString(
        image,
        watermarkText,
        font: img.arial24,
        x: 10,
        y: image.height - 30,
        color: img.ColorRgba8(255, 255, 255, opacity),
      );

      return Uint8List.fromList(img.encodeJpg(watermarked, quality: quality));
    } catch (e) {
      debugPrint('Error adding watermark: $e');
      rethrow;
    }
  }

  /// Save optimized image to temporary file
  static Future<File> saveToTempFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/optimized_$timestamp.jpg');
      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('Error saving to temp file: $e');
      rethrow;
    }
  }
}
