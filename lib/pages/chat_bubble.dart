import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String time;
  final Color bubbleColor;
  final Color textColor;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.time,
    required this.bubbleColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: isUser ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Align(
            alignment: isUser ? Alignment.topLeft : Alignment.bottomRight,
            child: Text(
              time,
              style: TextStyle(
                color: isUser ? Colors.black54 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
