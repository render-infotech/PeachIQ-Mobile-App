import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:peach_iq/Providers/content_page_provider.dart';
import 'package:peach_iq/models/content_page_model.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class RenderHtmlContent extends StatelessWidget {
  final ContentPageProvider provider;
  final ContentPage? page;
  final String pageTitle;

  const RenderHtmlContent({
    super.key,
    required this.provider,
    required this.page,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(child: Text('Error: ${provider.errorMessage}'));
    }
    if (page == null) {
      return Center(child: Text('Content for "$pageTitle" not found.'));
    }

    return Html(
      data: page!.pageDetails,
      onLinkTap: (url, _, __) async {
        if (url == null) return;
        final normalized =
            url.startsWith('http://') || url.startsWith('https://')
                ? url
                : 'https://$url';
        final uri = Uri.parse(normalized);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      style: {
        "*": Style(
          color: Colors.black87,
          fontSize: FontSize.medium,
        ),
        "h1": Style(fontSize: FontSize.xxLarge, fontWeight: FontWeight.bold),
        "h2": Style(fontSize: FontSize.xLarge, fontWeight: FontWeight.w600),
        "h3": Style(fontSize: FontSize.large, fontWeight: FontWeight.w600),
        "h4": Style(fontSize: FontSize.medium, fontWeight: FontWeight.w600),

        "p": Style(
          lineHeight: LineHeight.em(1.5),
          margin: Margins.symmetric(vertical: 8),
        ),
        // Links
        "a": Style(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
          textDecoration: TextDecoration.none,
        ),
        // Lists
        "ul": Style(padding: HtmlPaddings.only(left: 20)),
        "ol": Style(padding: HtmlPaddings.only(left: 20)),
        "li": Style(
          listStyleType: ListStyleType.disc,
          padding: HtmlPaddings.only(bottom: 8),
        ),
        // Blockquotes
        "blockquote": Style(
          padding: HtmlPaddings.all(12),
          margin: Margins.symmetric(vertical: 10),
          backgroundColor: Colors.black.withOpacity(0.05),
          border: Border(
            left:
                BorderSide(color: AppColors.primary.withOpacity(0.5), width: 4),
          ),
        ),
        // Emphasis
        "strong": Style(fontWeight: FontWeight.bold),
        "em": Style(fontStyle: FontStyle.italic),
      },
    );
  }
}
