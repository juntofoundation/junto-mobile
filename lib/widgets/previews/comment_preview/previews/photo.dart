import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:junto_beta_mobile/widgets/custom_parsed_text.dart';
import 'package:junto_beta_mobile/widgets/image_wrapper.dart';

// Displays the given [image] and [imageCaption]
class PhotoPreview extends StatelessWidget {
  const PhotoPreview({
    Key key,
    @required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: ImageWrapper(
            imageUrl: comment.expressionData.thumbnail600,
            placeholder: (BuildContext context, String _) {
              return Container(
                color: Theme.of(context).dividerColor,
                height: MediaQuery.of(context).size.width / 3 * 2,
                width: MediaQuery.of(context).size.width,
              );
            },
            fit: BoxFit.cover,
          ),
        ),
        if (comment.expressionData.caption.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            child: CustomParsedText(
              comment.expressionData.caption,
              overflow: TextOverflow.ellipsis,
              defaultTextStyle: Theme.of(context).textTheme.caption,
              mentionTextStyle: Theme.of(context).textTheme.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColorDark,
                  ),
            ),
          ),
      ],
    );
  }
}
