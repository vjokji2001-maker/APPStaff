// lib/services/speech_service.dart
//
// Centralised, singleton speech-recognition wrapper.
//
// Key performance choices
// ───────────────────────
// • partialResults: true  — text appears word-by-word while speaking, not only
//                           after the microphone closes.
// • ListenMode.dictation  — disables the "confirmation" pause that adds ~1-2 s
//                           of silence before the result is finalised.
// • pauseFor: 800 ms      — stops listening 0.8 s after the user goes silent
//                           (default was 3 s, making it feel "stuck").
// • listenFor: 60 s       — generous max duration; callers can stop earlier.
// • onDevice: true (if available) — eliminates the round-trip to Google's
//                           server for supported locales, cutting latency ~50%.
// • localeId: 'en_IN'     — Indian English; better accent recognition.
//
// Usage
// ─────
//   final speech = SpeechService.instance;
//   await speech.init();
//   speech.startListening(
//     onPartial: (text) => setState(() => _text = text),  // live update
//     onFinal:   (text) { /* do something with final text */ },
//   );
//   speech.stop();

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _initialised = false;
  bool _available   = false;
  bool _listening   = false;

  /// Whether speech recognition is currently capturing audio.
  bool get isListening => _listening;

  /// Whether the underlying STT engine is ready to use.
  bool get isAvailable => _available;

  // ── Init ───────────────────────────────────────────────────────────────────

  /// Must be called once before [startListening].
  /// Safe to call multiple times – subsequent calls are instant no-ops.
  Future<bool> init({String localeId = 'en_IN'}) async {
    if (_initialised && _available) return true;

    // Skip on web — speech_to_text uses dart:io on native only
    if (kIsWeb) {
      debugPrint('SpeechService: speech recognition not supported on web');
      return false;
    }

    try {
      _available = await _stt.initialize(
        onStatus: (status) {
          debugPrint('SpeechService status: $status');
          // 'done' / 'notListening' signals the STT engine stopped by itself
          if (status == 'done' || status == 'notListening') {
            _listening = false;
          }
        },
        onError: (error) {
          debugPrint('SpeechService error: ${error.errorMsg}');
          _listening = false;
        },
        // Request on-device recognition where the OS supports it.
        // Falls back to network automatically if unavailable.
        debugLogging: kDebugMode,
      );
      _initialised = true;
      debugPrint('SpeechService initialised — available: $_available');
    } catch (e) {
      debugPrint('SpeechService.init failed: $e');
      _available   = false;
      _initialised = false;
    }
    return _available;
  }

  // ── Start ──────────────────────────────────────────────────────────────────

  /// Start listening.
  ///
  /// [onPartial] is called with every partial result while the user is
  ///             speaking — use this to update the UI in real-time.
  /// [onFinal]   is called once with the confirmed transcript when the user
  ///             pauses or the session ends.
  /// [localeId]  defaults to 'en_IN' (Indian English).
  Future<void> startListening({
    required void Function(String text) onPartial,
    required void Function(String text) onFinal,
    String localeId = 'en_IN',
  }) async {
    if (kIsWeb) return;

    if (!_available) {
      final ok = await init(localeId: localeId);
      if (!ok) return;
    }

    // Check / re-request permission
    if (!await _stt.hasPermission) {
      final granted = await init(localeId: localeId);
      if (!granted) return;
    }

    // Stop any ongoing session before starting a new one
    if (_listening) await stop();

    _listening = true;

    String _lastPartial = '';

    try {
      await _stt.listen(
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isEmpty) return;

          if (result.finalResult) {
            // Final result — notify both callbacks so UI stays in sync
            onPartial(words);
            onFinal(words);
            _listening = false;
          } else {
            // Partial result — only fire onPartial if text actually changed
            if (words != _lastPartial) {
              _lastPartial = words;
              onPartial(words);
            }
          }
        },
        // ── Performance-tuned parameters ──────────────────────────────────
        listenFor: const Duration(seconds: 60),
        pauseFor:  const Duration(milliseconds: 800),   // stop 0.8 s after silence
        localeId:  localeId,
        listenOptions: stt.SpeechListenOptions(
          partialResults:  true,                        // word-by-word live update
          listenMode:      stt.ListenMode.dictation,    // no confirmation delay
          cancelOnError:   false,
          onDevice:        true,                        // prefer on-device (faster)
        ),
      );
    } catch (e) {
      debugPrint('SpeechService.startListening error: $e');
      _listening = false;
    }
  }

  // ── Stop ───────────────────────────────────────────────────────────────────

  Future<void> stop() async {
    if (!_listening) return;
    try {
      await _stt.stop();
    } catch (e) {
      debugPrint('SpeechService.stop error: $e');
    } finally {
      _listening = false;
    }
  }

  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (e) {
      debugPrint('SpeechService.cancel error: $e');
    } finally {
      _listening = false;
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  /// Call this when the owning widget is permanently destroyed.
  Future<void> dispose() async {
    await cancel();
    _initialised = false;
    _available   = false;
    _listening   = false;
  }
}
