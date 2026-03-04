import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.isOneColor,
    required this.color,
  });

  final bool isOneColor;
  final Color color;

  Future<void> _launchSocial(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      // ignore: use_build_context_synchronously
      if (!launched) _showErrorSnackbar(context);
    } catch (_) {
      // ignore: use_build_context_synchronously
      _showErrorSnackbar(context);
    }
  }

  void _showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Can't open app, check your internet connection"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openInstagram(BuildContext context, String username) {
    _launchSocial(context, "https://www.instagram.com/$username/");
  }

  void _openTwitter(BuildContext context, String handle) {
    _launchSocial(context, "https://twitter.com/$handle");
  }

  void _openTikTok(BuildContext context, String username) {
    _launchSocial(context, "https://www.tiktok.com/@$username");
  }

  void _openWhatsApp(BuildContext context, String phone) {
    _launchSocial(context, "https://wa.me/$phone");
  }

  void _openFacebook(BuildContext context, String profileId) {
    _launchSocial(context, "https://www.facebook.com/$profileId");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.facebook, color: isOneColor ? color : Colors.blue),
          onPressed: () => _openFacebook(context, "61561449877042"),
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.whatsapp,
            color: isOneColor ? color : Colors.green,
          ),
          onPressed: () => _openWhatsApp(context, "2348146269699"),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.instagram,
            color: isOneColor ? color : Colors.pink,
          ),
          onPressed: () => _openInstagram(context, "brillo_digitals112"),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.xTwitter,
            color: isOneColor ? color : Colors.black,
          ),
          onPressed: () => _openTwitter(context, "brillodigitals"),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.tiktok,
            color: isOneColor ? color : Colors.black,
          ),
          onPressed: () => _openTikTok(context, "brillo_digitals"),
        ),
      ],
    );
  }
}
