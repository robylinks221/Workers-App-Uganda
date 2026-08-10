import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  /// Standard cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// Premium cards
  static const List<BoxShadow> elevatedCard = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  /// Floating Bottom Navigation
  static const List<BoxShadow> floatingNavigation = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  /// Floating Action Button
  static const List<BoxShadow> floatingButton = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  /// Dialogs
  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color(0x25000000),
      blurRadius: 30,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];

  /// Search Bar
  static const List<BoxShadow> searchBar = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Chips
  static const List<BoxShadow> chip = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Images & Avatars
  static const List<BoxShadow> image = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 15,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// Bottom Sheets
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 28,
      spreadRadius: 0,
      offset: Offset(0, -2),
    ),
  ];

  /// Large Feature Cards
  static const List<BoxShadow> heroCard = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 26,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];
}
