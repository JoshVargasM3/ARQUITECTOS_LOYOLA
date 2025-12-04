import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../models/plan_document.dart';
import '../../models/project.dart';
import '../../models/project_photo.dart';
import '../../models/user_role.dart';
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

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double? _progressValue;
  bool _savingProgress = false;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _progressValue = widget.project.progressPercent;
    _tabController = TabController(length: 7, vsync: this, initialIndex: widget.initialTab);
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

    return StreamBuilder<Project?>(
      stream: _firestore.listenProject(widget.project.id),
      initialData: widget.project,
      builder: (context, snapshot) {
        final project = snapshot.data ?? widget.project;
        final progressValue = _progressValue ?? project.progressPercent;

        return Scaffold(
          appBar: AppBar(
            title: Text(project.projectName),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Presupuesto'),
                Tab(text: 'Inventario'),
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
              _buildSummary(project, isArchitect, progressValue),
              _buildBudget(project),
              _InventoryTab(
                projectId: project.id,
                isArchitect: isArchitect,
                onSaveItem: _saveInventoryItem,
                onDeleteItem: _deleteInventoryItem,
              ),
              _PhotosTab(projectId: project.id),
              _PlansTab(projectId: project.id),
              _VideosTab(projectId: project.id),
              _CommentsTab(projectId: project.id),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(Project project, bool isArchitect, double progressValue) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.projectName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(project.description),
                if (project.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(project.address, style: const TextStyle(color: Colors.black54)),
                ],
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: project.progressPercent / 100,
                  color: LoyolaTheme.gold,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 6),
                Text('Avance ${project.progressPercent.toStringAsFixed(0)}%'),
                if (isArchitect) ...[
                  const SizedBox(height: 16),
                  const Text('Editar avance',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Slider(
                    value: progressValue.clamp(0, 100).toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${progressValue.toStringAsFixed(0)}%',
                    onChanged: (value) => setState(() => _progressValue = value),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savingProgress
                          ? null
                          : () async {
                              setState(() => _savingProgress = true);
                              await _firestore.updateProjectProgress(
                                projectId: project.id,
                                progressPercent: _progressValue ?? project.progressPercent,
                              );
                              if (mounted) {
                                setState(() => _savingProgress = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Avance actualizado')),
                                );
                              }
                            },
                      icon: const Icon(Icons.save),
                      label: _savingProgress
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar cambios'),
                    ),
                  )
                ],
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
                const Text('Inventario (resumen)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _saveInventoryItem(InventoryItem item, {bool isEditing = false}) async {
    if (isEditing) {
      await _firestore.updateInventoryItem(projectId: widget.project.id, item: item);
    } else {
      await _firestore.addInventoryItem(projectId: widget.project.id, item: item);
    }
  }

  Future<void> _deleteInventoryItem(String itemId) async {
    await _firestore.deleteInventoryItem(projectId: widget.project.id, itemId: itemId);
  }
}

class _InventoryTab extends StatelessWidget {
  final String projectId;
  final bool isArchitect;
  final Future<void> Function(InventoryItem item, {bool isEditing}) onSaveItem;
  final Future<void> Function(String itemId) onDeleteItem;
  const _InventoryTab({
    required this.projectId,
    required this.isArchitect,
    required this.onSaveItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: FirestoreService().listenInventory(projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        final total = items.fold<double>(0, (sum, item) => sum + item.totalCost);
        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No hay materiales registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Card(
                            child: ListTile(
                              title: const Text('Total inventario',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Text('MXN ${total.toStringAsFixed(2)}'),
                            ),
                          );
                        }
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                                '${item.category} · ${item.quantity} ${item.unit} · MXN ${item.unitCost.toStringAsFixed(2)}'),
                            trailing: Text('MXN ${item.totalCost.toStringAsFixed(2)}'),
                            onTap: isArchitect
                                ? () => _openInventoryForm(context, item: item)
                                : null,
                            onLongPress:
                                isArchitect ? () => _confirmDelete(context, item.id) : null,
                          ),
                        );
                      },
                    ),
            ),
            if (isArchitect)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInventoryForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LoyolaTheme.gold,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar material'),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar material'),
        content: const Text('¿Deseas eliminar este material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      await onDeleteItem(id);
    }
  }

  Future<void> _openInventoryForm(BuildContext context, {InventoryItem? item}) async {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final categoryCtrl = TextEditingController(text: item?.category ?? '');
    final quantityCtrl = TextEditingController(text: (item?.quantity ?? 0).toString());
    final unitCtrl = TextEditingController(text: item?.unit ?? '');
    final unitCostCtrl = TextEditingController(text: (item?.unitCost ?? 0).toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item == null ? 'Agregar material' : 'Editar material',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: unitCostCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Costo unitario'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newItem = InventoryItem(
                      id: item?.id ?? '',
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      unit: unitCtrl.text.trim(),
                      quantity: double.tryParse(quantityCtrl.text) ?? 0,
                      unitCost: double.tryParse(unitCostCtrl.text) ?? 0,
                      totalCost: 0,
                      updatedAt: DateTime.now(),
                    );
                    await onSaveItem(newItem, isEditing: item != null);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoyolaTheme.gold,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotosTab extends StatelessWidget {
  final String projectId;
  const _PhotosTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectPhoto>>(
      stream: FirestoreService().listenPhotos(projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final photos = snapshot.data!;
        if (photos.isEmpty) {
          return const Center(child: Text('No hay fotos registradas'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(photo.imageUrl, fit: BoxFit.cover),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(photo.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(photo.section, style: const TextStyle(color: Colors.black54)),
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

class _PlansTab extends StatelessWidget {
  final String projectId;
  const _PlansTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlanDocument>>(
      stream: FirestoreService().listenPlans(projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final plans = snapshot.data!;
        if (plans.isEmpty) {
          return const Center(child: Text('No hay planos cargados'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: plan.fileUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(plan.fileUrl, width: 60, height: 60, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.description_outlined),
                title: Text(plan.name),
                subtitle: Text('${plan.section}\n${plan.description}'),
              ),
            );
          },
        );
      },
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
            final controller = YoutubePlayerController.fromVideoId(
                videoId: YoutubePlayerController.convertUrlToId(video.youtubeUrl) ?? '');
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
                  subtitle:
                      Text('${item.quantity} ${item.unit} · MXN ${item.unitCost.toStringAsFixed(2)}'),
                  trailing: Text('MXN ${item.totalCost.toStringAsFixed(2)}'),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
