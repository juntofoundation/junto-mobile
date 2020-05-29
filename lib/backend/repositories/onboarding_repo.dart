import 'package:hive/hive.dart';
import 'package:junto_beta_mobile/hive_keys.dart';

class OnBoardingRepo {
  OnBoardingRepo() {
    _loadTutorialState();
  }
  bool _showLotusTutorial = false;
  bool _showCollectiveTutorial = false;
  bool _showPackTutorial = false;
  bool _showDenTutorial = false;
  Box _appBox;

  bool get showLotusTutorial => _showLotusTutorial;
  bool get showCollectiveTutorial => _showCollectiveTutorial;
  bool get showPackTutorial => _showPackTutorial;
  bool get showDenTutorial => _showDenTutorial;

  Future<void> _loadTutorialState() async {
    _appBox = await Hive.box(HiveBoxes.kAppBox);
    _showLotusTutorial = await _appBox.get(HiveKeys.kShowLotusTutorial) ?? true;
    _showCollectiveTutorial =
        await _appBox.get(HiveKeys.kShowCollectiveTutorial) ?? true;
    _showPackTutorial = await _appBox.get(HiveKeys.kShowPackTutorial) ?? true;
    _showDenTutorial = await _appBox.get(HiveKeys.kShowDenTutorial) ?? true;
  }

  Future<void> setViewed(String key, bool value) async {
    switch (key) {
      case HiveKeys.kShowLotusTutorial:
        _showLotusTutorial = false;
        await _appBox.put(HiveKeys.kShowLotusTutorial, value);
        return;
      case HiveKeys.kShowCollectiveTutorial:
        _showCollectiveTutorial = false;
        await _appBox.put(HiveKeys.kShowCollectiveTutorial, value);
        return;
      case HiveKeys.kShowPackTutorial:
        _showPackTutorial = false;
        await _appBox.put(HiveKeys.kShowPackTutorial, value);
        return;
      case HiveKeys.kShowDenTutorial:
        _showDenTutorial = false;
        await _appBox.put(HiveKeys.kShowDenTutorial, value);
        return;
    }
  }
}
