import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/backend/repositories.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/member/member.dart';
import 'package:junto_beta_mobile/utils/junto_overlay.dart';
import 'package:junto_beta_mobile/widgets/avatars/member_avatar.dart';
import 'package:junto_beta_mobile/screens/notifications/notifications_handler.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:provider/provider.dart';

class PackRequest extends StatelessWidget {
  const PackRequest({
    this.pack,
    this.refreshGroups,
    @required this.userProfile,
  });

  final Group pack;
  final Function refreshGroups;
  final UserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        JuntoLoader.showLoader(context);
        try {
          JuntoLoader.hide();
          Navigator.push(
            context,
            CupertinoPageRoute<dynamic>(
              builder: (BuildContext context) =>
                  JuntoMember(profile: userProfile),
            ),
          );
        } catch (e, s) {
          logger.logException(e, s);
          JuntoLoader.hide();
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: <Widget>[
            MemberAvatar(
              diameter: 45,
              profilePicture: userProfile.profilePicture,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: .5,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userProfile.username,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            userProfile.name,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            JuntoLoader.showLoader(context);
                            try {
                              await Provider.of<GroupRepo>(context,
                                      listen: false)
                                  .respondToGroupRequest(pack.address, true);
                              await Provider.of<NotificationsHandler>(context,
                                      listen: false)
                                  .fetchNotifications();
                              refreshGroups();
                              JuntoLoader.hide();
                            } catch (e, s) {
                              JuntoLoader.hide();
                              logger.logException(e, s);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1.2,
                              ),
                            ),
                            height: 38,
                            width: 38,
                            child: Icon(
                              CustomIcons.check,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            JuntoLoader.showLoader(context);
                            try {
                              await Provider.of<GroupRepo>(context,
                                      listen: false)
                                  .respondToGroupRequest(pack.address, false);
                              await Provider.of<NotificationsHandler>(context,
                                      listen: false)
                                  .fetchNotifications();
                              refreshGroups();
                              JuntoLoader.hide();
                            } catch (e, s) {
                              logger.logException(e, s);
                              JuntoLoader.hide();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1.2,
                              ),
                            ),
                            height: 38,
                            width: 38,
                            child: Icon(
                              CustomIcons.cancel,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
