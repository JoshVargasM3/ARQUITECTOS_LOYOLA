import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../models/project.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_screen.dart';

class ClientProfileTab extends StatelessWidget {
  final Project project;
  const ClientProfileTab({super.key, required this.project});

  Color _budgetColor(double total, double used) {
    final remaining = total - used;
    final remainingPercent = total == 0 ? 0 : remaining / total;
    if (remainingPercent >= 0.3) return Colors.green;
    if (remainingPercent >= 0.1) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = auth.profile;
    final budgetRemaining = project.budgetRemaining;
    final budgetColor = _budgetColor(project.budgetTotal, project.budgetUsed);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(profile?.name ?? 'Cliente'),
              subtitle: Text(profile?.email ?? ''),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Presupuesto',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _budgetRow('Total', project.budgetTotal),
                  _budgetRow('Gastado', project.budgetUsed),
                  _budgetRow('Restante', budgetRemaining),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: project.budgetTotal == 0
                          ? 0
                          : (budgetRemaining / project.budgetTotal).clamp(0, 1),
                      backgroundColor: Colors.grey[200],
                      color: budgetColor,
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cronograma',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (project.estimatedDurationWeeks > 0)
                    Text('Duración estimada: ${project.estimatedDurationWeeks} semanas'),
                  if (project.startDate != null)
                    Text('Inicio: ${project.startDate!.toLocal().toString().split(' ').first}'),
                  if (project.estimatedEndDate != null)
                    Text('Entrega estimada: ${project.estimatedEndDate!.toLocal().toString().split(' ').first}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LoyolaTheme.gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          )
        ],
      ),
    );
  }

  Widget _budgetRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('MXN ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
