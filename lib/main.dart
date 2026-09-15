import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/bookings_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

const navy = Color(0xFF17143F);
const primary = Color(0xFF4B3FE4);
const orange = Color(0xFFFFA51F);
const pageBg = Color(0xFFF5F7FC);
const ink = Color(0xFF20253D);
const muted = Color(0xFF77809A);
const line = Color(0xFFE4E7F0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch (e) { debugPrint('Firebase initialization notice: $e'); }
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (_) => AppProvider())], child: const ApexFixApp()));
}

class ApexFixApp extends StatelessWidget {
  const ApexFixApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, scaffoldBackgroundColor: pageBg, colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, surface: Colors.white));
    return MaterialApp(
      title: 'ApexFix - Home Services & Repair', debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: ink, displayColor: ink),
        appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0),
        cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: line))),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, elevation: 0, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class ApexFixMark extends StatelessWidget {
  final bool compact;
  const ApexFixMark({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: compact ? 30 : 38, height: compact ? 30 : 38, decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.bolt_rounded, color: Colors.white, size: compact ? 18 : 23)),
    const SizedBox(width: 9),
    Text('apexfix', style: GoogleFonts.inter(fontSize: compact ? 15 : 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.4)),
  ]);
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});
  @override State<MainNavigationShell> createState() => _MainNavigationShellState();
}
class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final _screens = const [HomeScreen(), BookingsListScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    if (!app.isLoggedIn) return const LoginScreen();
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: line)), boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 20, offset: Offset(0, -4))]),
        child: NavigationBar(height: 70, selectedIndex: _currentIndex, backgroundColor: Colors.white, surfaceTintColor: Colors.white, indicatorColor: const Color(0xFFEAE8FF), labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, onDestinationSelected: (i) => setState(() => _currentIndex = i), destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined, color: muted), selectedIcon: Icon(Icons.home_rounded, color: primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined, color: muted), selectedIcon: Icon(Icons.receipt_long_rounded, color: primary), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded, color: muted), selectedIcon: Icon(Icons.person_rounded, color: primary), label: 'Profile'),
        ]),
      ),
    );
  }
}
