import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/user_profile.dart';
import '../../services/firestore_service.dart';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  UserProfile? _selectedClient;
  bool _saving = false;
  final _firestore = FirestoreService();
  late Future<List<UserProfile>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _firestore.fetchClients();
  }

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _budgetCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedClient == null) return;
    setState(() => _saving = true);
    try {
      await _firestore.createProject(
        projectName: _projectNameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        clientId: _selectedClient!.id,
        address: _addressCtrl.text.trim(),
        budgetTotal: double.tryParse(_budgetCtrl.text.trim()) ?? 0,
        estimatedDurationWeeks: int.tryParse(_durationCtrl.text.trim()) ?? 0,
        startDate: _startDate,
        estimatedEndDate: _endDate,
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto creado correctamente')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo proyecto')),
      body: FutureBuilder<List<UserProfile>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final clients = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _projectNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del proyecto'),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese la descripción' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserProfile>(
                    value: _selectedClient,
                    decoration: const InputDecoration(labelText: 'Cliente'),
                    items: clients
                        .map((client) => DropdownMenuItem(
                              value: client,
                              child: Text('${client.name} · ${client.email}'),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedClient = value),
                    validator: (value) => value == null ? 'Seleccione un cliente' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _budgetCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Presupuesto total (MXN)'),
                          validator: (v) => v == null || v.isEmpty ? 'Ingrese el presupuesto' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _durationCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duración (semanas)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: true),
                          icon: const Icon(Icons.date_range),
                          label: Text(_startDate == null
                              ? 'Fecha de inicio'
                              : 'Inicio: ${_startDate!.toLocal().toString().split(' ').first}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: false),
                          icon: const Icon(Icons.event_available),
                          label: Text(_endDate == null
                              ? 'Fecha estimada fin'
                              : 'Fin: ${_endDate!.toLocal().toString().split(' ').first}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LoyolaTheme.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Crear proyecto'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
