import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/iap_constants.dart';
import 'package:super_scan/localization/locales.dart';
import 'package:super_scan/models/singletons_data.dart';
import 'package:super_scan/widgets/universal_webview.dart';

class DonateScreen extends StatefulWidget {
  static const String id = 'donate_screen';

  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  Offering? _offering;
  List<Package> _packages = [];

  bool _loading = true;
  bool _isPurchasing = false;

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted) return;

      if (appData.entitlementIsActive) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              LocaleData.already_donated_alert.getString(context),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  LocaleData.close.getString(context),
                ),
              ),
            ],
          ),
        );
      } else {
        _loadOfferings();
      }
    });
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (!mounted) return;

      if (offerings.current == null) {
        setState(() => _loading = false);
        return;
      }

      final packages = [...offerings.current!.availablePackages];

      // Sort:
      // 1. Subscription first
      // 2. Lifetime last
      // 3. Cheapest first inside each group
      packages.sort((a, b) {
        final aIsLifetime =
            a.storeProduct.productCategory ==
                ProductCategory.nonSubscription;

        final bIsLifetime =
            b.storeProduct.productCategory ==
                ProductCategory.nonSubscription;

        if (aIsLifetime && !bIsLifetime) return 1;
        if (!aIsLifetime && bIsLifetime) return -1;

        return a.storeProduct.price.compareTo(
          b.storeProduct.price,
        );
      });

      int selectedIndex = packages.indexWhere(
            (pkg) =>
        pkg.storeProduct.identifier ==
            'supporter:support-plus-iap',
      );

      if (selectedIndex == -1 && packages.isNotEmpty) {
        selectedIndex = 0;
      }

      setState(() {
        _offering = offerings.current;
        _packages = packages;
        _selectedIndex = selectedIndex;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Offerings load error: $e');

      if (!mounted) return;

      setState(() => _loading = false);
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedIndex == null || _packages.isEmpty) return;

    setState(() => _isPurchasing = true);

    try {
      final pkg = _packages[_selectedIndex!];
      final result = await Purchases.purchasePackage(pkg);

      final entitlement = result.customerInfo.entitlements.all[entitlementID];

      // Update the app state
      appData.entitlementIsActive = entitlement?.isActive ?? false;

      if (!mounted) return;

      if (appData.entitlementIsActive) {
        // 1. Success case: Entitlement is live immediately
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleData.purchase_success.getString(context)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        // 2. Pending case: The purchase call finished, but entitlement isn't active.
        // On Google Play, this typically means a pending transaction.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleData.payment_pending.getString(context)),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // We don't pop the navigator here so the user can see the status,
        // or you can pop and let the listener handle the UI later.
      }
    } catch (e) {
      debugPrint('Purchase error: $e');

      if (!mounted) return;

      // Check if the user simply cancelled (common in pending/slow flows)
      if (e is PlatformException && e.code == '1') { // 1 = User cancelled
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.purchase_failed.getString(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isPurchasing) return;

    setState(() => _isPurchasing = true);

    try {
      final customerInfo =
      await Purchases.restorePurchases();

      final entitlement =
      customerInfo.entitlements.all[entitlementID];

      appData.entitlementIsActive =
          entitlement?.isActive ?? false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appData.entitlementIsActive
                ? LocaleData.restore_success.getString(context)
                : LocaleData.restore_non.getString(context),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (appData.entitlementIsActive) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Restore error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleData.restore_failed.getString(context),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.donate.getString(context)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (PlatformHelper.isDesktop) {
      return Center(
        child: Text(
          LocaleData.desktop_donation_attempt.getString(context),
        ),
      );
    } else if (_packages.isEmpty) {
      return Center(
        child: Text(
         LocaleData.no_donation_options.getString(context),
        ),
      );
    }

    final selectedPackage =
    _selectedIndex != null
        ? _packages[_selectedIndex!]
        : null;

    final selectedPrice =
    selectedPackage == null
        ? ''
        : selectedPackage.storeProduct.productCategory ==
        ProductCategory.nonSubscription
        ? selectedPackage.storeProduct.priceString
        : '${selectedPackage.storeProduct.priceString}${LocaleData.per_month.getString(context)}';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 12),

              Text(
                LocaleData.support_title.getString(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                LocaleData.support_benefits.getString(context),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              ..._packages.asMap().entries.map((entry) {
                final idx = entry.key;
                final pkg = entry.value;
                final product = pkg.storeProduct;

                final isSelected =
                    _selectedIndex == idx;

                final isLifetime =
                    product.productCategory ==
                        ProductCategory
                            .nonSubscription;

                final highlight =
                    product.identifier ==
                        'supporter:support-plus-iap';

                final title = _mapTitle(
                  product.identifier,
                );

                return _tierCard(
                  title: title,
                  price: isLifetime
                      ? product.priceString
                      : '${product.priceString}${LocaleData.per_month.getString(context)}',
                  isSelected: isSelected,
                  isLifetime: isLifetime,
                  onTap: () {
                    setState(() {
                      _selectedIndex = idx;
                    });
                  },
                );
              }),

              TextButton(
                onPressed: _isPurchasing
                    ? null
                    : _restorePurchases,
                child: Text(
                  LocaleData.restore_purchases
                      .getString(context),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UniversalWebView(
                            url:
                            'https://zennon-devhouse.blogspot.com/2026/03/donate-via-kbzpay-superscan.html',
                            title:
                            'Viber မှ တဆင့်လှူဒန်းမည်',
                          ),
                    ),
                  );
                },
                child: const Text(
                  'မြန်မာနိုင်ငံကလား? Viber မှ တဆင့်လှူဒန်းမည်',
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: kAccentColor.withOpacity(
                  0.1,
                ),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    kAccentColor,
                    foregroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isPurchasing
                      ? null
                      : _handlePurchase,
                  child: _isPurchasing
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth:
                      2,
                    ),
                  )
                      : Text(
                    selectedPrice
                        .isEmpty
                        ? LocaleData.support_now_button.getString(context)
                        : '${LocaleData.support_button.getString(context)} $selectedPrice',
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                LocaleData.purchase_footer.getString(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _mapTitle(String id) {
    switch (id) {
      case 'supporter:supporter-iap':
        return LocaleData.iap_supporter.getString(context);

      case 'supporter:support-plus-iap':
        return LocaleData.iap_supporter_plus.getString(context);

      case 'supporter:supporter-super':
        return LocaleData.iap_supporter_super.getString(context);

      case 'supporter:supporter-ultra':
        return LocaleData.iap_support_ultra.getString(context);

      case 'supportermax':
        return LocaleData.otp_max.getString(context);

      default:
        return LocaleData.default_support.getString(context);
    }
  }

  Widget _tierCard({
    required String title,
    required String price,
    required VoidCallback onTap,
    required bool isSelected,
    bool isLifetime = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? kAccentColor.withOpacity(0.2)
              : kAccentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? kAccentColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                if (isLifetime)
                  Text(
                    LocaleData.onetime_payment.getString(context),
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
              ],
            ),

            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}