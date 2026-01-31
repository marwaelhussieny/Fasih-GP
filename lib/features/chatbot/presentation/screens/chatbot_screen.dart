// lib/features/chatbot/presentation/screens/chatbot_screen.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/services/enhanced_chatbot_service.dart';
import 'package:grad_project/core/theme/app_theme.dart';

/// This screen is now used as a standalone chatbot page if needed
/// The floating chatbot functionality is handled by ChatbotOverlay widget
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with WidgetsBindingObserver {
  // Controllers with proper management
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Keyboard management
  bool _isKeyboardVisible = false;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();

    // Add observer for keyboard events
    WidgetsBinding.instance.addObserver(this);

    // Initialize chatbot service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedChatbotService>().initializeWithWelcomeMessage();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // Handle keyboard visibility changes
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0;

    if (newKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisible;
      });

      // Auto-scroll to bottom when keyboard appears
      if (_isKeyboardVisible) {
        _scrollToBottomDelayed();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
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

  Future<void> _sendMessage(String text, EnhancedChatbotService chatService) async {
    if (text.trim().isEmpty || chatService.isTyping || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      // Clear input immediately
      _textController.clear();

      // Send the message
      await chatService.sendMessage(text);

      // Scroll to bottom after sending
      _scrollToBottomDelayed();

    } catch (e) {
      print('Error sending message: $e');
      // Show error snackbar if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إرسال الرسالة. حاول مرة أخرى.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  void _handleSubmitted(String text, EnhancedChatbotService chatService) async {
    if (text.trim().isNotEmpty) {
      await _sendMessage(text, chatService);
      // CRITICAL: Keep focus after sending
      if (mounted) {
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      // CRITICAL: Enable resize to avoid bottom inset
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(isDarkMode),
      body: Consumer<EnhancedChatbotService>(
        builder: (context, chatService, child) {
          return Column( // REMOVED GestureDetector that was dismissing keyboard
            children: [
              // Suggested questions (hide when keyboard is open)
              if (chatService.messages.length <= 1 &&
                  chatService.suggestedQuestions.isNotEmpty &&
                  !_isKeyboardVisible)
                _buildSuggestedQuestions(isDarkMode, chatService),

              // Messages list
              Expanded(
                child: GestureDetector(
                  // ONLY dismiss keyboard when tapping in messages area
                  onTap: () {
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                    }
                  },
                  child: _buildMessagesList(isDarkMode, chatService),
                ),
              ),

              // Message input with proper keyboard handling
              _buildMessageInput(isDarkMode, chatService),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
          size: 20.r,
        ),
        onPressed: () {
          // Ensure keyboard is dismissed when leaving
          _focusNode.unfocus();
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          Container(
            width: 35.r,
            height: 35.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode ? AppTheme.darkGradient : AppTheme.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 18.r,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'فصيح',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                'مساعدك الذكي',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<EnhancedChatbotService>(
          builder: (context, chatService, child) {
            return Row(
              children: [
                // Connection status indicator
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: chatService.isConnected ? AppTheme.success : AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                // Clear chat button
                IconButton(
                  onPressed: () {
                    _showClearChatDialog(context, chatService);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                    size: 20.r,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedQuestions(bool isDarkMode, EnhancedChatbotService chatService) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أسئلة مقترحة:',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chatService.suggestedQuestions.length,
              itemBuilder: (context, index) {
                final question = chatService.suggestedQuestions[index];
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      _textController.clear();
                      chatService.sendSuggestedQuestion(question);
                      _scrollToBottomDelayed();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      constraints: BoxConstraints(maxWidth: 200.w),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isDarkMode ? AppTheme.darkHintColor : AppTheme.secondaryTextColor,
                        ),
                      ),
                      child: Text(
                        question,
                        style: TextStyle(
                          color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                          fontSize: 12.sp,
                          fontFamily: 'Tajawal',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDarkMode, EnhancedChatbotService chatService) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: chatService.messages.length + (chatService.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatService.messages.length && chatService.isTyping) {
          return _buildTypingIndicator(isDarkMode);
        }

        final message = chatService.messages[index];
        return _buildMessageBubble(message, isDarkMode);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDarkMode) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.8.sw),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? LinearGradient(
            colors: isDarkMode ? AppTheme.darkGradient : AppTheme.primaryGradient,
          )
              : null,
          color: message.isUser
              ? null
              : (message.isError
              ? (isDarkMode ? AppTheme.error.withOpacity(0.2) : AppTheme.error.withOpacity(0.1))
              : (isDarkMode ? AppTheme.darkCardColor.withOpacity(0.5) : AppTheme.cardBackgroundColor)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(message.isUser ? 20.r : 8.r),
            topRight: Radius.circular(message.isUser ? 20.r : 20.r),
            bottomLeft: Radius.circular(message.isUser ? 20.r : 8.r),
            bottomRight: Radius.circular(message.isUser ? 8.r : 20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : (message.isError
                    ? AppTheme.error
                    : (isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor)),
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
                height: 1.4,
              ),
              textAlign: message.isUser ? TextAlign.right : TextAlign.left,
            ),
            SizedBox(height: 4.h),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white70
                    : (isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor),
                fontSize: 10.sp,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'فصيح يكتب',
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 30.w,
              height: 15.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: AlwaysStoppedAnimation(0.0),
                    builder: (context, child) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 200)),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor)
                                    .withOpacity(0.7),
                              ),
                            ),
                          );
                        },
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

  // FIXED: Complete message input with keyboard persistence
  Widget _buildMessageInput(bool isDarkMode, EnhancedChatbotService chatService) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 120.h,
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  // CRITICAL: Prevent keyboard dismissal
                  onEditingComplete: () {
                    // Do nothing - prevents keyboard from dismissing
                  },
                  onChanged: (text) {
                    setState(() {}); // Update send button state
                  },
                  decoration: InputDecoration(
                    hintText: _isSendingMessage ? 'جاري الإرسال...' : 'اكتب رسالة...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
                      fontFamily: 'Tajawal',
                    ),
                    filled: true,
                    fillColor: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide(
                        color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.primaryBrandColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                    fontFamily: 'Tajawal',
                  ),
                  enabled: !_isSendingMessage,
                  onSubmitted: (text) => _handleSubmitted(text, chatService),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: _isSendingMessage
                    ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryBrandColor,
                    ),
                  ),
                )
                    : Icon(
                  Icons.send,
                  color: (_textController.text.trim().isNotEmpty && !chatService.isTyping)
                      ? (isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryBrandColor)
                      : (isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor),
                  size: 24.r,
                ),
                onPressed: (!_isSendingMessage && _textController.text.trim().isNotEmpty && !chatService.isTyping)
                    ? () => _handleSubmitted(_textController.text, chatService)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'اليوم, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'أمس, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showClearChatDialog(BuildContext context, EnhancedChatbotService chatService) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
          title: Text(
            'مسح المحادثة',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد مسح جميع الرسائل؟',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                chatService.clearMessages();
                chatService.initializeWithWelcomeMessage();
                Navigator.of(context).pop();
                _scrollToBottomDelayed();
              },
              child: Text(
                'مسح',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}