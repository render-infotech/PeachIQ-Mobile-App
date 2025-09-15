import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class HeaderCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final VoidCallback? onSignOut;
  final String? pageheader;
  final bool isLoading;

  const HeaderCard({
    super.key,
    required this.name,
    this.subtitle,
    this.onSignOut,
    this.pageheader,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: _buildNormalContent(),
    );
  }

  Widget _buildNormalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    'Welcome, ${name.isNotEmpty ? '$name' : ''}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (onSignOut != null)
              GestureDetector(
                onTap: onSignOut,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.signOutAlt,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Log out",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (pageheader != null && pageheader!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            pageheader!,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
