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

  // Helper function to handle launching
  Future<void> _launchSocial(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // 1. Instagram
  void _openInstagram(String username) {
    _launchSocial("https://www.instagram.com/$username/");
  }

  // 2. Twitter (X)
  void _openTwitter(String handle) {
    _launchSocial("https://twitter.com/$handle");
  }

  // 3. TikTok
  void _openTikTok(String username) {
    // TikTok handles usernames with the '@' symbol in the URL
    _launchSocial("https://www.tiktok.com/@$username");
  }

  // Function to open WhatsApp
  // Note: phone number must include country code without '+' or '00'
  void _openWhatsApp(String phone) {
    _launchSocial("https://wa.me/$phone");
  }

  // Function to open Facebook Profile
  void _openFacebook(String profileId) {
    // fb://facade/666 is the deep link for apps, but https works as a fallback
    _launchSocial("https://www.facebook.com/$profileId");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook Icon
        IconButton(
          icon: Icon(Icons.facebook, color: isOneColor ? color : Colors.blue),
          onPressed: () => _openFacebook("61561449877042"),
        ),
        // WhatsApp Icon
        IconButton(
          icon: Icon(
            FontAwesomeIcons.whatsapp,
            color: isOneColor ? color : Colors.green,
          ),
          onPressed: () => _openWhatsApp("2348146269699"), // Your number
        ),

        // Instagram Icon
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.instagram,
            color: isOneColor ? color : Colors.pink,
          ),
          onPressed: () => _openInstagram("brillo_digitals112"),
        ),
        // Twitter Icon
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.xTwitter,
            color: isOneColor ? color : Colors.black,
          ),
          onPressed: () => _openTwitter("brillodigitals"),
        ),
        // TikTok Icon
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.tiktok,
            color: isOneColor ? color : Colors.black,
          ),
          onPressed: () => _openTikTok("brillo_digitals"),
        ),
      ],
    );
  }
}
