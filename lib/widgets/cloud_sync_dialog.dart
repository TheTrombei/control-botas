import 'package:flutter/material.dart';
import '../services/cloud_sync_service.dart';

class CloudSyncDialog extends StatefulWidget {
  final VoidCallback onSyncCompleted;

  const CloudSyncDialog({super.key, required this.onSyncCompleted});

  static Future<void> show(BuildContext context, {required VoidCallback onSyncCompleted}) {
    return showDialog(
      context: context,
      builder: (ctx) => CloudSyncDialog(onSyncCompleted: onSyncCompleted),
    );
  }

  @override
  State<CloudSyncDialog> createState() => _CloudSyncDialogState();
}

class _CloudSyncDialogState extends State<CloudSyncDialog> {
  final TextEditingController _urlController = TextEditingController();
  bool _testing = false;
  String? _statusMessage;
  bool _isSuccess = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  void _loadCurrent() async {
    final url = await CloudSyncService.getCloudUrl();
    setState(() {
      _currentUrl = url;
      if (url != null) {
        _urlController.text = url;
      }
    });
  }

  void _testAndSave() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor escribe o pega el enlace de tu base de datos';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _testing = true;
      _statusMessage = 'Probando conexión con la nube...';
      _isSuccess = false;
    });

    final ok = await CloudSyncService.testConnection(url);
    if (!mounted) return;

    if (ok) {
      await CloudSyncService.setCloudUrl(url);
      CloudSyncService.startPolling();
      await CloudSyncService.syncNow();
      widget.onSyncCompleted();

      setState(() {
        _testing = false;
        _isSuccess = true;
        _currentUrl = url;
        _statusMessage = '¡Conexión Exitosa! Dispositivos sincronizados.';
      });
    } else {
      setState(() {
        _testing = false;
        _isSuccess = false;
        _statusMessage = 'No se pudo conectar. Verifica que el enlace sea correcto y termine en .firebaseio.com';
      });
    }
  }

  void _syncNow() async {
    setState(() {
      _testing = true;
      _statusMessage = 'Sincronizando datos...';
    });
    await CloudSyncService.syncNow();
    widget.onSyncCompleted();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _isSuccess = true;
      _statusMessage = '¡Sincronización completada!';
    });
  }

  void _disconnect() async {
    await CloudSyncService.removeCloudUrl();
    widget.onSyncCompleted();
    if (!mounted) return;
    setState(() {
      _currentUrl = null;
      _urlController.clear();
      _isSuccess = false;
      _statusMessage = 'Nube desconectada. Ahora se guarda solo en este dispositivo.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _currentUrl != null && _currentUrl!.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isConnected ? const Color(0xFFE8F5E9) : Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isConnected ? Icons.cloud_done : Icons.cloud_outlined,
                      color: isConnected ? const Color(0xFF2E7D32) : Colors.brown,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sincronización en la Nube',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E1C0C),
                          ),
                        ),
                        Text(
                          isConnected ? 'Conectado • Sincronizando en vivo' : 'Modo local • Sin conectar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isConnected ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Conecta esta aplicación a una base de datos en la nube gratuita (Firebase) para que lo que crees o palomees en un teléfono se vea al mismo segundo en los demás celulares y en la web.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
              ),

              const SizedBox(height: 16),

              // Input URL
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL de tu Base de Datos',
                  hintText: 'https://mi-taller-default-rtdb.firebaseio.com',
                  prefixIcon: const Icon(Icons.link, color: Colors.brown),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.brown.shade50.withValues(alpha: 0.3),
                ),
              ),

              const SizedBox(height: 12),

              // Status Message
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess ? const Color(0xFF81C784) : const Color(0xFFE57373),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.error_outline,
                        color: _isSuccess ? const Color(0xFF2E7D32) : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isSuccess ? const Color(0xFF1B5E20) : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Actions
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _testing ? null : _testAndSave,
                icon: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _testing ? 'Conectando...' : 'Guardar y Conectar Nube',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),

              if (isConnected) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3E2723),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _testing ? null : _syncNow,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar Manualmente Ahora'),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                  onPressed: _disconnect,
                  icon: const Icon(Icons.cloud_off, size: 18),
                  label: const Text('Desconectar Nube (Modo solo local)'),
                ),
              ],

              const Divider(height: 28),

              // Guide how to get free Firebase in 2 minutes
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline, color: Colors.brown),
                title: const Text(
                  '¿Cómo obtener tu enlace gratis en 2 min?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pasos en Google Firebase (100% Gratis):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '1. Entra con tu cuenta de Google a: console.firebase.google.com\n'
                          '2. Clic en "Crear un proyecto" (ponle el nombre de tu taller).\n'
                          '3. En el menú izquierdo ve a "Compilación" ➔ "Realtime Database".\n'
                          '4. Clic en "Crear base de datos" ➔ Elige "Comenzar en modo de prueba".\n'
                          '5. Copia el enlace que te da (ej: https://taller-xyz-default-rtdb.firebaseio.com) y pégalo aquí.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
