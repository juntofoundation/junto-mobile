import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Displays the given [image] and [imageCaption]
class PhotoPreview extends StatelessWidget {
  const PhotoPreview({
    Key key,
    @required this.expression,
  }) : super(key: key);

  final CentralizedExpressionResponse expression;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: MediaQuery.of(context).size.height * .4,
        width: MediaQuery.of(context).size.width,
        child: Hero(
          tag: 'photo_preview-' + expression.address,
          child: RepaintBoundary(
            child: CachedNetworkImage(
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 200),
              imageUrl: expression.expressionData.image,
              placeholder: (BuildContext context, String _) {
                return Container(color: Theme.of(context).dividerColor);
              },
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}