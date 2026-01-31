// // lib/features/chatbot/domain/repositories/chatbot_repository.dart
// import 'package:http/http.dart' as http;
// import 'package:grad_project/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
//
// abstract class ChatbotRepository {
//   Future<String> sendMessage(String message, String userId, List<ChatbotMessage> conversationHistory);
//   Future<List<String>> getSuggestedQuestions();
// }
//
// class ChatbotRepositoryImpl implements ChatbotRepository {
//   final ChatbotRemoteDataSource remoteDataSource;
//
//   ChatbotRepositoryImpl({required this.remoteDataSource});
//
//   // Simple factory constructor for easy instantiation
//   factory ChatbotRepositoryImpl.create({String? baseUrl}) {
//     final dataSource = ChatbotRemoteDataSourceImpl(
//       client: http.Client(),
//       baseUrl: baseUrl ?? 'https://5a8b45709327.ngrok-free.app',
//     );
//     return ChatbotRepositoryImpl(remoteDataSource: dataSource);
//   }
//
//   @override
//   Future<String> sendMessage(
//       String message,
//       String userId,
//       List<ChatbotMessage> conversationHistory
//       ) async {
//     try {
//       return await remoteDataSource.sendMessage(message, userId, conversationHistory);
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future<List<String>> getSuggestedQuestions() async {
//     try {
//       return await remoteDataSource.getSuggestedQuestions();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }