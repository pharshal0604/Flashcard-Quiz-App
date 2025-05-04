import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'providers/flashcard_data.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Intl.defaultLocale = 'en_US';
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (context) => FlashcardData(snapshot.data!),
            child: MaterialApp(
              title: 'SuperFlash',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system, // 🌓 Respects system theme
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFFF5F5F5),
                  foregroundColor: Colors.black87,
                ),
                colorScheme: const ColorScheme.light(
                  surface: Color(0xFFF5F5F5), // Replaces deprecated background
                  primary: Colors.black87,
                  secondary: Colors.grey,
                ),
                dividerColor: Colors.black12,
                cardColor: Colors.white,
                useMaterial3: true,
              ),

              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF121212),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF121212),
                  foregroundColor: Colors.white70,
                ),
                colorScheme: const ColorScheme.dark(
                  surface: Color(0xFF121212), // Replaces deprecated background
                  primary: Colors.white70,
                  secondary: Colors.grey,
                ),
                dividerColor: Colors.white10,
                cardColor: const Color(0xFF1E1E1E),
                useMaterial3: true,
              ),

              home: const HomePage(),
            ),
          );
        }
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
