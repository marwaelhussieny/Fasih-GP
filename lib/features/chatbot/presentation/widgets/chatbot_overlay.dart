// lib/features/chatbot/presentation/widgets/chatbot_overlay.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/services/enhanced_chatbot_service.dart';

class ChatbotOverlay extends StatefulWidget {
  const ChatbotOverlay({Key? key}) : super(key: key);

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _bubbleController;
  late AnimationController _chatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Input controllers with proper key management
  late TextEditingController _textController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  // Keyboard state management
  bool _isKeyboardVisible = false;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();

    // Add observer for keyboard events
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();

    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final chatService = context.read<EnhancedChatbotService>();

        if (chatService.messages.isEmpty) {
          chatService.initializeWithWelcomeMessage();
        }

        print('✅ Chatbot overlay initialized successfully');
      } catch (e) {
        print('⚠️ Chatbot overlay initialization warning: $e');
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0;

    if (newKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisible;
      });

      // Scroll to bottom when keyboard appears
      if (_isKeyboardVisible) {
        _scrollToBottomDelayed();
      }
    }
  }

  void _setupAnimations() {
    // Floating bubble animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));

    // Chat window animations
    _chatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _bubbleController.dispose();
    _chatController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomDelayed() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  // FIXED: Improved message sending with better state management
  Future<void> _sendMessage(EnhancedChatbotService chatService) async {
    final text = _textController.text.trim();
    if (text.isEmpty || chatService.isTyping || _isSendingMessage) return;

    print('📤 Sending message: $text');

    // Set sending state
    setState(() {
      _isSendingMessage = true;
    });

    try {
      // Clear the input field IMMEDIATELY
      _textController.clear();

      // Force rebuild to show cleared input
      setState(() {});

      // Send the message
      await chatService.sendMessage(text);

      // Scroll to bottom after sending
      _scrollToBottomDelayed();

    } catch (e) {
      print('Error sending message: $e');
    } finally {
      // Reset sending state
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<EnhancedChatbotService>(
      builder: (context, chatService, child) {
        // Animate chat window based on state
        if (chatService.isChatOpen) {
          _chatController.forward();
        } else {
          _chatController.reverse();
        }

        return Stack(
          children: [
            // Floating bubble
            if (!chatService.isChatOpen) _buildFloatingBubble(theme, isDarkMode),

            // Chat window
            if (chatService.isChatOpen) _buildChatWindow(theme, isDarkMode, chatService),
          ],
        );
      },
    );
  }

  Widget _buildFloatingBubble(ThemeData theme, bool isDarkMode) {
    return Positioned(
      bottom: 100.h,
      right: 20.w,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: GestureDetector(
              onTap: () {
                print('🎯 Opening chatbot from floating bubble');
                context.read<EnhancedChatbotService>().openChat();
              },
              child: Container(
                width: 65.r,
                height: 65.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Mascot icon
                    Center(
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.smart_toy_outlined,
                          size: 24.r,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    // Notification dot (optional)
                    Positioned(
                      top: 8.r,
                      right: 8.r,
                      child: Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // FIXED: Better chat window with proper keyboard handling
  Widget _buildChatWindow(ThemeData theme, bool isDarkMode, EnhancedChatbotService chatService) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    // Better height calculations
    final availableHeight = screenHeight - keyboardHeight - topPadding - bottomPadding;
    final maxChatHeight = _isKeyboardVisible
        ? availableHeight * 0.95  // Use more space when keyboard is open
        : screenHeight * 0.75;    // Normal height when keyboard is closed

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.black54,
          child: Column( // REMOVED GestureDetector that was dismissing keyboard
            children: [
              Expanded(
                child: GestureDetector(
                  // ONLY dismiss keyboard when tapping outside the chat window
                  onTap: () => _focusNode.unfocus(),
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: maxChatHeight,
                    width: screenWidth - 40.w,
                    margin: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: _isKeyboardVisible ? 5.h : 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildChatHeader(theme, isDarkMode, chatService),
                        Expanded(child: _buildMessageList(theme, isDarkMode, chatService)),
                        // Hide suggested questions when keyboard is open to save space
                        if (chatService.suggestedQuestions.isNotEmpty &&
                            chatService.messages.length <= 1 &&
                            !_isKeyboardVisible)
                          _buildSuggestedQuestions(theme, isDarkMode, chatService),
                        _buildMessageInput(theme, isDarkMode, chatService),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader(ThemeData theme, bool isDarkMode, EnhancedChatbotService chatService) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 20.r,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فصيح',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  'مساعدك الذكي',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          // Connection status indicator
          Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: chatService.isConnected ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            chatService.isConnected ? 'متصل' : 'محلي',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.sp,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () {
              print('🔒 Closing chatbot');
              _focusNode.unfocus(); // Dismiss keyboard when closing
              context.read<EnhancedChatbotService>().closeChat();
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme, bool isDarkMode, EnhancedChatbotService chatService) {
    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomDelayed();
    });

    return Flexible(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: chatService.messages.length + (chatService.isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatService.messages.length && chatService.isTyping) {
            return _buildTypingIndicator(theme, isDarkMode);
          }

          final message = chatService.messages[index];
          return _buildMessageBubble(message, theme, isDarkMode);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme, bool isDarkMode) {
    final isUser = message.isUser;
    final text = message.text;
    final isError = message.isError;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
          )
              : null,
          color: isUser
              ? null
              : isError
              ? Colors.red.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(isUser ? 8.r : 20.r),
            bottomRight: Radius.circular(isUser ? 20.r : 8.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isError
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : isError
                ? Colors.red.shade700
                : theme.textTheme.bodyLarge?.color,
            fontSize: 14.sp,
            fontFamily: 'Tajawal',
            height: 1.4,
          ),
          textAlign: isUser ? TextAlign.left : TextAlign.right,
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions(ThemeData theme, bool isDarkMode, EnhancedChatbotService chatService) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أسئلة مقترحة:',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: chatService.suggestedQuestions.take(3).map((question) {
              return GestureDetector(
                onTap: () {
                  print('💡 Sending suggested question: $question');
                  // Clear input first, then send question
                  _textController.clear();
                  chatService.sendSuggestedQuestion(question);
                  _scrollToBottomDelayed();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    question,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'يكتب',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 24.w,
              height: 12.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 200)),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Completely rewritten message input with proper keyboard handling
  Widget _buildMessageInput(ThemeData theme, bool isDarkMode, EnhancedChatbotService chatService) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.r),
          bottomRight: Radius.circular(25.r),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: _isKeyboardVisible ? 80.h : 100.h, // Smaller when keyboard is open
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? theme.primaryColor.withOpacity(0.5)
                        : theme.dividerColor,
                    width: _focusNode.hasFocus ? 2.0 : 1.0,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  enabled: !_isSendingMessage, // Disable when sending
                  // CRITICAL: Prevent keyboard dismissal
                  onEditingComplete: () {
                    // Do nothing - prevents keyboard from dismissing
                  },
                  onSubmitted: (text) async {
                    if (text.trim().isNotEmpty && !chatService.isTyping && !_isSendingMessage) {
                      await _sendMessage(chatService);
                      // CRITICAL: Keep focus after sending
                      if (mounted) {
                        _focusNode.requestFocus();
                      }
                    }
                  },
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 14.sp,
                    fontFamily: 'Tajawal',
                  ),
                  decoration: InputDecoration(
                    hintText: _isSendingMessage ? 'جاري الإرسال...' : 'اكتب رسالتك هنا...',
                    hintStyle: TextStyle(
                      color: theme.hintColor,
                      fontFamily: 'Tajawal',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h
                    ),
                  ),
                  onChanged: (text) {
                    // Update UI when text changes
                    setState(() {});

                    // Auto-scroll when typing long messages
                    if (text.length > 50) {
                      _scrollToBottomDelayed();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () async {
                if (_textController.text.trim().isNotEmpty &&
                    !chatService.isTyping &&
                    !_isSendingMessage) {
                  await _sendMessage(chatService);
                  // CRITICAL: Keep focus after sending
                  if (mounted) {
                    _focusNode.requestFocus();
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: (_isSendingMessage || chatService.isTyping)
                        ? [Colors.grey, Colors.grey.shade400]
                        : (_textController.text.trim().isNotEmpty)
                        ? [theme.primaryColor, theme.primaryColor.withOpacity(0.8)]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: (_isSendingMessage || chatService.isTyping)
                    ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}