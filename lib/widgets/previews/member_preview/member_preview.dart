import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/utils/utils.dart';
import 'package:junto_beta_mobile/widgets/avatars/member_avatar.dart';

/// Render a list tile showing the user's profile image.
/// Contains a callback [onUserTap] triggered when the user is selected.
/// If this value is not specified and left null, the user will be redirected to
/// the user "Den".
class MemberPreview extends StatelessWidget with MemberValidation {
  const MemberPreview({
    Key key,
    this.profile,
    this.onUserTap,
    this.showMore = false,
    this.onShowMore,
  }) : super(key: key);

  final UserProfile profile;
  final VoidCallback onUserTap;
  final bool showMore;
  final Function onShowMore;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onUserTap != null) {
          onUserTap();
        } else {
          if (await isHostUser(profile)) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
          showUserDen(context, profile);
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: <Widget>[
            MemberAvatar(
              diameter: 45,
              profilePicture: profile.profilePicture,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: .5,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.username,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(profile.name,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyText1)
                  ],
                ),
              ),
            ),
            if (showMore)
              IconButton(
                onPressed: onShowMore,
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              )
          ],
        ),
      ),
    );
  }
}
