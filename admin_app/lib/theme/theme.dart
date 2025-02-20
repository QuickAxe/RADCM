import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5d5791),
      surfaceTint: Color(0xff5d5791),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe4dfff),
      onPrimaryContainer: Color(0xff454077),
      secondary: Color(0xff5f5c71),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe4dff9),
      onSecondaryContainer: Color(0xff474459),
      tertiary: Color(0xff7b5266),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd8e8),
      onTertiaryContainer: Color(0xff613b4e),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffcf8ff),
      onSurface: Color(0xff1c1b20),
      onSurfaceVariant: Color(0xff47464f),
      outline: Color(0xff787680),
      outlineVariant: Color(0xffc9c5d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313036),
      inversePrimary: Color(0xffc7bfff),
      primaryFixed: Color(0xffe4dfff),
      onPrimaryFixed: Color(0xff191249),
      primaryFixedDim: Color(0xffc7bfff),
      onPrimaryFixedVariant: Color(0xff454077),
      secondaryFixed: Color(0xffe4dff9),
      onSecondaryFixed: Color(0xff1b192c),
      secondaryFixedDim: Color(0xffc8c3dc),
      onSecondaryFixedVariant: Color(0xff474459),
      tertiaryFixed: Color(0xffffd8e8),
      onTertiaryFixed: Color(0xff301122),
      tertiaryFixedDim: Color(0xffecb8cf),
      onTertiaryFixedVariant: Color(0xff613b4e),
      surfaceDim: Color(0xffddd8e0),
      surfaceBright: Color(0xfffcf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f2fa),
      surfaceContainer: Color(0xfff1ecf4),
      surfaceContainerHigh: Color(0xffebe6ef),
      surfaceContainerHighest: Color(0xffe5e1e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff352f65),
      surfaceTint: Color(0xff5d5791),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6c66a1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff363447),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6e6a80),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4e2b3d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8b6174),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8ff),
      onSurface: Color(0xff111016),
      onSurfaceVariant: Color(0xff37353e),
      outline: Color(0xff53515a),
      outlineVariant: Color(0xff6e6c75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313036),
      inversePrimary: Color(0xffc7bfff),
      primaryFixed: Color(0xff6c66a1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff544e87),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6e6a80),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff555267),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8b6174),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff71495c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c5cd),
      surfaceBright: Color(0xfffcf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f2fa),
      surfaceContainer: Color(0xffebe6ef),
      surfaceContainerHigh: Color(0xffdfdbe3),
      surfaceContainerHighest: Color(0xffd4d0d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff2a245b),
      surfaceTint: Color(0xff5d5791),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff48427a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2c2a3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff49475b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff432132),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff643e50),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2c2b33),
      outlineVariant: Color(0xff4a4851),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313036),
      inversePrimary: Color(0xffc7bfff),
      primaryFixed: Color(0xff48427a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff312b62),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff49475b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff333044),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff643e50),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4a2839),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb7bf),
      surfaceBright: Color(0xfffcf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4eff7),
      surfaceContainer: Color(0xffe5e1e9),
      surfaceContainerHigh: Color(0xffd7d3db),
      surfaceContainerHighest: Color(0xffc9c5cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc7bfff),
      surfaceTint: Color(0xffc7bfff),
      onPrimary: Color(0xff2f295f),
      primaryContainer: Color(0xff454077),
      onPrimaryContainer: Color(0xffe4dfff),
      secondary: Color(0xffc8c3dc),
      onSecondary: Color(0xff302e41),
      secondaryContainer: Color(0xff474459),
      onSecondaryContainer: Color(0xffe4dff9),
      tertiary: Color(0xffecb8cf),
      onTertiary: Color(0xff482537),
      tertiaryContainer: Color(0xff613b4e),
      onTertiaryContainer: Color(0xffffd8e8),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141318),
      onSurface: Color(0xffe5e1e9),
      onSurfaceVariant: Color(0xffc9c5d0),
      outline: Color(0xff928f99),
      outlineVariant: Color(0xff47464f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e1e9),
      inversePrimary: Color(0xff5d5791),
      primaryFixed: Color(0xffe4dfff),
      onPrimaryFixed: Color(0xff191249),
      primaryFixedDim: Color(0xffc7bfff),
      onPrimaryFixedVariant: Color(0xff454077),
      secondaryFixed: Color(0xffe4dff9),
      onSecondaryFixed: Color(0xff1b192c),
      secondaryFixedDim: Color(0xffc8c3dc),
      onSecondaryFixedVariant: Color(0xff474459),
      tertiaryFixed: Color(0xffffd8e8),
      onTertiaryFixed: Color(0xff301122),
      tertiaryFixedDim: Color(0xffecb8cf),
      onTertiaryFixedVariant: Color(0xff613b4e),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff3a383e),
      surfaceContainerLowest: Color(0xff0e0e13),
      surfaceContainerLow: Color(0xff1c1b20),
      surfaceContainer: Color(0xff201f25),
      surfaceContainerHigh: Color(0xff2a292f),
      surfaceContainerHighest: Color(0xff35343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffded8ff),
      surfaceTint: Color(0xffc7bfff),
      onPrimary: Color(0xff241d54),
      primaryContainer: Color(0xff908ac7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffded9f3),
      onSecondary: Color(0xff252336),
      secondaryContainer: Color(0xff928ea5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffcfe3),
      onTertiary: Color(0xff3b1b2c),
      tertiaryContainer: Color(0xffb28498),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdfdae6),
      outline: Color(0xffb4b0bb),
      outlineVariant: Color(0xff928f99),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e1e9),
      inversePrimary: Color(0xff474179),
      primaryFixed: Color(0xffe4dfff),
      onPrimaryFixed: Color(0xff0f053f),
      primaryFixedDim: Color(0xffc7bfff),
      onPrimaryFixedVariant: Color(0xff352f65),
      secondaryFixed: Color(0xffe4dff9),
      onSecondaryFixed: Color(0xff110f21),
      secondaryFixedDim: Color(0xffc8c3dc),
      onSecondaryFixedVariant: Color(0xff363447),
      tertiaryFixed: Color(0xffffd8e8),
      onTertiaryFixed: Color(0xff230717),
      tertiaryFixedDim: Color(0xffecb8cf),
      onTertiaryFixedVariant: Color(0xff4e2b3d),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff45434a),
      surfaceContainerLowest: Color(0xff07070c),
      surfaceContainerLow: Color(0xff1e1d23),
      surfaceContainer: Color(0xff28272d),
      surfaceContainerHigh: Color(0xff333238),
      surfaceContainerHighest: Color(0xff3e3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff2edff),
      surfaceTint: Color(0xffc7bfff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffc3bbfc),
      onPrimaryContainer: Color(0xff080038),
      secondary: Color(0xfff2edff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc4c0d8),
      onSecondaryContainer: Color(0xff0b091a),
      tertiary: Color(0xffffebf1),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffe8b5cb),
      onTertiaryContainer: Color(0xff1c0311),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff3eef9),
      outlineVariant: Color(0xffc5c1cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e1e9),
      inversePrimary: Color(0xff474179),
      primaryFixed: Color(0xffe4dfff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffc7bfff),
      onPrimaryFixedVariant: Color(0xff0f053f),
      secondaryFixed: Color(0xffe4dff9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc8c3dc),
      onSecondaryFixedVariant: Color(0xff110f21),
      tertiaryFixed: Color(0xffffd8e8),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffecb8cf),
      onTertiaryFixedVariant: Color(0xff230717),
      surfaceDim: Color(0xff141318),
      surfaceBright: Color(0xff514f56),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f25),
      surfaceContainer: Color(0xff313036),
      surfaceContainerHigh: Color(0xff3c3a41),
      surfaceContainerHighest: Color(0xff47464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
