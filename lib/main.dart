import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/games_screen.dart';
import 'screens/saved_screen.dart';
import 'services/app_state.dart';
import 'models/brand_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved dark-mode setting and bookmarks before the app starts
  await Future.wait([
    AppSettings.instance.load(),
    BookmarkStore.instance.load(),
  ]);
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final isDark = AppSettings.instance.is_Dark;
        return MaterialApp(
          title:                    'AM News',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme:     buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: HomeScreen(
            isDarkMode:    isDark,
            onThemeToggle: AppSettings.instance.toggleDark,
          ),
          routes: {
            '/games': (context) => const GamesScreen(),
            '/saved': (context) => const SavedScreen(),
          },
        );
      },
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final base = ColorScheme.fromSeed(
    seedColor:  AmBrand.navy,
    brightness: brightness,
  );

  final scheme = isDark
      ? base.copyWith(
    primary:              AmBrand.sun,
    onPrimary:            const Color(0xFF2B1B00),
    secondary:            const Color(0xFFF5B54A),
    onSecondary:          const Color(0xFF2B1B00),
    surface:              const Color(0xFF111418),
    onSurface:            const Color(0xFFF2F0EB),
    onSurfaceVariant:     const Color(0xFFB4BAC5),
    surfaceContainerHighest: const Color(0xFF232E42),
    surfaceContainerLow:  const Color(0xFF182030),
  )
      : base.copyWith(
    primary:              AmBrand.navy,
    onPrimary:            Colors.white,
    secondary:            const Color(0xFFC96F12),
    onSecondary:          Colors.white,
    surface:              const Color(0xFFFAF9F6),
    onSurface:            const Color(0xFF14171C),
    onSurfaceVariant:     const Color(0xFF555B66),
    surfaceContainerHighest: const Color(0xFFECEAE4),
    surfaceContainerLow:  Colors.white,
  );

  return ThemeData(
    colorScheme:          scheme,
    useMaterial3:         true,
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle:            false,
      elevation:              0,
      scrolledUnderElevation: 0,
      backgroundColor:        scheme.surface,
      foregroundColor:        scheme.onSurface,
    ),
  );
}