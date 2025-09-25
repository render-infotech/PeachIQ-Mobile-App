import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/content_page_provider.dart';
import 'package:peach_iq/screens/profile/settings/render_html.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<ContentPageProvider>();
    final aboutPage = pageProvider.getPageByTitle('About Us');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'About us',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Use the reusable widget here
            RenderHtmlContent(
              provider: pageProvider,
              page: aboutPage,
              pageTitle: 'About Us',
            ),
          ],
        ),
      ),
    );
  }
}
