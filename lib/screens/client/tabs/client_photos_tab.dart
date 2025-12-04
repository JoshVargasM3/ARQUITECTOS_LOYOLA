import 'package:flutter/material.dart';

import '../../../models/project_photo.dart';
import '../../../services/firestore_service.dart';

class ClientPhotosTab extends StatelessWidget {
  final String projectId;
  const ClientPhotosTab({super.key, required this.projectId});

  static const sections = ['Terreno', 'Cimentación', 'Estructura', 'Interiores'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: sections.length,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Terreno'),
              Tab(text: 'Cimentación'),
              Tab(text: 'Estructura'),
              Tab(text: 'Interiores'),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<ProjectPhoto>>(
              stream: FirestoreService().listenPhotos(projectId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final photos = snapshot.data ?? [];
                if (photos.isEmpty) {
                  return const Center(child: Text('No hay fotos registradas aún'));
                }
                return TabBarView(
                  children: sections.map((section) {
                    final sectionPhotos =
                        photos.where((p) => p.section.toLowerCase() == section.toLowerCase()).toList();
                    if (sectionPhotos.isEmpty) {
                      return Center(child: Text('No hay fotos en $section'));
                    }
                    return PageView.builder(
                      itemCount: sectionPhotos.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        final photo = sectionPhotos[index];
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(photo.imageUrl, fit: BoxFit.cover),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Text(
                                    photo.title,
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
