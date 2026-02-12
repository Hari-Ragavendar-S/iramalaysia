import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Gold Theme (Original)
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color secondaryGold = Color(0xFFFFD700);
  static const Color darkContrastGold = Color(0xFFB8860B);
  static const Color softGoldHighlight = Color(0xFFFFF8DC);
  
  // Keep the original gold colors as primary
  static const Color primaryPurple = primaryGold;
  static const Color primaryPurpleLight = secondaryGold;
  static const Color primaryPurpleDark = darkContrastGold;
  static const Color primaryPurpleExtraLight = softGoldHighlight;
  
  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF4F46E5);
  static const Color secondaryTeal = Color(0xFF06B6D4);
  static const Color secondaryGreen = Color(0xFF10B981);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentYellow = Color(0xFFFBBF24);
  
  // Neutral Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  static const Color textColor = textPrimary; // Legacy
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF9FAFB);
  static const Color backgroundTertiary = Color(0xFFF3F4F6);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceMedium = Color(0xFFE2E8F0);
  static const Color surfaceDark = Color(0xFFCBD5E1);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, secondaryGold],
  );
  
  static const LinearGradient goldGradient = primaryGradient; // Legacy
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundSecondary, backgroundPrimary],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundCard, backgroundSecondary],
  );
  
  // Legacy Colors (for backward compatibility)
  static const Color gradientStart = secondaryGold;
  static const Color gradientEnd = primaryGold;
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  
  // Overlay Colors
  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayMedium = Color(0x33000000);
  static const Color overlayDark = Color(0x66000000);
  
  // Rating Colors
  static const Color ratingActive = Color(0xFFFBBF24);
  static const Color ratingInactive = Color(0xFFE5E7EB);
  
  // Calendar Colors
  static const Color calendarSelected = primaryGold;
  static const Color calendarToday = secondaryGold;
  static const Color calendarDisabled = Color(0xFFE5E7EB);
  
  // Status Badge Colors
  static const Color badgePending = warning;
  static const Color badgeVerified = success;
  static const Color badgeRejected = error;
  static const Color badgeCompleted = info;
  
  // Spacing Constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius Constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 50.0;
  
  // Elevation Constants
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
}