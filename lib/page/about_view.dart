import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final fonstStyleMedium = Theme.of(context).textTheme.bodyMedium;
    return Column(
      children: [
        Text('SkorionOS Tool', style: Theme.of(context).textTheme.titleLarge),
        // Text('Version: 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
        Text('Author: honjow', style: fonstStyleMedium),
        SelectionArea(
          child: Linkify(
            onOpen: (link) async {
              if (await canLaunchUrl(Uri.parse(link.url))) {
                await canLaunchUrl(Uri.parse(link.url));
              }
            },
            text: 'Github: https://github.com/honjow/sk-chos-tool',
            style: fonstStyleMedium,
          ),
        ),
      ],
    );
  }
}
