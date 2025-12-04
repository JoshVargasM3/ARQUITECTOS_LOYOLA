import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../models/project.dart';
import '../../../services/firestore_service.dart';

class ClientHomeTab extends StatelessWidget {
  final Project project;
  const ClientHomeTab({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Project?>(
      stream: FirestoreService().listenProject(project.id),
      initialData: project,
      builder: (context, snapshot) {
        final currentProject = snapshot.data ?? project;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentProject.projectName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (currentProject.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(currentProject.address,
                    style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Avance del proyecto',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${currentProject.progressPercent.toStringAsFixed(0)}%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: currentProject.progressPercent / 100,
                        color: LoyolaTheme.gold,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descripción',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(currentProject.description),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
