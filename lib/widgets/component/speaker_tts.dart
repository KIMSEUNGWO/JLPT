import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/widgets/component/speaker.dart';

/// FlutterTts 래퍼.
///
/// 일부 플랫폼(macOS 데스크톱·일부 시뮬레이터)에는 TTS 채널이 등록 안 돼
/// 있을 수 있다 — 이 경우 init 이 `MissingPluginException` 을 throw 한다.
/// 사용자 흐름을 막지 않도록 모든 실패는 내부에서 흡수하고
/// [speak]/[stopped] 는 no-op 으로 graceful degrade 한다.
class SpeakerTTS extends Speaker {
  /// 발음 locale (예: 'ja-JP'). 활성 코스에서 주입된다.
  SpeakerTTS({required this.locale});

  final String locale;

  /// 초기화 성공 시에만 보관 — null 이면 TTS 사용 불가능한 환경.
  FlutterTts? _flutterTts;
  Future<void>? _initFuture;

  @override
  Future<void> init({Function()? completionHandler}) async {
    _initFuture ??= _doInit();
    await _initFuture;

    // 자동 발음이 먼저 init 을 시작한 뒤 AudioWaveAnimation 이 붙어도
    // 완료 콜백은 늦게 등록할 수 있어야 한다.
    if (completionHandler != null) {
      _flutterTts?.setCompletionHandler(completionHandler);
    }
  }

  Future<void> _doInit() async {
    try {
      final tts = FlutterTts();

      if (Platform.isIOS) {
        await tts.setSharedInstance(true);
        await tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      await tts.setLanguage(locale);
      // 발음 속도는 플랫폼/시스템 기본값 사용.
      await tts.setVolume(1.0);
      await tts.setPitch(1.0);

      // 모든 초기화에 성공한 경우에만 인스턴스를 보관.
      _flutterTts = tts;
    } catch (e, st) {
      appLogger.w('[tts] init failed (graceful degrade): $e\n$st');
    }
  }

  @override
  Future<void> speak(String word) async {
    await init();
    final tts = _flutterTts;
    if (tts == null) return;
    try {
      await tts.stop();
      await tts.speak(word);
    } catch (e) {
      appLogger.w('[tts] speak failed: $e');
    }
  }

  @override
  Future<void> stopped() async {
    if (_initFuture == null) return;
    await _initFuture;
    final tts = _flutterTts;
    if (tts == null) return;
    try {
      await tts.stop();
    } catch (_) {
      // stop 실패는 무시 — 이미 멈췄거나 채널이 끊긴 경우.
    }
  }
}
