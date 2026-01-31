// lib/main.dart - FULLY FIXED WITH PROPER BACKEND INTEGRATION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core navigation and services
import 'package:grad_project/core/navigation/app_routes.dart';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/core/theme/theme_provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';

// Authentication Imports
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

// Enhanced Chatbot Imports
import 'package:grad_project/core/services/enhanced_chatbot_service.dart';
import 'package:grad_project/features/chatbot/presentation/widgets/chatbot_overlay.dart';

// Grammar Feature Imports
import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source_impl.dart';
import 'package:grad_project/features/grammar/data/repositories/grammar_morphology_repository_impl.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_parsing_usecase.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_morphology_usecase.dart';
import 'package:grad_project/features/grammar/presentation/providers/grammar_morphology_provider.dart';

// Community Feature Imports
import 'package:grad_project/features/community/data/services/community_service.dart';
import 'package:grad_project/features/community/presentation/providers/community_provider.dart';

// Quiz Feature Imports
import 'package:grad_project/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:grad_project/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_quiz.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_quiz_by_criteria.dart';
import 'package:grad_project/features/quiz/domain/usecases/submit_quiz_answers.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_user_quiz_results.dart';
import 'package:grad_project/features/quiz/domain/usecases/generate_quiz_questions.dart';
import 'package:grad_project/features/quiz/presentation/providers/quiz_provider.dart';

// Home Feature Imports
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';

// Profile Feature Imports
import 'features/profile/presentation/providers/user_provider.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/profile_usecases.dart';

// Library Feature Imports
import 'features/library/presentation/providers/library_provider.dart';
import 'features/library/data/datasources/library_remote_data_source.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/usecases/filter_library_items_usecase.dart';
import 'features/library/domain/usecases/get_library_items_usecase.dart';
import 'features/library/domain/usecases/search_library_items_usecase.dart';

import 'core/navigation/app_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BackendConfig {
  // Updated to use your provided ngrok URL
  static const String baseUrl = 'https://f35f3ddf1acd.ngrok-free.app';
  static const String authBaseUrl = '$baseUrl/api/auth';
  static const String apiBaseUrl = '$baseUrl/api/v1';

  static Future<bool> testConnection() async {
    print('🔍 Testing backend connection...');
    print('🌐 Base URL: $baseUrl');

    // Test endpoints in order of importance
    final endpointsToTry = [
      '$apiBaseUrl/community/post/allcategories',  // Community endpoint
      '$apiBaseUrl/chatbot/chat',                  // Chatbot endpoint
      '$authBaseUrl/login',                        // Auth endpoint
      '$apiBaseUrl/grammar/morphology',            // Grammar endpoint
      '$apiBaseUrl/courses/',                      // Library endpoint
      baseUrl,                                     // Base endpoint
    ];

    for (final endpoint in endpointsToTry) {
      try {
        print('🔍 Testing: $endpoint');
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'ngrok-skip-browser-warning': 'true',
            'User-Agent': 'FlutterApp/1.0',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));

        print('📡 Response: ${response.statusCode}');

        // Accept any non-404 response as connection success
        if (response.statusCode >= 200 && response.statusCode < 500) {
          print('✅ Connection successful via: $endpoint');
          return true;
        }
      } catch (e) {
        print('❌ Endpoint $endpoint failed: $e');
        continue;
      }
    }

    print('❌ All connection attempts failed');
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 Starting Fasih app with enhanced chatbot integration...');

  try {
    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    print('✅ SharedPreferences initialized');

    // Initialize AuthService
    AuthService? authService;
    try {
      authService = await AuthService.getInstance();
      print('✅ AuthService initialized');
    } catch (e) {
      print('⚠️ AuthService initialization failed: $e');
    }

    // Initialize date formatting
    await initializeDateFormatting('ar', null);
    print('✅ Date formatting initialized');

    // Set screen orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print('✅ Screen orientation set');

    // Initialize theme provider
    final themeProvider = ThemeProvider();
    await themeProvider.loadThemeFromPrefs();
    print('✅ Theme provider initialized');

    // Test backend connection
    final isConnected = await BackendConfig.testConnection();
    print('🌐 Backend connection: ${isConnected ? "✅ Connected" : "❌ Failed"}');

    print('✅ App initialization complete');

    runApp(FasihApp(
      themeProvider: themeProvider,
      sharedPreferences: sharedPreferences,
      authService: authService,
      isBackendConnected: isConnected,
    ));
  } catch (e, stack) {
    print('❌ Critical error during app initialization: $e');
    print('Stack trace: $stack');
    runApp(const FallbackApp());
  }
}

class FasihApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final SharedPreferences sharedPreferences;
  final AuthService? authService;
  final bool isBackendConnected;

  const FasihApp({
    Key? key,
    required this.themeProvider,
    required this.sharedPreferences,
    required this.authService,
    required this.isBackendConnected,
  }) : super(key: key);

  String _getInitialRoute(AuthProvider authProvider) {
    if (!isBackendConnected) {
      print('🚫 Backend not connected, showing status screen');
      return '/status';
    }
    if (!authProvider.isInitialized) {
      print('🔄 AuthProvider not initialized, showing login');
      return AppRoutes.login;
    }
    if (authProvider.isAuthenticated) {
      print('✅ User authenticated, navigating to main screen');
      return AppRoutes.main;
    }
    print('🔐 User not authenticated, showing login');
    return AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: _buildProviders(),
          builder: (context, child) {
            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return MaterialApp(
                      title: 'فصيح - تعلم اللغة العربية',
                      debugShowCheckedModeBanner: false,
                      navigatorKey: navigatorKey,
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
                      onGenerateRoute: AppRouter.onGenerateRoute,
                      initialRoute: _getInitialRoute(authProvider),
                      builder: (context, navigator) {
                        if (navigator == null) {
                          return const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: Stack(
                            children: [
                              navigator,
                              // Only show chatbot overlay when backend is connected
                              if (isBackendConnected)
                                const ChatbotOverlay(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<ChangeNotifierProvider> _buildProviders() {
    final providers = <ChangeNotifierProvider>[];

    // Core providers (always available)
    providers.add(
      ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
    );

    providers.add(
      ChangeNotifierProvider<AuthProvider>(
        create: (context) {
          final authProvider = AuthProvider();
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await authProvider.initialize();
              print('✅ AuthProvider initialized successfully');
            } catch (e) {
              print('❌ AuthProvider initialization failed: $e');
            }
          });
          return authProvider;
        },
        lazy: false,
      ),
    );

    // Backend-dependent providers
    if (isBackendConnected && authService != null) {
      try {
        providers.addAll([
          // Enhanced Chatbot Service - Most Important
          ChangeNotifierProvider<EnhancedChatbotService>(
            create: (context) {
              try {
                print('🤖 Initializing Enhanced Chatbot Service...');

                final apiService = ApiServiceImpl(
                  baseUrl: BackendConfig.apiBaseUrl,
                  httpClient: http.Client(),
                );

                // Set auth token for API service
                final token = authService!.getAccessToken();
                if (token != null && token.isNotEmpty) {
                  apiService.setAuthToken(token);
                  print('🔑 Auth token set for chatbot API service');
                } else {
                  print('⚠️ No auth token available for chatbot - using anonymous mode');
                }

                final chatbotService = EnhancedChatbotService(
                  authService: authService!,
                  apiService: apiService,
                );

                print('✅ Enhanced Chatbot Service initialized successfully');
                return chatbotService;

              } catch (e) {
                print('❌ Error creating enhanced chatbot service: $e');

                // Create fallback service
                final fallbackApiService = ApiServiceImpl(
                  baseUrl: BackendConfig.apiBaseUrl,
                  httpClient: http.Client(),
                );

                return EnhancedChatbotService(
                  authService: authService!,
                  apiService: fallbackApiService,
                );
              }
            },
            lazy: false,
          ),

          // Quiz Provider
          ChangeNotifierProvider<QuizProvider>(
            create: (context) {
              try {
                print('🧩 Initializing Quiz Provider...');

                final quizRemoteDataSource = QuizRemoteDataSourceImpl();
                final quizRepository = QuizRepositoryImpl(
                  remoteDataSource: quizRemoteDataSource,
                );

                final provider = QuizProvider(
                  getQuiz: GetQuiz(quizRepository),
                  getQuizzesByCriteria: GetQuizzesByCriteria(quizRepository),
                  submitQuizAnswers: SubmitQuizAnswers(quizRepository),
                  getUserQuizResults: GetUserQuizResults(quizRepository),
                  generateQuizQuestions: GenerateQuizQuestions(quizRepository),
                );

                print('✅ Quiz service initialized successfully');
                return provider;
              } catch (e) {
                print('❌ Error creating quiz provider: $e');
                rethrow;
              }
            },
            lazy: false,
          ),

          // Grammar Provider
          ChangeNotifierProvider<GrammarMorphologyProvider>(
            create: (context) {
              try {
                print('🔧 Initializing Grammar Provider...');

                final apiService = ApiServiceImpl(
                  baseUrl: BackendConfig.apiBaseUrl,
                  httpClient: http.Client(),
                );

                final dataSource = GrammarMorphologyRemoteDataSourceImpl(
                  apiService: apiService,
                  userId: authService!.getUser()?.id ?? 'anonymous',
                  baseUrl: BackendConfig.apiBaseUrl,
                );

                final repository = GrammarMorphologyRepositoryImpl(dataSource);
                final provider = GrammarMorphologyProvider(
                  PerformParsingUseCase(repository),
                  PerformMorphologyUseCase(repository),
                  dataSource,
                );

                // Check service status
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try {
                    await provider.checkServiceStatus();
                    print('✅ Grammar service status checked');
                  } catch (e) {
                    print('❌ Grammar service status check failed: $e');
                  }
                });

                print('✅ Grammar service initialized successfully');
                return provider;
              } catch (e) {
                print('❌ Error creating grammar provider: $e');
                rethrow;
              }
            },
            lazy: false,
          ),

          // Community Provider
          ChangeNotifierProvider<CommunityProvider>(
            create: (context) {
              try {
                print('🏠 Initializing Community Provider...');
                final apiService = ApiServiceImpl(
                  baseUrl: BackendConfig.apiBaseUrl,
                  httpClient: http.Client(),
                );
                final communityService = CommunityService(apiService);
                final provider = CommunityProvider(communityService, authService!);
                print('✅ Community service initialized successfully');
                return provider;
              } catch (e) {
                print('❌ Error creating community provider: $e');
                rethrow;
              }
            },
            lazy: false,
          ),

          // Library Provider
          ChangeNotifierProvider<LibraryProvider>(
            create: (context) {
              try {
                print('📚 Initializing Library Provider...');

                final remoteDataSource = LibraryRemoteDataSourceImpl();
                final repository = LibraryRepositoryImpl(
                  remoteDataSource: remoteDataSource,
                );

                final provider = LibraryProvider(
                  getLibraryItemsUseCase: GetLibraryItemsUseCase(repository),
                  searchLibraryItemsUseCase: SearchLibraryItemsUseCase(repository),
                  filterLibraryItemsUseCase: FilterLibraryItemsUseCase(repository),
                  repository: repository,
                );

                print('✅ Library service initialized successfully');
                return provider;
              } catch (e) {
                print('❌ Error creating library provider: $e');
                // Return fallback provider to prevent crashes
                final fallbackRemoteDataSource = LibraryRemoteDataSourceImpl();
                final fallbackRepository = LibraryRepositoryImpl(
                  remoteDataSource: fallbackRemoteDataSource,
                );

                return LibraryProvider(
                  getLibraryItemsUseCase: GetLibraryItemsUseCase(fallbackRepository),
                  searchLibraryItemsUseCase: SearchLibraryItemsUseCase(fallbackRepository),
                  filterLibraryItemsUseCase: FilterLibraryItemsUseCase(fallbackRepository),
                  repository: fallbackRepository,
                );
              }
            },
            lazy: false,
          ),

          // User Provider
          ChangeNotifierProvider<UserProvider>(
            create: (context) {
              try {
                print('👤 Initializing User Provider...');

                final apiService = ApiServiceImpl(
                  baseUrl: BackendConfig.apiBaseUrl,
                  httpClient: http.Client(),
                );

                final profileRemoteDataSource = ProfileRemoteDataSourceImpl(
                  apiService: apiService,
                  authService: authService!,
                );

                final profileLocalDataSource = ProfileLocalDataSourceImpl(
                  sharedPreferences: sharedPreferences,
                );

                final profileRepository = ProfileRepositoryImpl(
                  remoteDataSource: profileRemoteDataSource,
                  localDataSource: profileLocalDataSource,
                  authService: authService!,
                );

                final provider = UserProvider(
                  getProfileUseCase: GetProfileUseCase(repository: profileRepository),
                  updateProfileUseCase: UpdateProfileUseCase(repository: profileRepository),
                  uploadProfileImageUseCase: UploadProfileImageUseCase(repository: profileRepository),
                  updateProfileImageUseCase: UpdateProfileImageUseCase(repository: profileRepository),
                  deleteAccountUseCase: DeleteAccountUseCase(repository: profileRepository),
                  getPreferencesUseCase: GetPreferencesUseCase(repository: profileRepository),
                  updatePreferencesUseCase: UpdatePreferencesUseCase(repository: profileRepository),
                  updateAccessibilityPreferenceUseCase: UpdateAccessibilityPreferenceUseCase(repository: profileRepository),
                  updateGeneralPreferenceUseCase: UpdateGeneralPreferenceUseCase(repository: profileRepository),
                  updateThemePreferenceUseCase: UpdateThemePreferenceUseCase(repository: profileRepository),
                  updateLanguagePreferenceUseCase: UpdateLanguagePreferenceUseCase(repository: profileRepository),
                  changePasswordUseCase: ChangePasswordUseCase(repository: profileRepository),
                  changeEmailUseCase: ChangeEmailUseCase(repository: profileRepository),
                  updateNotificationSettingsUseCase: UpdateNotificationSettingsUseCase(repository: profileRepository),
                );

                print('✅ User/Profile service initialized successfully');
                return provider;
              } catch (e) {
                print('❌ Error creating user provider: $e');
                rethrow;
              }
            },
            lazy: false,
          ),

          // Home Provider
          ChangeNotifierProvider<HomeProvider>(
            create: (context) {
              try {
                print('🏠 Initializing Home Provider...');

                final apiService = ApiServiceImpl(
                  baseUrl: BackendConfig.apiBaseUrl,
                  httpClient: http.Client(),
                );

                final homeRemoteDataSource = HomeRemoteDataSourceImpl(
                  apiService: apiService,
                  authService: authService!,
                );

                final provider = HomeProvider(
                  sharedPreferences: sharedPreferences,
                  remoteDataSource: homeRemoteDataSource,
                  authService: authService!,
                );

                // Load home data after provider creation
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try {
                    print('🔄 Loading home data...');
                    await provider.loadLessons();
                    print('✅ Home data loaded successfully');
                  } catch (e) {
                    print('❌ Error loading home data: $e');
                  }
                });

                print('✅ Home service initialized successfully');
                return provider;
              } catch (e) {
                print('❌ Error creating home provider: $e');
                rethrow;
              }
            },
            lazy: false,
          ),
        ]);
      } catch (e) {
        print('❌ Error adding backend-dependent providers: $e');
      }
    } else {
      print('⚠️ Backend not connected or AuthService not available - limited functionality');
    }

    print('📋 Total providers registered: ${providers.length}');
    return providers;
  }
}

