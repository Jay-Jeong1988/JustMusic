import 'dart:io';
import 'package:ads/ads.dart';
import 'package:firebase_admob/firebase_admob.dart';

class AppAds {
  static Ads _ads;

  static final String _appId = 'ca-app-pub-7258776822668372~6942506662';

  static eventListener(MobileAdEvent event) async{
    if (event == MobileAdEvent.loaded) {
      _ads.showBannerAd();
    }
  }

  static void init({List<String> keywords, String contentUrl, String bannerUnitId}) => _ads ??= Ads(
    _appId,
    bannerUnitId: bannerUnitId,
    keywords: keywords,
    contentUrl: contentUrl,
    childDirected: false,
    testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
    testing: false,
  );

  static showBanner({size}) => _ads.showBannerAd(
    listener: eventListener,
      size: size ?? AdSize.fullBanner,
  );

  static void hideBanner() => _ads?.hideBannerAd();

  /// Remember to call this in the State object's dispose() function.
  static void dispose() {
    _ads?.dispose();
    print("ad is disposed");
  }
}