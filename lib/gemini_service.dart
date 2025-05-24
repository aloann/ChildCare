import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class GeminiService {
  String? _apiKey;
  final String _baseUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=";

  Future<void> _loadApiKey() async {
    final String response = await rootBundle.loadString('assets/api_keys.json');
    final data = json.decode(response);
    _apiKey = data['gemini_api_key'];
  }

  Future<String> getGeminiResponse(String prompt) async {
    if (_apiKey == null) {
      await _loadApiKey();
    }

    if (_apiKey == null) {
      return "Error: API Key not loaded.";
    }

    final url = Uri.parse('$_baseUrl$_apiKey');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      "contents": [{
        "role": "user",
        "parts": [{"text": prompt}]
      }]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null && 
            jsonResponse['candidates'].isNotEmpty && 
            jsonResponse['candidates'][0]['content'] != null) {
          return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "لم أتمكن من فهم السؤال. هل يمكنك إعادة صياغته بطريقة مختلفة؟";
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return "حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.";
      }
    } catch (e) {
      print("Exception: $e");
      return "حدث خطأ غير متوقع. يرجى التحقق من اتصالك بالإنترنت.";
    }
  }
}
