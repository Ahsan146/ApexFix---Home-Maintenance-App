import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/technician_provider.dart';
import 'screens/technician_login_screen.dart';
import 'screens/technician_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const ApexFixProApp());
}

class ApexFixProApp extends StatelessWidget {
  const ApexFixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TechnicianProvider()),
      ],
      child: MaterialApp(
        title: 'ApexFix Pro - Technician & Partner App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.dark,
            primary: const Color(0xFF2563EB),
            surface: const Color(0xFF1E293B),
          ),
        ),
        home: const MainGate(),
      ),
    );
  }
}

class MainGate extends StatelessWidget {
  const MainGate({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TechnicianProvider>();

    if (!provider.isLoggedIn) {
      return const TechnicianLoginScreen();
    }

    return const TechnicianDashboardScreen();
  }
}
