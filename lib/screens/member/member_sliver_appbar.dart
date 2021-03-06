import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/app_config.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/screens/member/member_relation_button.dart';
import 'package:junto_beta_mobile/widgets/member_widgets/about_item.dart';
import 'package:junto_beta_mobile/widgets/member_widgets/background_photo.dart';
import 'package:junto_beta_mobile/widgets/member_widgets/background_placeholder.dart';
import 'package:junto_beta_mobile/widgets/member_widgets/bio.dart';
import 'package:junto_beta_mobile/widgets/member_widgets/profile_picture_avatar.dart';
import 'package:junto_beta_mobile/widgets/member_widgets/badges_row.dart';

class MemberDenAppbar extends StatefulWidget {
  const MemberDenAppbar(
      {Key key,
      @required this.profile,
      @required this.isConnected,
      @required this.toggleMemberRelationships,
      this.isFollowing})
      : super(key: key);

  final UserProfile profile;
  final bool isConnected;
  final bool isFollowing;
  final Function toggleMemberRelationships;

  @override
  State<StatefulWidget> createState() {
    return MemberDenAppbarState();
  }
}

class MemberDenAppbarState extends State<MemberDenAppbar> {
  final GlobalKey<MemberDenAppbarState> _keyFlexibleSpace =
      GlobalKey<MemberDenAppbarState>();

  UserData _memberProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getFlexibleSpaceSize);
    _memberProfile = UserData(
      user: widget.profile,
      pack: null,
      connectionPerspective: null,
      userPerspective: null,
      privateDen: null,
      publicDen: null,
    );
  }

  double _flexibleHeightSpace;

  void _getFlexibleSpaceSize(_) {
    final RenderBox renderBoxFlexibleSpace =
        _keyFlexibleSpace.currentContext.findRenderObject();
    final Size sizeFlexibleSpace = renderBoxFlexibleSpace.size;
    final double heightFlexibleSpace = sizeFlexibleSpace.height;

    setState(() {
      _flexibleHeightSpace = heightFlexibleSpace;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      brightness: Theme.of(context).brightness,
      primary: false,
      actions: const <Widget>[
        SizedBox(
          height: 0,
          width: 0,
        )
      ],
      backgroundColor: Theme.of(context).backgroundColor,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).dividerColor, width: .75),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _memberProfile.user.backgroundPhoto.isNotEmpty ||
                          _memberProfile.user.backgroundPhoto != ''
                      ? MemberBackgroundPhoto(profile: _memberProfile)
                      : MemberBackgroundPlaceholder(),
                  Container(
                    key: _keyFlexibleSpace,
                    margin: const EdgeInsets.only(top: 35),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  widget.profile.name.trim(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              // Member Badges
                              if (widget.profile.badges != null &&
                                  widget.profile.badges.isNotEmpty)
                                MemberBadgesRow(
                                  badges: widget.profile.badges,
                                ),
                            ]),
                        if (widget.profile.gender[0] != '' &&
                            widget.profile.location[0] != '' &&
                            widget.profile.website[0] != '')
                          const SizedBox(height: 10),
                        AboutItem(
                          item: widget.profile.gender,
                          icon: Icon(
                            CustomIcons.gender,
                            size: 17,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        AboutItem(
                          item: widget.profile.location,
                          icon: Image.asset(
                            'assets/images/junto-mobile__location.png',
                            height: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        AboutItem(
                          isWebsite: true,
                          item: widget.profile.website,
                          icon: Image.asset(
                            'assets/images/junto-mobile__link.png',
                            height: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (_memberProfile != null)
                          MemberBio(
                            profile: _memberProfile,
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_memberProfile != null)
              MemberProfilePictureAvatar(profile: _memberProfile),
            MemberRelationButton(
              toggleMemberRelationships: widget.toggleMemberRelationships,
            ),
          ],
        ),
      ),
      expandedHeight: _flexibleHeightSpace == null
          ? 1000
          : _flexibleHeightSpace + MediaQuery.of(context).size.width / 2 + .75,
      forceElevated: false,
    );
  }
}
