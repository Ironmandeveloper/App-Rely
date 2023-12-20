import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_mqtt/style/colors.dart';

class textStyle {
    final h1 = GoogleFonts.ubuntu(
      textStyle: TextStyle(
    color:  colors().secondry,

    fontSize: 35,
  ));
     final h1W = GoogleFonts.ubuntu(
      textStyle: TextStyle(
    color:  colors().primary,

    fontSize: 16,
  ));
    final h2 = GoogleFonts.ubuntu(
      textStyle: TextStyle(
    color:  colors().secondry,

    fontSize: 20,
  ));
  final body = GoogleFonts.ubuntu(
      textStyle: TextStyle(
    color:  colors().primary,
    fontSize: 17,
  ));
  final bodyB = GoogleFonts.ubuntu(
      textStyle: TextStyle(
    color:  colors().primary,
    fontSize: 17,
    fontWeight: FontWeight.w500
  ));
    final bodyC = GoogleFonts.ubuntu(
      textStyle: TextStyle(
    color:  colors().lightG,
    fontSize: 17,
    fontWeight: FontWeight.w500
  ));
   final bodyW = GoogleFonts.ubuntu(
      textStyle: TextStyle(
      color:  colors().backGround,

    fontSize: 
    20,
  ));
   final bodyS = GoogleFonts.ubuntu(
      textStyle: TextStyle(
      color:  colors().secondry,

    fontSize: 20,
  ));
  final small_under =  GoogleFonts.ubuntu(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                               color:  colors(). secondry,

                              decoration: TextDecoration.underline,
                           
                            ));
                             final small =  GoogleFonts.ubuntu(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                               color:  colors().primary,

                             
                           
                            ));

}