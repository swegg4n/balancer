import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var appTheme = ThemeData(
  fontFamily: GoogleFonts.nunito().fontFamily,
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.black87,
  ),
  primaryColor: Colors.lightBlue[700],
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey[850],
  sliderTheme: ThemeData.dark().sliderTheme.copyWith(
        valueIndicatorColor: Colors.lightBlue[700],
        valueIndicatorTextStyle: const TextStyle(
          backgroundColor: Colors.transparent,
        ),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        showValueIndicator: ShowValueIndicator.always,
      ),
);
