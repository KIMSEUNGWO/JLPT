
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return _bannerAd == null ? SizedBox() :
    SizedBox(
      width: widget.width ?? _bannerAd!.size.width.toDouble(),
      height: widget.height ?? _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
