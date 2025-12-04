import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/inventory_item.dart';
import '../../models/project.dart';
import '../../models/video.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final int initialTab;
  const ProjectDetailScreen({super.key, required this.project, this.initialTab = 0});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isArchitect = auth.role == UserRole.architect;
    final project = widget.project;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.projectName),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Presupuesto'),
            Tab(text: 'Fotos'),
            Tab(text: 'Planos'),
            Tab(text: 'Videos'),
            Tab(text: 'Comentarios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummary(project),
          _buildBudget(project),
          const _PlaceholderTab(message: 'Integra Firebase Storage para fotos'),
          const _PlaceholderTab(message: 'Integra Firebase Storage para planos'),
          _VideosTab(projectId: project.id),
          _CommentsTab(projectId: project.id),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: LoyolaTheme.gold),
              child: Center(
                child: Text('Arquitectos Loyola', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await context.read<AuthService>().signOut();
                if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isArchitect
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildSummary(Project project) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.projectName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(project.description),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: project.progressPercent / 100,
                  color: LoyolaTheme.gold,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 6),
                Text('Avance ${project.progressPercent.toStringAsFixed(0)}% · ${projectStatusLabel(project.status)}'),
                const SizedBox(height: 12),
                Text('Última actualización: ${project.updatedAt.toLocal()}'),
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
                const Text('Inventario (resumen)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _InventoryPreview(projectId: project.id),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudget(Project project) {
    final remaining = project.budgetRemaining;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Presupuesto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Total: MXN ${project.budgetTotal.toStringAsFixed(2)}'),
                Text('Gastado: MXN ${project.budgetUsed.toStringAsFixed(2)}'),
                Text('Restante: MXN ${remaining.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentsTab extends StatefulWidget {
  final String projectId;
  const _CommentsTab({required this.projectId});

  @override
  State<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<_CommentsTab> {
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: FirestoreService().listenComments(widget.projectId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final comments = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final isMine = comment.userId == auth.currentUser?.uid;
                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMine ? LoyolaTheme.gold.withOpacity(0.9) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.message,
                              style: TextStyle(
                                color: isMine ? Colors.white : Colors.black87,
                              )),
                          const SizedBox(height: 4),
                          Text(comment.fromRole,
                              style: TextStyle(
                                color: isMine ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: LoyolaTheme.gold),
                  onPressed: () async {
                    final text = _messageCtrl.text.trim();
                    if (text.isEmpty) return;
                    await FirestoreService().addComment(
                      projectId: widget.projectId,
                      userId: auth.currentUser!.uid,
                      fromRole: auth.role == UserRole.architect ? 'architect' : 'client',
                      message: text,
                    );
                    _messageCtrl.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideosTab extends StatelessWidget {
  final String projectId;
  const _VideosTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectVideo>>(
      stream: FirestoreService().listenVideos(projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final videos = snapshot.data!;
        if (videos.isEmpty) {
          return const Center(child: Text('No hay videos aún'));
        }
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            final controller = YoutubePlayerController.fromVideoId(videoId: YoutubePlayerController.convertUrlToId(video.youtubeUrl) ?? '');
            return Card(
              margin: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(controller: controller),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(video.description),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InventoryPreview extends StatelessWidget {
  final String projectId;
  const _InventoryPreview({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: FirestoreService().listenInventory(projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Cargando inventario...');
        }
        final items = snapshot.data!;
        if (items.isEmpty) return const Text('Sin materiales cargados aún');
        return Column(
          children: items
              .take(3)
              .map(
                (item) => ListTile(
                  dense: true,
                  title: Text(item.name),
                  subtitle: Text('${item.quantity} ${item.unit} · MXN ${item.unitCost.toStringAsFixed(2)}'),
                  trailing: Text('MXN ${item.totalCost.toStringAsFixed(2)}'),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String message;
  const _PlaceholderTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
