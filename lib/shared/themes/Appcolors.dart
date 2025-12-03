import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF020C19); // Updated to design system dark
  
  // Primary Color Palette (New Design System)
  static const Color primary = Color(0xFF0B1829); // Dark blue as primary
  static const Color primaryDark = Color(0xFFFE691E); // Orange for accents/buttons
  static const Color accent = Color(0xFFFE691E); // Orange accent for times, dates, highlights
  
  // Background Colors
  static const Color background = Color(0xFFFAF9F9); // Light gray from design
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white for cards
  
  // Text Colors
  static const Color textPrimary = Color(0xFF020C19); // Very dark for main text
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray for secondary text
  static const Color textLight = Color(0xFF9CA3AF); // Light gray for subtle text
  
  // UI Element Colors
  static const Color border = Color(0xFFD9D9D9); // Medium gray from design
  static const Color divider = Color(0xFFE5E7EB); // Light divider
  static const Color disabled = Color(0xFFF3F4F6); // Disabled state
  
  // Status Colors (keeping existing functionality)
  static const Color success = Color(0xFF0BA94D); // Green for success states
  static const Color error = Color(0xFFEF4444); // Red for error states
  static const Color warning = Color(0xFFF59E0B); // Amber for warnings
  static const Color info = Color(0xFF3B82F6); // Blue for info
  
  // Legacy Colors (for backward compatibility)
  static const Color AppSelectedGreen = success;
  static const Color cardsWhite = background;
  static const Color Red = error;
}
