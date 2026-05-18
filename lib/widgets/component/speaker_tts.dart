
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:jlpt_app/widgets/component/speaker.dart';

class SpeakerTTS extends Speaker {

  late final FlutterTts flutterTts;

  @override
  Future<void> init({Function()? completionHandler}) async {
    flutterTts = FlutterTts();
    await flutterTts.setSharedInstance(true);

    if (Platform.isIOS) {
      await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.voicePrompt
      );
    }

    await flutterTts.setLanguage("ja-JP");
    // 발음 속도는 플랫폼/시스템 기본값 사용 (이전 0.5 는 너무 빠르게 들렸음).
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    if (completionHandler != null) {
      flutterTts.setCompletionHandler(completionHandler);
    }
  }

  @override
  Future<void> speak(String word) async {
    await stopped();
    await flutterTts.speak(word);
  }

  @override
  Future<void> stopped() async {
    await flutterTts.stop();
  }

}