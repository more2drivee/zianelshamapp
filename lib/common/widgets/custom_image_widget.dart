import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool transparentPlaceholder;

  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder = '',
    this.transparentPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: kIsWeb
          ? '${AppConstants.baseUrl}/image-proxy?url=$image'
          : image,
      height: height,
      width: width,
      fit: fit,
      // 🚫 منع أي أنيميشن عشان مايبقاش فيه فلاش/تكبير مفاجئ
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      useOldImageOnUrlChange: true,

      // ✅ Placeholder ثابت بنفس المقاس
      placeholder: (context, url) => transparentPlaceholder
          ? SizedBox(height: height, width: width)
          : SizedBox(
              height: height,
              width: width,
              child: Image.asset(
                placeholder.isNotEmpty
                    ? placeholder
                    : Images.placeholderImage,
                fit: fit,
              ),
            ),

      // ✅ ErrorWidget برضه بنفس المقاس
      errorWidget: (context, url, error) => transparentPlaceholder
          ? SizedBox(height: height, width: width)
          : SizedBox(
              height: height,
              width: width,
              child: Image.asset(
                placeholder.isNotEmpty
                    ? placeholder
                    : Images.placeholderImage,
                fit: fit,
              ),
            ),
    );
  }
}
