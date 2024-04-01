import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;

  static const colorPrimary = Color.fromARGB(255, 20, 95, 138);
  static const colorsDarkTheme = Color(0xFF1A1A1A);
  static const colosrLightTheme = Color(0xFFFFFFFF);
  static final green = Colors.green[400];
  static const grey = Color(0xFF212121);
  static const lightGrey = Color(0xFFBBBBBB);
  static const veryLightGrey = Color(0xFFF3F3F3);
  static const letterGray = Color(0XFF5C656C);
  static final tileOnlineBackgroud = Colors.blueGrey[100];
  static final tileOfflineBackgroud = Colors.blueGrey[50];

  AppTheme(this.context);

  ThemeData lightTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light().copyWith(
            surfaceTint: Colors.white,
            background: Colors
                .white), // ColorScheme.fromSeed(seedColor: Colors.white), //
        primaryColor: colorPrimary,
        appBarTheme: AppBarTheme(
          backgroundColor: colorPrimary,
          titleTextStyle: const TextStyle().copyWith(
            color: Colors.white,
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              displayColor: Colors.black,
              bodyColor: Colors.white,
            ),
        dialogBackgroundColor: Colors.white);
  }

  ThemeData darkTheme() {
    return ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark().copyWith(
            surface: colorsDarkTheme,
            background:
                colorsDarkTheme), // ColorScheme.fromSeed(seedColor: Colors.white), //
        primaryColor: colorPrimary,
        appBarTheme: AppBarTheme(
          backgroundColor: colorPrimary,
          titleTextStyle: const TextStyle().copyWith(
            color: Colors.white,
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              displayColor: Colors.white,
              bodyColor: Colors.white,
            ),
        scaffoldBackgroundColor: colorsDarkTheme,
        dialogBackgroundColor: Colors.black);
  }
}
