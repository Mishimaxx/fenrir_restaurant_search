import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/search_screen.dart';
import 'screens/result_screen.dart';
import 'screens/detail_screen.dart';
import 'providers/restaurant_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RestaurantProvider(),
      child: MaterialApp(
        title: 'グルメサーチ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF3D00),
            brightness: Brightness.light,
            secondary: const Color(0xFF00BFA5),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          cardTheme: CardTheme(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black.withOpacity(0.2),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFFFF3D00),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            bodyLarge: TextStyle(fontSize: 16, letterSpacing: 0.2),
            bodyMedium: TextStyle(fontSize: 14, letterSpacing: 0.1),
          ),
          sliderTheme: SliderThemeData(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            thumbColor: const Color(0xFFFF3D00),
            activeTrackColor: const Color(0xFFFF3D00),
            inactiveTrackColor: Colors.grey[300],
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SearchScreen(),
          '/results': (context) => const ResultScreen(),
          '/detail': (context) => const DetailScreen(),
        },
      ),
    );
  }
}
