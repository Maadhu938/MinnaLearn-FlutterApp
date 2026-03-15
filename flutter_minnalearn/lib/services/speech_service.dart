import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class SpeechService {
  SpeechService._internal() {
    _initTts();
  }

  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  static const MethodChannel _channel = MethodChannel('minnalearn/tts');
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;
  bool _isLanguageAvailable = false;

  Future<void> _initTts() async {
    try {
      if (Platform.isAndroid) {
        // Only set Google TTS if it's available, otherwise fallback to default
        final engines = await _flutterTts.getEngines;
        if (engines.contains("com.google.android.tts")) {
          await _flutterTts.setEngine("com.google.android.tts");
        }
      }
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setPitch(1.0);
      
      // Initial check
      _isLanguageAvailable = await _flutterTts.isLanguageAvailable("ja-JP");
      
      _isTtsInitialized = true;
    } catch (e) {
      _isTtsInitialized = false;
    }
  }

  Future<void> openTtsSettings() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('openTtsSettings');
      }
    } catch (_) {}
  }

  Future<bool> speakJapanese(String text) async {
    final value = text.trim();
    if (value.isEmpty) return false;

    if (!_isTtsInitialized) await _initTts();

    try {
      // Re-check availability if it was previously false
      if (!_isLanguageAvailable) {
        _isLanguageAvailable = await _flutterTts.isLanguageAvailable("ja-JP");
      }

      if (!_isLanguageAvailable) return false;

      await _flutterTts.stop();
      await _flutterTts.speak(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> playWrongAnswer() async {
    try {
      await _channel.invokeMethod('playWrongTone');
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> playCorrectAnswer() async {
    try {
      await _channel.invokeMethod('playCorrectTone');
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
