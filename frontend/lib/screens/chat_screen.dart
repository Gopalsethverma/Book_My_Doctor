import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text:
          "👋 Hi, I'm your Health Bot!\n\nI can answer your health questions, provide information about symptoms, diseases, and healthy habits, and guide you to the right resources. Just type your question below and I'll do my best to help you!",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final String _apiKey =
      'AIzaSyCFij3ISLP-8hxL-i7hKLwyAXmEqT2mSoo'; // TODO: Replace with your actual Gemini API key

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: now));
      _isTyping = true;
    });
    _controller.clear();
    final geminiService = GeminiService(_apiKey);
    final response = await geminiService.getHealthResponse(text);
    setState(() {
      _messages.add(
          ChatMessage(text: response, isUser: false, time: DateTime.now()));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Bot'),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[100],
            child: Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels <
                          notification.metrics.maxScrollExtent - 100) {
                        if (!_showScrollToBottom) {
                          setState(() => _showScrollToBottom = true);
                        }
                      } else {
                        if (_showScrollToBottom) {
                          setState(() => _showScrollToBottom = false);
                        }
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return ChatBubble(message: msg);
                      },
                    ),
                  ),
                ),
                if (_isTyping) TypingIndicator(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 80,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.arrow_downward, color: Colors.white),
                onPressed: _scrollToBottom,
                tooltip: 'Scroll to latest',
              ),
            ),
        ],
      ),
    );
  }
}
