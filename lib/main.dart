import 'package:flutter/material.dart';
import 'package:flutter_application_1/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_controller.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BannerAd? _banner;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _rewardedScore = 0;
  var myContr = Get.put(MyController());
  @override
  void initState() {
    super.initState();

    _createBannerAd();
    _createInterstitialAd();
    _createRewardedAd();
    myContr.loadAd();
  }

  void _createBannerAd() {
    _banner = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: AdHelper.bannerListener,
        request: const AdRequest())
      ..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => setState(() => _rewardedAd = null),
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createInterstitialAd();
      });
      _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) => setState(() => _rewardedScore++));
      _rewardedAd = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Layout")),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Image.asset('Assets/gambar.jpg'),
            titleSection,
            buttonSection,
            Container(
              padding: const EdgeInsets.all(32),
              child: Text(
                  'Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese '
                  'but you aint have any money? you just need ur score above 5 to go there '
                  'UR SCORE IS $_rewardedScore'),
            ),
            ElevatedButton(
                onPressed: _showInterstitialAd,
                child: const Text("InterstitialAd")),
            ElevatedButton(
                onPressed: _showRewardedAd, child: const Text('Get 1 free score')),
            
            Obx(() => Container(
                  child: myContr.isAdLoaded.value
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 100,
                            minHeight: 100,
                          ),
                          child: AdWidget(ad: myContr.nativeAd!))
                      : const SizedBox())),
          ]),
        ),
        bottomNavigationBar: _banner == null
            ? Container()
            : Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 52,
                child: AdWidget(ad: _banner!),
              ),
      ),
    );
  }
}

Widget titleSection = Container(
  padding: const EdgeInsets.all(32),
  child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              "Oeschinen Lake Campground",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "Kandersteg, Switzerland",
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.red,
            ),
            Text("41"),
          ],
        )
      ]),
);

Widget buttonSection = Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: <Widget>[
    btnSection(Icons.phone, 'Phone'),
    btnSection(Icons.navigation, 'Route'),
    btnSection(Icons.share, 'Share')
  ],
);

Container btnSection(IconData icon, String text) {
  return Container(
      child: InkWell(
    onTap: () {},
    child: Column(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.blue,
        ),
        Text(text)
      ],
    ),
  ));
}

Widget textSection = Container(
  padding: const EdgeInsets.all(32),
  child: const Text(
      'Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese '
      'but you aint have any money? you just ur score above 5 to go there '
      'UR SCORE IS'),
);