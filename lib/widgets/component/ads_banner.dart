import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jlpt_app/component/ad_helper.dart';

class SimpleBannerAd extends StatefulWidget {
  final double? width;
  final double? height;
  const SimpleBannerAd({super.key, this.width, this.height});

  @override
  State<SimpleBannerAd> createState() => _SimpleBannerAdState();
}

class _SimpleBannerAdState extends State<SimpleBannerAd> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    try {
      final ad = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() => _bannerAd = ad as BannerAd);
          },
          onAdFailedToLoad: (ad, _) => ad.dispose(),
        ),
      );
      ad.load();
    } on UnsupportedError {
      // 광고가 지원되지 않는 플랫폼에서는 배너 영역을 렌더링하지 않는다.
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (bannerAd == null) return const SizedBox();
    return SizedBox(
      width: widget.width ?? bannerAd.size.width.toDouble(),
      height: widget.height ?? bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}
