import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'message_model.dart';
import 'chat_bubble.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});

  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  final _messageController = TextEditingController();
  final List<MessageModel> _messages = [];
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    const apiKey =
        'AIzaSyA8s0uZi2ws1166UZaUkqluzoD73ffhxfg'; // Updated with provided API key
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    ); // Updated model name to gemini-2.0-flash
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "مساعدك الطبي الافتراضي",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "تنبيه: الإجابات هنا ليست تشخيصًا طبيًا. يُرجى استشارة الطبيب للتأكد.",
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  isUser: message.isUser,
                  message: message.message,
                  time: DateFormat('hh:mm a').format(message.time),
                  bubbleColor:
                      message.isUser
                          ? const Color.fromARGB(255, 216, 133, 224)
                          : Colors.grey.shade300,
                  textColor: message.isUser ? Colors.black : Colors.black87,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(fontSize: 17, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Message Gemini...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueGrey,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text;
    setState(() {
      _messages.add(
        MessageModel(isUser: true, message: message, time: DateTime.now()),
      );
    });
    _messageController.clear();

    final response = await _model.generateContent([Content.text(message)]);
    final responseText = response.text;
    if (responseText != null) {
      setState(() {
        _messages.add(
          MessageModel(
            isUser: false,
            message: responseText,
            time: DateTime.now(),
          ),
        );
      });
    }
  }
}
