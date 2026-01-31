// lib/features/wordle/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Domain
import 'domain/repositories/wordle_repository.dart';
import 'domain/usecases/wordle_usecases.dart';

// Data
import 'data/repositories/wordle_repository_impl.dart';
import 'data/datasources/wordle_remote_datasource.dart';

// Presentation
import 'presentation/providers/wordle_provider.dart';

final sl = GetIt.instance;

Future<void> initWordleFeature() async {
  // External dependencies
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }

  // Data sources
  sl.registerLazySingleton<WordleRemoteDataSource>(
        () => WordleRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<WordleLocalDataSource>(
        () => WordleLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<WordleRepository>(
        () => WordleRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDailyWordleUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetRandomWordleUseCase(repository: sl()));
  sl.registerLazySingleton(() => SubmitGuessUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetWordleHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => SaveWordleProgressUseCase(repository: sl()));

  // Providers
  sl.registerFactory(
        () => WordleProvider(
      getDailyWordleUseCase: sl(),
      getRandomWordleUseCase: sl(),
      submitGuessUseCase: sl(),
      getWordleHistoryUseCase: sl(),
      saveWordleProgressUseCase: sl(),
    ),
  );
}

// Add this to your main.dart or app initialization
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Wordle feature dependencies
  await initWordleFeature();

  runApp(MyApp());
}
*/