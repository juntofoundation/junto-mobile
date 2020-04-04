import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/screens/collective/perspectives/expression_feed.dart';
import 'package:junto_beta_mobile/screens/notifications/notifications.dart';
import 'package:junto_beta_mobile/widgets/tutorial/information_icon.dart';
import 'package:junto_beta_mobile/widgets/tutorial/described_feature_overlay.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:provider/provider.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/widgets/avatars/member_avatar.dart';
import 'package:junto_beta_mobile/screens/packs/pack_open/pack_open_action_items.dart';
import 'package:junto_beta_mobile/screens/packs/pack_open/pack_name.dart';

typedef SwitchColumnView = Future<void> Function(ExpressionFeedLayout layout);

// Junto app bar used in collective screen.
class PackOpenAppbar extends SliverPersistentHeaderDelegate {
  PackOpenAppbar({
    @required this.expandedHeight,
    @required this.pack,
    @required this.tabs,
  });

  final double expandedHeight;
  final Group pack;
  final List<String> tabs;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Consumer<UserDataProvider>(
      builder: (context, user, child) {
        final userProfile = user.userProfile;
        return Container(
          height: MediaQuery.of(context).size.height * .1 + 50,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * .1,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                    bottom: 10,
                    right: 10,
                    left: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: .75,
                      ),
                    ),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      userProfile != null
                          ? Flexible(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  MemberAvatar(
                                    diameter: 28,
                                    profilePicture:
                                        pack.address == userProfile.pack.address
                                            ? userProfile.user.profilePicture
                                            : pack.creator['profile_picture'],
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      pack.address == userProfile.pack.address
                                          ? 'My Pack'
                                          : pack.groupData.name,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                      maxLines: 1,
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => NotificationsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 38,
                              color: Colors.transparent,
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                CustomIcons.moon,
                                size: 22,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          userProfile != null &&
                                  userProfile.pack.address != pack.address
                              ? GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      builder: (BuildContext context) =>
                                          PackOpenActionItems(
                                        pack: pack,
                                        userProfile: userProfile,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 38,
                                    alignment: Alignment.centerRight,
                                    color: Colors.transparent,
                                    child: Icon(
                                      CustomIcons.morevertical,
                                      size: 22,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          GestureDetector(
                            onTap: () {
                              FeatureDiscovery.clearPreferences(
                                  context, <String>{
                                'packs_info_id',
                                // 'collective_filter_id',
                                'packs_toggle_id',
                              });
                              FeatureDiscovery.discoverFeatures(
                                context,
                                const <String>{
                                  'packs_info_id',
                                  // 'collective_filter_id',
                                  'packs_toggle_id',
                                },
                              );
                            },
                            child: JuntoDescribedFeatureOverlay(
                              icon: Icon(
                                CustomIcons.newpacks,
                                size: 33,
                                color: Colors.white,
                              ),
                              featureId: 'packs_info_id',
                              title:
                                  'This is your Pack. It displays all of the publicly shared posts from you and the people you choose to have in you pack. There is also a section where you can share things privately to just your pack members.',
                              learnMore: true,
                              learnMoreText:
                                  'Your Pack is your community of people that best represent who you are and evoke the the most unfiltered version of you. Your pack will display the public expressions of all your pack members and all the posts you choose to share privately to just your pack members. In this light, you are the common thread between all of your pack members, facilitating a more organic means for your pack members to discover new people and information through their mutual connection - you. Anyone who belongs to your pack can see your pack feed, and vice versa.',
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: JuntoInfoIcon(),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: .75,
                    ),
                  ),
                ),
                child: TabBar(
                  labelPadding: const EdgeInsets.all(0),
                  isScrollable: true,
                  labelColor: Theme.of(context).primaryColorDark,
                  unselectedLabelColor: Theme.of(context).primaryColorLight,
                  labelStyle: Theme.of(context).textTheme.subtitle1,
                  indicatorWeight: 0.0001,
                  tabs: <Widget>[
                    for (String name in tabs) PackName(name: name),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => expandedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
