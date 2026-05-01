import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jlpt_app/initdata/update/update_checker.dart';

class InitWidget extends ConsumerStatefulWidget {
  const InitWidget({super.key});

  @override
  ConsumerState<InitWidget> createState() => _InitWidgetState();
}

class _InitWidgetState extends ConsumerState<InitWidget> {
  Future<void> _adsInit() async {
    await MobileAds.instance.initialize();
  }

  @override
  void initState() {
    super.initState();
    _adsInit();
  }

  @override
  Widget build(BuildContext context) => const UpdateChecker();
}
