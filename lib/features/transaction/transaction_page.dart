import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/transaction_model.dart';
import 'widgets/transaction_card.dart';
import 'widgets/transaction_filter_bar.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with AutomaticKeepAliveClientMixin {
  static const _gold = Color(0xFFFFC107);
  static const _bg = Color(0xFF000000);

  TransactionStatus _activeStatus = TransactionStatus.pending;

  // Salinan mutable dari dummy data
  final List<TransactionModel> _transactions = List.from(dummyTransactions);

  @override
  bool get wantKeepAlive => true;

  // ── Filter ───────────────────────────────────────────────────────────────────
  List<TransactionModel> get _filtered =>
      _transactions.where((t) => t.status == _activeStatus).toList();

  int _countOf(TransactionStatus s) =>
      _transactions.where((t) => t.status == s).length;

  // ── Terima booking ───────────────────────────────────────────────────────────
  void _onAccept(String id) {
    HapticFeedback.mediumImpact();
    _showConfirmDialog(
      context,
      title: 'Terima Booking?',
      message: 'Booking ini akan dikonfirmasi dan customer akan mendapat notifikasi.',
      confirmLabel: 'Terima',
      confirmColor: _gold,
      confirmTextColor: Colors.black,
      onConfirm: () {
        setState(() {
          final idx = _transactions.indexWhere((t) => t.id == id);
          if (idx != -1) {
            _transactions[idx] = TransactionModel(
              id: _transactions[idx].id,
              customerName: _transactions[idx].customerName,
              serviceName: _transactions[idx].serviceName,
              phoneNumber: _transactions[idx].phoneNumber,
              scheduleTime: _transactions[idx].scheduleTime,
              status: TransactionStatus.diterima,
              hasConflict: _transactions[idx].hasConflict,
            );
          }
        });
      },
    );
  }

  // ── Tolak booking ─────────────────────────────────────────────────────────────
  void _onReject(String id) {
    HapticFeedback.mediumImpact();
    _showConfirmDialog(
      context,
      title: 'Tolak Booking?',
      message: 'Booking ini akan ditolak dan customer akan mendapat notifikasi.',
      confirmLabel: 'Tolak',
      confirmColor: const Color(0xFFFF453A),
      confirmTextColor: Colors.white,
      onConfirm: () {
        setState(() {
          final idx = _transactions.indexWhere((t) => t.id == id);
          if (idx != -1) {
            _transactions[idx] = TransactionModel(
              id: _transactions[idx].id,
              customerName: _transactions[idx].customerName,
              serviceName: _transactions[idx].serviceName,
              phoneNumber: _transactions[idx].phoneNumber,
              scheduleTime: _transactions[idx].scheduleTime,
              status: TransactionStatus.ditolak,
              hasConflict: _transactions[idx].hasConflict,
            );
          }
        });
      },
    );
  }

  // ── Dialog konfirmasi ─────────────────────────────────────────────────────────
  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Color confirmTextColor,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: confirmColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          color: confirmTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtered = _filtered;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _TransactionHeader(),
          ),

          const SizedBox(height: 20),

          // ── Filter pills ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TransactionFilterBar(
              activeStatus: _activeStatus,
              onChanged: (s) => setState(() => _activeStatus = s),
            ),
          ),

          const SizedBox(height: 20),

          // ── List transaksi ────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(status: _activeStatus)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final trx = filtered[index];
                      return TransactionCard(
                        key: ValueKey(trx.id),
                        transaction: trx,
                        onAccept: trx.status == TransactionStatus.pending
                            ? () => _onAccept(trx.id)
                            : null,
                        onReject: trx.status == TransactionStatus.pending
                            ? () => _onReject(trx.id)
                            : null,
                        onChat: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Header widget ─────────────────────────────────────────────────────────────
class _TransactionHeader extends StatelessWidget {
  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar BC
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold,
            border: Border.all(color: _gold.withOpacity(0.4), width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'BC',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Judul + subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaksi',
                style: TextStyle(
                  color: _gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kelola booking customer',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Ikon search
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1C1C1E),
            border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8E8E93),
            size: 20,
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final TransactionStatus status;
  const _EmptyState({required this.status});

  String get _label {
    switch (status) {
      case TransactionStatus.pending:
        return 'Tidak ada booking pending';
      case TransactionStatus.diterima:
        return 'Belum ada booking diterima';
      case TransactionStatus.ditolak:
        return 'Belum ada booking ditolak';
    }
  }

  IconData get _icon {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.hourglass_empty_rounded;
      case TransactionStatus.diterima:
        return Icons.check_circle_outline_rounded;
      case TransactionStatus.ditolak:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: const Color(0xFF3A3A3C), size: 56),
          const SizedBox(height: 14),
          Text(
            _label,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
