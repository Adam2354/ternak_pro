import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ternak_pro/services/api_service.dart';
import 'package:ternak_pro/shared/custom_loading.dart';
import 'package:ternak_pro/shared/theme.dart';

import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/stats_ternak_item.dart';

class DataTernakPage extends StatefulWidget {
  const DataTernakPage({super.key});

  @override
  State<DataTernakPage> createState() => _DataTernakPageState();
}

bool _isLoading = true;

class _DataTernakPageState extends State<DataTernakPage> {
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  final ApiService _apiService = ApiService(); // Initialize your ApiService

  String dataUser = '';
  String formattedDate = '';
  int jmlTernak = 0;
  int jmlSakit = 0;
  int jmlHamil = 0;
  int jmlMeninggal = 0;
  int jmlSiapJual = 0;
  double rataUsia = 0;
  Future<void> loadUserData() async {
    final credential = await _apiService.loadCredentials(); // Await the Future
    final ternak = await _apiService.getTernakUserAll(credential['user_id']);
    final now = DateTime.now();
    final activeTernak = ternak.where((item) {
      return item.kondisiTernak.toLowerCase() != 'meninggal';
    }).toList();
    final usiaTotal = activeTernak.fold<int>(
      0,
      (total, item) => total + item.usia,
    );

    // Format tanggal ke "Nama Hari, DD Bulan YYYY"
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    setState(() {
      dataUser = credential['name'] ?? ''; // Safe access with default value
      jmlTernak = activeTernak.length;
      jmlSakit = ternak
          .where((item) => item.kondisiTernak.toLowerCase() == 'sakit')
          .length;
      jmlHamil = ternak
          .where((item) => item.kondisiTernak.toLowerCase() == 'hamil')
          .length;
      jmlMeninggal = ternak
          .where((item) => item.kondisiTernak.toLowerCase() == 'meninggal')
          .length;
      jmlSiapJual = ternak
          .where((item) => item.kondisiTernak.toLowerCase() == 'siap jual')
          .length;
      rataUsia = activeTernak.isEmpty ? 0 : usiaTotal / activeTernak.length;
      formattedDate = dateFormat.format(now);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context),
            _buildStatsCard(
              context,
              dataUser,
              jmlTernak,
              formattedDate,
              jmlSakit,
              jmlHamil,
              jmlMeninggal,
              rataUsia,
              jmlSiapJual,
            ),
            _buildTernakServices(context),
            SizedBox(height: 110), // Spacing at the bottom
          ],
        ),
      ),
    );
  }
}

