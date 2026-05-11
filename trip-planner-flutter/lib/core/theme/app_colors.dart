import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFFC47B5A);
  static const primaryLight = Color(0xFFD9A38B);
  static const primaryDark = Color(0xFFA05D3F);
  static const accent = Color(0xFF3D6B6B);
  static const accentLight = Color(0xFF5A8F8F);

  // Semantic
  static const success = Color(0xFF7B8C4E);
  static const warning = Color(0xFFC4963E);
  static const danger = Color(0xFFB8453E);
  static const info = Color(0xFF6B7D8B);

  // Text
  static const textPrimary = Color(0xFF2C2416);
  static const textRegular = Color(0xFF5C5343);
  static const textSecondary = Color(0xFF8B7E6A);
  static const textPlaceholder = Color(0xFFB8AE9C);

  // Surfaces
  static const pageBg = Color(0xFFF9F5ED);
  static const surface = Color(0xFFFFFDF7);
  static const elevated = Color(0xFFFFFFFF);
  static const muted = Color(0xFFF4EFE4);

  // Borders
  static const border = Color(0xFFE8DFD0);
  static const borderLight = Color(0xFFF2EBE0);

  // Transport type colors
  static const transportWalk = Color(0xFF7B8C4E);
  static const transportBus = Color(0xFF5A8B9E);
  static const transportSubway = Color(0xFF3D6B6B);
  static const transportTaxi = Color(0xFFC4963E);
  static const transportRideHail = Color(0xFF9B6B9E);
  static const transportSelfDrive = Color(0xFF6B7D8B);
  static const transportBike = Color(0xFF8A9E5A);
  static const transportFlight = Color(0xFF5C6BC0);
  static const transportTrain = Color(0xFF26A69A);

  static Color transportColor(String type) {
    return switch (type) {
      'WALK' => transportWalk,
      'BUS' => transportBus,
      'SUBWAY' => transportSubway,
      'TAXI' => transportTaxi,
      'RIDE_HAIL' => transportRideHail,
      'SELF_DRIVE' => transportSelfDrive,
      'BIKE' => transportBike,
      'FLIGHT' => transportFlight,
      'TRAIN' => transportTrain,
      _ => textSecondary,
    };
  }
}
