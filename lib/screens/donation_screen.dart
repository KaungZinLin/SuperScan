import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/widgets/universal_webview.dart';

class DonateScreen extends StatelessWidget {
  static const String id = 'donate_screen';

  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Thank You!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Keeping SuperScan ad-free and paywall-free is the dream, but for now, those ads help me cover development costs and keep the app alive. If you want to help me out and get a cleaner, ad-free experience with access to AI features in return, pick a donation option below. Thanks for being awesome!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              const Text(
                'Select an amount to donate from the Apple App Store or the Google Play Store',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  const Text(
                    'Recurring Donations',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _buildAmountList(context, [
                      '\$5',
                      '\$10',
                      '\$25',
                      '\$60',
                      '\$100',
                    ]),
                  ),

                  const SizedBox(height: 32), // Clearer gap between sections
                  // Section 2: One-time
                  const Text(
                    'One-time Donations',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _buildAmountList(context, [
                      '\$5',
                      '\$10',
                      '\$25',
                      '\$60',
                      '\$100',
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildDonationButton(context, 'Restore Purchases'),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 24),
              _buildLinkTile(
                icon: Icons.wallet_rounded,
                label: 'Donate via KBZPay (Myanmar)',
                color: const Color(0xFF1044A4),
                onTap: () {
                  Navigator.push(
                    context,
                      MaterialPageRoute(builder: (_) => UniversalWebView(url: kKbzPayDonationMethodUrl, title: 'Donate via KBZPay'))
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationButton(BuildContext context, String amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccentColor.withAlpha(30),
        foregroundColor: kAccentColor,
        elevation: 0,
        // Removes standard shadow
        shadowColor: Colors.transparent,
        // Removes shadow color entirely
        // Removes lift when focused
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (!PlatformHelper.isDesktop) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coming soon...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Due to platform limitations, you can only donate from alternative methods on desktop.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      tileColor: color.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  List<Widget> _buildAmountList(BuildContext context, List<String> amounts) {
    return amounts
        .map((amount) => _buildDonationButton(context, amount))
        .toList();
  }
}
