import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HeroAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  const HeroAvatar({Key key, @required this.imageUrl, this.size = 100})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
        ));
  }
}
