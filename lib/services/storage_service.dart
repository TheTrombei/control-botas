import 'package:shared_preferences/shared_preferences.dart';
import '../models/boot_model.dart';
import 'cloud_sync_service.dart';

class StorageService {
  static const String _kModelsKey = 'boot_cutting_models_v1';

  static Future<List<BootModel>> loadModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kModelsKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }
      return BootModel.decodeList(jsonStr);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveModels(List<BootModel> models, {bool syncToCloud = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = BootModel.encodeList(models);
      final saved = await prefs.setString(_kModelsKey, jsonStr);

      if (saved && syncToCloud) {
        // Fire and forget push to cloud
        CloudSyncService.pushToCloud(models);
      }

      return saved;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveSingleModel(BootModel model) async {
    final list = await loadModels();
    final index = list.indexWhere((m) => m.id == model.id);
    if (index >= 0) {
      list[index] = model;
    } else {
      list.insert(0, model);
    }
    return await saveModels(list);
  }

  static Future<bool> deleteModel(String modelId) async {
    final list = await loadModels();
    list.removeWhere((m) => m.id == modelId);
    return await saveModels(list);
  }
}
