import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';

class DictionaryBannerAd extends StatefulWidget {
  const DictionaryBannerAd({Key? key}) : super(key: key);

  @override
  _DictionaryBannerAdState createState() => _DictionaryBannerAdState();
}

class _DictionaryBannerAdState extends State<DictionaryBannerAd> {
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidAdUnitId =
      'ca-app-pub-4592603753721232/8369891839';
  static const String _iosAdUnitId = 'ca-app-pub-4592603753721232/6466849196';

  static const List<String> _universalKeywords = [
    'medical',
    'spanish',
    'english',
    'pharmaceutical',
    'doctor',
  ];

  ValueNotifier<List<String>> get adKeywords {
    return DictionaryModel.instance.currentAdKeywords;
  }

  @override
  void initState() {
    super.initState();
    adKeywords.addListener(() {
      _updateKeywords(adKeywords.value);
    });
  }

  Future<void> _updateKeywords(List<String> keywords) async {
    final AdRequest request = (await _bannerAd).request;
    request.keywords!.clear();
    request.keywords!.addAll([
      ..._universalKeywords,
      ...keywords,
    ]);
  }

  late Future<BannerAd> _bannerAd = _getBannerAd();
  late MediaQueryData _query = MediaQuery.of(context);

  Future<BannerAd> _getBannerAd() async {
    final AdSize? adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      _query.orientation,
      // Don't allow the ad to be wider than the screen height so that it
      // doesn't overdraw on screen rotate.
      _query.size.width.truncate(),
    );
    final BannerAd ad = BannerAd(
      adUnitId: _testAdUnitId,
      size: adSize ?? AdSize.banner,
      request: AdRequest(
        keywords: [
          ..._universalKeywords,
          ...adKeywords.value,
        ],
        nonPersonalizedAds: true,
      ),
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, loadAdError) {
          DictionaryApp.analytics.logEvent(
            name: 'ad_load_error',
            parameters: {'ad': ad.toString(), 'error': loadAdError.toString()},
          );
          print(loadAdError);
        },
      ),
    );
    await ad.load();
    return ad;
  }

  @override
  void didChangeDependencies() {
    final MediaQueryData newQuery = MediaQuery.of(context);
    if (newQuery.size != _query.size) {
      _query = newQuery;
      _bannerAd = _getBannerAd();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (const bool.fromEnvironment('is_screenshot')) {
      // Google ads make integration tests hang so skip them if we're in a test
      // environment. Dictionary app uses integration tests to automatically
      // generate screenshots.
      // The `is_integration` environment flag must be set from command line
      // when launching integration tests.
      return Container(height: 50);
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        top: false,
        child: FutureBuilder<BannerAd>(
          future: _bannerAd,
          builder: (context, snap) {
            if (!snap.hasData || snap.data == null) {
              return Container();
            }
            return Container(
              height: snap.data!.size.height.toDouble(),
              width: snap.data!.size.width.toDouble(),
              child: AdWidget(
                ad: snap.data!,
              ),
            );
          },
        ),
      ),
    );
  }
}
