import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_dashboard.dart';
import 'screens/toddler_data.dart';
import 'screens/input_data.dart';
import 'screens/growth_tracker.dart';
import 'screens/export_reports.dart';
import 'screens/register_toddler.dart';
import 'screens/splash_screen.dart';
import 'screens/ble_splash.dart';
import 'screens/activity_logs_screen.dart';
import 'screens/settings_screen.dart';
import 'services/activity_log_service.dart';
import 'services/app_settings_service.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  await AppSettingsService().load();
  await ActivityLogService().init();
  await ActivityLogService().log('System', 'Aplikasi dibuka');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppSettingsService _settingsService = AppSettingsService();

  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Locale _localeFromString(String lang) {
    return lang == 'en' ? const Locale('en') : const Locale('id');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: _settingsService.listen,
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'E-Posyandu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeModeFromString(settings.themeMode),
          locale: _localeFromString(settings.language),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaleFactor: settings.textScale),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: SplashScreen(nextScreen: const HomeDashboard()),
          routes: {
            '/toddler_data': (context) => const ToddlerDataScreen(),
            '/input': (context) => const InputDataScreen(),
            '/input_data': (context) => const InputDataScreen(),
            '/ble': (context) => const BLEDiceSplashScreen(),
            '/growth': (context) => const GrowthTrackerScreen(),
            '/export': (context) => const ExportReportsScreen(),
            '/register': (context) => const RegisterToddlerScreen(),
            '/activity_logs': (context) => const ActivityLogsScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
