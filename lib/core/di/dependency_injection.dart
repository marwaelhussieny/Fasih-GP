// // lib/core/di/dependency_injection.dart
//
// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // Core Services
// import 'package:grad_project/core/services/api_service.dart';
// import 'package:grad_project/core/services/auth_service.dart';
//
// // Profile Feature
// import 'package:grad_project/features/profile/data/datasources/profile_remote_datasource.dart';
// import 'package:grad_project/features/profile/data/datasources/profile_local_datasource.dart';
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
// final GetIt sl = GetIt.instance;
//
// Future<void> initializeDependencies() async {
//   // =========================================================================
//   // External Dependencies
//   // =========================================================================
//   final sharedPreferences = await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
//
//   // HTTP Client
//   sl.registerLazySingleton(() => http.Client());
//
//   // =========================================================================
//   // Core Services
//   // =========================================================================
//   sl.registerLazySingleton<ApiService>(
//         () => ApiServiceImpl(
//       baseUrl: 'https://3608bf173666.ngrok-free.app/api',
//     ),
//   );
//
//   sl.registerLazySingleton<AuthService>(
//         () => AuthService(),
//   );
//
//   // =========================================================================
//   // Profile Feature Dependencies
//   // =========================================================================
//
//   // Data Sources
//   sl.registerLazySingleton<ProfileRemoteDataSource>(
//         () => ProfileRemoteDataSourceImpl(
//       apiService: sl(),
//       authService: sl(),
//     ),
//   );
//
//   sl.registerLazySingleton<ProfileLocalDataSource>(
//         () => ProfileLocalDataSourceImpl(
//       sharedPreferences: sl(),
//     ),
//   );
//
//   sl.registerLazySingleton<ActivityRemoteDataSource>(
//         () => ActivityRemoteDataSourceImpl(
//       apiClient: sl(),
//     ),
//   );
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
//   // Use Cases - Profile
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
//   sl.registerLazySingleton(() => DeleteAccountUseCase(repository: sl()));
//
//   // Use Cases - Activity
//   // Add the missing use cases that ActivityProvider requires:
//   sl.registerLazySingleton(() => GetWeeklyLessonsDataUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetDailyAchievementsUseCase(repository: sl()));
//   sl.registerLazySingleton(() => AddDailyActivityUseCase(repository: sl()));
//
//   // Existing use cases:
//   sl.registerLazySingleton(() => GetDailyActivitiesUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetDailyActivityUseCase(repository: sl()));
//   sl.registerLazySingleton(() => GetMonthlyStatsUseCase(repository: sl()));
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
//       getWeeklyLessonsDataUseCase: sl(),
//       getDailyAchievementsUseCase: sl(),
//       addDailyActivityUseCase: sl(),
//       getDailyActivitiesUseCase: sl(),
//       getDailyActivityUseCase: sl(),
//       getMonthlyStatsUseCase: sl(),
//     ),
//   );
// }
//
// // Helper function to setup API service with auth token
// void setupApiServiceWithToken(String token) {
//   final apiService = sl<ApiService>();
//   // Check if the ApiService implementation has a setAuthToken method
//   if (apiService is ApiServiceImpl) {
//     apiService.setAuthToken(token);
//   }
//
//   final authService = sl<AuthService>();
//   // Check if the AuthService has a setToken method
//   // Uncomment this if AuthService has a setToken method:
//   // authService.setToken(token);
// }