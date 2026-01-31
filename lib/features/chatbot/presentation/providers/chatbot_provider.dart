// lib/features/chatbot/presentation/providers/chatbot_provider.dart - COMPLETE IMPLEMENTATION

import 'package:flutter/foundation.dart';
import 'package:grad_project/core/services/enhanced_chatbot_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/core/services/api_service.dart';

enum ChatbotState {
  initial,
  loading,
  loaded,
  error,
  typing,
  sending,
}

class ChatbotProvider extends ChangeNotifier {
  final EnhancedChatbotService _chatbotService;
  final AuthService _authService;
  final ApiService _apiService;

  // State management
  ChatbotState _state = ChatbotState.initial;
  String? _errorMessage;
  bool _isInitialized = false;

  // Chat-specific state
  bool _isChatMinimized = false;
  int _unreadMessageCount = 0;
  String _currentConversationId = '';

  ChatbotProvider({
    required EnhancedChatbotService chatbotService,
    required AuthService authService,
    required ApiService apiService,
  })  : _chatbotService = chatbotService,
        _authService = authService,
        _apiService = apiService {
    _initialize();
  }

  // Getters
  ChatbotState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isChatMinimized => _isChatMinimized;
  int get unreadMessageCount => _unreadMessageCount;
  String get currentConversationId => _currentConversationId;

  // Delegate to EnhancedChatbotService
  bool get isChatOpen => _chatbotService.isChatOpen;
  bool get isTyping => _chatbotService.isTyping;
  bool get isConnected => _chatbotService.isConnected;
  List<ChatMessage> get messages => _chatbotService.messages;
  List<String> get suggestedQuestions => _chatbotService.suggestedQuestions;

  // Private initialization
  Future<void> _initialize() async {
    try {
      _setState(ChatbotState.loading);

      print('🤖 ChatbotProvider: Initializing...');

      // Generate conversation ID
      _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';

      // Initialize the service if not already done
      if (_chatbotService.messages.isEmpty) {
        await _chatbotService.initializeWithWelcomeMessage();
      }

      _isInitialized = true;
      _setState(ChatbotState.loaded);

      print('✅ ChatbotProvider: Initialization complete');
    } catch (e) {
      print('❌ ChatbotProvider: Initialization failed - $e');
      _setError('فشل في تهيئة المحادثة: ${e.toString()}');
    }
  }

