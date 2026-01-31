// lib/core/services/enhanced_chatbot_service.dart - FULLY FUNCTIONAL WITH BACKEND

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';

// ChatMessage model
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? userId;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'isError': isError,
    'userId': userId,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    text: json['text'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    isError: json['isError'] ?? false,
    userId: json['userId'],
  );
}

class EnhancedChatbotService extends ChangeNotifier {
  final AuthService authService;
  final ApiService apiService;

  // State management
  bool _isChatOpen = false;
  bool _isTyping = false;
  bool _isConnected = false;
  final List<ChatMessage> _messages = [];
  Timer? _typingTimer;

  // Suggested questions
  final List<String> _suggestedQuestions = [
    'ما هو الفرق بين الفاعل والمفعول به؟',
    'اشرح لي قواعد النحو بطريقة بسيطة',
    'ما هو مضاد كلمة النور؟',
    'ساعدني في تعلم الشعر العربي',
    'كيف أحسن خطي في الكتابة؟',
  ];

  // Constructor
  EnhancedChatbotService({
    required this.authService,
    required this.apiService,
  }) {
    _initialize();
  }

  // Getters
  bool get isChatOpen => _isChatOpen;
  bool get isTyping => _isTyping;
  bool get isConnected => _isConnected;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<String> get suggestedQuestions => List.unmodifiable(_suggestedQuestions);

  // Private initialization
  Future<void> _initialize() async {
    print('🤖 Enhanced Chatbot Service: Initializing...');

    // Check backend connection
    await _checkConnection();

    // Set auth token if available
    final token = authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      apiService.setAuthToken(token);
      print('🤖 Auth token set for chatbot');
    }

