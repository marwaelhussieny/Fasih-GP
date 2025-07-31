// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:grad_project/firebase_options.dart';

// Theme imports
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/core/theme/theme_provider.dart';

// Authentication Imports
import 'package:grad_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grad_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:grad_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/signup_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/signout_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

// User Profile Imports
import 'package:grad_project/features/profile/data/datasources/user_remote_data_source.dart';
import 'package:grad_project/features/profile/data/repositories/user_repository_impl.dart';
import 'package:grad_project/features/profile/domain/usecases/profile_usecases.dart'; // Consolidated Profile Use Cases
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';

// Activity Imports
import 'package:grad_project/features/profile/domain/usecases/activity_usecases.dart'; // Consolidated Activity Use Cases
import 'package:grad_project/features/profile/presentation/providers/activity_provider.dart'; // Corrected import path
import 'package:grad_project/features/profile/data/repositories/activity_repository_impl.dart';

// Quiz Imports
import 'package:grad_project/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:grad_project/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:grad_project/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_quiz.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_quiz_by_criteria.dart';
import 'package:grad_project/features/quiz/domain/usecases/submit_quiz_answers.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_user_quiz_results.dart';
import 'package:grad_project/features/quiz/domain/usecases/generate_quiz_questions.dart';

// Home Imports
import 'package:grad_project/features/home/data/datasources/home_remote_data_source.dart';
import 'package:grad_project/features/home/data/repositories/home_repository_impl.dart';
import 'package:grad_project/features/home/domain/usecases/home_usecases.dart'; // Consolidated Home Use Cases
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';

// Grammar/Morphology Imports
import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source.dart';
import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source_impl.dart';
import 'package:grad_project/features/grammar/data/repositories/grammar_morphology_repository_impl.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_parsing_usecase.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_morphology_usecase.dart';
import 'package:grad_project/features/grammar/presentation/providers/grammar_morphology_provider.dart';

// Core navigation
import 'package:grad_project/core/navigation/app_routes.dart';
import 'package:grad_project/core/navigation/app_router.dart';

// SeedDataService
import 'package:grad_project/core/services/seed_data_service.dart';

// Import MainScreen (NEW)
import 'package:grad_project/features/main/presentation/main_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ar', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeFromPrefs();

  // Initialize Auth Dependencies
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final loginUseCase = LoginUseCase(repository: authRepository);
  final signUpUseCase = SignUpUseCase(repository: authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(repository: authRepository);
  final signOutUseCase = SignOutUseCase(repository: authRepository);
  final getAuthStateChangesUseCase = GetAuthStateChangesUseCase(repository: authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(repository: authRepository);

  // Initialize User Profile Dependencies (using consolidated use cases)
  final userRemoteDataSource = UserRemoteDataSourceImpl();
  final userRepository = UserRepositoryImpl(remoteDataSource: userRemoteDataSource);
  final getUserProfile = GetUserProfile(userRepository);
  final updateUserProfile = UpdateUserProfile(userRepository);
  final uploadProfileImage = UploadProfileImage(userRepository);
  final createUserProfile = CreateUserProfile(userRepository);

  // Initialize Activity Dependencies (using consolidated use cases)
  final activityRepositoryImpl = ActivityRepositoryImpl(userRepository);
  final getWeeklyLessonsDataUseCase = GetWeeklyLessonsData(activityRepositoryImpl);
  final getDailyAchievementsUseCase = GetDailyAchievements(activityRepositoryImpl);
  final addDailyActivityUseCase = AddDailyActivity(activityRepositoryImpl);

  // Initialize Quiz Dependencies
  final quizRemoteDataSource = QuizRemoteDataSourceImpl();
  final quizRepositoryImpl = QuizRepositoryImpl(remoteDataSource: quizRemoteDataSource);
  final getQuizUseCase = GetQuiz(quizRepositoryImpl);
  final getQuizzesByCriteriaUseCase = GetQuizzesByCriteria(quizRepositoryImpl);
  final submitQuizAnswersUseCase = SubmitQuizAnswers(quizRepositoryImpl);
  final getUserQuizResultsUseCase = GetUserQuizResults(quizRepositoryImpl);
  final generateQuizQuestionsUseCase = GenerateQuizQuestions(quizRepositoryImpl);

  // Initialize Home Dependencies
  final homeRemoteDataSource = HomeRemoteDataSourceImpl();
  final homeRepository = HomeRepositoryImpl(remoteDataSource: homeRemoteDataSource);
  final getLessonsUseCase = GetLessons(homeRepository);
  final updateLessonActivityCompletionUseCase = UpdateLessonActivityCompletion(homeRepository);
  final seedDataService = SeedDataService();

  // Initialize Grammar/Morphology Dependencies
  final grammarMorphologyRemoteDataSource = GrammarMorphologyRemoteDataSourceImpl();
  final grammarMorphologyRepository = GrammarMorphologyRepositoryImpl(grammarMorphologyRemoteDataSource);
  final performParsingUseCase = PerformParsingUseCase(grammarMorphologyRepository);
  final performMorphologyUseCase = PerformMorphologyUseCase(grammarMorphologyRepository);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            loginUseCase: loginUseCase,
            signUpUseCase: signUpUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            signOutUseCase: signOutUseCase,
            getAuthStateChangesUseCase: getAuthStateChangesUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => UserProvider(
            getUserProfile: getUserProfile,
            updateUserProfile: updateUserProfile,
            uploadProfileImage: uploadProfileImage,
            createUserProfile: createUserProfile,
            getAuthStateChangesUseCase: getAuthStateChangesUseCase,
          )..loadUser(),
        ),
        ChangeNotifierProvider(
          create: (context) => ActivityProvider(
            getWeeklyLessonsDataUseCase: getWeeklyLessonsDataUseCase,
            getDailyAchievementsUseCase: getDailyAchievementsUseCase,
            addDailyActivityUseCase: addDailyActivityUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => QuizProvider(
            getQuiz: getQuizUseCase,
            getQuizzesByCriteria: getQuizzesByCriteriaUseCase,
            submitQuizAnswers: submitQuizAnswersUseCase,
            getUserQuizResults: getUserQuizResultsUseCase,
            generateQuizQuestions: generateQuizQuestionsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            getLessonsUseCase: getLessonsUseCase,
            updateLessonActivityCompletionUseCase: updateLessonActivityCompletionUseCase,
            seedDataService: seedDataService,
          )..loadLessons(), // Load lessons on app start
        ),

        // Grammar/Morphology Providers
        Provider<GrammarMorphologyRemoteDataSource>(
          create: (_) => grammarMorphologyRemoteDataSource,
        ),
        Provider<GrammarMorphologyRepository>(
          create: (_) => grammarMorphologyRepository,
        ),
        Provider<PerformParsingUseCase>(
          create: (_) => performParsingUseCase,
        ),
        Provider<PerformMorphologyUseCase>(
          create: (_) => performMorphologyUseCase,
        ),
        ChangeNotifierProvider(
          create: (context) => GrammarMorphologyProvider(
            context.read<PerformParsingUseCase>(),
            context.read<PerformMorphologyUseCase>(),
          ),
        ),
      ],
      child: const MyAppContent(),
    ),
  );
}

class MyAppContent extends StatelessWidget {
  const MyAppContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'مشروع التخرج',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ar', 'AE'),
                Locale('ar', 'SA'),
                Locale('ar', 'EG'),
                Locale('en', 'US'),
              ],
              locale: const Locale('ar', 'AE'),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              initialRoute: AppRoutes.main, // Changed to AppRoutes.main
              onGenerateRoute: AppRouter.onGenerateRoute,
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
