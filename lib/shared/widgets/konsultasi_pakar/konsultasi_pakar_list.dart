import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ternak_pro/shared/theme.dart';

import '../../../models/KonsultasiPakarItem.dart' as KonsultasiPakarItemModel;

import '../../../services/api_service.dart';
import '../../../ui_pages/konsultasi_pakar/konsultasi_pakar_detail_page.dart';
import '../custom_image_view.dart';

class KonsultasiPakarItem extends StatelessWidget {
  final String imageUrl;
  final String nama;
  final String spealis; // ejaan mengikuti field map
  final String pukulMulai; // "HH:mm:ss"
  final String pukulAkhir; // "HH:mm:ss"
  final int harga;
  final int durasi; // menit / jam sesuai datamu
  final VoidCallback? onTap;

  const KonsultasiPakarItem({
    super.key,
    required this.imageUrl,
    required this.nama,
    required this.spealis,
    required this.pukulMulai,
    required this.pukulAkhir,
    required this.harga,
    required this.durasi,
    this.onTap,
  });

  String formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.blue01),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // kalau pakai CircleAvatar (harus radius = diameter / 2)
                ClipOval(
                  child: Container(
                    width: 75,
                    height: 75,
                    color: AppColors.green01,
                    child: CustomImageView(
                      imagePath: imageUrl.isEmpty
                          ? 'assets/home_assets/images/img_not_found.png'
                          : imageUrl,
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      placeHolder:
                          'assets/home_assets/images/img_not_found.png',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: AppTextStyle.semiBold.copyWith(
                        fontSize: 14,
                        color: AppColors.black100,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      spealis,
                      style: AppTextStyle.semiBold.copyWith(
                        fontSize: 14,
                        color: AppColors.blue01,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Image.asset(
                          'assets/konsultasi_pakan_assets/icons/ic_time.png',
                          width: 14,
                          height: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "$pukulMulai - $pukulAkhir"
                          ' WIB',
                          style: AppTextStyle.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.black100,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 17),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.gradasi01,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Jadwalkan Konsultasi',
                    style: AppTextStyle.medium.copyWith(
                      color: AppColors.white100,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KonsultasiPakarList extends StatefulWidget {
  final String searchQuery;

  const KonsultasiPakarList({super.key, this.searchQuery = ''});

  @override
  State<KonsultasiPakarList> createState() => _KonsultasiPakarListState();
}

class _KonsultasiPakarListState extends State<KonsultasiPakarList> {
  final ApiService _apiService = ApiService();
  List<KonsultasiPakarItemModel.KonsultasiPakarItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKonsultasiPakar();
  }

  Future<void> _fetchKonsultasiPakar() async {
    try {
      final konsultasiPakarList = await _apiService.getAllKonsultasiPakar();
      setState(() {
        items = konsultasiPakarList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            ) // Show loading indicator while fetching
          : items.isEmpty
          ? Center(child: Text("Tidak ada Konsultasi Pakar tersedia."))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return KonsultasiPakarItem(
                  imageUrl: item.imageUrl,
                  nama: item.nama,
                  spealis: item.spealis,
                  pukulMulai: item.pukulMulai.toString(),
                  pukulAkhir: item.pukulAkhir.toString(),
                  harga: item.harga,
                  durasi: item.durasi,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            KonsultasiPakarDetailPage.fromMap(item.toJson()),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
