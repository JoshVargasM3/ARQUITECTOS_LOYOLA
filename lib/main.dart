import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/architect/architect_home_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LoyolaApp());
}

class LoyolaApp extends StatelessWidget {
  const LoyolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Arquitectos Loyola',
        debugShowCheckedModeBanner: false,
        theme: LoyolaTheme.theme,
        home: const SplashScreen(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          ClientHomeScreen.routeName: (_) => const ClientHomeScreen(),
          ArchitectHomeScreen.routeName: (_) => const ArchitectHomeScreen(),
        },
      ),
    );
  }
}
