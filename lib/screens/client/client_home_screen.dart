import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../project/project_detail_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  static const routeName = '/client-home';
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final uid = auth.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi proyecto'),
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
      body: uid == null
          ? const Center(child: Text('Inicia sesión para ver tus proyectos'))
          : StreamBuilder<List<Project>>(
              stream: FirestoreService().listenProjectsForClient(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final projects = snapshot.data ?? [];
                if (projects.isEmpty) {
                  return const Center(child: Text('No hay proyectos asignados'));
                }
                final project = projects.first;
                return Container(
                  decoration: LoyolaTheme.gradientBackground(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, ${auth.profile?.name ?? 'Cliente'}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _ProjectSummaryCard(project: project),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickAction(
                            icon: Icons.timeline,
                            label: 'Avance',
                            onTap: () => _openDetails(context, project),
                          ),
                          _QuickAction(
                            icon: Icons.photo_library_outlined,
                            label: 'Fotos',
                            onTap: () => _openDetails(context, project, tabIndex: 2),
                          ),
                          _QuickAction(
                            icon: Icons.description_outlined,
                            label: 'Planos',
                            onTap: () => _openDetails(context, project, tabIndex: 3),
                          ),
                          _QuickAction(
                            icon: Icons.attach_money,
                            label: 'Presupuesto',
                            onTap: () => _openDetails(context, project, tabIndex: 1),
                          ),
                          _QuickAction(
                            icon: Icons.chat_outlined,
                            label: 'Comentarios',
                            onTap: () => _openDetails(context, project, tabIndex: 5),
                          ),
                          _QuickAction(
                            icon: Icons.video_library_outlined,
                            label: 'Videos',
                            onTap: () => _openDetails(context, project, tabIndex: 4),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _openDetails(BuildContext context, Project project, {int tabIndex = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(project: project, initialTab: tabIndex),
      ),
    );
  }
}

class _ProjectSummaryCard extends StatelessWidget {
  final Project project;
  const _ProjectSummaryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.projectName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(project.description),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: project.progressPercent / 100,
              color: LoyolaTheme.gold,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 4),
            Text('Avance ${project.progressPercent.toStringAsFixed(0)}%'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BudgetIndicator(
                    label: 'Total',
                    amount: project.budgetTotal,
                  ),
                ),
                Expanded(
                  child: _BudgetIndicator(
                    label: 'Gastado',
                    amount: project.budgetUsed,
                    highlight: true,
                  ),
                ),
              ],
            ),
            if (!project.isActive || project.status == ProjectStatus.finished)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Proyecto finalizado. Visualiza el historial de avances.',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetIndicator extends StatelessWidget {
  final String label;
  final double amount;
  final bool highlight;
  const _BudgetIndicator({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text('MXN ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? LoyolaTheme.gold : Colors.black,
            )),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: LoyolaTheme.gold),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
