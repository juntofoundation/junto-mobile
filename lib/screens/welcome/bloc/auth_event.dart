import 'dart:io';

import 'package:junto_beta_mobile/models/auth_result.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  SignUpEvent({
    this.details,
    this.profilePicture,
    this.username,
    this.password,
    this.birthday,
  });

  final UserRegistrationDetails details;
  final File profilePicture;
  final String username;
  final String password;
  final String birthday;
}

class AcceptAgreements extends AuthEvent {}

class LoginEvent extends AuthEvent {
  LoginEvent(this.username, this.password);

  final String username;
  final String password;
}

/// Called when the user is logged into the app.
/// Cases may include: Launching the app from the background, closing and
/// re-opening, etc..
class LoggedInEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {
  final bool manualLogout;

  LogoutEvent({this.manualLogout = false});
}

class RefreshUser extends AuthEvent {}