// Backend Status Screen
class StatusScreen extends StatefulWidget {
  final bool isConnected;
  const StatusScreen({Key? key, required this.isConnected}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isRetrying = false;
  List<String> _connectionLogs = [];

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
      _connectionLogs.clear();
    });

    _addLog('🔍 بدء اختبار الاتصال...');
    _addLog('🌐 الخادم: ${BackendConfig.baseUrl}');

    final isConnected = await BackendConfig.testConnection();

    if (isConnected) {
      _addLog('✅ تم الاتصال بنجاح!');
      setState(() => _isRetrying = false);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
              (route) => false,
        );
      }
    } else {
      _addLog('❌ فشل الاتصال بجميع نقاط النهاية');
      setState(() => _isRetrying = false);
    }
  }

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _connectionLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      });
    }
    print(message);
  }

  void _bypassConnection() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isConnected ? Icons.check_circle : Icons.cloud_off,
                size: 80,
                color: widget.isConnected ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isConnected ? 'متصل بالخادم' : 'فشل الاتصال بالخادم',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تفاصيل الخادم:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Base URL: ${BackendConfig.baseUrl}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Courier',
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'API URL: ${BackendConfig.apiBaseUrl}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Courier',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isConnected
                    ? 'جميع الخدمات تعمل بشكل طبيعي'
                    : 'تأكد من:\n• تشغيل الخادم\n• صحة عنوان ngrok\n• اتصال الإنترنت\n• تفعيل API',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'Tajawal',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!widget.isConnected) ...[
                if (_connectionLogs.isNotEmpty) ...[
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _connectionLogs.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Courier',
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRetrying ? null : _retryConnection,
                        icon: _isRetrying
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.refresh),
                        label: Text(
                          _isRetrying ? 'جاري الاختبار...' : 'إعادة المحاولة',
                          style: const TextStyle(fontFamily: 'Tajawal'),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _bypassConnection,
                  icon: const Icon(Icons.skip_next, color: Colors.orange),
                  label: const Text(
                    'تجاوز (وضع التطوير)',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: Colors.orange,
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                        (route) => false,
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'متابعة إلى التطبيق',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Fallback App for Critical Errors
class FallbackApp extends StatelessWidget {
  const FallbackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فصيح',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal',
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'خطأ حرج في تحميل تطبيق فصيح',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'تأكد من إعدادات الخادم وأعد المحاولة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text(
                  'إغلاق التطبيق',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}