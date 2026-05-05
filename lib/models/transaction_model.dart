enum TransactionStatus { pending, diterima, ditolak }

class TransactionModel {
  final String id;
  final String customerName;
  final String serviceName;
  final String phoneNumber;
  final String scheduleTime;
  final TransactionStatus status;
  final bool hasConflict;

  const TransactionModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.phoneNumber,
    required this.scheduleTime,
    required this.status,
    this.hasConflict = false,
  });

  String get initials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.substring(0, 2).toUpperCase();
  }
}

// ── Dummy data ────────────────────────────────────────────────────────────────
final List<TransactionModel> dummyTransactions = [
  const TransactionModel(
    id: 'TRX-001',
    customerName: 'Budi Santoso',
    serviceName: 'Classic Fade + Beard Trim',
    phoneNumber: '0812-3456-7890',
    scheduleTime: 'Hari ini, 14:00',
    status: TransactionStatus.pending,
  ),
  const TransactionModel(
    id: 'TRX-002',
    customerName: 'Adit Pratama',
    serviceName: 'Premium Hair Sculpting',
    phoneNumber: '0812-9876-5432',
    scheduleTime: 'Hari ini, 15:30',
    status: TransactionStatus.pending,
    hasConflict: true,
  ),
  const TransactionModel(
    id: 'TRX-003',
    customerName: 'Raka Wijaya',
    serviceName: 'Hot Towel Shave',
    phoneNumber: '0813-1122-3344',
    scheduleTime: 'Kemarin, 10:00',
    status: TransactionStatus.diterima,
  ),
  const TransactionModel(
    id: 'TRX-004',
    customerName: 'Dimas Prayoga',
    serviceName: 'Reguler Haircut',
    phoneNumber: '0857-4455-6677',
    scheduleTime: 'Kemarin, 13:00',
    status: TransactionStatus.diterima,
  ),
  const TransactionModel(
    id: 'TRX-005',
    customerName: 'Farhan Nugroho',
    serviceName: 'Skin Fade + Wax',
    phoneNumber: '0821-9988-7766',
    scheduleTime: '23 Okt, 11:00',
    status: TransactionStatus.ditolak,
  ),
  const TransactionModel(
    id: 'TRX-006',
    customerName: 'Rio Ananda',
    serviceName: 'Classic Fade',
    phoneNumber: '0896-3344-5566',
    scheduleTime: '22 Okt, 09:00',
    status: TransactionStatus.ditolak,
  ),
];
