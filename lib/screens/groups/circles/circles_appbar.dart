import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/backend/repositories/onboarding_repo.dart';
import 'package:junto_beta_mobile/hive_keys.dart';
import 'package:junto_beta_mobile/screens/groups/circles/bloc/circle_bloc.dart';
import 'package:junto_beta_mobile/widgets/tutorial/described_feature_overlay.dart';
import 'package:junto_beta_mobile/widgets/tutorial/information_icon.dart';
import 'package:junto_beta_mobile/widgets/tutorial/overlay_info_icon.dart';
import 'package:junto_beta_mobile/widgets/appbar/appbar_logo.dart';
import 'package:junto_beta_mobile/widgets/appbar/notifications_lunar_icon.dart';
import 'package:junto_beta_mobile/app/themes_provider.dart';
import 'package:junto_beta_mobile/screens/groups/circles/create_sphere/create_sphere.dart';
import 'package:provider/provider.dart';

class CirclesAppbar extends StatefulWidget {
  const CirclesAppbar({
    this.currentIndex,
    this.changePageView,
  });
  final int currentIndex;
  final Function changePageView;
  @override
  _CirclesAppbarState createState() => _CirclesAppbarState();
}

class _CirclesAppbarState extends State<CirclesAppbar> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = Provider.of<OnBoardingRepo>(context);
    if (repo.showGroupTutorial) {
      repo.setViewed(HiveKeys.kGroupTutorial, false);
    }
  }

  void showTutorial() {
    FeatureDiscovery.clearPreferences(context, <String>{
      'groups_info_id',
    });
    FeatureDiscovery.discoverFeatures(
      context,
      const <String>{
        'groups_info_id',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JuntoThemesProvider>(builder: (context, theme, child) {
      return BlocBuilder<CircleBloc, CircleState>(builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * .1 + 50,
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * .1,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(
                  left: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: .75,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.bottomLeft,
                      color: Colors.transparent,
                      child: AppbarLogo(theme: theme),
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          NotificationsLunarIcon(),
                          GestureDetector(
                            onTap: showTutorial,
                            child: JuntoDescribedFeatureOverlay(
                              icon: OverlayInfoIcon(),
                              featureId: 'groups_info_id',
                              isLastFeature: true,
                              title:
                                  'Groups are public, private, or secret communities you can create on Junto. We will open this layer soon.',
                              learnMore: false,
                              child: JuntoInfoIcon(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            widget.changePageView(0);
                          },
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.only(
                              right: 20,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Text(
                              'CIRCLES',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.currentIndex == 0
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.changePageView(1);
                          },
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: Text(
                              'REQUESTS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.currentIndex == 1
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute<void>(
                            builder: (BuildContext context) => CreateSphere(),
                          ),
                        ).then((value) =>
                            context.bloc<CircleBloc>().add(FetchMyCircle()));
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.transparent,
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.add,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    });
  }
}
