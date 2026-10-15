import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:staff_mate/services/vitals_voice_session.dart';

class FakeSpeech implements stt.SpeechToText {
  @override
  stt.SpeechStatusListener? statusListener;
  @override
  stt.SpeechErrorListener? errorListener;
  dynamic result;
  int starts = 0;
  int cancels = 0;
  final modes = <bool>[];
  @override
  bool isListening = false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #initialize) return Future.value(true);
    if (invocation.memberName == #cancel) {
      cancels++;
      isListening = false;
      return Future<void>.value();
    }
    if (invocation.memberName == #stop) {
      isListening = false;
      return Future<void>.value();
    }
    if (invocation.memberName == #listen) {
      starts++;
      isListening = true;
      modes.add(
        (invocation.namedArguments[#listenOptions] as stt.SpeechListenOptions)
            .onDevice,
      );
      result = invocation.namedArguments[#onResult];
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }

  void say(String words, {bool finalResult = true}) {
    if (finalResult) isListening = false;
    result(
      SpeechRecognitionResult.init([
        SpeechRecognitionWords(words, null, 1),
      ], finalResult ? ResultType.finalResult : ResultType.partial),
    );
  }
}

void main() {
  testWidgets(
    'Android client errors recreate recognition mode with bounded retries',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final engine = FakeSpeech();
      final voice = VitalsVoiceSession(speech: engine);
      var retries = 0;
      final errors = <String>[];
      for (var attempt = 0; attempt < 3; attempt++) {
        final pending = voice.start(
          onPartial: (_) {},
          onFinal: (_) => fail('Client failure must not fill a field'),
          onEmpty: () => retries++,
          onError: errors.add,
        );
        await tester.pump(const Duration(milliseconds: 1000));
        await pending;
        engine.isListening = false;
        engine.errorListener!(SpeechRecognitionError('error_client', true));
        await tester.pump();
      }
      expect(engine.modes, [false, true, false]);
      expect(retries, 2);
      expect(errors, ['error_client']);
      expect(engine.cancels, 0);
      voice.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('silent native session times out and can restart', (
    tester,
  ) async {
    final engine = FakeSpeech();
    final voice = VitalsVoiceSession(speech: engine);
    var empty = 0;
    Future<void> start() => voice.start(
      onPartial: (_) {},
      onFinal: (_) => fail('Unexpected transcript'),
      onEmpty: () => empty++,
      onError: (error) => fail(error),
    );
    var pending = start();
    await tester.pump(const Duration(milliseconds: 1000));
    await pending;
    await tester.pump(const Duration(seconds: 20));
    expect(empty, 1);
    pending = start();
    await tester.pump(const Duration(milliseconds: 1000));
    await pending;
    expect(engine.starts, 2);
    voice.dispose();
  });

  testWidgets('can capture a second value and ignores duplicate finals', (
    tester,
  ) async {
    final engine = FakeSpeech();
    final voice = VitalsVoiceSession(speech: engine);
    final values = <String>[];
    Future<void> start() => voice.start(
      onPartial: (_) {},
      onFinal: values.add,
      onEmpty: () {},
      onError: (error) => fail(error),
    );
    var pending = start();
    await tester.pump(const Duration(milliseconds: 1000));
    await pending;
    engine.say('98.6');
    engine.say('98.6');
    await tester.pump();
    pending = start();
    await tester.pump(const Duration(milliseconds: 1000));
    await pending;
    engine.say('72');
    await tester.pump();
    expect(values, ['98.6', '72']);
    expect(
      engine.cancels,
      0,
      reason: 'Completed native requests must not be cancelled',
    );
    expect(engine.starts, 2);
    voice.dispose();
  });

  testWidgets('uses last partial when native final result is missing', (
    tester,
  ) async {
    final engine = FakeSpeech();
    final voice = VitalsVoiceSession(speech: engine);
    final values = <String>[];
    final pending = voice.start(
      onPartial: (_) {},
      onFinal: values.add,
      onEmpty: () {},
      onError: (error) => fail(error),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await pending;
    engine.say('250', finalResult: false);
    engine.statusListener!('notListening');
    engine.statusListener!('done');
    await tester.pump(const Duration(milliseconds: 2200));
    expect(values, ['250']);
    voice.dispose();
  });

  testWidgets(
    'closing session prevents a delayed result entering another field',
    (tester) async {
      final engine = FakeSpeech();
      final voice = VitalsVoiceSession(speech: engine);
      final values = <String>[];
      final pending = voice.start(
        onPartial: (_) {},
        onFinal: values.add,
        onEmpty: () {},
        onError: (error) => fail(error),
      );
      await tester.pump(const Duration(milliseconds: 1000));
      await pending;
      final oldResult = engine.result;
      await voice.stop();
      oldResult(
        SpeechRecognitionResult.init([
          const SpeechRecognitionWords('120', null, 1),
        ], ResultType.finalResult),
      );
      await tester.pump();
      expect(values, isEmpty);
      voice.dispose();
    },
  );
}
