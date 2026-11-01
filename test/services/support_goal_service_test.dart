import 'package:aurora_music_v01/shared/services/support_goal_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SupportGoalService.dismiss();
  });

  test('showNow shows the banner without using up the reminder schedule',
      () async {
    await SupportGoalService.showNow();
    expect(SupportGoalService.bannerNotifier.value, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('support_banner_last_shown'), isNull);
  });

  test('dismiss hides the banner', () async {
    await SupportGoalService.showNow();
    SupportGoalService.dismiss();
    expect(SupportGoalService.bannerNotifier.value, isFalse);
  });
}