Widget _buildHeaderSection(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.12,
    width: double.infinity,
    decoration: BoxDecoration(gradient: AppColors.gradasi01),
    child: Stack(
      children: [
        CustomImageView(
          imagePath: "assets/home_assets/images/img_star.png",
          height: MediaQuery.of(context).size.height * 0.12,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 60,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Ternak Hari Ini',
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 20,
                      color: AppColors.white100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatsCard(
  BuildContext context,
  String dataUser,
  int jmlTernak,
  String tglHariIni,
  int jmlSakit,
  int jmlHamil,
  int jmlMeninggal,
  double rataUsia,
  int jmlSiapJual,
) {
  final fiturList = [
    StatsTernakItem(
      title: "Jumlah\nTernak",
      keterangan: jmlTernak.toString(),
      imagePath: "assets/data_ternak_assets/illustrations/cow_jumlah.png",
    ),
    // StatsTernakItem(
    //   title: "Pakan\nHarian",
    //   keterangan: "Sudah",
    //   imagePath: "assets/data_ternak_assets/illustrations/cow_pakan.png",
    // ),
    StatsTernakItem(
      title: "Ternak\nSakit",
      keterangan: jmlSakit.toString(),
      imagePath: "assets/data_ternak_assets/illustrations/cow_sakit.png",
    ),
    StatsTernakItem(
      title: "Ternak\nHamil",
      keterangan: jmlHamil.toString(),
      imagePath: "assets/data_ternak_assets/illustrations/cow_hamil.png",
    ),
    StatsTernakItem(
      title: "Ternak\nMeninggal",
      keterangan: jmlMeninggal.toString(),
      imagePath: "assets/data_ternak_assets/illustrations/cow_meninggal.png",
    ),
    // StatsTernakItem(
    //   title: "Penyimpanan\nPakan",
    //   keterangan: "10 Kg",
    //   imagePath: "assets/data_ternak_assets/illustrations/cow_penyimpanan.png",
    // ),
    StatsTernakItem(
      title: "Rata-rata\nUsia",
      keterangan: "${rataUsia.toStringAsFixed(1)} Thn",
      imagePath: "assets/data_ternak_assets/illustrations/cow_usia.png",
    ),
    StatsTernakItem(
      title: "Ternak Siap\nJual",
      keterangan: jmlSiapJual.toString(),
      imagePath: "assets/data_ternak_assets/illustrations/cow_panen.png",
    ),
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      // Hitung berapa item per baris berdasarkan lebar kontainer
      double maxWidth = constraints.maxWidth;
      double itemWidth = 90; // lebar ideal item
      int itemsPerRow = (maxWidth / itemWidth).floor().clamp(
        1,
        4,
      ); // maksimal 4 item

      double spacing = 8;

      return Container(
        margin: EdgeInsets.only(top: 25, left: 24, right: 24),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: AppColors.gradasi01WithOpacity20,
          border: Border.all(color: AppColors.grey20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isLoading
            ? const Center(child: TernakProBoxLoading())
            : Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Peternakan $dataUser",
                            style: AppTextStyle.extraBold.copyWith(
                              fontSize: 12,
                              color: AppColors.blackText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Image.asset(
                                'assets/data_ternak_assets/icons/ic_calendar.png',
                                height: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tanggal: $tglHariIni',
                                style: AppTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: AppColors.blackText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/data_ternak_assets/icons/ic_more.png',
                        height: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Divider(color: AppColors.grey20, thickness: 1),

                  // Grid-like Items
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: fiturList.map((item) {
                      return SizedBox(
                        width:
                            (maxWidth - ((itemsPerRow - 1) * spacing)) /
                            itemsPerRow,
                        child: item,
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 4),
                  Divider(color: AppColors.grey20, thickness: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dibesarkan Untuk : Sapi Perah",
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 12,
                          color: AppColors.blackText,
                        ),
                      ),
                      Text(
                        "Jumlah Awal : 5",
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 12,
                          color: AppColors.blackText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    },
  );
}

Widget _buildTernakServices(BuildContext context) {
  final fiturItems = [
    {
      "imagePath": 'assets/data_ternak_assets/icons/ic_add_data_ternak.png',
      "title": 'Tambah Data Ternak',
      "gradient": AppColors.gradasiFitur1,
      "onClick": () {
        Navigator.pushNamed(context, '/tambah-data-ternak');
      },
    },
    {
      "imagePath": 'assets/data_ternak_assets/icons/ic_update_data_ternak.png',
      "title": 'Update Data Ternak',
      "gradient": AppColors.gradasiFitur2,
      "onClick": () {
        Navigator.pushNamed(context, '/list-data-ternak-tugas');
      },
    },
    {
      "imagePath": 'assets/data_ternak_assets/icons/ic_add_tugas.png',
      "title": 'Tambah Tugas & Jadwal Pengingat',
      "gradient": AppColors.gradasi02,
      "onClick": () {
        Navigator.pushNamed(context, '/tambah-data-tugas');
      },
    },
    {
      "imagePath": 'assets/data_ternak_assets/icons/ic_kelola_keuangan.png',
      "title": 'Kelola Keuangan',
      "gradient": AppColors.gradasiFitur4,
      "onClick": () {
        // pastikan berada di tab Konsultasi
        // context.read<PageCubit>().setPage(2);
        // // tampilkan KeuanganPage di dalam tab Konsultasi
        // context.read<KonsultasiPageCubit>().setKonsultasiPage(1);

        // (opsional) lakukan hal lain yang diperlukan, contoh:
        // context.read<KeuanganCubit>().initData();  // preload data
        Navigator.pushNamed(context, '/keuangan');
      },
    },
  ];

  return Container(
    margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
    transform: Matrix4.translationValues(0, 0, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur Data Ternak',
          style: AppTextStyle.semiBold.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            const spacing = 16.0;
            final itemWidth = (maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: fiturItems.map((item) {
                return SizedBox(
                  width: itemWidth,
                  height: 140, // ✅ samakan tingginya di sini juga
                  child: FiturTernakItem(
                    imagePath: item["imagePath"] as String,
                    title: item["title"] as String,
                    gradient: item["gradient"] as Gradient,
                    onClick: item["onClick"] as VoidCallback,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}

class FiturTernakItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final Gradient gradient;
  final VoidCallback onClick;

  const FiturTernakItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.gradient,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: 140, // ✅ Atur tinggi tetap
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey20,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // ✅ Tengah vertikal
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomImageView(
                imagePath: imagePath,
                height: 37,
                placeHolder: 'assets/home_assets/images/img_not_found.png',
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyle.semiBold.copyWith(
                    fontSize: 14,
                    color: AppColors.primaryWhite,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // agar tidak meluber
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
