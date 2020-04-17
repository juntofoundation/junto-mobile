import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/generated/l10n.dart';
import 'package:junto_beta_mobile/screens/welcome/widgets/sign_up_text_field.dart';
import 'package:junto_beta_mobile/screens/welcome/widgets/sign_in_back_nav.dart';
import 'package:junto_beta_mobile/widgets/buttons/call_to_action.dart';

class ResetPasswordRequest extends StatelessWidget {
  const ResetPasswordRequest({this.signInController});

  final PageController signInController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SignUpTextField(
                          hint: S.of(context).welcome_email_hint,
                          maxLength: 100,
                          textInputActionType: TextInputAction.next,
                          onSubmit: () {
                            FocusScope.of(context).nextFocus();
                          },
                          // valueController: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                        ),
                        const SizedBox(height: 60),
                        CallToActionButton(
                          callToAction: () {
                            signInController.nextPage(
                              curve: Curves.easeIn,
                              duration: const Duration(milliseconds: 300),
                            );
                          },
                          title: S.of(context).welcome_reset_password,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SignInBackNav(signInController: signInController),
      ],
    );
  }
}
