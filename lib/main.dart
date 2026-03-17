import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_dashboard.dart';
import 'screens/toddler_data.dart';
import 'screens/input_data.dart';
import 'screens/growth_tracker.dart';
import 'screens/export_reports.dart';
import 'screens/register_toddler.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Posyandu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeDashboard(),
        '/toddler_data': (context) => const ToddlerDataScreen(),
        '/input': (context) => const InputDataScreen(),
        '/growth': (context) => const GrowthTrackerScreen(),
        '/export': (context) => const ExportReportsScreen(),
        '/register': (context) => const RegisterToddlerScreen(),
      },
    );
  }
}
