import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/controllers/settings_controller.dart';
import 'package:super_scan/helpers/platform_helper.dart';
import 'package:super_scan/helpers/sign_in_result.dart';
import 'package:super_scan/helpers/toast_helper.dart';
import 'package:super_scan/helpers/url_launcher.dart';
import 'package:super_scan/localization/locales.dart';
import 'package:super_scan/screens/api_key_screen.dart';
import 'package:super_scan/screens/donation_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:super_scan/screens/half_popup_screen.dart';
import 'package:super_scan/widgets/universal_webview.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:super_scan/services/language_service.dart';

import '../models/singletons_data.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _viewController = SettingsController();

  bool isConnected = false; // Declare default internet connection
  StreamSubscription?
  _internetConnectionStreamSubscription; // Start a stream and

  late final InternetConnection _checker;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewController.addListener(_controllerListener);
    });

    _checkInitialConnection();

    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen(_internetListener);
  }

  Future<void> _checkInitialConnection() async {
    final result = await _checker.hasInternetAccess;
    if (!mounted) return;
    setState(() => isConnected = result);
  }

  void _controllerListener() {
    if (!mounted) return;
    setState(() {});
  }

  void _internetListener(InternetStatus event) {
    if (!mounted) return;
    switch (event) {
      case InternetStatus.connected:
        setState(() => isConnected = true);
        break;
      case InternetStatus.disconnected:
        setState(() => isConnected = false);
        break;
    }
  }

  // Dispose the subscription to prevent memory leak
  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    _internetConnectionStreamSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _viewController.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(LocaleData.settings.getString(context)), centerTitle: true),
      body: _viewController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Expanded(child:
              ListView(
                children: [
                  // Added internet connection warning
                  if (!isConnected)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildNoInternetWidget(context),
                    ),

                  const SizedBox(height: 16),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.google),
                    title: Text(
                      LocaleData.google_account_for_sync.getString(context)
                    ),
                    subtitle: user != null
                        ? Text('${user.displayName} • ${user.email}')
                        : Text(LocaleData.not_signed_in.getString(context)),
                  ),

                  if (user == null)
                    ListTile(
                      leading: const Icon(Icons.login_rounded),
                      title: Text(
                        LocaleData.sign_in.getString(context),
                      ),
                      onTap: () async {
                        try {
                          final result = await _viewController.signIn();

                          if(!context.mounted) return;

                          switch(result) {
                            case SignInResult.success:
                              ToastHelper.show('Signed in successfully');
                              break;
                            case SignInResult.failed:
                              ToastHelper.show('Signed in failed');
                              break;
                            case SignInResult.cancelled:
                              ToastHelper.show('Signed in failed');
                              break;
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          ToastHelper.show(e.toString());
                        }
                      },
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.red),
                      title: Text(
                        LocaleData.sign_out.getString(context),
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        _viewController.showSignOutOptions(context);
                      },
                    ),

                  ListTile(
                    enabled: !PlatformHelper.isDesktop,
                    leading: const Icon(Icons.install_desktop_rounded),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    title: Text(
                      LocaleData.get_on_dekstop.getString(context),
                    ),
                    onTap: () {
                      launchMyURL('https://github.com/KaungZinLin/SuperScan');
                    },
                  ),

                  const Divider(),
                  ListTile(
                    enabled: !PlatformHelper.isDesktop,
                    leading: const Icon(Icons.auto_awesome_rounded),
                    title: Text(
                      LocaleData.ai_config.getString(context),
                    ),
                    subtitle: PlatformHelper.isDesktop
                        ? Text(
                      LocaleData.ai_platform_limitations.getString(context)
                    )
                        : null,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (!appData.entitlementIsActive) {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) => HalfPopupScreen(
                            title: LocaleData.support_title.getString(context),
                            subtitle: LocaleData.support_subtitle.getString(context),
                            body: '',
                            iconData: Icons.favorite,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ApiKeyScreen()),
                        );
                      }
                      },
                  ),
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(LocaleData.language.getString(context)),
                    trailing: DropdownButton<String>(
                      value: FlutterLocalization.instance.currentLocale?.languageCode ?? "en",
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: "en", child: Text("English")),
                        DropdownMenuItem(value: "my", child: Text("ဗမာ")),
                        DropdownMenuItem(value: "zh", child: Text("简体中文 (Beta)")),
                        DropdownMenuItem(value: "zh_Hant", child: Text("繁體中文 (Beta)")),
                        DropdownMenuItem(value: "vi", child: Text("Tiếng Việt (Beta)")),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;

                        // Change language instantly
                        FlutterLocalization.instance.translate(value);

                        // Save it
                        await LanguageService.saveLanguage(value);

                        setState(() {});
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.redAccent,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    title: Text(LocaleData.donate.getString(context)),
                    subtitle: Text(
                      LocaleData.donate_description.getString(context),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DonateScreen()),
                      );
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.info_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    title: Text(LocaleData.about.getString(context)),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationIcon: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        applicationName: 'SuperScan',
                        applicationVersion: 'v2.0 Stable (Build 13)',
                        applicationLegalese: '© 2026 Kaung Zin Lin',
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              'Built with Flutter',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.person_rounded),
                    title: Text(
                      LocaleData.kzl.getString(context)
                    ),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () async {
                      launchMyURL('https://github.com/KaungZinLin');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article_rounded),
                    title: Text(
                      LocaleData.tos.getString(context)
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (!Platform.isWindows && !Platform.isLinux) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => UniversalWebView(
                                  url: kTermsAndConditionsUrl,
                                  title: LocaleData.tos.getString(context),
                                )
                            )
                        );
                      } else {
                        launchMyURL(kTermsAndConditionsUrl);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_rounded),
                    title: Text(
                      LocaleData.pp.getString(context)
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (!Platform.isWindows || !Platform.isLinux) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => UniversalWebView(
                                  url: kPrivacyPolicyUrl,
                                  title: LocaleData.pp.getString(context),
                                )
                            )
                        );
                      } else {
                        launchMyURL(kPrivacyPolicyUrl);
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.medical_information_rounded),
                    title: Text(LocaleData.license.getString(context)),
                    subtitle: const Text(
                      'MIT License © 2026',
                    ), // Keep it short here
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(LocaleData.license.getString(context)),
                            content: const SingleChildScrollView(
                              child: Text(
                                'MIT License\n\n'
                                    'Copyright (c) 2026 Kaung Zin Lin\n\n'
                                    'Permission is hereby granted, free of charge, to any person obtaining a copy '
                                    'of this software and associated documentation files (the "Software"), to deal '
                                    'in the Software without restriction, including without limitation the rights '
                                    'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                                    'copies of the Software, and to permit persons to whom the Software is '
                                    'furnished to do so, subject to the following conditions:\n\n'
                                    'The above copyright notice and this permission notice shall be included in all '
                                    'copies or substantial portions of the Software.\n\n'
                                    'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
                                    'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
                                    'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
                                    'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
                                    'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
                                    'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
                                    'SOFTWARE.',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  LocaleData.close.getString(context)
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              ),
            ],
          ),
    );
  }

  Widget _buildNoInternetWidget(BuildContext context) {
    // Defining a red color with transparency to match your previous style
    final Color errorRed = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        // Using .withOpacity or .withAlpha for that soft background look
        color: errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Keeps the box tight around the content
        children: [
          Icon(Icons.wifi_off_rounded, color: errorRed, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              LocaleData.internet_warning.getString(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Slightly smaller to ensure it fits on one line
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}