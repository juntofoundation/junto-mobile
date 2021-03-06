import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:junto_beta_mobile/api.dart';
import 'package:junto_beta_mobile/app/app_config.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/hive_keys.dart';
import 'package:junto_beta_mobile/app/screens.dart';
import 'package:junto_beta_mobile/models/models.dart';

/// Repository retrieving and saving various app settings:
///
/// - column layout of expressions
class AppRepo extends ChangeNotifier {
  AppRepo(AppService service) {
    _loadAppConfig();
    _appService = service;
  }

  AppService _appService;

  int get collectivePageIndex => _collectivePageIndex ?? 0;

  int get packsPageIndex => _packsPageIndex ?? 0;

  int get groupsPageIndex => _groupPageIndex ?? 0;

  int _collectivePageIndex;
  int _packsPageIndex;
  int _groupPageIndex;
  Box _appBox;

  Screen currentScreen;
  Screen latestScreen;
  bool showCreateScreen = false;
  ExpressionContext expressionContext;
  Group group;

  bool _twoColumn = true;

  /// Exposes the current layout config.
  bool get twoColumnLayout => _twoColumn;

  Future<void> initHome(Screen screen) async {
    showCreateScreen = screen == Screen.create;
    currentScreen = screen;
    latestScreen = screen;
    notifyListeners();
  }

  Future<void> reset() async {
    _packsPageIndex = 0;
    _groupPageIndex = 0;
    _collectivePageIndex = 0;
    group = null;
    expressionContext = null;
    showCreateScreen = false;
    latestScreen = null;
    currentScreen = null;
    notifyListeners();
  }

  Future<void> changeScreen({
    Screen screen,
    ExpressionContext newExpressionContext,
    Group newGroup,
  }) async {
    if (currentScreen != screen) {
      currentScreen = screen;
      expressionContext = newExpressionContext ?? ExpressionContext.Collective;
      if (newGroup != null) {
        group = newGroup;
      }
      if (screen == Screen.create) {
        showCreateScreen = true;
      } else {
        showCreateScreen = false;
        latestScreen = screen;
      }
    }

    notifyListeners();
  }

  Future<void> closeCreate() async {
    showCreateScreen = false;
    currentScreen = latestScreen;
    if (latestScreen == Screen.create) {
      currentScreen = Screen.groups;
    }

    notifyListeners();
  }

  Future<void> setActiveGroup(Group group) async {
    this.group = group;
    notifyListeners();
  }

  /// Loads the previously save configuration. If there is none, it starts with a
  /// default of false.
  Future<void> _loadAppConfig() async {
    _appBox = await Hive.box(HiveBoxes.kAppBox);
    final bool _result = _appBox.get(HiveKeys.kLayoutView);
    if (_result != null) {
      _twoColumn = _result;
    } else {
      await _appBox.put(HiveKeys.kLayoutView, _twoColumn);
    }
    return;
  }

  /// Allows the layout type to be updated and saved.
  Future<void> setLayout(bool value) async {
    _twoColumn = value;
    notifyListeners();
    await _appBox.put(HiveKeys.kLayoutView, value);
    return;
  }

  Future<bool> isFirstLaunch() async {
    final _appBox = await Hive.box(HiveBoxes.kAppBox);
    final bool _result = _appBox.get(HiveKeys.kFirstLaunch);
    if (_result != null) {
      return _result;
    } else {
      return true;
    }
  }

  Future<void> setFirstLaunch() async {
    try {
      _appBox = await Hive.box(HiveBoxes.kAppBox);
      await _appBox.put(HiveKeys.kFirstLaunch, false);
    } catch (e) {
      logger.logDebug("Unable to set first launch");
    }
    return;
  }

  Future<bool> isDenOpened() async {
    final _appBox = await Hive.box(HiveBoxes.kAppBox);
    final bool _result = _appBox.get(HiveKeys.kDenOpened);

    if (_result != null) {
      return _result;
    } else {
      return false;
    }
  }

  Future<void> setDenOpened() async {
    try {
      final _appBox = await Hive.box(HiveBoxes.kAppBox);
      await _appBox.put(HiveKeys.kDenOpened, true);
    } catch (e) {
      logger.logDebug("Unable to set the den opened");
    }

    return;
  }

  void setCollectivePageIndex(int index) {
    _collectivePageIndex = index;
    notifyListeners();
  }

  void setPacksPageIndex(int index) {
    _packsPageIndex = index;
    notifyListeners();
  }

  void setGroupsPageIndex(int index) {
    _groupPageIndex = index;
    notifyListeners();
  }

  Future<bool> isValidVersion() async {
    final isProd = appConfig.flavor == Flavor.prod;
    try {
      final serVersion = await _appService.getServerVersion();
      if (isProd) {
        if (Platform.isAndroid) {
          return currentAppVersion.minAndroidBuild >=
              serVersion.minAndroidBuild;
        } else {
          return currentAppVersion.minIosBuild >= serVersion.minIosBuild;
        }
      } else {
        return false;
      }
    } on DioError catch (error) {
      print(error.response.data);
      return false;
    } catch (e, s) {
      logger.logException(e, s);
      return false;
    }
  }
}
