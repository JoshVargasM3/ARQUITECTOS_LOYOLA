import 'package:flutter/material.dart';

import '../../../models/plan_document.dart';
import '../../../services/firestore_service.dart';

class ClientPlansTab extends StatelessWidget {
  final String projectId;
  const ClientPlansTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlanDocument>>(
      stream: FirestoreService().listenPlans(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final plans = snapshot.data ?? [];
        if (plans.isEmpty) {
          return const Center(child: Text('No hay planos cargados aún'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (plan.fileUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          plan.fileUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (plan.fileUrl.isNotEmpty) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(plan.section,
                              style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 8),
                          Text(plan.description),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
