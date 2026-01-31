// // lib/core/di/injection_container.dart
//
// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // Core services
// import 'package:grad_project/core/services/api_service.dart';
// import 'package:grad_project/core/services/auth_service.dart';
//
// // Auth feature
// import 'package:grad_project/features/auth/data/datasources/auth_local_datasource.dart';
// import 'package:grad_project/features/auth/data/datasources/auth_remote_data_source.dart';
// import 'package:grad_project/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
// import 'package:grad_project/features/auth/domain/usecases/auth_usecases.dart';
// import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';
//
// // Profile feature
// import 'package:grad_project/features/profile/data/datasources/profile_local_datasource.dart';
// import 'package:grad_project/features/profile/data/datasources/profile_remote_datasource.dart';
// import 'package:grad_project/features/profile/data/datasources/activity_remote_data_source.dart';
// import 'package:grad_project/features/profile/data/repositories/profile_repository_impl.dart';
// import 'package:grad_project/features/profile/data/repositories/activity_repository_impl.dart';
// import 'package:grad_project/features/profile/domain/repositories/profile_repository.dart';
// import 'package:grad_project/features/profile/domain/repositories/activity_repository.dart';
// import 'package:grad_project/features/profile/domain/usecases/profile_usecases.dart';
// import 'package:grad_project/features/profile/domain/usecases/activity_usecases.dart';
// import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
// import 'package:grad_project/features/profile/presentation/providers/activity_provider.dart';
//
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   // =========================================================================
//   // Features - Auth
//   // =========================================================================
//
//   // Providers
//   sl.registerFactory(
//         () => AuthProvider(
//       signUpUseCase: sl(),
//       verifyOTPUseCase: sl(),
//       resendOTPUseCase: sl(),
//       loginUseCase: sl(),
//       refreshTokenUseCase: sl(),
//       forgotPasswordUseCase: sl(),
//       resetPasswordUseCase: sl(),
//       logoutUseCase: sl(),
//       getCurrentUserUseCase: sl(),
//       isLoggedInUseCase: sl(),
//     ),
//   );
//
//   // Use cases
//   sl.registerLazySingleton(() => SignUpUseCase(repository: sl()));
//   sl.registerLazySingleton(() => VerifyOTPUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ResendOTPUseCase(repository: sl()));
//   sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
//   sl.registerLazySingleton(() => RefreshTokenUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ForgotPasswordUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ResetPasswordUseCase(repository: sl()));
//   sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));
//   sl.registerLazySingleton(() => IsLoggedInUseCase(repository: sl()));
//
//   // Repository
//   sl.registerLazySingleton<AuthRepository>(
//         () => AuthRepositoryImpl(
//       remoteDataSource: sl(),
//       localDataSource: sl(),
//     ),
//   );
//
//   // Data sources
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//         () => AuthRemoteDataSourceImpl(apiService: sl(), authService: sl()),
//   );
//
//   sl.registerLazySingleton<AuthLocalDataSource>(
//         () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
//   );
//
//   // =========================================================================
//   // Features - Profile
//   // =========================================================================
//
//   // Providers
//   sl.registerFactory(
//         () => UserProvider(
//       getProfileUseCase: sl(),
//       updateProfileUseCase: sl(),
//       uploadProfileImageUseCase: sl(),
//       updateProfileImageUseCase: sl(),
//       getPreferencesUseCase: sl(),
//       updatePreferencesUseCase: sl(),
//       updateAccessibilityPreferenceUseCase: sl(),
//       updateGeneralPreferenceUseCase: sl(),
//       changePasswordUseCase: sl(),
//       changeEmailUseCase: sl(),
//       updateNotificationSettingsUseCase: sl(),
//       updateThemePreferenceUseCase: sl(),
//       deleteAccountUseCase: sl(),
//       updateLanguagePreferenceUseCase: sl(),
//     ),
//   );
//
//   sl.registerFactory(
//         () => ActivityProvider(
//       // Update these parameters based on your actual ActivityProvider constructor
//       // getWeeklyLessonsDataUseCase: sl(),
//       // getDailyAchievementsUseCase: sl(),
//       // addDailyActivityUseCase: sl(),
//       getDailyActivitiesUseCase: sl(),
//       getDailyActivityUseCase: sl(),
//       getMonthlyStatsUseCase: sl(),
//     ),
//   );
//
//   // Use cases - Profile
//   sl.registerLazySingleton(() => GetProfileUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateProfileUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UploadProfileImageUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateProfileImageUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetPreferencesUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdatePreferencesUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateAccessibilityPreferenceUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateGeneralPreferenceUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateNotificationSettingsUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateLanguagePreferenceUseCase(repository: sl()));
//   sl.registerLazySingleton(() => UpdateThemePreferenceUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ChangePasswordUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ChangeEmailUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ResetProgressUseCase(repository: sl()));
//   sl.registerLazySingleton(() => ExportDataUseCase(repository: sl()));
//   sl.registerLazySingleton(() => DeleteAccountUseCase(repository: sl()));
//
//   // Use cases - Activity
//   sl.registerLazySingleton(() => GetDailyActivitiesUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetDailyActivityUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetWeeklyProgressUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetMonthlyStatsUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetAchievementsUseCase(repository: sl()));
//
//   // These use cases might not exist - check your activity_usecases.dart file:
//   // sl.registerLazySingleton(() => GetWeeklyLessonsDataUseCase(repository: sl()));
//   // sl.registerLazySingleton(() => GetDailyAchievementsUseCase(repository: sl()));
//   // sl.registerLazySingleton(() => AddDailyActivityUseCase(repository: sl()));
//
//   // Repositories
//   sl.registerLazySingleton<ProfileRepository>(
//         () => ProfileRepositoryImpl(
//       remoteDataSource: sl(),
//       localDataSource: sl(),
//       authService: sl(),
//     ),
//   );
//
//   sl.registerLazySingleton<ActivityRepository>(
//         () => ActivityRepositoryImpl(
//       remoteDataSource: sl(),
//       authService: sl(),
//     ),
//   );
//
//   // Data sources
//   sl.registerLazySingleton<ProfileRemoteDataSource>(
//         () => ProfileRemoteDataSourceImpl(apiService: sl(), authService: sl()),
//   );
//
//   sl.registerLazySingleton<ProfileLocalDataSource>(
//         () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
//   );
//
//   sl.registerLazySingleton<ActivityRemoteDataSource>(
//         () => ActivityRemoteDataSourceImpl(apiClient: sl()),
//   );
//
//   // =========================================================================
//   // Core
//   // =========================================================================
//
//   // API Service - using concrete implementation
//   sl.registerLazySingleton<ApiService>(
//         () => ApiServiceImpl(baseUrl: 'http://localhost:5000/api'),
//   );
//
//   // Auth Service
//   sl.registerLazySingleton<AuthService>(
//         () => AuthService(),
//   );
//
//   // =========================================================================
//   // External
//   // =========================================================================
//
//   // SharedPreferences
//   final sharedPreferences = await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
//
//   // HTTP Client
//   sl.registerLazySingleton(() => http.Client());
// }