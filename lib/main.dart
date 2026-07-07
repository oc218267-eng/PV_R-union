import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/accueil_screen.dart';
import 'screens/nouvelle_reunion_screen.dart';
import 'screens/parametres_screen.dart';
import 'screens/pv_screen.dart';
import 'screens/seance_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const PvReunionApp());
}

class PvReunionApp extends StatelessWidget {
  const PvReunionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PV Réunion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AccueilScreen(),
        '/nouvelle':(context) => const NouvelleReunionScreen(),
        '/nouvelle-reunion': (context) => const NouvelleReunionScreen(),
        '/seance': (context) => const SeanceScreen(),
        '/pv': (context) => const PvScreen(),
        '/parametres': (context) => const ParametresScreen(),
      },
    );
  }
}