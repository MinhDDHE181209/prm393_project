import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/collection_model.dart';

class CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final VoidCallback onTap;
  const CollectionCard({super.key, required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = !collection.isUnlocked && collection.price > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: locked ? Colors.black45 : Colors.black26,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        collection.emoji,
                        style: TextStyle(
                          fontSize: 52,
                          color: locked ? Colors.white38 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (locked)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.lock, color: Colors.white60, size: 20),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.title,
                    style: TextStyle(
                      color: locked ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    collection.titleJP,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: collection.price == 0
                          ? AppTheme.teal.withOpacity(0.2)
                          : AppTheme.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      collection.price == 0
                          ? '🔓 Miễn phí'
                          : locked
                              ? '🔒 ${collection.price}đ'
                              : '✅ Đã mở khoá',
                      style: TextStyle(
                        color: collection.price == 0
                            ? AppTheme.teal
                            : AppTheme.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
