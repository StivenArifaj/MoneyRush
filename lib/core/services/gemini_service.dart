import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GeminiService {
  static Future<String> getAdvisorResponse({
    required String scenarioSituation,
    required String chosenOptionText,
    required String consequenceText,
    required String knowledgeEntry,
    required Map<String, int> relevantDomainScores,
    required Map<String, dynamic> financialState,
  }) async {
    if (AppConstants.geminiKey.isEmpty) {
      return _fallback(wasOptimal: false);
    }

    final avgScore = relevantDomainScores.isEmpty
        ? 30
        : (relevantDomainScores.values.reduce((a, b) => a + b) /
                relevantDomainScores.length)
            .round();

    final prompt = '''
${AppConstants.advisorSystemPrompt}

CURRENT SCENARIO: $scenarioSituation
PLAYER CHOSE: $chosenOptionText
CONSEQUENCE: $consequenceText
KNOWLEDGE REFERENCE: $knowledgeEntry
PLAYER KNOWLEDGE SCORES: $relevantDomainScores (average: $avgScore/100)
PLAYER FINANCIAL STATE: bank_balance=\$${financialState['bank_balance']}, monthly_income=\$${financialState['monthly_income']}, net_worth=\$${financialState['net_worth']}

Respond as the advisor now. 3-4 sentences only. Do not exceed 4 sentences.
''';

    try {
      final uri = Uri.parse(
        '${AppConstants.geminiBaseUrl}/${AppConstants.geminiModel}:generateContent'
        '?key=${AppConstants.geminiKey}',
      );

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 200,
                'topP': 0.9,
              },
              'safetySettings': [
                {
                  'category': 'HARM_CATEGORY_HARASSMENT',
                  'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                },
                {
                  'category': 'HARM_CATEGORY_HATE_SPEECH',
                  'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return _fallback(wasOptimal: false);
      }

      final json = jsonDecode(response.body);
      final text = json['candidates']?[0]?['content']?['parts']?[0]?['text']
          as String?;

      return text?.trim() ?? _fallback(wasOptimal: false);
    } catch (_) {
      return _fallback(wasOptimal: false);
    }
  }

  // Shown when Gemini is unreachable — keeps the experience intact offline
  static String _fallback({required bool wasOptimal}) {
    if (wasOptimal) {
      return "That was a solid move. You understood the trade-offs and chose the option that works best for your current situation. Keep thinking this way and you'll build real financial strength over time.";
    }
    return "That decision had a cost — and now you've felt it. Next time, consider how this same situation might play out differently. Every mistake here is a lesson that protects you in real life.";
  }
}
