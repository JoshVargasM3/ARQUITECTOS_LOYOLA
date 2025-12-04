import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/project.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../project/project_detail_screen.dart';
import 'project_form_screen.dart';

class ArchitectHomeScreen extends StatefulWidget {
  static const routeName = '/architect-home';
  const ArchitectHomeScreen({super.key});

  @override
  State<ArchitectHomeScreen> createState() => _ArchitectHomeScreenState();
}

class _ArchitectHomeScreenState extends State<ArchitectHomeScreen> {
  final _firestore = FirestoreService();
  final Map<String, Future<UserProfile?>> _clientCache = {};

  Future<UserProfile?> _clientFuture(String uid) {
    return _clientCache.putIfAbsent(uid, () => _firestore.fetchUserProfile(uid));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos activos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProjectFormScreen()),
          );
          if (created == true && mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Proyecto creado')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Project>>(
        stream: _firestore.listenActiveProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) {
            return const Center(child: Text('Crea el primer proyecto'));
          }
          return Container(
            decoration: LoyolaTheme.gradientBackground(),
            child: ListView.builder(
              itemCount: projects.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final project = projects[index];
                return FutureBuilder<UserProfile?>(
                  future: _clientFuture(project.clientId),
                  builder: (context, clientSnapshot) {
                    final client = clientSnapshot.data;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(project.projectName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (client != null)
                              Text('${client.name} · ${client.email}',
                                  style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: project.progressPercent / 100,
                                minHeight: 8,
                                color: LoyolaTheme.gold,
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Avance ${project.progressPercent.toStringAsFixed(0)}%'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: LoyolaTheme.gold),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(project: project),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
