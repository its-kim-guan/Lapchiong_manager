import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_app/database/app_database_service.dart';
import 'package:my_app/screens/inventory_app.dart';
import 'package:my_app/screens/login_page.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/app_constants.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final databaseService = AppDatabaseService();
  await databaseService.init();

  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.databaseService});

  final AppDatabaseService databaseService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppUser? _currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9F1D20),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF5EF),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD8C8B8)),
          ),
        ),
        useMaterial3: true,
      ),
      home: _currentUser == null
          ? LoginPage(
              onLogin: (user) {
                setState(() {
                  _currentUser = user;
                });
              },
            )
          : InventoryApp(
              databaseService: widget.databaseService,
              currentUser: _currentUser!,
              onLogout: () {
                setState(() {
                  _currentUser = null;
                });
              },
            ),
    );
  }
}
