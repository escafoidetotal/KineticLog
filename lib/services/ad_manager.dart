import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/ad_constants.dart';

enum AdLoadState { idle, loading, loaded, failed }

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  AdLoadState _interstitialState = AdLoadState.idle;
  AdLoadState _rewardedState = AdLoadState.idle;

  bool get isInterstitialReady => _interstitialState == AdLoadState.loaded;
  bool get isRewardedReady => _rewardedState == AdLoadState.loaded;

  // ─── Inicialización ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['EMULATOR']),
      );
    }
    _preloadInterstitial();
    _preloadRewarded();
  }

  // ─── Interstitial ─────────────────────────────────────────────────────────

  void _preloadInterstitial() {
    if (_interstitialState == AdLoadState.loading ||
        _interstitialState == AdLoadState.loaded) return;

    _interstitialState = AdLoadState.loading;

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialState = AdLoadState.loaded;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _interstitialState = AdLoadState.failed;
          debugPrint('[AdManager] Interstitial falló: ${error.message}');
          Future.delayed(const Duration(seconds: 30), _preloadInterstitial);
        },
      ),
    );
  }

  /// Muestra el interstitial si está listo. Devuelve true si se mostró.
  Future<bool> showInterstitial({VoidCallback? onDismissed}) async {
    if (!isInterstitialReady || _interstitialAd == null) {
      _preloadInterstitial();
      onDismissed?.call();
      return false;
    }

    final completer = ValueNotifier<bool>(false);

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialState = AdLoadState.idle;
        _preloadInterstitial();
        onDismissed?.call();
        completer.value = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialState = AdLoadState.idle;
        _preloadInterstitial();
        onDismissed?.call();
      },
    );

    await _interstitialAd!.show();
    return true;
  }

  // ─── Rewarded ─────────────────────────────────────────────────────────────

  void _preloadRewarded() {
    if (_rewardedState == AdLoadState.loading ||
        _rewardedState == AdLoadState.loaded) return;

    _rewardedState = AdLoadState.loading;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedState = AdLoadState.loaded;
        },
        onAdFailedToLoad: (error) {
          _rewardedState = AdLoadState.failed;
          debugPrint('[AdManager] Rewarded falló: ${error.message}');
          Future.delayed(const Duration(seconds: 30), _preloadRewarded);
        },
      ),
    );
  }

  /// Muestra el rewarded. Llama [onRewarded] si el usuario completa el vídeo.
  Future<void> showRewarded({
    required VoidCallback onRewarded,
    VoidCallback? onNotAvailable,
    VoidCallback? onDismissed,
  }) async {
    if (!isRewardedReady || _rewardedAd == null) {
      _preloadRewarded();
      onNotAvailable?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedState = AdLoadState.idle;
        _preloadRewarded();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedState = AdLoadState.idle;
        _preloadRewarded();
        onNotAvailable?.call();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) => onRewarded(),
    );
  }

  // ─── Banner ───────────────────────────────────────────────────────────────

  BannerAd createBanner({AdSize size = AdSize.banner}) {
    return BannerAd(
      adUnitId: AdConstants.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('[AdManager] Banner falló: ${error.message}');
        },
      ),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
