import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:junto_beta_mobile/app/app.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/utils/logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final Backend backend = await Backend.init();
  final bool _loggedIn = await backend.authRepo.isLoggedIn();
  backend.currentTheme.brightness == Brightness.dark
      ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
      : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runLoggedApp(
    JuntoApp(
      backend: backend,
      loggedIn: _loggedIn ?? false,
    ),
  );
}
