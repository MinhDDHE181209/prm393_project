import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/origami_model.dart';
import '../services/origami_service.dart';

/// Tải [OrigamiModel] theo ID trước khi render màn hình con.
class RouteModelLoader extends StatelessWidget {
  final String modelId;
  final Widget Function(OrigamiModel model) builder;

  const RouteModelLoader({
    super.key,
    required this.modelId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrigamiModel>(
      future: OrigamiService().getModelById(modelId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.amber),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: Center(
              child: Text(
                snapshot.error?.toString() ?? 'Không tìm thấy mẫu gấp',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }
        return builder(snapshot.data!);
      },
    );
  }
}
