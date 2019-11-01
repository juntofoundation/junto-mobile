import 'dart:async' show Timer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:junto_beta_mobile/api.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:junto_beta_mobile/screens/expression_open/expression_open_appbar.dart';
import 'package:junto_beta_mobile/screens/expression_open/expression_open_bottom.dart';
import 'package:junto_beta_mobile/screens/expression_open/expression_open_top.dart';
import 'package:junto_beta_mobile/screens/expression_open/expressions/event_open.dart';
import 'package:junto_beta_mobile/screens/expression_open/expressions/longform_open.dart';
import 'package:junto_beta_mobile/screens/expression_open/expressions/photo_open.dart';
import 'package:junto_beta_mobile/app/palette.dart';
import 'package:junto_beta_mobile/app/styles.dart';
import 'package:junto_beta_mobile/screens/expression_open/expressions/shortform_open.dart';
import 'package:junto_beta_mobile/widgets/comment_preview/comment_preview.dart';

class ExpressionOpen extends StatefulWidget {
  const ExpressionOpen(this.expression);

  final CentralizedExpressionResponse expression;

  @override
  State<StatefulWidget> createState() {
    return ExpressionOpenState();
  }
}

class ExpressionOpenState extends State<ExpressionOpen> {
  //  whether the comments are visible or not
  bool commentsVisible = false;

  // privacy layer of the comment
  String _commentPrivacy = 'public';

  // Create a controller for the comment text field
  TextEditingController commentController;

  // Boolean that signals whether the member can create a comment or not
  ValueNotifier<bool> createComment = ValueNotifier<bool>(false);

  /// [FocusNode] passed to Comments [TextField]
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Builds an expression for the given type. IE: Longform or shortform
  Widget _buildExpression() {
    final String expressionType = widget.expression.type;
    if (expressionType == 'LongForm') {
      return LongformOpen(widget.expression);
    } else if (expressionType == 'ShortForm') {
      return ShortformOpen(widget.expression);
    } else if (expressionType == 'PhotoForm') {
      return PhotoOpen(widget.expression);
    } else if (expressionType == 'EventForm') {
      return EventOpen(widget.expression);
    } else {
      print(widget.expression.type);

      return const Text('no expressions!');
    }
  }

  // Swipe down to dismiss keyboard
  void _onDragDown(DragDownDetails details) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Bring the focus back to the TextField
  void _focusTextField() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  // Open modal bottom sheet and refocus TextField after dismissed
  Future<void> _showPrivacyModalSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        color: const Color(0xff737373),
        child: Container(
          height: 240,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  setState(() {
                    _commentPrivacy = 'public';
                  });
                  Navigator.pop(context);
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Public',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Your comment will visible to everyone who can see '
                      'this expression.',
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  setState(() {
                    _commentPrivacy = 'private';
                  });
                  Navigator.pop(context);
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Private',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Your comment will only be visible to the creator of '
                      'this expression.',
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    _focusTextField();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0),
        child: ExpressionOpenAppbar(),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragDown: _onDragDown,
              child: ListView(
                children: <Widget>[
                  ExpressionOpenTop(expression: widget.expression),
                  _buildExpression(),
                  ExpressionOpenBottom(widget.expression),
                  GestureDetector(
                    onTap: () {
                      if (commentsVisible == false) {
                        setState(() {
                          commentsVisible = true;
                        });
                      } else if (commentsVisible == true) {
                        setState(() {
                          commentsVisible = false;
                        });
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xffeeeeee), width: .75),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Row(
                        children: <Widget>[
                          const Text(
                            'Show replies (9)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 5),
                          commentsVisible == false
                              ? const Icon(Icons.keyboard_arrow_down, size: 17)
                              : const Icon(Icons.keyboard_arrow_up, size: 17)
                        ],
                      ),
                    ),
                  ),
                  commentsVisible
                      ? ListView(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          children: const <Widget>[
                            CommentPreview(
                              commentText:
                                  'Hey there! This is what a comment preview looks like.',
                            ),
                            CommentPreview(
                              commentText:
                                  'All comments are hidden initially so the viewer can have complete independence of thought while viewing expressions.',
                            ),
                            CommentPreview(
                              commentText:
                                  'In Junto, comments are treated like expressions. You can resonate them or reply to a comment (nested comments). This is quite complex so we are tacklign this once the rest of the core functionality is finished.',
                            ),
                            CommentPreview(
                              commentText:
                                  "And yes, I know what you're thinking. 'Comments??' We need a new semantic!",
                            ),
                            CommentPreview(
                              commentText:
                                  "Let's leave that to Fri to discuss :)",
                            ),
                            CommentPreview(
                              commentText: 'Much',
                            ),
                            CommentPreview(
                              commentText: 'love <3',
                            ),
                          ],
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
          _BottomCommentBar(
            canCreateComment: createComment,
            commentController: commentController,
            commentPrivacy: _commentPrivacy,
            focusNode: _focusNode,
            onTextChange: (String value) {
              if (value == '') {
                createComment.value = false;
              } else if (value != '') {
                createComment.value = true;
              }
            },
            showPrivacySheet: () async {
              await _showPrivacyModalSheet();
            },
          ),
        ],
      ),
    );
  }
}

