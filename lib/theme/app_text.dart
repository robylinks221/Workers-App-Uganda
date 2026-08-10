import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppText {
  AppText._();

  // ===========================
  // HEADINGS
  // ===========================

  static Text heading(
    String text, {
    Color color = AppColors.textPrimary,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      ),
    );
  }

  static Text title(
    String text, {
    Color color = AppColors.textPrimary,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  static Text subtitle(
    String text, {
    Color color = AppColors.textSecondary,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  // ===========================
  // BODY
  // ===========================

  static Text body(
    String text, {
    Color color = AppColors.textSecondary,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.45,
      ),
    );
  }

  static Text small(String text, {Color color = AppColors.textMuted}) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }

  static Text caption(String text, {Color color = AppColors.textMuted}) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  // ===========================
  // BUTTONS
  // ===========================

  static Text button(String text, {Color color = Colors.white}) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  // ===========================
  // STATUS
  // ===========================

  static Text success(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
      ),
    );
  }

  static Text warning(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.warning,
      ),
    );
  }

  static Text error(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      ),
    );
  }
}
