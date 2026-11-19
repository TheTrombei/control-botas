import 'package:flutter/material.dart';
import '../models/boot_model.dart';
import '../services/storage_service.dart';
import '../services/cloud_sync_service.dart';
import '../widgets/cloud_sync_dialog.dart';
import 'new_model_screen.dart';
import 'table_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BootModel> _models = [];
  bool _loading = true;
  String? _cloudUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkCloudStatus();
    CloudSyncService.addListener(_onCloudUpdated);
    CloudSyncService.startPolling();
  }

  @override
  void dispose() {
    CloudSyncService.removeListener(_onCloudUpdated);
    super.dispose();
  }

  void _onCloudUpdated(List<BootModel> updated) {
    if (mounted) {
      setState(() {
        _models = updated;
      });
    }
  }

  void _checkCloudStatus() async {
    final url = await CloudSyncService.getCloudUrl();
    if (mounted) {
      setState(() {
        _cloudUrl = url;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    // First load local immediately
    final list = await StorageService.loadModels();
    setState(() {
      _models = list;
      _loading = false;
    });

    // Check cloud in background
    _checkCloudStatus();
    final cloudList = await CloudSyncService.pullFromCloud();
    if (cloudList != null && mounted) {
      setState(() {
        _models = cloudList;
      });
    }
  }

  void _openModel(BootModel model) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TableScreen(model: model),
      ),
    );
    if (result == true || mounted) {
      _loadData();
    }
  }

  void _openCloudDialog() {
    CloudSyncDialog.show(
      context,
      onSyncCompleted: () {
        _loadData();
        _checkCloudStatus();
      },
    );
  }

  void _deleteModel(BootModel model) async {
    final is100 = model.isFullyCompleted;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              is100 ? Icons.check_circle : Icons.warning_amber_rounded,
              color: is100 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(is100 ? '¿Borrar Modelo Completado?' : '¿Borrar Modelo?'),
          ],
        ),
        content: Text(
          is100
              ? 'Has completado el 100% de "${model.name}". Al borrarlo se eliminará de la memoria de todos los dispositivos conectados.'
              : 'El modelo "${model.name}" tiene un ${model.progressPercentInt}% completado. ¿Seguro que deseas eliminarlo?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Borrar'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteModel(model.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modelo "${model.name}" eliminado'),
            backgroundColor: Colors.brown.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloudActive = _cloudUrl != null && _cloudUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.content_cut, color: Colors.amberAccent, size: 24),
            SizedBox(width: 10),
            Text(
              'Control de Corte de Botas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
        actions: [
          // Cloud Sync button
          IconButton(
            tooltip: isCloudActive ? 'Nube Activa (Sincronizado)' : 'Conectar Nube para Compartir',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isCloudActive ? Icons.cloud_done : Icons.cloud_outlined,
                  color: isCloudActive ? Colors.greenAccent : Colors.white70,
                ),
                if (isCloudActive)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openCloudDialog,
          ),
          IconButton(
            tooltip: 'Actualizar lista',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 26),
        label: const Text(
          'Nuevo Modelo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewModelScreen()),
          );
          _loadData();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : _models.isEmpty
              ? _buildEmptyState()
              : _buildModelList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.brown.shade200, width: 2),
              ),
              child: const Icon(
                Icons.table_chart_outlined,
                size: 72,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay modelos en corte',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Registra un nuevo modelo para hombre o mujer, selecciona los puntos y las cantidades, y empieza a palomear tu avance.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Crear Primer Modelo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewModelScreen()),
                );
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.brown,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _models.length,
        itemBuilder: (context, index) {
          final model = _models[index];
          final is100 = model.isFullyCompleted;
          final percent = model.progressPercentInt;

          Color accentColor;
          if (is100) {
            accentColor = const Color(0xFF2E7D32);
          } else if (percent > 40) {
            accentColor = const Color(0xFFFB8C00);
          } else {
            accentColor = const Color(0xFF6D4C41);
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: is100 ? const Color(0xFF4CAF50) : Colors.brown.shade100,
                width: is100 ? 2 : 1,
              ),
            ),
            elevation: is100 ? 4 : 2,
            child: InkWell(
              onTap: () => _openModel(model),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: is100 ? const Color(0xFFE8F5E9) : Colors.brown.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            is100 ? Icons.check_circle : Icons.content_cut,
                            color: is100 ? const Color(0xFF2E7D32) : Colors.brown.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E1C0C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: model.gender == 'Hombre'
                                          ? const Color(0xFFE3F2FD)
                                          : const Color(0xFFFCE4EC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      model.gender,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: model.gender == 'Hombre'
                                            ? const Color(0xFF1976D2)
                                            : const Color(0xFFC2185B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${model.totalPairs} pares  •  ${model.rows.length} puntos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Percent Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: accentColor),
                          ),
                          child: Text(
                            '$percent%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: model.progressPercentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Status and Delete Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${model.completedPieces} / ${model.totalPieces} piezas listas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (is100) ...[
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text(
                              'Borrar (100%)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () => _deleteModel(model),
                          ),
                        ] else ...[
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Abrir Hoja'),
                            onPressed: () => _openModel(model),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
