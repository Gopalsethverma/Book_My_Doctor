import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(width: 8),
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 12),
          Text('Bot is typing...'),
        ],
      ),
    );
  }
}
