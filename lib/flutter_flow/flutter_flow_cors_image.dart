import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Helper widget to handle CORS issues with external images
/// For web platform, it uses a CORS proxy for external images
class CorsAwareImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CorsAwareImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  String _getCorsProxyUrl(String url) {
    // For web platform, use a CORS proxy for external images
    // This is only needed for development
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Check if it's not from Firebase Storage or your own domain
      if (!url.contains('firebasestorage.googleapis.com') &&
          !url.contains('localhost')) {
        // Use CORS proxy (you can use cors-anywhere or allorigins)
        // For production, upload images to your own storage
        return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final processedUrl = _getCorsProxyUrl(imageUrl);

    return CachedNetworkImage(
      imageUrl: processedUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) =>
          placeholder ??
          const Center(
            child: CircularProgressIndicator(),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          const Icon(
            Icons.error_outline,
            color: Colors.grey,
            size: 48,
          ),
    );
  }
}
