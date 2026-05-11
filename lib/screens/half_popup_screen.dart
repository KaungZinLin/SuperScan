import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/localization/locales.dart';
import 'package:super_scan/screens/donation_screen.dart';
import 'package:super_scan/widgets/ad_banner.dart';

class HalfPopupScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String body;
  final IconData iconData;

  const HalfPopupScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.iconData,
  });

  @override
  State<HalfPopupScreen> createState() => _HalfPopupScreenState();
}

class _HalfPopupScreenState extends State<HalfPopupScreen> {

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
                widget.iconData,
                color: Colors.green,
                size: 60,
                fontWeight: FontWeight.bold,
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                )
              ),
              SizedBox(height: 16),
              Text(
                widget.body,
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
                      label: Text(LocaleData.donate_button.getString(context)),
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
                      label: Text(LocaleData.close.getString(context)),
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
