import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension ThemeExtensions on BuildContext{
Color get primaryColor => Theme.of(this).primaryColor;
Color get primaryColorLight => Theme.of(this).primaryColorLight;
Color get buttonColor => Theme.of(this).buttonTheme.colorScheme!.primary;
TextTheme get textTheme => Theme.of(this).textTheme;
 TextStyle get titleTextStyle => GoogleFonts.lato( // Correção aqui
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

 TextStyle lato({
    Color? color,
    double? fontSize, 
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.lato(
      color: color ?? Colors.black,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}





