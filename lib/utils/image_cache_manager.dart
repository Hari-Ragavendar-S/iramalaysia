import 'package:flutter/material.dart';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  static void precacheEventImages(BuildContext context, List<String> imageUrls) {
    for (String url in imageUrls) {
      try {
        precacheImage(NetworkImage(url), context);
      } catch (e) {
        debugPrint('Failed to precache image: $url - $e');
      }
    }
  }

  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static void configureImageCache() {
    // Increase cache size for better performance
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200MB
  }
}