import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AriaVoice {
  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<bool> speaking = ValueNotifier(false);

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);    // neutral — avoids adding urgency on top of rate
    await _tts.setSpeechRate(0.42); // deliberate pace; TTS rate is a multiplier on top of device baseline
    await _tts.setVolume(1.0);
    _tts.setStartHandler(() => speaking.value = true);
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setCancelHandler(() => speaking.value = false);
    _tts.setErrorHandler((_) => speaking.value = false);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    speaking.value = false;
  }

  Future<void> dispose() async {
    // Replace all callbacks with no-ops BEFORE stopping.
    // The native TTS engine can emit cancelled/completed events after stop()
    // returns; these must not touch speaking after it is disposed.
    _tts.setStartHandler(() {});
    _tts.setCompletionHandler(() {});
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((_) {});
    await _tts.stop();
    speaking.dispose();
  }
}
