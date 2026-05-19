import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:jlpt_app/widgets/component/speaker.dart';

class SpeakerTTS extends Speaker {
  late final FlutterTts flutterTts;

  /// `init()` 완료 future. `speak/stopped` 가 init 전/중에 호출돼도 안전하게
  /// 대기할 수 있도록 가드. null 이면 아직 init 호출 자체가 안 됨.
  Future<void>? _initFuture;

  @override
  Future<void> init({Function()? completionHandler}) {
    return _initFuture ??= _doInit(completionHandler);
  }

  Future<void> _doInit(Function()? completionHandler) async {
    flutterTts = FlutterTts();
    await flutterTts.setSharedInstance(true);

    if (Platform.isIOS) {
      await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    await flutterTts.setLanguage("ja-JP");
    // 발음 속도는 플랫폼/시스템 기본값 사용.
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    if (completionHandler != null) {
      flutterTts.setCompletionHandler(completionHandler);
    }
  }

  @override
  Future<void> speak(String word) async {
    if (_initFuture == null) return;
    await _initFuture;
    await flutterTts.stop();
    await flutterTts.speak(word);
  }

  @override
  Future<void> stopped() async {
    if (_initFuture == null) return;
    await _initFuture;
    await flutterTts.stop();
  }
}
