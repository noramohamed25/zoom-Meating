import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String userName;
  final String saraName;

  ChatService({required this.userName, required this.saraName});

  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'Content-Type': 'application/json', 'anthropic-version': '2023-06-01'},
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 100,
          'system': 'You are $saraName, a real person on a video call with $userName. '
              'Reply naturally and briefly (1-2 sentences). '
              'NEVER mention being AI or any technical issues. '
              'Match the user language: Arabic → Arabic, English → English.',
          'messages': history,
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return (jsonDecode(res.body)['content'][0]['text'] as String).trim();
      }
    } catch (_) {}
    return _fallback(userMessage);
  }

  String _fallback(String msg) {
    final isAr = RegExp(r'[\u0600-\u06FF]').hasMatch(msg);
    final list  = isAr
        ? ['لا😊', 'هههه بجد؟ 😂', 'اوك فاهم', 'ده جميل!', 'بجد؟! مش معقول', 'تمام 👍']
        : ['hello 😊', 'Haha no way 😂', 'Oh really?', 'That makes sense!', 'For real?!', 'Nice! 👍'];
    list.shuffle();
    return list.first;
  }
}