class _BottomCommentBar extends StatefulWidget {
  const _BottomCommentBar({
    Key key,
    @required this.focusNode,
    @required this.onTextChange,
    @required this.commentController,
    @required this.canCreateComment,
    @required this.showPrivacySheet,
    @required this.commentPrivacy,
  }) : super(key: key);
  final FocusNode focusNode;
  final ValueChanged<String> onTextChange;
  final TextEditingController commentController;
  final ValueNotifier<bool> canCreateComment;
  final VoidCallback showPrivacySheet;
  final String commentPrivacy;
  @override
  _BottomCommentBarState createState() => _BottomCommentBarState();
}

class _BottomCommentBarState extends State<_BottomCommentBar> {
  Widget _createCommentIcon(bool createComment) {
    if (createComment == true) {
      return GestureDetector(
        onTap: () {},
        child: const Icon(
          Icons.send,
          size: 20,
          color: JuntoPalette.juntoPrimary,
        ),
      );
    } else {
      return const Icon(
        Icons.send,
        size: 20,
        color: Color(0xff999999),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: JuntoStyles.horizontalPadding,
          vertical: 5,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 1,
              color: JuntoPalette.juntoFade,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/junto-mobile__eric.png',
                            height: 36.0,
                            width: 36.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xfff9f9f9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: widget.focusNode.hasFocus
                            ? MediaQuery.of(context).size.width - 100
                            : MediaQuery.of(context).size.width - 66,
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 140,
                              child: TextField(
                                focusNode: widget.focusNode,
                                controller: widget.commentController,
                                onChanged: widget.onTextChange,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  // hintText: 'reply',
                                ),
                                maxLines: null,
                                cursorColor: JuntoPalette.juntoGrey,
                                cursorWidth: 2,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: JuntoPalette.juntoGrey,
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                widget.focusNode.hasFocus
                    ? _createCommentIcon(widget.canCreateComment.value)
                    : const SizedBox()
              ],
            ),
            widget.focusNode.hasFocus
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: widget.showPrivacySheet,
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  widget.commentPrivacy,
                                  style: const TextStyle(
                                    color: Color(0xff333333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 14)
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xff737373),
                              builder: (BuildContext context) => _GiphyPanel(
                                onGifSelected: (String selected) {
                                  print(selected);
                                },
                              ),
                            );
                          },
                          child: const Text('Insert Gif 🤓'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class _GiphyPanel extends StatefulWidget {
  const _GiphyPanel({Key key, @required this.onGifSelected}) : super(key: key);
  final ValueChanged<String> onGifSelected;

  @override
  _GiphyPanelState createState() => _GiphyPanelState();
}

class _GiphyPanelState extends State<_GiphyPanel> {
  final GiphyClient client = GiphyClient(apiKey: kGiphyApi);
  GiphyCollection gifs;
  Timer _searchTimer;
  final ValueNotifier<String> _query = ValueNotifier<String>(null);

  /// Waits 500 milliseconds before calling the server with the given query.
  void onTextChange(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _query.value = query;
    });
  }

  /// Returns a collection of trending gifs.
  Future<GiphyCollection> getGifs() async {
    return client.trending();
  }

  /// Returns a collection of gifs that matchs the given [query]
  Future<GiphyCollection> searchGifs(String query) async {
    if (query != null && query.isNotEmpty) {
      final GiphyCollection giphs = await client.search(query);
      return giphs;
    } else {
      return await getGifs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                decoration: const InputDecoration(hintText: 'Search Giphy...'),
                onChanged: onTextChange,
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _query,
            builder: (BuildContext context, String term, _) {
              return FutureBuilder<GiphyCollection>(
                future: searchGifs(term),
                builder: (BuildContext context,
                    AsyncSnapshot<GiphyCollection> snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(child: Container());
                  }
                  if (snapshot.hasError) {
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.red,
                      ),
                    );
                  }
                  final GiphyCollection _data = snapshot.data;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final GiphyGif _gifs = _data.data[index];

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onGifSelected(_gifs.images.downsized.url);
                          },
                          child: CachedNetworkImage(
                            placeholder: (BuildContext context, String _) {
                              return Image.asset(
                                'assets/images/junto-mobile__logo.png',
                              );
                            },
                            imageUrl: _gifs.images.downsized.url,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      childCount: _data.data.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2.0,
                      mainAxisSpacing: 2.0,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
