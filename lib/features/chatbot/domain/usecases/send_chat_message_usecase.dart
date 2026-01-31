// lib/features/chatbot/domain/usecases/send_chat_message_usecase.dart - CORRECTED
import 'package:grad_project/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:grad_project/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:grad_project/core/services/api_service.dart'; // ADDED: Import ApiService

class SendChatMessageParams {
  final String message;
  final String userId;
  final List<ChatbotMessage> conversationHistory;

  SendChatMessageParams({
    required this.message,
    required this.userId,
    required this.conversationHistory,
  });
}

class SendChatMessageUseCase {
  final ChatbotRepository repository;

  SendChatMessageUseCase({required this.repository});

  // Simple factory constructor
  factory SendChatMessageUseCase.create({
    String? baseUrl,
    required ApiService apiService, // ADDED: The missing parameter
  }) {
    final repository = ChatbotRepositoryImpl.create(
      baseUrl: baseUrl,
      // apiService: apiService, // ADDED: Passing the missing parameter
    );
    return SendChatMessageUseCase(repository: repository);
  }

  Future<String> call(SendChatMessageParams params) async {
    return await repository.sendMessage(
      params.message,
      params.userId,
      params.conversationHistory,
    );
  }
}