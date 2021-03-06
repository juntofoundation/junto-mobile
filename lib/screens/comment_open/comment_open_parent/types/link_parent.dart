import 'package:flutter/material.dart';
import 'package:embedly_preview/embedly_preview.dart';
import 'package:embedly_preview/theme/embedly_theme_data.dart';
import 'package:embedly_preview/theme/theme.dart';
import 'package:junto_beta_mobile/widgets/custom_parsed_text.dart';

class LinkParent extends StatelessWidget {
  const LinkParent({this.expression});

  final dynamic expression;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expression.expressionData.title.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: SelectableText(
                expression.expressionData.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (expression.expressionData.caption.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: CustomParsedText(
                expression.expressionData.caption,
                selectable: false,
                defaultTextStyle: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                ),
                mentionTextStyle: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 17,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (expression.expressionData.data != null)
            OEmbedWidget(
              data: expression.expressionData.data,
              expanded: true,
              theme: EmbedlyThemeData(
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).backgroundColor,
                headingText: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                subheadingText: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                elevation: 0.0,
              ),
            )
          else
            Container(
              child: SelectableText(
                expression.expressionData.url,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
