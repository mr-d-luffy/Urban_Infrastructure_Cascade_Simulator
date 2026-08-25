import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/simulation_controller.dart';
import 'providers/theme_controller.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing or invalid, fallback defaults in ApiConfig are used.
  }

  runApp(const CascadeSimulatorApp());
}

class CascadeSimulatorApp extends StatelessWidget {
  const CascadeSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => SimulationController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Urban Infrastructure Cascade Simulator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeController.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
