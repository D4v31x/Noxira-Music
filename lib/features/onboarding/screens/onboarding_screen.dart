import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/user_preferences.dart';
import '../../../shared/providers/performance_mode_provider.dart';
import '../../home/screens/home_screen.dart';
import '../pages/welcome_page.dart';
import '../pages/app_info_page.dart';
import '../pages/language_selection_page.dart';
import '../pages/theme_selection_page.dart';
import '../pages/internet_usage_page.dart';
import '../pages/permissions_page.dart';
import '../pages/completion_page.dart';
import '../pages/donation_page.dart';
import '../pages/translation_contribution_page.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_kit.dart';
import '../../../shared/widgets/expanding_player.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  static const int _totalPages = 9;

  @override
  Widget build(BuildContext context) {
    final currentPage = useState(0);
    final lowEnd =
        context.select<PerformanceModeProvider, bool>((p) => p.isLowEndDevice);

    final transition = useAnimationController(
      duration: Duration(milliseconds: lowEnd ? 150 : 280),
      initialValue: 1.0,
    );
    final presence = useMemoized(() => ValueNotifier<double>(1.0));

    useEffect(() {
      void sync() =>
          presence.value = Curves.easeInOut.transform(transition.value);
      transition.addListener(sync);
      return () => transition.removeListener(sync);
    }, [transition]);

    Future<void> goTo(int page) async {
      await transition.reverse();
      currentPage.value = page;
      transition.value = 1.0;
    }

    Future<void> nextPage() async {
      if (currentPage.value < _totalPages - 1) {
        await goTo(currentPage.value + 1);
      } else {
        await _completeOnboarding(context);
      }
    }

    Future<void> previousPage() async {
      if (currentPage.value > 0) await goTo(currentPage.value - 1);
    }

    Widget getCurrentPage() {
      switch (currentPage.value) {
        case 0:
          return WelcomePage(onContinue: nextPage);
        case 1:
          return LanguageSelectionPage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 2:
          return TranslationContributionPage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 3:
          return AppInfoPage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 4:
          return PermissionsPage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 5:
          return ThemeSelectionPage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 6:
          return InternetUsagePage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 7:
          return DonationPage(
            onContinue: nextPage,
            onBack: previousPage,
          );
        case 8:
          return CompletionPage(onComplete: () => _completeOnboarding(context));
        default:
          return WelcomePage(onContinue: nextPage);
      }
    }

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                // The page's own parts fade and lift away (see
                // [OnboardingExit]); a fade layer around the whole page would
                // hide the glass backdrops.
                child: OnboardingExit(
                  presence: presence,
                  child: KeyedSubtree(
                    key: ValueKey(currentPage.value),
                    child: getCurrentPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    await UserPreferences.setFirstTimeUser(false);
    if (context.mounted) {
      ExpandingPlayer.hiddenNotifier.value = false;
      final lowEnd = context.read<PerformanceModeProvider>().isLowEndDevice;
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (lowEnd) return FadeTransition(opacity: animation, child: child);
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: lowEnd ? 250 : 800),
        ),
      );
    }
  }
}
