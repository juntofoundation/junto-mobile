import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_beta_mobile/app/expressions.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/backend/repositories/expression_repo.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/create/create_actions/create_actions.dart';
import 'package:junto_beta_mobile/screens/create/create_actions/create_comment_actions.dart';
import 'package:junto_beta_mobile/screens/create/create_actions/widgets/create_expression_scaffold.dart';
import 'package:junto_beta_mobile/screens/global_search/search_bloc/search_bloc.dart';
import 'package:junto_beta_mobile/screens/global_search/search_bloc/search_event.dart';
import 'package:junto_beta_mobile/screens/global_search/search_bloc/search_state.dart';
import 'package:junto_beta_mobile/utils/utils.dart';
import 'package:junto_beta_mobile/widgets/dialogs/single_action_dialog.dart';
import 'package:junto_beta_mobile/widgets/mentions/channel_search_list.dart';
import 'package:junto_beta_mobile/widgets/mentions/mentions_search_list.dart';
import 'package:provider/provider.dart';

class NewCreate extends StatefulWidget {
  const NewCreate({Key key, this.expressionContext, this.address})
      : super(key: key);
  final ExpressionContext expressionContext;
  final String address;

  @override
  State<StatefulWidget> createState() {
    return NewCreateState();
  }
}

class NewCreateState extends State<NewCreate> with CreateExpressionHelpers {
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _bodyFocus = FocusNode();
  bool _showBottomNav = true;
  TextEditingController _titleController;
  GlobalKey<FlutterMentionsState> mentionKey =
      GlobalKey<FlutterMentionsState>();
  bool _showList = false;
  List<Map<String, dynamic>> addedmentions = [];
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> completeUserList = [];
  List<Map<String, dynamic>> addedChannels = [];
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> completeChannelsList = [];
  ListType listType = ListType.empty;

