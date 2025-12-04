import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'tabs/client_home_tab.dart';
import 'tabs/client_inventory_tab.dart';
import 'tabs/client_photos_tab.dart';
import 'tabs/client_plans_tab.dart';
import 'tabs/client_profile_tab.dart';

class ClientMainShell extends StatefulWidget {
  static const routeName = '/client-main';
  const ClientMainShell({super.key});

  @override
  State<ClientMainShell> createState() => _ClientMainShellState();
}

class _ClientMainShellState extends State<ClientMainShell> {
  int _currentIndex = 0;
  final _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final uid = auth.currentUser?.uid;

    return Scaffold(
      body: uid == null
          ? const Center(child: Text('Inicia sesión para ver tu proyecto'))
          : StreamBuilder<Project?>(
              stream: _firestore.listenActiveProjectForClient(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final project = snapshot.data;
                if (project == null) {
                  return const Center(child: Text('No hay proyecto activo asignado'));
                }

                final tabs = [
                  ClientHomeTab(project: project),
                  ClientPlansTab(projectId: project.id),
                  ClientPhotosTab(projectId: project.id),
                  ClientInventoryTab(projectId: project.id),
                  ClientProfileTab(project: project),
                ];

                return Container(
                  decoration: LoyolaTheme.gradientBackground(),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: IndexedStack(
                            index: _currentIndex,
                            children: tabs,
                          ),
                        ),
                        BottomNavigationBar(
                          currentIndex: _currentIndex,
                          selectedItemColor: LoyolaTheme.gold,
                          unselectedItemColor: Colors.grey,
                          onTap: (index) => setState(() => _currentIndex = index),
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.home_outlined),
                              label: 'Home',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.description_outlined),
                              label: 'Planos',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.photo_camera_back_outlined),
                              label: 'Fotos',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.inventory_2_outlined),
                              label: 'Inventario',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.person_outline),
                              label: 'Perfil',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
