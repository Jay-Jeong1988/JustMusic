import 'dart:io';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:ads/ads.dart';
import 'package:firebase_admob/firebase_admob.dart';

class AppAds {
  static Ads _ads;
  static Singleton _singleton = Singleton();

  static final String _appId = 'ca-app-pub-7258776822668372~6942506662';

  static eventListener(MobileAdEvent event) async {
//    if (event == MobileAdEvent.loaded) {
//      _ads.showBannerAd();
//    }
  }

  static void init(
      {List<String> keywords, String contentUrl, String bannerUnitId}) {
    _ads ??= Ads(
      _appId,
      bannerUnitId: bannerUnitId,
      keywords: keywords,
      contentUrl: contentUrl,
      childDirected: false,
      testDevices: [],
      testing: false,
    );
    print("app instance created: $_ads");
    _singleton.isAdLoaded = true;
  }


  static void showBanner({size}) {
    _ads?.showBannerAd(
        size: size ?? AdSize.fullBanner);
    _singleton.isAdShowing = true;
    print("app instance showing: $_ads");
  }

//  static void closeBanner() {
//    _ads?.dispose();
//    print("app instance disposed: $_ads");
//    _singleton.isAdOn = false;
//    AppAds.init(bannerUnitId: 'ca-app-pub-7258776822668372/6576702822');
//  }

  static void removeBanner() {
    _ads?.dispose();
    _singleton.isAdShowing = false;
    _singleton.isAdLoaded = false;
    print("app instance disposed: $_ads");
  }

}