    print('🤖 Enhanced Chatbot Service: Initialization complete');
  }

  // Check backend connection
  Future<void> _checkConnection() async {
    try {
      // Test connection with a simple API call
      await apiService.get('/community/post/allcategories');
      _isConnected = true;
      print('🤖 Backend connection: SUCCESS');
    } catch (e) {
      _isConnected = false;
      print('🤖 Backend connection: FAILED - $e');
    }
    notifyListeners();
  }

  // Initialize with welcome message
  Future<void> initializeWithWelcomeMessage() async {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        text: 'مرحباً بك في فصيح! 👋\n\nأنا مساعدك الذكي لتعلم اللغة العربية. يمكنني مساعدتك في:\n\n📚 قواعد النحو والصرف\n🎭 الشعر والأدب العربي\n📖 معاني الكلمات والمرادفات\n✍️ تحسين مهارات الكتابة\n\nاختر سؤالاً من الأسئلة المقترحة أو اكتب سؤالك مباشرة!',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(welcomeMessage);
      notifyListeners();
      print('🤖 Welcome message added');
    }
  }

  // Open chat
  void openChat() {
    _isChatOpen = true;
    notifyListeners();
    print('🤖 Chat opened');
  }

  // Close chat
  void closeChat() {
    _isChatOpen = false;
    notifyListeners();
    print('🤖 Chat closed');
  }

  // Clear messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
    print('🤖 Messages cleared');
  }

  // Send message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      userId: authService.getUser()?.id,
    );

    _messages.add(userMessage);
    notifyListeners();

    print('🤖 Sending message: ${text.trim()}');

    // Start typing animation
    _startTyping();

    try {
      if (_isConnected) {
        // Send to backend
        await _sendToBackend(text.trim());
      } else {
        // Fallback offline response
        await _sendOfflineResponse(text.trim());
      }
    } catch (e) {
      print('🤖 Error sending message: $e');
      await _handleError(e.toString());
    } finally {
      _stopTyping();
    }
  }

  // Send suggested question
  Future<void> sendSuggestedQuestion(String question) async {
    await sendMessage(question);
  }

  // Send to backend
  Future<void> _sendToBackend(String message) async {
    try {
      print('🤖 Sending to backend: $message');

      final user = authService.getUser();
      final requestBody = {
        'message': message,
        'userId': user?.id ?? 'anonymous',
      };

      print('🤖 Request body: $requestBody');

      final response = await apiService.post(
        '/chatbot/chat',
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🤖 Backend response: $response');

      // Extract bot response
      String botResponse = 'عذراً، لم أتمكن من فهم سؤالك. يرجى المحاولة مرة أخرى.';

      if (response['status'] == 'success' && response['response'] != null) {
        botResponse = response['response'].toString();
      } else if (response['message'] != null) {
        botResponse = response['message'].toString();
      } else if (response['data'] != null && response['data']['response'] != null) {
        botResponse = response['data']['response'].toString();
      }

      // Add bot response
      await _addBotResponse(botResponse);

    } catch (e) {
      print('🤖 Backend error: $e');
      throw e;
    }
  }

  // Fallback offline response
  Future<void> _sendOfflineResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    String response = _generateOfflineResponse(message.toLowerCase());
    await _addBotResponse(response);
  }

  // Generate offline response
  String _generateOfflineResponse(String message) {
    // Simple keyword-based responses
    if (message.contains('مرحبا') || message.contains('السلام') || message.contains('أهلا')) {
      return 'مرحباً بك! كيف يمكنني مساعدتك في تعلم اللغة العربية اليوم؟';
    }

    if (message.contains('فاعل') || message.contains('نحو') || message.contains('قواعد')) {
      return 'قواعد النحو العربي واسعة ومتنوعة. الفاعل هو من قام بالفعل أو اتصف بالصفة. هل تريد معرفة المزيد عن موضوع معين في النحو؟';
    }

    if (message.contains('شعر') || message.contains('قصيدة') || message.contains('بحر')) {
      return 'الشعر العربي له بحور مختلفة مثل الطويل والكامل والوافر. كل بحر له تفعيلات خاصة به. عن أي بحر شعري تريد أن تتعلم؟';
    }

    if (message.contains('مضاد') || message.contains('ضد')) {
      return 'المتضادات جزء مهم من اللغة العربية. مثلاً: النور ضده الظلام، والحر ضده البرد. ما الكلمة التي تريد معرفة مضادها؟';
    }

    if (message.contains('معنى') || message.contains('تفسير')) {
      return 'يمكنني مساعدتك في فهم معاني الكلمات العربية وتفسيرها. ما الكلمة التي تريد معرفة معناها؟';
    }

    if (message.contains('شكر') || message.contains('أشكرك')) {
      return 'العفو! سعيد بمساعدتك في تعلم اللغة العربية. هل هناك شيء آخر تريد معرفته؟';
    }

    // Default response
    return 'أعتذر، أنا حالياً في وضع عدم الاتصال. يمكنني مساعدتك في أسئلة أساسية حول النحو والشعر ومعاني الكلمات. هل يمكنك إعادة صياغة سؤالك؟';
  }

  // Add bot response
  Future<void> _addBotResponse(String text) async {
    final botMessage = ChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(botMessage);
    notifyListeners();
    print('🤖 Bot response added: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
  }

  // Handle errors
  Future<void> _handleError(String error) async {
    String errorMessage = 'عذراً، حدث خطأ في النظام. يرجى المحاولة مرة أخرى.';

    if (error.contains('network') || error.contains('connection') || error.contains('internet')) {
      errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
    } else if (error.contains('timeout')) {
      errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
    } else if (error.contains('unauthorized') || error.contains('401')) {
      errorMessage = 'جلسة انتهت الصلاحية. يرجى تسجيل الدخول مرة أخرى.';
    }

    final errorMsg = ChatMessage(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      text: errorMessage,
      isUser: false,
      timestamp: DateTime.now(),
      isError: true,
    );

    _messages.add(errorMsg);
    notifyListeners();
    print('🤖 Error message added: $errorMessage');
  }

  // Typing animation
  void _startTyping() {
    _isTyping = true;
    notifyListeners();

    // Auto-stop typing after 10 seconds as fallback
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 10), () {
      if (_isTyping) {
        _stopTyping();
        print('🤖 Typing auto-stopped after timeout');
      }
    });
  }

  void _stopTyping() {
    _isTyping = false;
    _typingTimer?.cancel();
    notifyListeners();
  }

  // Reconnect to backend
  Future<void> reconnect() async {
    print('🤖 Attempting to reconnect...');
    await _checkConnection();

    if (_isConnected) {
      final token = authService.getAccessToken();
      if (token != null) {
        apiService.setAuthToken(token);
      }
      print('🤖 Reconnection successful');
    } else {
      print('🤖 Reconnection failed');
    }
  }

  // Update auth token
  void updateAuthToken(String token) {
    apiService.setAuthToken(token);
    print('🤖 Auth token updated');
  }

  // Dispose
  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
    print('🤖 Enhanced Chatbot Service disposed');
  }
}