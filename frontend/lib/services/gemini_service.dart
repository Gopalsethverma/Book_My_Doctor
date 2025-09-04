import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', // Updated to latest model
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.5,
            topP: 0.9,
            topK: 40,
            maxOutputTokens: 2048,
          ),
          safetySettings: [
            SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
            SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
            SafetySetting(
              HarmCategory.sexuallyExplicit,
              HarmBlockThreshold.medium,
            ),
            SafetySetting(
              HarmCategory.dangerousContent,
              HarmBlockThreshold.medium,
            ),
          ],
        );

  Future<String> getHealthResponse(String prompt) async {
    try {
      final content = Content.text(
        '''You are a professional health assistant named HealthBot. Follow these rules:
1. Provide accurate, evidence-based health information
2. For serious symptoms, advise consulting a doctor immediately
3. Never diagnose - only suggest possibilities
4. Be empathetic and clear
5. If question isn't health-related, politely decline
6. Always include a disclaimer that you're not a substitute for professional medical advice

Current conversation: $prompt''',
      );

      final response = await _model.generateContent([content]);
      return response.text?.trim() ??
          "I couldn't process that request. Please try again.";
    } catch (e) {
      return "Sorry, I'm having trouble responding. Please try again later. Error: " +
          e.toString();
    }
  }
}
