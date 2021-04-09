import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/models/group_model.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/groups/circles/bloc/circle_bloc.dart';
import 'package:junto_beta_mobile/widgets/previews/member_preview/member_preview.dart';
import 'package:junto_beta_mobile/widgets/progress_indicator.dart';
import 'package:junto_beta_mobile/widgets/tab_bar/tab_bar.dart';

import 'sphere_add_members.dart';

class SphereOpenMembers extends StatefulWidget {
  const SphereOpenMembers({
    Key key,
    @required this.group,
    this.relationToGroup,
  }) : super(key: key);

  final Group group;
  final Map<String, dynamic> relationToGroup;

  @override
  _SphereOpenMembersState createState() => _SphereOpenMembersState();
}

class _SphereOpenMembersState extends State<SphereOpenMembers>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = <String>['Facilitators', 'Members'];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CircleBloc, CircleState>(
      builder: (context, state) {
        if (state is CircleLoaded) {
          return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(45),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  brightness: Theme.of(context).brightness,
                  elevation: 0,
                  titleSpacing: 0,
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            color: Colors.transparent,
                            width: 42,
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              CustomIcons.back,
                              color: Theme.of(context).primaryColorDark,
                              size: 17,
                            ),
                          ),
                        ),
                        if (widget.relationToGroup != null &&
                            ((widget.relationToGroup['creator'] ||
                                    widget.relationToGroup['facilitator']) ||
                                (widget.relationToGroup['member'])))
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute<dynamic>(
                                  builder: (BuildContext context) =>
                                      SphereAddMembers(
                                    group: widget.group,
                                    permission: 'Member',
                                    members: state.members,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                CustomIcons.add,
                                color: Theme.of(context).primaryColorDark,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(.75),
                    child: Container(
                      height: .75,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: .75,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: DefaultTabController(
                length: _tabs.length,
                child: NestedScrollView(
                  physics: const ClampingScrollPhysics(),
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverPersistentHeader(
                        delegate: JuntoAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelPadding: const EdgeInsets.all(0),
                            isScrollable: true,
                            labelColor: Theme.of(context).primaryColorDark,
                            unselectedLabelColor:
                                Theme.of(context).primaryColorLight,
                            labelStyle: Theme.of(context).textTheme.subtitle1,
                            indicatorWeight: 0.0001,
                            tabs: <Widget>[
                              for (String name in _tabs)
                                Container(
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    right: 20,
                                  ),
                                  child: Text(
                                    name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // Circle Facilitators
                      CircleFacilitators(
                          creator: state.creator?.user,
                          users: state.members ?? []),
                      // All Circle Members
                      CircleMembers(
                        creator: state.creator?.user,
                        users: state.members ?? [],
                        group: widget.group,
                      ),
                    ],
                  ),
                ),
              ));
        }
        return Expanded(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0.0, -50),
              child: JuntoProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class CircleFacilitators extends StatelessWidget {
  const CircleFacilitators({this.creator, this.users});

  final UserProfile creator;
  final List<Users> users;
  @override
  Widget build(BuildContext context) {
    // Circle Facilitators (Admins)
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              if (creator != null) MemberPreview(profile: creator),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  if (users[index].permissionLevel == 'Admin') {
                    return MemberPreview(
                      profile: users[index].user,
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CircleMembers extends StatefulWidget {
  const CircleMembers({
    this.creator,
    this.users,
    this.group,
  });

  final UserProfile creator;
  final List<Users> users;
  final Group group;

  @override
  _CircleMembersState createState() => _CircleMembersState();
}

class _CircleMembersState extends State<CircleMembers> {
  double position = 0.0;

  double sensitivityFactor = 20.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // All Circle Members
    final list = [
      if (widget.creator != null) widget.creator,
      ...widget.users.map((e) => e.user).toList()
    ];

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        final metrics = notification.metrics;
        double scrollPercent = (metrics.pixels / metrics.maxScrollExtent) * 100;

        if (notification.metrics.pixels - position >= sensitivityFactor) {
          position = notification.metrics.pixels;
          if (scrollPercent.toInt() == 80) {
            context.read<CircleBloc>().add(
                LoadCircleMembersMore(sphereAddress: widget.group.address));

            return true;
          }
        }

        if (position - notification.metrics.pixels >= sensitivityFactor) {
          position = notification.metrics.pixels;
        }

        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        physics: NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return MemberPreview(
            profile: list[index],
          );
        },
      ),
    );
  }
}
