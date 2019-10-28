import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:junto_beta_mobile/app/styles.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/member/member.dart';
import 'package:junto_beta_mobile/widgets/expression_action_items.dart';

class ExpressionOpenTop extends StatelessWidget {
  const ExpressionOpenTop({Key key, this.expression}) : super(key: key);

  final CentralizedExpressionResponse expression;

  @override
  Widget build(BuildContext context) {
    final String username = expression.creator.username;
    final String firstName = expression.creator.firstName;
    final String lastName = expression.creator.lastName;

    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute<dynamic>(
                  builder: (BuildContext context) => JuntoMember(
                    profile: UserProfile(
                      address: '',
                      firstName: firstName,
                      lastName: lastName,
                      bio: 'This is a test',
                      profilePicture:
                          'assets/images/junto-mobile__placeholder--member.png',
                      username: 'Gmail',
                      verified: false,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.white,
              child: Row(children: <Widget>[
                // profile picture
                ClipOval(
                  child: Image.asset(
                    'assets/images/junto-mobile__placeholder--member.png',
                    height: 45.0,
                    width: 45.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),

                // profile name and handle
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        username ?? '',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        firstName + ' ' + lastName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) => ExpressionActionItems(),
              );
            },
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(5),
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xff777777),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
