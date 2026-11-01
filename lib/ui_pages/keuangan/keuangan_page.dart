import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ternak_pro/cubit/year_cubit.dart';
import 'package:ternak_pro/shared/custom_loading.dart';
import 'package:ternak_pro/shared/widgets/keuangan/keuangan_riwayat_section.dart';

import '../../cubit/month_cubit.dart';
import '../../services/api_service.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/keuangan/income_expense_donut_card.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  final ApiService _apiService = ApiService(); // Initialize your ApiService
  int _refreshVersion = 0;
  final Map<String, Future<Map<String, int>>> _totalsFutures = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Method untuk memuat ulang data setelah menerima true
  void _refreshPage() {
    final month = context.read<MonthCubit>().state.selectedMonth;
    final year = context.read<YearCubit>().state.selectedYear;
    _totalsFutures.remove('$month-$year');
    setState(() {
      _refreshVersion++;
    });
    loadUserData();
  }

  Future<Map<String, int>> _getTotalsFuture(int month, int year) {
    final key = '$month-$year';
    return _totalsFutures.putIfAbsent(
      key,
      () => _fetchKeuanganData(_apiService, month, year),
    );
  }

  String dataUser = '';
  Future<void> loadUserData() async {
    final credential = await _apiService.loadCredentials(); // Await the Future
    setState(() {
      dataUser = credential['name'] ?? ''; // Safe access with default value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // konten scroll
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context, dataUser),
                _buildKeuanganContent(
                  context,
                  _refreshPage,
                  _refreshVersion,
                  _getTotalsFuture,
                ),
                const SizedBox(height: 150), // ruang untuk bottom nav
              ],
            ),
          ),

          // tombol melayang
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20),
              child: _FloatingAddButton(
                onTap: () async {
                  // Tunggu hasil dari halaman tambah data
                  final result = await Navigator.pushNamed(
                    context,
                    '/tambah-data-keuangan',
                  );

                  // Jika hasilnya true, lakukan refresh halaman
                  if (result == true) {
                    _refreshPage();
                  }
                },
              ),
            ),
          ),

          // tombol melayang - back button
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20),
              child: _FloatingBackButton(
                onTap: () async {
                  // Tunggu hasil dari halaman tambah data
                  final result = await Navigator.pushNamed(context, '/main');

                  // Jika hasilnya true, lakukan refresh halaman
                  if (result == true) {
                    _refreshPage();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ukuran responsif biar mirip tombol AI kamu
    final double size = (MediaQuery.of(context).size.width * 0.18).clamp(
      56.0,
      68.0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/keuangan_assets/icons/ic_add.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ukuran responsif biar mirip tombol AI kamu
    final double size = (MediaQuery.of(context).size.width * 0.18).clamp(
      56.0,
      68.0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size * 1.5,
        height: size * 0.8,
        decoration: BoxDecoration(
          gradient: AppColors.gradasi01,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "Kembali",
            style: AppTextStyle.semiBold.copyWith(
              color: AppColors.primaryWhite,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildHeaderSection(BuildContext context, String name) {
  double screenHeight = MediaQuery.of(
    context,
  ).size.height; // Mendapatkan tinggi layar
  double headerHeight = screenHeight * 0.29;
  double imageHeight = headerHeight;

  return Container(
    height: headerHeight,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: AppColors.gradasi01,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    child: Stack(
      children: [
        // Gambar latar belakang bintang (jika dibutuhkan)
        CustomImageView(
          imagePath: "assets/home_assets/images/img_star.png",
          height: imageHeight,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Image.asset(
            'assets/keuangan_assets/images/header_main.png',
            height: 170,
          ),
        ),

        // Konten Utama
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.rotate(
                angle: -0.0227, // 1.3 derajat dalam radian
                child: Text(
                  'Halo, $name',
                  style: AppTextStyle.semiBold.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Transform.rotate(
                angle: -0.0227, // 1.3 derajat dalam radian
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Text(
                    'Cara Sederhana Mengelola',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Transform.rotate(
                angle: -0.0227, // 1.3 derajat
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Text(
                    'Keuangan Peternakanmu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildKeuanganContent(
  BuildContext context,
  VoidCallback onChanged,
  int refreshVersion,
  Future<Map<String, int>> Function(int month, int year) getTotalsFuture,
) {
  return Container(
    margin: const EdgeInsets.only(top: 20, left: 24, right: 24),
    transform: Matrix4.translationValues(0, 0, 0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Keuanganmu',
            style: AppTextStyle.semiBold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Menggunakan BlocBuilder untuk mendengarkan perubahan bulan
          BlocBuilder<MonthCubit, MonthState>(
            builder: (context, monthState) {
              return BlocBuilder<YearCubit, YearState>(
                builder: (context, yearState) {
                  // Menggunakan bulan dari MonthCubit dan tahun dari YearCubit
                  return FutureBuilder<Map<String, int>>(
                    future: getTotalsFuture(
                      monthState.selectedMonth,
                      yearState.selectedYear,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: TernakProBoxLoading());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            _shortKeuanganError(snapshot.error),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text('Tidak ada data keuangan'),
                        );
                      }

                      final totalPendapatan = snapshot.data!['pendapatan'] ?? 0;
                      final totalPengeluaran =
                          snapshot.data!['pengeluaran'] ?? 0;

                      return IncomeExpenseDonutCard(
                        totalPendapatan: totalPendapatan,
                        totalPengeluaran: totalPengeluaran,
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          KeuanganRiwayatSection(
            key: ValueKey('keuangan_riwayat_$refreshVersion'),
            onChanged: onChanged,
          ),
        ],
      ),
    ),
  );
}

// Fungsi untuk mengambil data pendapatan dan pengeluaran
Future<Map<String, int>> _fetchKeuanganData(
  ApiService apiService,
  int selectedMonth,
  int selectedYear,
) async {
  try {
    // Ambil userId dari kredensial
    final credential = await apiService.loadCredentials();
    final userId = credential['user_id'];

    // Panggil API untuk pendapatan dan pengeluaran
    final totalPendapatan = await apiService.getTotalKeuangan(
      'pendapatan',
      selectedMonth,
      selectedYear,
      userId,
    );
    final totalPengeluaran = await apiService.getTotalKeuangan(
      'pengeluaran',
      selectedMonth,
      selectedYear,
      userId,
    );

    return {'pendapatan': totalPendapatan, 'pengeluaran': totalPengeluaran};
  } catch (e) {
    throw Exception('Gagal mengambil data keuangan: $e');
  }
}

String _shortKeuanganError(Object? error) {
  final message = error?.toString().replaceFirst('Exception: ', '').trim();
  if (message == null || message.isEmpty) {
    return 'Gagal mengambil data keuangan';
  }
  return message.length > 180 ? '${message.substring(0, 177)}...' : message;
}
