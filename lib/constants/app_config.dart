import 'dart:io';

class AppConfig {
  // App Store Configuration
  // TODO: Replace with actual App Store ID after iOS app is published (e.g. '1234567890')
  static const String appStoreId = 'YOUR_APP_STORE_ID';
  
  // Play Store Configuration
  // UPDATED: This matches your actual Android Package Name
  static const String playStoreId = 'com.renderinfotech.peach_iq';
  
  // App Information
  static const String appName = 'PeachIQ';
  
  // Store URLs
  static String get appStoreUrl => 'https://apps.apple.com/app/id$appStoreId';
  static String get playStoreUrl => 'https://play.google.com/store/apps/details?id=$playStoreId';
  
  // Get platform-specific store URL
  static String get storeUrl {
    if (Platform.isIOS) {
      return appStoreUrl;
    } else if (Platform.isAndroid) {
      return playStoreUrl;
    }
    return playStoreUrl; // Default to Play Store
  }
  
  // Share message
  static String get shareMessage => 
      'Check out $appName! Download it here: $storeUrl';
}