import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/boot_model.dart';
import 'storage_service.dart';

class CloudSyncService {
  static const String _kCloudUrlKey = 'boot_cloud_sync_url_v1';

  static Timer? _pollingTimer;
  static bool isSyncing = false;
  static String? currentError;
  static DateTime? lastSyncTime;

  // Callback to notify UI when cloud data updates
  static final List<Function(List<BootModel>)> _listeners = [];

  static void addListener(Function(List<BootModel>) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(List<BootModel>) listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners(List<BootModel> models) {
    for (var l in _listeners) {
      try {
        l(models);
      } catch (_) {}
    }
  }

  // Get current cloud URL
  static Future<String?> getCloudUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCloudUrlKey);
  }

  // Set current cloud URL
  static Future<bool> setCloudUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    var cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    return await prefs.setString(_kCloudUrlKey, cleanUrl);
  }

  // Remove cloud URL (switch to local only)
  static Future<bool> removeCloudUrl() async {
    final prefs = await SharedPreferences.getInstance();
    stopPolling();
    return await prefs.remove(_kCloudUrlKey);
  }

  // Test connection to URL
  static Future<bool> testConnection(String url) async {
    try {
      var cleanUrl = url.trim();
      if (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      final endpoint = cleanUrl.endsWith('.json') ? cleanUrl : '$cleanUrl/test_connection.json';
      final res = await http.get(Uri.parse(endpoint)).timeout(const Duration(seconds: 5));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // Push local models to the cloud
  static Future<bool> pushToCloud(List<BootModel> models) async {
    final url = await getCloudUrl();
    if (url == null || url.isEmpty) return false;

    try {
      isSyncing = true;
      final endpoint = url.endsWith('.json') ? url : '$url/modelos.json';
      final body = BootModel.encodeList(models);

      final res = await http.put(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        lastSyncTime = DateTime.now();
        currentError = null;
        return true;
      } else {
        currentError = 'Error servidor: ${res.statusCode}';
        return false;
      }
    } catch (e) {
      currentError = 'Error de red: $e';
      return false;
    } finally {
      isSyncing = false;
    }
  }

  // Pull models from cloud and update local storage if newer
  static Future<List<BootModel>?> pullFromCloud() async {
    final url = await getCloudUrl();
    if (url == null || url.isEmpty) return null;

    try {
      isSyncing = true;
      final endpoint = url.endsWith('.json') ? url : '$url/modelos.json';

      final res = await http.get(
        Uri.parse(endpoint),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bodyStr = res.body.trim();
        if (bodyStr.isEmpty || bodyStr == 'null') {
          // If empty in cloud, push our local models up
          final local = await StorageService.loadModels();
          if (local.isNotEmpty) {
            await pushToCloud(local);
          }
          lastSyncTime = DateTime.now();
          currentError = null;
          return local;
        }

        List<BootModel> remoteModels = [];
        try {
          final decoded = jsonDecode(bodyStr);
          if (decoded is List) {
            remoteModels = decoded.map((m) => BootModel.fromJson(m as Map<String, dynamic>)).toList();
          } else if (decoded is Map) {
            // Firebase sometimes returns a map with keys if saved as map
            remoteModels = decoded.values
                .map((m) => BootModel.fromJson(m as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}

        // Save remote to local
        await StorageService.saveModels(remoteModels);
        lastSyncTime = DateTime.now();
        currentError = null;
        _notifyListeners(remoteModels);
        return remoteModels;
      } else {
        currentError = 'Error HTTP: ${res.statusCode}';
        return null;
      }
    } catch (e) {
      currentError = 'Sin conexión: $e';
      return null;
    } finally {
      isSyncing = false;
    }
  }

  // Synchronize: push and pull
  static Future<void> syncNow() async {
    final cloudModels = await pullFromCloud();
    if (cloudModels == null) {
      // If pull failed or cloud is empty, try pushing local
      final local = await StorageService.loadModels();
      if (local.isNotEmpty) {
        await pushToCloud(local);
      }
    }
  }

  // Start background polling (every 6 seconds) for real-time multi-device sync
  static void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      final url = await getCloudUrl();
      if (url != null && url.isNotEmpty && !isSyncing) {
        await pullFromCloud();
      }
    });
  }

  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
