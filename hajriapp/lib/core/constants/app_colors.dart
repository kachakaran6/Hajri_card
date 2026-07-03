import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primary = Color(0xFF7C3AED); // violet-600
  static const Color primaryLight = Color(0xFF8B5CF6); // violet-500
  static const Color primaryDark = Color(0xFF6D28D9); // violet-700

  // Light Mode Colors (Sleek Zinc / Off-white)
  static const Color lightBg = Color(0xFFFAFAFA); // zinc-50
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE4E4E7); // zinc-200
  static const Color lightTextPrimary = Color(0xFF18181B); // zinc-900
  static const Color lightTextSecondary = Color(0xFF71717A); // zinc-500

  // Dark Mode Colors (Deep charcoal / Zinc black)
  static const Color darkBg = Color(0xFF09090B); // zinc-950
  static const Color darkSurface = Color(0xFF18181B); // zinc-900
  static const Color darkBorder = Color(0xFF27272A); // zinc-800
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // zinc-400

  // Status Colors
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color successBg = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6); // blue-500
  static const Color infoBg = Color(0xFFEFF6FF);

  // Helper methods
  static Color getStatusBg(String status) {
    switch (status) {
      case 'Present':
      case 'Overtime':
        return const Color(0xFFD1FAE5); // light green
      case 'Half Day':
        return const Color(0xFFFEF3C7); // light amber
      case 'Leave':
      case 'Holiday':
        return const Color(0xFFDBEAFE); // light blue
      case 'Absent':
        return const Color(0xFFFEE2E2); // light red
      default:
        return const Color(0xFFF4F4F5); // light zinc
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Present':
      case 'Overtime':
        return const Color(0xFF065F46); // dark green
      case 'Half Day':
        return const Color(0xFF92400E); // dark amber
      case 'Leave':
      case 'Holiday':
        return const Color(0xFF1E40AF); // dark blue
      case 'Absent':
        return const Color(0xFF991B1B); // dark red
      default:
        return const Color(0xFF374151); // dark gray
    }
  }
}
