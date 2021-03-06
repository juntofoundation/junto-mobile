import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:junto_beta_mobile/app/bloc/app_bloc.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/app/themes_provider.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/backend/repositories/app_repo.dart';
import 'package:junto_beta_mobile/generated/l10n.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/screens/lotus/lotus.dart';
import 'package:junto_beta_mobile/screens/notifications/notification_navigation_observer.dart';
import 'package:junto_beta_mobile/screens/notifications/notifications_handler.dart';
import 'package:junto_beta_mobile/screens/welcome/bloc/bloc.dart';
import 'package:junto_beta_mobile/screens/welcome/sign_up_agreement.dart';
import 'package:junto_beta_mobile/screens/welcome/welcome.dart';
import 'package:junto_beta_mobile/widgets/background/background_theme.dart';
import 'package:junto_beta_mobile/widgets/progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:junto_beta_mobile/backend/services/hive_service.dart';

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<JuntoThemesProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          home: HomePage(),
          title: 'JUNTO Alpha',
          debugShowCheckedModeBanner: false,
          theme: theme.currentTheme,
          navigatorObservers: [
            NotificationNavigationObserver(
                Provider.of<NotificationsHandler>(context)),
          ],
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute(
              builder: (context) => Welcome(),
            );
          },
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Replace later with S.supportedLocales
          supportedLocales: [
            Locale('en'),
          ],
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  Widget _buildChildFor({@required AuthState state}) {
    print('test: $state');

    if (state is AuthLoading) {
      return HomeLoadingPage();
    } else if (state is AuthAgreementsRequired) {
      return SignUpAgreements();
    } else if (state is AuthAuthenticated) {
      return HomePageContent();
    } else if (state is AuthUnauthenticated) {
      return Welcome();
    } else {
      return Welcome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if ((state.error != null && !state.error) &&
                !(ModalRoute.of(context).isFirst &&
                    ModalRoute.of(context).isCurrent)) {
              Provider.of<HiveCache>(context).wipe();
              Provider.of<JuntoThemesProvider>(context).reset();
              Provider.of<AppRepo>(context).reset();

              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, anim1, anim2) => HomePage(),
                  transitionDuration: Duration(seconds: 0),
                ),
                (route) => false,
              );
            }
          });
        }
        return Stack(
          children: <Widget>[
            BackgroundTheme(),
            AnimatedSwitcher(
              duration: kThemeAnimationDuration,
              child: _buildChildFor(state: state),
            ),
          ],
        );
      },
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageContentState();
  }
}

class HomePageContentState extends State<HomePageContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      logger.logDebug('Launch message $_');
    });
    FirebaseMessaging.onMessage.listen((_) {
      logger.logDebug('message $_');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkServerVersion();
    configureNotifications();
  }

  Future<void> configureNotifications() async {
    final notificationRepo = Provider.of<NotificationRepo>(context);
    final appRepo = Provider.of<AppRepo>(context);

    try {
      // context.read<NotificationSettingBloc>().add(FetchNotificationSetting());

      final _isFirst = await appRepo.isFirstLaunch();
      if (_isFirst) {
        final token = await notificationRepo.getFCMToken();
        await notificationRepo.requestPermissions();
        final success = await notificationRepo.registerDevice(token);

        if (!success) {
          await notificationRepo.unRegisterDevice(token);

          await notificationRepo.registerDevice(token);
        }
        // await notificationRepo
        //     .manageNotifications(NotificationPrefsModel.enabled());
        await appRepo.setFirstLaunch();
        return;
      } else {
        return;
      }
    } catch (e) {
      logger.logException(e, null, "Error configuring notifications");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    UserData userProfile =
        await Provider.of<UserDataProvider>(context, listen: false).userProfile;

    if (userProfile == null || userProfile.user.address == null) {
      await context.read<AuthBloc>().add(RefreshUser());
    }
    if (state == AppLifecycleState.resumed) {
      logger.logInfo('checking server version');
      await _checkServerVersion();
    }
  }

  void _checkServerVersion() {
    context.read<AppBloc>().add(CheckServerVersion());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: JuntoLotus(),
    );
  }
}

class HomeLoadingPage extends StatelessWidget {
  const HomeLoadingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          BackgroundTheme(),
          JuntoProgressIndicator(),
        ],
      ),
    );
  }
}
