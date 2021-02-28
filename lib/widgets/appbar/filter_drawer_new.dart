import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/filters/bloc/channel_filtering_bloc.dart';
import 'package:junto_beta_mobile/models/expression_query_params.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/widgets/drawer/channel_preview.dart';
import 'package:junto_beta_mobile/widgets/drawer/widgets/widgets.dart';
import 'package:provider/provider.dart';

class FilterDrawerNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FilterDrawerNewState();
  }
}

class FilterDrawerNewState extends State<FilterDrawerNew> {
  FocusNode focusNode;
  double channelsContainerHeight = 200.0;
  TextEditingController textEditingController;

  animateChannelsContainer() {
    if (focusNode.hasFocus) {
      setState(() {
        channelsContainerHeight = 500.0;
      });
    } else {
      setState(() {
        channelsContainerHeight = 200.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()..addListener(animateChannelsContainer);

    textEditingController = TextEditingController()
      ..addListener(_onSearchChanged);
  }

  Future<void> _onSearchChanged() async {
    context
        .bloc<ChannelFilteringBloc>()
        .add(FilterQueryUpdated(textEditingController.text));
  }

  @override
  void dispose() {
    textEditingController.removeListener(_onSearchChanged);
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelFilteringBloc, ChannelFilteringState>(
        builder: (BuildContext context, ChannelFilteringState state) {
      List<Channel> filteredList = [];

      if (state is ChannelsPopulatedState) {
        final selectedSet = state.selectedChannel != null
            ? state.selectedChannel.map((e) => e.name).toList()
            : [];
        filteredList = state.channels
            .where((element) => !selectedSet.contains(element.name))
            .toList();
      }
      return Container(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * .9,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 15,
                  bottom: 15,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.translate(
                        offset: Offset(-10, 0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 38,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ClipOval(
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  stops: const <double>[0.3, 0.9],
                                  colors: <Color>[
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/junto-mobile__custom-filter.png',
                                    height: 15,
                                    color: Colors.white,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipOval(
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  stops: const <double>[0.3, 0.9],
                                  colors: <Color>[
                                    Theme.of(context).dividerColor,
                                    Theme.of(context).dividerColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/junto-mobile__perspective--white.png',
                                    height: 15,
                                    color: Theme.of(context).primaryColorDark,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),

              // Filter Pages
              Expanded(
                child: PageView(
                  children: [
                    // Custom Filter (starting with channels in V1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 25),
                        AnimatedContainer(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: channelsContainerHeight,
                          duration: Duration(milliseconds: 200),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'Channels',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                FilterDrawerTextField(
                                  textEditingController: textEditingController,
                                  focusNode: focusNode,
                                ),
                                if (state is ChannelsPopulatedState &&
                                    state.selectedChannel != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: Row(
                                      children: [
                                        ...state.selectedChannel
                                            .map((e) => SelectedChannelChip(
                                                channel: e.name,
                                                onTap: () {
                                                  context
                                                      .bloc<
                                                          ChannelFilteringBloc>()
                                                      .add(
                                                        FilterSelected(
                                                          state.selectedChannel
                                                              .where((element) =>
                                                                  element
                                                                      .name !=
                                                                  e.name)
                                                              .toList(),
                                                          ExpressionContextType
                                                              .Collective,
                                                        ),
                                                      );
                                                }))
                                            .toList(),
                                      ],
                                    ),
                                  ),
                                if (state is ChannelsPopulatedState)
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(0),
                                      itemCount: filteredList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final Channel item =
                                            filteredList[index];
                                        if (item != null) {
                                          return InkWell(
                                            onTap: () {
                                              context
                                                  .bloc<ChannelFilteringBloc>()
                                                  .add(FilterSelected(
                                                    [
                                                      if (state
                                                              .selectedChannel !=
                                                          null)
                                                        ...state
                                                            .selectedChannel,
                                                      item
                                                    ],
                                                    ExpressionContextType
                                                        .Collective,
                                                  ));
                                              textEditingController.clear();
                                              // Navigator.pop(context);
                                            },
                                            child: FilterDrawerChannelPreview(
                                              channel: item,
                                            ),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }
}
