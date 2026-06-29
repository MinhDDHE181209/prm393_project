import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../models/collection_model.dart';
import '../providers/progress_provider.dart';

// Dùng: PaymentBottomSheet.show(context, ref, collection: collection)
// Sau khi unlock xong → collectionsProvider tự refresh (vì progressProvider.invalidate)

class PaymentBottomSheet extends ConsumerStatefulWidget {
  final CollectionModel collection;
  const PaymentBottomSheet._({required this.collection});

 /// Gọi từ bất kỳ đâu — không cần route riêng
  static Future<bool> show(
    BuildContext context,
    WidgetRef ref, { // 🌟 THÊM DÒNG NÀY: Nhận thêm ref làm tham số vị trí thứ 2
    required CollectionModel collection,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentBottomSheet._(collection: collection),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  _PayState _state = _PayState.idle;

  Future<void> _confirm() async {
    setState(() => _state = _PayState.loading);

    // Mock payment: delay 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));

    // Unlock collection trong SQLite qua provider
    await ref
        .read(progressNotifierProvider.notifier)
        .unlockCollection(widget.collection.id);

    if (!mounted) return;
    setState(() => _state = _PayState.success);

    // Hiển thị success 1.2s rồi đóng
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          if (_state == _PayState.success)
            _SuccessView()
          else ...[
            _Header(collection: widget.collection),
            const SizedBox(height: 20),
            _BenefitsList(),
            const SizedBox(height: 24),
            _PriceRow(price: widget.collection.price),
            const SizedBox(height: 20),
            _ConfirmButton(
              price: widget.collection.price,
              isLoading: _state == _PayState.loading,
              onPressed: _state == _PayState.loading ? null : _confirm,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _state == _PayState.loading
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Để sau',
                  style: TextStyle(color: Colors.white38, fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }
}

enum _PayState { idle, loading, success }

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final CollectionModel collection;
  const _Header({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(collection.emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 10),
        Text(
          'Mở khoá "${collection.title}"',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(collection.titleJP,
            style: const TextStyle(color: Colors.white38, fontSize: 14)),
      ],
    );
  }
}

// ── Benefits ──────────────────────────────────────────────────────────────────
class _BenefitsList extends StatelessWidget {
  static const _items = [
    ('🦢', 'Toàn bộ mẫu gấp trong bộ sưu tập'),
    ('📖', 'Từ vựng tiếng Nhật theo từng bước'),
    ('⭐', 'Huy hiệu độc quyền khi hoàn thành'),
    ('♾️', 'Truy cập vĩnh viễn, không gia hạn'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.$2,
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Price row ─────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final int price;
  const _PriceRow({required this.price});

  String _formatPrice(int p) {
    if (p == 0) return 'Miễn phí';
    return '${(p / 1000).toStringAsFixed(0)}.000 đ';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Giá mở khoá',
            style: TextStyle(color: Colors.white54, fontSize: 15)),
        Text(
          _formatPrice(price),
          style: const TextStyle(
              color: AppTheme.amber, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ── Confirm Button ────────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final int price;
  final bool isLoading;
  final VoidCallback? onPressed;
  const _ConfirmButton(
      {required this.price, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                price == 0 ? 'Nhận miễn phí' : 'Xác nhận mua (Demo)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.teal, width: 2),
            ),
            child: const Icon(Icons.check_rounded, color: AppTheme.teal, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Mở khoá thành công! 🎉',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Bắt đầu gấp ngay thôi nào',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }
}
