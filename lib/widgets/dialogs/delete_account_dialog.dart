import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:provider/provider.dart';
import 'package:junto_beta_mobile/widgets/dialogs/single_action_dialog.dart';
import 'package:junto_beta_mobile/utils/junto_overlay.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/screens/welcome/bloc/auth_bloc.dart';
import 'package:junto_beta_mobile/screens/welcome/bloc/auth_event.dart';
import 'package:junto_beta_mobile/widgets/fade_route.dart';
import 'package:junto_beta_mobile/screens/welcome/welcome.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({this.buildContext, this.user});

  final BuildContext buildContext;
  final UserDataProvider user;

  @override
  Widget build(BuildContext context) {
    final deleteController = TextEditingController();
    Future<void> _deleteAccount() async {
      JuntoLoader.showLoader(context);
      try {
        // Delete user account
        await Provider.of<UserRepo>(context, listen: false)
            .deleteUserAccount(user.userAddress);
        JuntoLoader.hide();
        // Log the user out
        await context.bloc<AuthBloc>().add(LogoutEvent());
        // Bring user back to Welcome screen after logging out
        if (ModalRoute.of(context).settings.name != "/") {
          Navigator.of(context).pushAndRemoveUntil(
            FadeRoute(child: Welcome(), name: "Welcome"),
            ModalRoute.withName('/'),
          );
        }
      } catch (e, s) {
        JuntoLoader.hide();
        print(e);
        showDialog(
          context: context,
          builder: (BuildContext context) => SingleActionDialog(
            dialogText:
                'Unable to delete your account. Double check your password.',
          ),
        );
        logger.logException(e, s);
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 25,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "If you are sure you'd like to leave Junto, type 'delete' below and confirm.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 25),
              child: TextField(
                controller: deleteController,
                obscureText: true,
                buildCounter: (
                  BuildContext context, {
                  int currentLength,
                  int maxLength,
                  bool isFocused,
                }) =>
                    null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  hintText: 'Type here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                cursorColor: Theme.of(context).primaryColor,
                cursorWidth: 1,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                maxLength: 40,
                textInputAction: TextInputAction.done,
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            right: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (deleteController.text.trim().toLowerCase() ==
                            'delete') {
                          _deleteAccount();
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                SingleActionDialog(
                              dialogText: "Type 'delete' to leave Junto.",
                            ),
                          );
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          'CONFIRM',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
