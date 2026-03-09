import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'material_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();
    return MaterialTheme(textTheme).light();
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return MaterialTheme(textTheme).dark();
  }
}
