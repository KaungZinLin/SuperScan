import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'ad_helper.dart';

class InlineAdManager {
  InlineAdManager._();

  static final Map<int, BannerAd> _ads = {};
  static final ValueNotifier<int> adUpdate = ValueNotifier(0);

  /// Create ad ONLY if it doesn't exist
  static BannerAd getAd(int slot) {
    return _ads.putIfAbsent(slot, () {
      final ad = BannerAd(
        adUnitId: AdHelper.inlineBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            // Ad is ready to display
            adUpdate.value++; // notify UI
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _ads.remove(slot);
          },
        ),
      )..load();

      return ad;
    });
  }

  /// Check if ad is actually ready (safe display gate)
  static bool isAdReady(int slot) {
    return _ads.containsKey(slot);
  }

  /// Dispose all ads (important for memory safety)
  static void dispose() {
    for (final ad in _ads.values) {
      ad.dispose();
    }
    _ads.clear();
  }

  static int activeAdSlotsCount(int adFrequency, int itemCount) {
    int count = 0;

    for (int i = 0; i < itemCount; i++) {
      if ((i + 1) % (adFrequency + 1) == 0) {
        count++;
      }
    }

    return count;
  }
}