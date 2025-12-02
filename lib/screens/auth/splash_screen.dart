import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import '../architect/architect_home_screen.dart';
import '../client/client_home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _redirect();
  }

  Future<void> _redirect() async {
    final auth = context.read<AuthService>();
    await auth.ensureProfileLoaded();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final user = auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      return;
    }

    if (auth.role == UserRole.architect) {
      Navigator.pushReplacementNamed(context, ArchitectHomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, ClientHomeScreen.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: LoyolaTheme.gradientBackground(),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.architecture, size: 96, color: LoyolaTheme.gold),
                SizedBox(height: 16),
                Text(
                  'Arquitectos Loyola',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
