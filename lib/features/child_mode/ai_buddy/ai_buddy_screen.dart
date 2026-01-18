import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';

class AiBuddyScreen extends ConsumerStatefulWidget {
  const AiBuddyScreen({super.key});

  @override
  ConsumerState<AiBuddyScreen> createState() => _AiBuddyScreenState();
}

class _AiBuddyScreenState extends ConsumerState<AiBuddyScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  
  // Chat messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hi! I\'m your AI Buddy. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Quick actions
  final List<QuickAction> _quickActions = [
    QuickAction(
      title: 'Recommend Lesson',
      icon: Icons.school,
      onTap: 'recommend_lesson',
    ),
    QuickAction(
      title: 'Suggest Game',
      icon: Icons.games,
      onTap: 'suggest_game',
    ),
    QuickAction(
      title: 'Tell Story',
      icon: Icons.book,
      onTap: 'tell_story',
    ),
    QuickAction(
      title: 'Fun Fact',
      icon: Icons.lightbulb,
      onTap: 'fun_fact',
    ),
    QuickAction(
      title: 'Motivation',
      icon: Icons.favorite,
      onTap: 'motivation',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    
    final userMessage = ChatMessage(
      text: _textController.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMessage);
      _textController.clear();
    });
    
    // Simulate AI response
    _simulateAiResponse(userMessage.text);
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _simulateAiResponse(String userMessage) {
    // Show typing indicator
    final typingMessage = ChatMessage(
      text: '...',
      isUser: false,
      isTyping: true,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(typingMessage);
    });
    
    // Simulate thinking time
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        // Remove typing indicator
        _messages.removeWhere((msg) => msg.isTyping);
        
        // Add AI response
        final response = _generateAiResponse(userMessage);
        _messages.add(response);
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  ChatMessage _generateAiResponse(String userMessage) {
    String response;
    
    // Simple response generation based on keywords
    if (userMessage.toLowerCase().contains('math')) {
      response = 'I love math! How about practicing some addition problems? I can recommend a fun math game for you.';
    } else if (userMessage.toLowerCase().contains('story')) {
      response = 'Once upon a time, in a magical forest, there lived a curious little rabbit who loved to learn new things...';
    } else if (userMessage.toLowerCase().contains('game')) {
      response = 'I have some great game suggestions! Would you like to try a puzzle game or an adventure game?';
    } else if (userMessage.toLowerCase().contains('sad')) {
      response = 'I\'m sorry you\'re feeling sad. Remember, it\'s okay to have different feelings. Would you like to hear a funny joke to cheer you up?';
    } else {
      response = 'That sounds interesting! Tell me more about what you\'d like to learn or do today.';
    }
    
    return ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  void _handleQuickAction(String action) {
    String response;
    
    switch (action) {
      case 'recommend_lesson':
        response = 'I recommend the "Math Adventure" lesson! It\'s perfect for your level and really fun. Would you like to try it?';
        break;
      case 'suggest_game':
        response = 'How about the "Puzzle Challenge" game? It helps improve your problem-solving skills while having fun!';
        break;
      case 'tell_story':
        response = 'Here\'s a quick story: Sammy the Science Explorer discovered that learning can be the greatest adventure of all!';
        break;
      case 'fun_fact':
        response = 'Fun fact: Did you know that octopuses have three hearts and blue blood? Nature is amazing!';
        break;
      case 'motivation':
        response = 'You\'re doing great! Every time you learn something new, you\'re becoming smarter and stronger. Keep up the amazing work!';
        break;
      default:
        response = 'I\'m here to help! What would you like to know?';
    }
    
    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // AI Buddy Avatar
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_bounceAnimation.value * 0.1),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 30,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Title
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Buddy',
                            style: TextStyle(
                              fontSize: AppConstants.largeFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Your learning companion',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: AppConstants.fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickActions.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final action = _quickActions[index];
                        return _buildQuickActionCard(action);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat Messages
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(_messages[index]);
                  },
                ),
              ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Text input
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Ask me anything...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Send button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return InkWell(
      onTap: () => _handleQuickAction(action.onTap),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.isTyping) {
      return _buildTypingIndicator();
    }
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: message.isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: !message.isUser ? const Radius.circular(20) : Radius.zero,
          ),
          boxShadow: message.isUser ? [] : [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? AppColors.white : AppColors.textPrimary,
            fontSize: AppConstants.fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    required this.timestamp,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final String onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
