import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// One utterance at a time; callbacks belong to the tab that starts listening.
class VitalsVoiceSession {
  VitalsVoiceSession({stt.SpeechToText? speech})
    : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  static VitalsVoiceSession? _owner;
  Timer? _endTimer;
  Timer? _watchdog;
  int _generation = 0;
  bool _active = false;
  bool _starting = false;
  bool _disposed = false;
  int _busyRetries = 0;
  int _clientRetries = 0;
  bool _onDevice = false;
  stt.SpeechStatusListener? _previousStatus;
  stt.SpeechErrorListener? _previousError;

  Future<void> start({
    required void Function(String) onPartial,
    required void Function(String) onFinal,
    required void Function() onEmpty,
    required void Function(String) onError,
  }) async {
    if (_disposed || _starting || _active) return;
    _starting = true;
    final generation = ++_generation;
    bool current() => !_disposed && generation == _generation;
    String lastWords = '';
    bool finishing = false;

    Future<void> finish({String? error, bool stopNative = true}) async {
      if (!current() || finishing) return;
      finishing = true;
      _endTimer?.cancel();
      _watchdog?.cancel();
      _active = false;
      // Detach before cancelling: cancellation itself emits status callbacks.
      _speech.statusListener = null;
      _speech.errorListener = null;
      // A final result/error already ends the native request. Cancelling it
      // again can generate ERROR_CLIENT during the following Android request.
      if (stopNative && _speech.isListening) await _speech.stop();
      if (!current()) return;
      _starting = false;
      if (error != null) {
        onError(error);
      } else if (lastWords.isNotEmpty) {
        _busyRetries = 0;
        _clientRetries = 0;
        onFinal(lastWords);
      } else {
        onEmpty();
      }
    }

    try {
      if (_owner != null && _owner != this) await _owner!.stop();
      if (_owner != this) {
        _previousStatus = _speech.statusListener;
        _previousError = _speech.errorListener;
      }
      _owner = this;
      final available = await _speech.initialize();
      if (!current()) return;
      if (!available) {
        _starting = false;
        onError(
          'Speech unavailable. Enable microphone and speech recognition in Settings.',
        );
        return;
      }
      _speech.statusListener = null;
      _speech.errorListener = null;
      if (_speech.isListening) await _speech.stop();
      // Android's recognizer releases its audio session asynchronously.
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (!current()) return;
      _speech.statusListener = (status) {
        if (!current() || finishing) return;
        if (status == 'done' || status == 'notListening') {
          // Some devices send done before the final transcript.
          _endTimer?.cancel();
          _endTimer = Timer(const Duration(milliseconds: 2200), finish);
        }
      };
      _speech.errorListener = (error) {
        if (!current() || finishing) return;
        final clientError = error.errorMsg == 'error_client';
        if (clientError) lastWords = '';
        if (clientError && defaultTargetPlatform == TargetPlatform.android) {
          // Switching mode causes the plugin to create a fresh recognizer.
          _onDevice = !_onDevice;
        }
        final retryable =
            error.errorMsg.contains('no_match') ||
            error.errorMsg.contains('speech_timeout') ||
            (error.errorMsg.contains('busy') && _busyRetries++ < 2) ||
            (clientError && _clientRetries++ < 2);
        finish(error: retryable ? null : error.errorMsg, stopNative: false);
      };
      _active = true;
      _watchdog = Timer(const Duration(seconds: 20), finish);
      await _speech.listen(
        onResult: (result) {
          if (!current() || finishing) return;
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            lastWords = words;
            onPartial(lastWords);
          }
          if (result.finalResult) finish(stopNative: false);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: _onDevice,
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (error) {
      await finish(error: 'Could not start microphone: $error');
    } finally {
      if (current()) _starting = false;
    }
  }

  Future<void> stop() async {
    ++_generation;
    _endTimer?.cancel();
    _watchdog?.cancel();
    _active = false;
    _starting = false;
    if (_owner == this) {
      _speech.statusListener = null;
      _speech.errorListener = null;
      _owner = null;
      if (_speech.isListening) await _speech.cancel();
      if (_owner == null) {
        _speech.statusListener = _previousStatus;
        _speech.errorListener = _previousError;
      }
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(stop());
  }
}
