import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/app/themes_provider.dart';
import 'package:junto_beta_mobile/backend/mock/mock_auth.dart';
import 'package:junto_beta_mobile/backend/mock/mock_expression.dart';
import 'package:junto_beta_mobile/backend/mock/mock_search.dart';
import 'package:junto_beta_mobile/backend/mock/mock_sphere.dart';
import 'package:junto_beta_mobile/backend/mock/mock_user.dart';
import 'package:junto_beta_mobile/backend/repositories.dart';
import 'package:junto_beta_mobile/backend/repositories/app_repo.dart';
import 'package:junto_beta_mobile/backend/repositories/create_circle_repo.dart';
import 'package:junto_beta_mobile/backend/repositories/onboarding_repo.dart';
import 'package:junto_beta_mobile/backend/repositories/search_repo.dart';
import 'package:junto_beta_mobile/backend/repositories/user_repo.dart';
import 'package:junto_beta_mobile/backend/services.dart';
import 'package:junto_beta_mobile/backend/services/app_service.dart';
import 'package:junto_beta_mobile/backend/services/auth_cognito_service.dart';
import 'package:junto_beta_mobile/backend/services/expression_service.dart';
import 'package:junto_beta_mobile/backend/services/group_service.dart';
import 'package:junto_beta_mobile/backend/services/hive_service.dart';
import 'package:junto_beta_mobile/backend/services/image_handler.dart';
import 'package:junto_beta_mobile/backend/services/notification_service.dart';
import 'package:junto_beta_mobile/backend/services/search_service.dart';
import 'package:junto_beta_mobile/backend/services/user_service.dart';
import 'package:junto_beta_mobile/backend/user_data_provider.dart';
import 'package:junto_beta_mobile/utils/junto_http.dart';

export 'package:junto_beta_mobile/backend/repositories.dart';
export 'package:junto_beta_mobile/backend/services.dart';
export 'package:junto_beta_mobile/backend/user_data_provider.dart';

class Backend {
  const Backend._({
    @required this.client,
    this.searchRepo,
    this.authRepo,
    this.userRepo,
    this.groupsProvider,
    this.expressionRepo,
    this.notificationRepo,
    this.appRepo,
    this.db,
    this.themesProvider,
    this.onBoardingRepo,
    this.dataProvider,
    this.createCircleRepo,
  });

  // ignore: missing_return
  static Future<Backend> init() async {
    try {
      final dbService = HiveCache();
      await dbService.init();
      await Firebase.initializeApp();
      final themesProvider = JuntoThemesProvider();
      final imageHandler = DeviceImageHandler();
      final authService = CognitoClient();
      final client = JuntoHttp(
        tokenProvider: authService,
      );
      final userService = UserServiceCentralized(client);
      final expressionService = ExpressionServiceCentralized(client);
      final appRepo = AppRepo(AppServiceImpl(client));
      final createCircleRepo = CreateCircleRepo();
      final authRepo = AuthRepo(
        authService,
        onLogout: () async {
          await themesProvider.reset();
          await appRepo.reset();
          await dbService.wipe();
        },
      );
      final groupService = GroupServiceCentralized(client);
      final searchService = SearchServiceCentralized(client);
      final notificationService = NotificationServiceImpl(client);
      final notificationRepo = NotificationRepo(notificationService, dbService);
      final userRepo =
          UserRepo(userService, notificationRepo, dbService, expressionService);
      final dataProvider = UserDataProvider(appRepo, userRepo);
      return Backend._(
        searchRepo: SearchRepo(searchService),
        authRepo: authRepo,
        userRepo: userRepo,
        groupsProvider: GroupRepo(groupService, userService),
        expressionRepo:
            ExpressionRepo(expressionService, dbService, imageHandler),
        notificationRepo: notificationRepo,
        appRepo: appRepo,
        db: dbService,
        themesProvider: themesProvider,
        dataProvider: dataProvider,
        onBoardingRepo: OnBoardingRepo(dataProvider),
        client: client,
        createCircleRepo: createCircleRepo,
      );
    } catch (e, s) {
      logger.logException(e, s);
    }
  }

  static Future<Backend> mocked() async {
    final AuthenticationService authService = MockAuth();
    final UserService userService = MockUserService();
    final ExpressionService expressionService = MockExpressionService();
    final GroupService groupService = MockSphere();
    final SearchService searchService = MockSearch();
    final ImageHandler imageHandler = MockedImageHandler();
    return Backend._(
      authRepo: AuthRepo(authService, onLogout: () {}),
      userRepo: UserRepo(userService, null, null, expressionService),
      groupsProvider: GroupRepo(groupService, userService),
      expressionRepo: ExpressionRepo(expressionService, null, imageHandler),
      searchRepo: SearchRepo(searchService),
      appRepo: AppRepo(null),
      db: null,
      dataProvider: null,
      themesProvider: MockedThemesProvider(),
      onBoardingRepo: null,
    );
  }

  final SearchRepo searchRepo;
  final AuthRepo authRepo;
  final UserRepo userRepo;
  final GroupRepo groupsProvider;
  final ExpressionRepo expressionRepo;
  final NotificationRepo notificationRepo;
  final AppRepo appRepo;
  final CreateCircleRepo createCircleRepo;
  final LocalCache db;
  final ThemesProvider themesProvider;
  final OnBoardingRepo onBoardingRepo;
  final UserDataProvider dataProvider;
  final JuntoHttp client;
}
