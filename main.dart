import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:animator/animator.dart';
import 'package:animated_button/animated_button.dart';
import 'package:url_launcher/url_launcher.dart'as urlLauncher;
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const int maxAttempts = 3;

class _MyAppState extends State<MyApp> {

  bool carregar = false;
  bool splash = true;
  late BannerAd staticAd;
  bool staticAdLoaded = false;
  InterstitialAd? interstitialAd;
  int numInterstitialLoadAttempts = 0;
  static const AdRequest request = AdRequest(
    // keywords: ['', ''],
    // contentUrl: '',
    // nonPersonalizedAds: false
  );

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-2222616495258461/6844682742',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            interstitialAd = ad;
            numInterstitialLoadAttempts = 0;
            interstitialAd?.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            numInterstitialLoadAttempts += 1;
            interstitialAd = null;
            if (numInterstitialLoadAttempts < maxAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      _launchURL(context);
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _launchURL(context);
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _launchURL(context);
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    interstitialAd?.show();
    interstitialAd = null;
  }

  void loadStaticBannerAd() {
    staticAd = BannerAd(
        adUnitId: "ca-app-pub-2222616495258461/2897968375",
        size: AdSize.banner,
        request: request,
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                staticAdLoaded = true;
              });
            },
            onAdFailedToLoad: (ad, error){
              ad.dispose();
              print('ad failed to load ${error.message}');
            }
        )
    );
    staticAd.load();
  }

  void splashScreen(){
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        splash = false;
      });
      timer.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    splashScreen();
    loadStaticBannerAd();
    createInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT - Quick Acess',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          color: Color(0xFF263238),
        ),
      ),
      home: Builder(
        builder: (context) => Scaffold(
          drawer: Drawer(
            backgroundColor: Color(0xFF263238),
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountEmail: Text(
                    ' Powerful artificial intelligence assistant.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  currentAccountPicture: Image.asset(
                    "imagens/chat.png",
                    fit: BoxFit.fill,
                  ),
                  accountName: Container(
                    padding: EdgeInsets.all(3),
                    child: Text(
                      "ChatGPT - Quick Acess",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Share.share('ChapGPT - Quick Acess in Play Store: https://play.google.com/store/apps/details?id=developer.flutter.chatgpt');
                  },
                  child: ListTile(
                    leading: Icon(Icons.share,
                      color: Colors.white,
                    ),
                    title: RichText(
                      text: TextSpan(
                        text: "Share",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    var url = "https://play.google.com/store/apps/details?id=developer.flutter.chatgpt";
                    if (await urlLauncher.canLaunch(url)){
                      await urlLauncher.launch(url);
                    }else{
                      throw "site fora do ar";
                    }
                  },
                  child: ListTile(
                    leading: Icon(Icons.open_in_new,
                      color: Colors.white,
                    ),
                    title: RichText(
                      text: TextSpan(
                        text: "Rate us ★★★★★",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            child: AdWidget(ad: staticAd,),
            width: staticAd.size.width.toDouble(),
            height: staticAd.size.height.toDouble(),
            alignment: Alignment.bottomCenter,
          ),
          appBar: AppBar(
            centerTitle: true,
            title: const Text('ChatGPT - Quick Acess',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 180,
                        width: 180,
                        child: Animator<double>(
                          duration: Duration(milliseconds: 3000),
                          cycles: 0,
                          curve: Curves.easeInOut,
                          tween: Tween<double>(begin: 0, end: 8),
                          builder: (context, animatorState,
                              child)=> Container(
                            margin: EdgeInsets.all(animatorState.value),
                            child: Container(
                              height: 160,
                              width: 160,
                              child: Image.asset(
                                "imagens/chat.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(50),
                        child: Container(
                          child: Text(
                            'ChatGPT is famous for its powerful human-like conversation features. You can ask almost all types of questions from science, life questions, writing emails, writing essays, ads, coding, and even playing games with you.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      AnimatedButton(
                        color:Colors.green,
                        onPressed: (){
                          showInterstitialAd();
                          setState(() {
                            carregar = true;
                          });
                        },
                        child: Text(
                          'Start ChatGPT',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if(splash)
                  Container(
                    color: Colors.blueGrey,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Color(0xFF263238),
                        color: Colors.white,
                      ),
                    ),
                  ),
                if(carregar)
                  Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xFF263238),
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launch(
        'https://chat.openai.com/chat',
        customTabsOption: CustomTabsOption(
          toolbarColor: Color(0xFF263238),
          enableDefaultShare: false,
          enableUrlBarHiding: true,
          showPageTitle: false,
          animation: CustomTabsSystemAnimation.fade(),
          extraCustomTabs: const <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: Color(0xFF263238),
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
      setState(() {
        carregar = false;
      });
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
      setState(() {
        carregar = false;
      });
    }
  }
}