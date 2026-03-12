import 'package:flutter/material.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/screens/donation_screen.dart';
import 'package:super_scan/widgets/ad_banner.dart';

class AfterSharingScreen extends StatefulWidget {
  const AfterSharingScreen({super.key});

  @override
  State<AfterSharingScreen> createState() => _AfterSharingScreenState();
}

class _AfterSharingScreenState extends State<AfterSharingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 60,
                fontWeight: FontWeight.bold,
              ),
              Text(
                'Success',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Your document has been exported!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                )
              ),
              SizedBox(height: 16),
              Text(
                  "Keeping SuperScan is the dream, but for now, the ads I've implemented help me pay the bills. If you want to help me out, you can donate to remove ads and to get access to AI features.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => DonateScreen()));
                      },
                      label: const Text('Donate'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: const Text('Close'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16)
            ],
          ),
        ),
      ),
      bottomNavigationBar: PlatformHelper.isDesktop
          ? null
          : BottomAppBar(
        height: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(children: [Expanded(child: const AdBanner())]),
        ),
      ),
    );
  }
}
