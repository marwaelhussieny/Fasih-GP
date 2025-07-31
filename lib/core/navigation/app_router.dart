// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:grad_project/core/navigation/app_routes.dart';

// Import ALL your screens that will be routed to
import 'package:grad_project/features/splash/presentation/splash_screen.dart';
import 'package:grad_project/features/auth/presentation/screens/signup_screen.dart';
import 'package:grad_project/features/auth/presentation/screens/login_screen.dart';
import 'package:grad_project/features/auth/presentation/screens/otp_screen.dart';
import 'package:grad_project/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:grad_project/features/profile/presentation/screens/profile_screen.dart';
import 'package:grad_project/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:grad_project/features/profile/settings/presentation/screens/settings_screen.dart';
import 'package:grad_project/features/profile/settings/presentation/screens/personal_account_screen.dart';
import 'package:grad_project/features/profile/settings/presentation/screens/notifications_screen.dart';
import 'package:grad_project/features/profile/settings/presentation/screens/about_app_screen.dart';
import 'package:grad_project/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:grad_project/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:grad_project/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:grad_project/features/profile/settings/presentation/screens/accessibility_screen.dart';
import 'package:grad_project/features/profile/settings/presentation/screens/security_screen.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart';
import 'package:grad_project/features/main/presentation/main_screen.dart';
import 'package:grad_project/features/community/presentation/screens/community_screen.dart'; // <--- ADDED THIS IMPORT

// Import the actual feature screens
import 'package:grad_project/features/grammar/presentation/screens/grammar_parsing_screen.dart';
import 'package:grad_project/features/grammar/presentation/screens/morphology_screen.dart';
import 'package:grad_project/features/grammar/presentation/screens/poetry_generation_screen.dart';
import 'package:grad_project/features/grammar/presentation/screens/plural_finder_screen.dart';
import 'package:grad_project/features/grammar/presentation/screens/antonym_finder_screen.dart';
import 'package:grad_project/features/grammar/presentation/screens/meaning_finder_screen.dart';

// Dummy screen definition (if needed for temporary routing)
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title screen.')),
    );
  }
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
      // return MaterialPageRoute(builder: (_) => const OnboardingScreens());
        return MaterialPageRoute(builder: (_) => const DummyScreen(title: 'Onboarding'));
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.otp:
        return MaterialPageRoute(builder: (_) => const OTPScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.personalAccount:
        return MaterialPageRoute(builder: (_) => const PersonalAccountScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.aboutApp:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());
      case AppRoutes.quizList:
        return MaterialPageRoute(builder: (_) => const QuizListScreen());
      case AppRoutes.quiz:
        final String? quizId = settings.arguments as String?;
        if (quizId != null) {
          // return MaterialPageRoute(builder: (_) => QuizScreen(quizId: quizId));
        }
        return MaterialPageRoute(builder: (_) => const Text('Error: Quiz ID not provided.'));
      case AppRoutes.quizResult:
        return MaterialPageRoute(builder: (_) => const QuizResultScreen());
      case AppRoutes.accessibility:
        return MaterialPageRoute(builder: (_) => const AccessibilityScreen());
      case AppRoutes.security:
        return MaterialPageRoute(builder: (_) => const SecurityScreen());
      case AppRoutes.newPassword:
        return MaterialPageRoute(builder: (_) => const DummyScreen(title: 'New Password Screen'));
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case AppRoutes.community: // <--- ADDED THIS CASE FOR COMMUNITY SCREEN
        return MaterialPageRoute(builder: (_) => const CommunityScreen());

    // Separate routes for grammar parsing and morphology
      case AppRoutes.grammarParsing:
        return MaterialPageRoute(builder: (_) => const GrammarParsingScreen());
      case AppRoutes.morphology:
        return MaterialPageRoute(builder: (_) => const MorphologyScreen());

    // Routes for other language features
      case AppRoutes.poetryGeneration:
        return MaterialPageRoute(builder: (_) => const PoetryGenerationScreen());
      case AppRoutes.pluralFinder:
        return MaterialPageRoute(builder: (_) => const PluralFinderScreen());
      case AppRoutes.antonymFinder:
        return MaterialPageRoute(builder: (_) => const AntonymFinderScreen());
      case AppRoutes.meaningFinder:
        return MaterialPageRoute(builder: (_) => const MeaningFinderScreen());

      default:
        return MaterialPageRoute(builder: (_) => Text('Error: Unknown route ${settings.name}'));
    }
  }
}
