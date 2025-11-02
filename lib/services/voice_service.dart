import 'dart:convert';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart'; // backup TTS
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class VoiceService {
  // 🎙️ Speech & Audio
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _fallbackTts = FlutterTts();

  // 🔑 API Keys
  final String geminiApiKey = "AIzaSyB5Edx_8VwOvLmviwgAPNpmtbaj1eSvToA";
  final String elevenLabsApiKey = "sk_5d7069e9ea1deab6aa955c02e84a5156a541929a9a2567c2"; // put your key
  final String elevenVoiceId = "4BoDaQ6aygOP6fpsUmJe";
  final String geminiModel = "gemini-2.0-flash";

  // ✅ Detect if text is Hindi
  bool _isHindi(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]+');
    return hindiRegex.hasMatch(text);
  }

  // 🎧 ElevenLabs speech
  Future<void> speakWithElevenLabs(
    String text, {
    double rate = 1.0,
    bool isHindi = false,
    VoidCallback? onStart,
    VoidCallback? onEnd,
  }) async {
    onStart?.call();
    final voiceId = elevenVoiceId;
    final uri = Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voiceId");

    final body = jsonEncode({
      "text": text,
      "model_id": "eleven_multilingual_v2",
      "voice_settings": {
        "stability": 0.15,
        "similarity_boost": 0.85,
        "style": rate.clamp(0.5, 1.5),
        "use_speaker_boost": true
      }
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          "Accept": "audio/mpeg",
          "Content-Type": "application/json",
          "xi-api-key": elevenLabsApiKey,
        },
        body: body,
      );

      if (response.statusCode == 200 &&
          (response.headers['content-type']?.contains('audio') ?? false)) {
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/tts_output.mp3");
        await file.writeAsBytes(response.bodyBytes);

        await _player.stop();
        await _player.play(DeviceFileSource(file.path), mode: PlayerMode.lowLatency);
        _player.onPlayerComplete.listen((_) => onEnd?.call());
      } else {
        print("❌ ElevenLabs error: ${response.body}");
        await _fallbackTts.speak(text);
        onEnd?.call();
      }
    } catch (e) {
      print("⚠️ ElevenLabs exception: $e");
      await _fallbackTts.speak(text);
      onEnd?.call();
    }
  }

  // 🎤 Long-duration speech recognition (Hindi + English)
  Future<String?> listenUserSpeech({
    Duration maxDuration = const Duration(seconds: 60),
    String initialLocale = "en-IN",
  }) async {
    bool available = await _speech.initialize(
      onError: (err) => print("⚠️ Speech error: $err"),
      onStatus: (status) => print("🎧 Status: $status"),
    );

    if (!available) {
      print("❌ Speech recognition unavailable");
      return null;
    }

    String finalResult = "";
    bool isListening = true;

    // Listen in English first
    await _speech.listen(
      listenFor: maxDuration,
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: initialLocale,
      onResult: (result) {
        final text = result.recognizedWords.trim();
        if (text.isNotEmpty) {
          finalResult = text;
        }
      },
    );

    // Wait until listening finishes
    final start = DateTime.now();
    while (isListening && DateTime.now().difference(start) < maxDuration) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_speech.isListening) {
        isListening = false;
      }
    }

    await _speech.stop();

    // If empty or Hindi detected → try Hindi mode
    if (finalResult.isEmpty || _isHindi(finalResult)) {
      print("🔁 Switching to Hindi recognition...");
      finalResult = "";
      await _speech.listen(
        listenFor: maxDuration,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: "hi-IN",
        onResult: (result) {
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) {
            finalResult = text;
          }
        },
      );

      final start2 = DateTime.now();
      bool listeningHindi = true;
      while (listeningHindi && DateTime.now().difference(start2) < maxDuration) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_speech.isListening) {
          listeningHindi = false;
        }
      }
      await _speech.stop();
    }

    print("🎙️ Final Speech Result: $finalResult");
    return finalResult.isNotEmpty ? finalResult : null;
  }

  // 🧠 Get Gemini reply
  Future<String> getGeminiReply(String query, {bool detailed = false}) async {
    final isHindi = _isHindi(query);

    final tonePrompt = isHindi
        ? "तुम एक दोस्ताना और जानकारीपूर्ण वर्चुअल गाइड हो।"
        : "You are a friendly and knowledgeable virtual tour guide.";

    final stylePrompt = detailed
        ? (isHindi
            ? "उत्तर विस्तृत और रोचक दो।"
            : "Give a detailed, engaging answer.")
        : (isHindi
            ? "उत्तर छोटा और स्पष्ट दो।"
            : "Give a short and clear answer.");

    final langPrompt = isHindi ? "उत्तर केवल हिंदी में दो।" : "Reply only in English.";

    final prompt = "$tonePrompt\n$stylePrompt\n$langPrompt\nUser said: \"$query\"";

    try {
      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {"role": "user", "parts": [{"text": prompt}]}
          ]
        }),
      );

      final data = jsonDecode(response.body);
      final reply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      return reply ??
          (isHindi ? "माफ़ कीजिए, मैं नहीं समझ पाया।" : "Sorry, I didn’t catch that.");
    } catch (e) {
      print("⚠️ Gemini API error: $e");
      return isHindi ? "कुछ गड़बड़ हो गई।" : "Something went wrong.";
    }
  }

  // 🎵 Intro audio
  Future<void> playIntroAudio() async {
    await speakWithElevenLabs(
      "Hey there! I'm your virtual guide today — ready for an awesome tour?",
    );
  }

  void dispose() {
    _player.dispose();
    _fallbackTts.stop();
  }
}