  void toggleBottomNav() {
    setState(() {
      _showBottomNav = !_showBottomNav;
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _titleFocus.addListener(toggleBottomNav);
    _bodyFocus.addListener(toggleBottomNav);
  }

  /// Creates a [LongFormExpression] from the given data entered
  /// by the user.
  LongFormExpression createExpression() {
    final markupText = mentionKey.currentState.controller.markupText;

    return LongFormExpression(
      title: _titleController.value.text.trim(),
      body: markupText.trim(),
    );
  }

  bool expressionHasData() {
    final body = mentionKey.currentState.controller.text.trim();
    final title = _titleController.value.text.trim();
    // Body cannot be empty if the title is also empty
    if (title.isEmpty) {
      return body.isNotEmpty;
    }
    // Body can be empty if the title is not empty
    if (title.isNotEmpty) {
      return true;
    }
    // Title can be empty if the title is not empty
    if (body.isNotEmpty) {
      return true;
    }
    return false;
  }

  void _onNext() {
    if (expressionHasData() == true) {
      final LongFormExpression expression = createExpression();
      final mentions = getMentionUserId(expression.body);
      final channels = getChannelsId(expression.body);

      if (channels.length > 5) {
        showDialog(
          context: context,
          builder: (BuildContext context) => SingleActionDialog(
            context: context,
            dialogText:
                'You can only add five channels. Please reduce the number of channels you have before continuing.',
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) {
              if (widget.expressionContext == ExpressionContext.Comment) {
                return CreateCommentActions(
                  expression: expression,
                  address: widget.address,
                  expressionType: ExpressionType.dynamic,
                );
              } else {
                return CreateActions(
                  expressionType: ExpressionType.dynamic,
                  address: widget.address,
                  expressionContext: widget.expressionContext,
                  expression: expression,
                  mentions: mentions,
                  channels: channels,
                );
              }
            },
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => const SingleActionDialog(
            dialogText: 'Please fill in the required fields.'),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
  }

  void toggleSearch(bool value) {
    if (value != _showList) {
      setState(() {
        _showList = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return SearchBloc(Provider.of<SearchRepo>(context, listen: false));
      },
      child: CreateExpressionScaffold(
        showBottomNav: _showBottomNav,
        expressionType: ExpressionType.dynamic,
        onNext: _onNext,
        expressionHasData: expressionHasData,
        child: Container(
          child: BlocConsumer<SearchBloc, SearchState>(
            buildWhen: (prev, cur) {
              return !(cur is LoadingSearchState ||
                  cur is LoadingSearchChannelState);
            },
            listener: (context, state) {
              if (!(state is LoadingSearchState) &&
                  (state is SearchUserState)) {
                final eq = DeepCollectionEquality.unordered().equals;

                final _users = getUserList(state, []);

                final isEqual = eq(users, _users);

                if (!isEqual) {
                  setState(() {
                    users = _users;

                    listType = ListType.mention;

                    completeUserList =
                        generateFinalList(completeUserList, _users);
                  });
                }
              }

              if (!(state is LoadingSearchChannelState) &&
                  (state is SearchChannelState)) {
                final eq = DeepCollectionEquality.unordered().equals;

                final _channels = getChannelsList(state, []);

                final isEqual = eq(channels, _channels);

                if (!isEqual) {
                  setState(() {
                    channels = _channels;

                    listType = ListType.channels;

                    completeChannelsList =
                        generateFinalList(completeChannelsList, _channels);
                  });
                }
              }
            },
            builder: (context, state) {
              return Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        focusNode: _titleFocus,
                        buildCounter: (
                          BuildContext context, {
                          int currentLength,
                          int maxLength,
                          bool isFocused,
                        }) =>
                            null,
                        controller: _titleController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          hintStyle:
                              Theme.of(context).textTheme.headline6.copyWith(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                        ),
                        cursorColor: Theme.of(context).primaryColor,
                        cursorWidth: 2,
                        maxLines: null,
                        maxLength: 140,
                        style: Theme.of(context).textTheme.headline6,
                        keyboardAppearance: Theme.of(context).brightness,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: FlutterMentions(
                              key: mentionKey,
                              suggestionPosition: SuggestionPosition.Bottom,
                              minLines: 1,
                              maxLines: 20,
                              keyboardAppearance: Theme.of(context).brightness,
                              cursorWidth: 2,
                              focusNode: _bodyFocus,
                              textInputAction: TextInputAction.newline,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(fontSize: 17),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Write here...',
                              ),
                              onSearchChanged: (String trigger, String value) {
                                if (value.isNotEmpty && _showList) {
                                  final channel = trigger == '#';

                                  if (!channel) {
                                    context
                                        .bloc<SearchBloc>()
                                        .add(SearchingEvent(
                                          value,
                                          QueryUserBy.BOTH,
                                        ));
                                  } else {
                                    context
                                        .bloc<SearchBloc>()
                                        .add(SearchingChannelEvent(value));
                                  }
                                } else {
                                  setState(() {
                                    users = [];
                                    channels = [];
                                    listType = ListType.empty;
                                    _showList = false;
                                  });
                                }
                              },
                              onSuggestionVisibleChanged: toggleSearch,
                              hideSuggestionList: true,
                              mentions: getMention(
                                context,
                                [...addedmentions, ...completeUserList],
                                [...addedChannels, ...completeChannelsList],
                              ),
                            ),
                          ),
                          if (_showList &&
                              _bodyFocus.hasFocus &&
                              listType == ListType.mention)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: MentionsSearchList(
                                userList: users,
                                onMentionAdd: (index) {
                                  mentionKey.currentState
                                      .addMention(users[index]);

                                  if (addedmentions.indexWhere((element) =>
                                          element['id'] ==
                                          users[index]['id']) ==
                                      -1) {
                                    addedmentions = [
                                      ...addedmentions,
                                      users[index]
                                    ];
                                  }

                                  setState(() {
                                    _showList = false;
                                    users = [];
                                  });
                                },
                              ),
                            ),
                          if (_showList &&
                              _bodyFocus.hasFocus &&
                              listType == ListType.channels)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: ChannelsSearchList(
                                channels: channels,
                                onChannelAdd: (index) {
                                  mentionKey.currentState
                                      .addMention(channels[index]);

                                  if (addedChannels.indexWhere((element) =>
                                          element['id'] ==
                                          channels[index]['id']) ==
                                      -1) {
                                    addedChannels = [
                                      ...addedChannels,
                                      channels[index]
                                    ];
                                  }

                                  setState(() {
                                    _showList = false;
                                    channels = [];
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}