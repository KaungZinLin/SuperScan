import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:super_scan/helpers/platform_helper.dart';

class DonateScreen extends StatelessWidget {
  static const String id = 'donate_screen';

  const DonateScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support SuperScan'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: kTextLetterSpacing.letterSpacing,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Keeping SuperScan ad-free is the dream, but for now, those ads help me cover development costs and keep the app alive. If you want to help me out and get a cleaner, ad-free experience in return, pick a donation option below. Thanks for being awesome!",
                textAlign: TextAlign.center,
                style: kTextLetterSpacing,
              ),
              const SizedBox(height: 40),

              const Text('Select an amount to donate from the Apple App Store or the Google Play Store', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildDonationButton(context, '\$5'),
                  _buildDonationButton(context, '\$10'),
                  _buildDonationButton(context, '\$25'),
                  _buildDonationButton(context, '\$60'),
                  _buildDonationButton(context, '\$100'),
                ],
              ),

              const SizedBox(height: 20),

              _buildDonationButton(context, 'Restore Purchases'),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 24),

              // --- EXTERNAL LINKS ---
              _buildLinkTile(
                icon: Icons.coffee,
                label: 'Buy Me a Coffee',
                color: Colors.brown,
                onTap: () => _launchURL('https://buymeacoffee.com/kaungzinlin'),
              ),
              const SizedBox(height: 12),
              _buildLinkTile(
                icon: Icons.account_balance_wallet,
                label: 'Donate via KBZPay (Myanmar)',
                color: const Color(0xFF1044A4),
                onTap: () => _showKbzQr(context),
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
        elevation: 0,           // Removes standard shadow
        shadowColor: Colors.transparent, // Removes shadow color entirely
   // Removes lift when focused
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing $amount donation...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildLinkTile({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: kTextLetterSpacing),
      trailing: const Icon(Icons.open_in_new, size: 18),
      tileColor: color.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  void _showKbzQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        title: const Text(
          'Scan to Donate',
          textAlign: TextAlign.center,
          style: kTextLetterSpacing,
        ),
        content: SizedBox(
          // Limit width so it doesn't look giant on Desktop
          width: PlatformHelper.isDesktop ? 400 : double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  // Limit height to 50% of screen so the Close button stays visible
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/kbzdonation.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Save or screenshot this QR for KBZPay.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 0.0
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}