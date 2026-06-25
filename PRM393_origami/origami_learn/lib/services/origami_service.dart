import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/collection_model.dart';
import '../models/origami_model.dart';
import '../models/fold_step.dart';

/// Đọc dữ liệu từ JSON local (assets/data/).
/// Khi nối Firestore thật, chỉ cần sửa nội bộ 3 hàm này —
/// toàn bộ Screen và Provider gọi vào đây không cần đổi.
class OrigamiService {
  Future<List<CollectionModel>> getCollections() async {
    final raw = await rootBundle.loadString('assets/data/seed_collections.json');
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => CollectionModel.fromJson(e)).toList();
  }

  Future<List<OrigamiModel>> getModelsInCollection(String collectionId) async {
    final raw = await rootBundle.loadString('assets/data/seed_models.json');
    final List<dynamic> list = jsonDecode(raw);
    return list
        .map((e) => OrigamiModel.fromJson(e))
        .where((m) => m.collectionId == collectionId)
        .toList();
  }

  Future<OrigamiModel> getModelById(String modelId) async {
    final raw = await rootBundle.loadString('assets/data/seed_models.json');
    final List<dynamic> list = jsonDecode(raw);
    return list
        .map((e) => OrigamiModel.fromJson(e))
        .firstWhere((m) => m.id == modelId,
            orElse: () => throw Exception('Không tìm thấy model: $modelId'));
  }
  Future<List<FoldStep>> getFoldSteps(String modelId) async {
  final raw = await rootBundle.loadString('assets/data/seed_steps.json');
  final Map<String, dynamic> map = jsonDecode(raw);
  final steps = map[modelId] as List<dynamic>? ?? [];
  return steps.map((e) => FoldStep.fromJson(e)).toList();
}
Future<ModuleData> getModuleData(String modelId) async {
  final raw = await rootBundle.loadString('assets/data/seed_steps.json');
  final Map<String, dynamic> map = jsonDecode(raw);
  final data = map[modelId] as Map<String, dynamic>?;
  if (data == null) throw Exception('Không tìm thấy module data cho: $modelId');
  return ModuleData.fromJson(data);
}
}