import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/content_page_provider.dart';
import 'package:peach_iq/screens/profile/settings/render_html.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:provider/provider.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh data every time this screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pageProvider = context.read<ContentPageProvider>();
      pageProvider.fetchFreshPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<ContentPageProvider>();
    final termsPage = pageProvider.getPageByTitle('TnC');

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
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 20,
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
              page: termsPage,
              pageTitle: 'Terms & Conditions',
            ),
          ],
        ),
      ),
    );
  }
}
