import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


void precachePropertyCardHeroImage(
  BuildContext context,
  List<String> imageUrls,
) {
  if (imageUrls.isEmpty) {
    return;
  }
  final url = imageUrls.first;
  if (!url.startsWith('http')) {
    return;
  }
  precacheImage(CachedNetworkImageProvider(url), context);
}
