import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A widget that safely loads images from external URLs that may have CORS restrictions
/// Falls back to a placeholder if the image fails to load
class CorsSafeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholder;
  final BorderRadius? borderRadius;

  const CorsSafeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.borderRadius,
  });

  /// Check if URL is from Firebase Storage or localhost
  bool _isFirebaseOrLocal(Uri uri) {
    return uri.host.contains('firebasestorage.googleapis.com') ||
           uri.host.contains('localhost') ||
           uri.host.contains('127.0.0.1');
  }

  /// Get CORS proxy URL for external images on web
  String _getCorsProxyUrl(String url) {
    // Use CORS proxy for external images on web
    // corsproxy.io is a free CORS proxy service
    return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
  }

  @override
  Widget build(BuildContext context) {
    // If the URL is empty or invalid, show placeholder
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      return _buildPlaceholder();
    }
    
    final isFirebaseOrLocal = _isFirebaseOrLocal(uri);
    
    // Determine the URL to use
    String finalUrl = imageUrl;
    if (kIsWeb && !isFirebaseOrLocal) {
      // Use CORS proxy for external images on web
      finalUrl = _getCorsProxyUrl(imageUrl);
      debugPrint('🔄 CorsSafeImage: Using CORS proxy for: ${uri.host}');
    }

    Widget imageWidget;

    // Use CachedNetworkImage for all images
    imageWidget = CachedNetworkImage(
      imageUrl: finalUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('❌ CorsSafeImage: Error loading image: $error');
        return _buildPlaceholder();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPlaceholder({bool showWarning = true}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: showWarning
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image unavailable',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            )
          : Center(
              child: Icon(
                Icons.image,
                size: 48,
                color: Colors.grey[500],
              ),
            ),
    );
  }
}
