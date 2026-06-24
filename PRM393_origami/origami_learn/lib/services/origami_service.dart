import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/collection_model.dart';
import '../models/origami_model.dart';

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
}