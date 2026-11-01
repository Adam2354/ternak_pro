import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ternak_pro/shared/custom_loading.dart';
import '../../../cubit/month_cubit.dart';
import '../../../cubit/year_cubit.dart';
import '../../../models/KeuanganItem.dart';
import '../../../services/api_service.dart';
import '../../theme.dart'; // Sesuaikan path ke model KeuanganItem

// ---------- MODEL ----------
enum TxType { income, expense }

class FinanceRecord {
  final int id;
  final DateTime date;
  final String title;
  final String subtitle;
  final int amount; // rupiah (positif)
  final TxType type;

  const FinanceRecord({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });

  // Konversi dari KeuanganItem ke FinanceRecord
  factory FinanceRecord.fromKeuanganItem(KeuanganItem item) {
    return FinanceRecord(
      id: item.idKeuangan,
      date: item.tglKeuangan,
      title: item.dariTujuan.isNotEmpty ? item.dariTujuan : 'Transaksi',
      subtitle: item.namaAset.isNotEmpty
          ? item.namaAset
          : (item.catatan.isNotEmpty ? item.catatan : 'Tanpa catatan'),
      amount: item.nominalTotal,
      type: item.isPengeluaran ? TxType.expense : TxType.income,
    );
  }
}

// ---------- WIDGET SECTION ----------
class KeuanganRiwayatSection extends StatefulWidget {
  final VoidCallback? onChanged;

  const KeuanganRiwayatSection({super.key, this.onChanged});

  @override
  State<KeuanganRiwayatSection> createState() => _KeuanganRiwayatSectionState();
}

class _KeuanganRiwayatSectionState extends State<KeuanganRiwayatSection> {
  final ApiService _apiService = ApiService();
  late int _selectedMonth;
  late int _selectedYear;
  late Future<List<FinanceRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    _recordsFuture = _fetchKeuanganData();
  }

  String _formatMonthYear(int m, int y) {
    final date = DateTime(y, m, 1);
    return DateFormat('MMM yyyy', 'id_ID').format(date);
  }

  Future<void> _pickMonthYear() async {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pilih Bulan'),
          content: Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: tempMonth,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            DateFormat(
                              'MMM',
                              'id_ID',
                            ).format(DateTime(2000, m, 1)),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => tempMonth = val);
                    (ctx as Element).markNeedsBuild();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: tempYear,
                  items: List.generate(11, (i) => (_selectedYear - 5) + i)
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => tempYear = val);
                    (ctx as Element).markNeedsBuild();
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            // Membungkus hanya FilledButton dengan MultiBlocProvider
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => MonthCubit(),
                ), // Membuat instance MonthCubit hanya untuk FilledButton
                BlocProvider(
                  create: (_) => YearCubit(),
                ), // Membuat instance YearCubit hanya untuk FilledButton
              ],
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = tempMonth;
                    _selectedYear = tempYear;
                    context.read<MonthCubit>().changeMonth(tempMonth);
                    context.read<YearCubit>().changeYear(tempYear);
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Pilih'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<FinanceRecord>> _fetchKeuanganData() async {
    final credential = await _apiService.loadCredentials();
    final userId = credential['user_id'];
    final keuanganItems = await _apiService.getDataKeuanganUser(userId);
    return keuanganItems
        .map((item) => FinanceRecord.fromKeuanganItem(item))
        .toList();
  }

  List<FinanceRecord> _filtered(List<FinanceRecord> items) {
    return items
        .where(
          (e) => e.date.month == _selectedMonth && e.date.year == _selectedYear,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<bool> _confirmDeleteKeuangan(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus riwayat'),
        content: const Text('Anda yakin ingin menghapus data keuangan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await _apiService.deleteKeuangan(id);
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      return false;
    }
  }

  String _fmtDate(DateTime d) => DateFormat('dd MMM yyyy', 'id_ID').format(d);

  String _fmtRupiah(int v, {bool withSign = true, required TxType type}) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final s = f.format(v);
    if (!withSign) return s;
    return type == TxType.income ? '+$s' : '-$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            Text(
              'Riwayat',
              style: AppTextStyle.semiBold.copyWith(fontSize: 16),
            ),
            const Spacer(),
            InkWell(
              onTap: _pickMonthYear,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMonthYear(_selectedMonth, _selectedYear),
                    style: AppTextStyle.semiBold.copyWith(
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
                ],
              ),
            ),
          ],
        ),
        // LIST
        FutureBuilder<List<FinanceRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: TernakProBoxLoading()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      style: AppTextStyle.regular.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _recordsFuture = _fetchKeuanganData();
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Tidak ada catatan untuk bulan ini.',
                  style: AppTextStyle.regular.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              );
            }

            final items = _filtered(snapshot.data!);

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.divider, height: 16),
              itemBuilder: (context, i) {
                final it = items[i];
                final isIncome = it.type == TxType.income;
                final color = isIncome ? AppColors.blue : AppColors.red;
                final chipBg = isIncome
                    ? AppColors.chipBgBlue
                    : AppColors.chipBgRed;

                return Dismissible(
                  key: Key('keuangan_${it.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDeleteKeuangan(it.id),
                  onDismissed: (_) {
                    setState(() {});
                    widget.onChanged?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Riwayat dihapus')),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: chipBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            it.type == TxType.income
                                ? 'assets/keuangan_assets/icons/ic_wallet.png'
                                : 'assets/keuangan_assets/icons/ic_cart.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.title,
                              style: AppTextStyle.semiBold.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              it.subtitle,
                              style: AppTextStyle.regular.copyWith(
                                color: AppColors.greyText,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _fmtDate(it.date),
                            style: AppTextStyle.regular.copyWith(
                              color: AppColors.greyText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _fmtRupiah(it.amount, type: it.type),
                            style: AppTextStyle.semiBold.copyWith(
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.divider, height: 16),
      ],
    );
  }
}
