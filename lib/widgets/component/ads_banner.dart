
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
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
    super.initState();
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