  // State management helpers
  void _setState(ChatbotState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(ChatbotState.error);
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == ChatbotState.error) {
      _setState(ChatbotState.loaded);
    }
  }

  // Chat window management
  Future<void> openChat() async {
    try {
      _clearError();
      _chatbotService.openChat();
      _isChatMinimized = false;
      _unreadMessageCount = 0;
      notifyListeners();

      print('🤖 ChatbotProvider: Chat opened');
    } catch (e) {
      print('❌ ChatbotProvider: Error opening chat - $e');
      _setError('فشل في فتح المحادثة');
    }
  }

  Future<void> closeChat() async {
    try {
      _chatbotService.closeChat();
      _isChatMinimized = false;
      notifyListeners();

      print('🤖 ChatbotProvider: Chat closed');
    } catch (e) {
      print('❌ ChatbotProvider: Error closing chat - $e');
      _setError('فشل في إغلاق المحادثة');
    }
  }

  void minimizeChat() {
    _isChatMinimized = true;
    _chatbotService.closeChat();
    notifyListeners();
    print('🤖 ChatbotProvider: Chat minimized');
  }

  // Message management
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      _clearError();
      _setState(ChatbotState.sending);

      print('🤖 ChatbotProvider: Sending message - $text');

      await _chatbotService.sendMessage(text.trim());

      // Update unread count if chat is minimized
      if (_isChatMinimized) {
        _unreadMessageCount++;
      }

      _setState(ChatbotState.loaded);
      print('✅ ChatbotProvider: Message sent successfully');

    } catch (e) {
      print('❌ ChatbotProvider: Failed to send message - $e');
      _setError('فشل في إرسال الرسالة: ${e.toString()}');
    }
  }

  Future<void> sendSuggestedQuestion(String question) async {
    try {
      _clearError();
      print('🤖 ChatbotProvider: Sending suggested question - $question');

      await _chatbotService.sendSuggestedQuestion(question);

      if (_isChatMinimized) {
        _unreadMessageCount++;
      }

      print('✅ ChatbotProvider: Suggested question sent successfully');
    } catch (e) {
      print('❌ ChatbotProvider: Failed to send suggested question - $e');
      _setError('فشل في إرسال السؤال المقترح');
    }
  }

  Future<void> clearMessages() async {
    try {
      _clearError();
      _chatbotService.clearMessages();
      await _chatbotService.initializeWithWelcomeMessage();

      _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
      _unreadMessageCount = 0;

      print('🤖 ChatbotProvider: Messages cleared and reinitialized');
    } catch (e) {
      print('❌ ChatbotProvider: Error clearing messages - $e');
      _setError('فشل في مسح الرسائل');
    }
  }

  // Connection management
  Future<void> reconnect() async {
    try {
      _setState(ChatbotState.loading);
      _clearError();

      print('🤖 ChatbotProvider: Attempting to reconnect...');

      await _chatbotService.reconnect();

      if (_chatbotService.isConnected) {
        _setState(ChatbotState.loaded);
        print('✅ ChatbotProvider: Reconnection successful');
      } else {
        _setError('فشل في إعادة الاتصال بالخادم');
      }
    } catch (e) {
      print('❌ ChatbotProvider: Reconnection failed - $e');
      _setError('فشل في إعادة الاتصال: ${e.toString()}');
    }
  }

  // Authentication management
  Future<void> updateAuthToken(String token) async {
    try {
      _chatbotService.updateAuthToken(token);
      _apiService.setAuthToken(token);

      print('🤖 ChatbotProvider: Auth token updated');
    } catch (e) {
      print('❌ ChatbotProvider: Error updating auth token - $e');
      _setError('فشل في تحديث رمز المصادقة');
    }
  }

  Future<void> clearAuthToken() async {
    try {
      _chatbotService.updateAuthToken('');
      _apiService.clearToken();

      print('🤖 ChatbotProvider: Auth token cleared');
    } catch (e) {
      print('❌ ChatbotProvider: Error clearing auth token - $e');
    }
  }

  // Conversation management
  Future<void> startNewConversation() async {
    try {
      await clearMessages();
      _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';

      print('🤖 ChatbotProvider: New conversation started - $_currentConversationId');
    } catch (e) {
      print('❌ ChatbotProvider: Error starting new conversation - $e');
      _setError('فشل في بدء محادثة جديدة');
    }
  }

  // Analytics and tracking
  Map<String, dynamic> getChatAnalytics() {
    return {
      'conversationId': _currentConversationId,
      'messageCount': messages.length,
      'isConnected': isConnected,
      'unreadCount': _unreadMessageCount,
      'lastMessageTime': messages.isNotEmpty
          ? messages.last.timestamp.toIso8601String()
          : null,
      'userMessageCount': messages.where((m) => m.isUser).length,
      'botMessageCount': messages.where((m) => !m.isUser).length,
    };
  }

  // Error handling
  void retryLastAction() {
    _clearError();
    // Could implement specific retry logic based on last action
    print('🤖 ChatbotProvider: Retrying last action');
  }

  void dismissError() {
    _clearError();
    print('🤖 ChatbotProvider: Error dismissed');
  }

  // Utility methods
  bool hasUnreadMessages() => _unreadMessageCount > 0;

  void markMessagesAsRead() {
    _unreadMessageCount = 0;
    notifyListeners();
  }

  ChatMessage? getLastMessage() {
    return messages.isNotEmpty ? messages.last : null;
  }

  ChatMessage? getLastUserMessage() {
    try {
      return messages.lastWhere((message) => message.isUser);
    } catch (e) {
      return null;
    }
  }

  ChatMessage? getLastBotMessage() {
    try {
      return messages.lastWhere((message) => !message.isUser);
    } catch (e) {
      return null;
    }
  }

  List<ChatMessage> getUserMessages() {
    return messages.where((message) => message.isUser).toList();
  }

  List<ChatMessage> getBotMessages() {
    return messages.where((message) => !message.isUser).toList();
  }

  // Lifecycle management
  @override
  void dispose() {
    print('🤖 ChatbotProvider: Disposing...');
    // The EnhancedChatbotService will be disposed by the provider system
    super.dispose();
  }

  // Debug helpers
  void printDebugInfo() {
    print('🤖 ChatbotProvider Debug Info:');
    print('  - State: $_state');
    print('  - Initialized: $_isInitialized');
    print('  - Chat Open: $isChatOpen');
    print('  - Connected: $isConnected');
    print('  - Messages: ${messages.length}');
    print('  - Unread: $_unreadMessageCount');
    print('  - Conversation ID: $_currentConversationId');
    print('  - Error: $_errorMessage');
  }
}