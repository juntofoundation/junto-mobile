import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:share/share.dart';

class JuntoInviteAppBar extends StatelessWidget {
  final UserData userProfile;

  const JuntoInviteAppBar({Key key, this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).backgroundColor,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
      elevation: 0,
      titleSpacing: 0,
      brightness: Theme.of(context).brightness,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                width: 42,
                height: 42,
                alignment: Alignment.centerLeft,
                color: Colors.transparent,
                child: Icon(
                  CustomIcons.back,
                  color: Theme.of(context).primaryColorDark,
                  size: 17,
                ),
              ),
            ),
            Text(
              'Build Your Pack',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            GestureDetector(
              onTap: () async {
                Share.share(
                  "Hey! I started using this more authentic and nonprofit social media platform called Junto. Here's an invite to their closed alpha - you can connect with me @${userProfile.user.username}. https://junto.typeform.com/to/k7BUVK8f",
                  subject: 'Check Junto out!',
                );
              },
              child: Container(
                width: 42,
                child: Image.asset(
                  'assets/images/junto-mobile__external-link.png',
                  height: 17,
                  color: Theme.of(context).primaryColor,
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
                color: Theme.of(context).dividerColor,
                width: .75,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
