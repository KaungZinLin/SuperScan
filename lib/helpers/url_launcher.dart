import 'package:url_launcher/url_launcher.dart';

Future<void> launchMyURL(String urlString) async {
  final Uri url = Uri.parse(urlString);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    print('Could not launch $url');
  }
}
