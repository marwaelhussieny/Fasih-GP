// lib/features/chatbot/domain/usecases/get_suggested_questions_usecase.dart - CORRECTED
import 'package:grad_project/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:grad_project/core/services/api_service.dart'; // ADDED: Import ApiService

class GetSuggestedQuestionsUseCase {
  final ChatbotRepository repository;

  GetSuggestedQuestionsUseCase({required this.repository});

  // Simple factory constructor
  factory GetSuggestedQuestionsUseCase.create({
    String? baseUrl,
    required ApiService apiService, // ADDED: The missing parameter
  }) {
    final repository = ChatbotRepositoryImpl.create(
      baseUrl: baseUrl,
      // apiService: apiService, // ADDED: Passing the missing parameter
    );
    return GetSuggestedQuestionsUseCase(repository: repository);
  }

  Future<List<String>> call() async {
    return await repository.getSuggestedQuestions();
  }
}