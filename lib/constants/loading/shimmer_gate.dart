import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class ShimmerGate extends StatelessWidget {
  const ShimmerGate({
    super.key,
    required this.child,
    required this.isLoading,
  });
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: Center(
              child: Container(
                height: 150,
                width: 300,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 30.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          strokeWidth: 4.0,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
