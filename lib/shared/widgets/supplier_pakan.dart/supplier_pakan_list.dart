import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Tambahkan import ini
import 'package:ternak_pro/shared/widgets/custom_button.dart';
import 'package:ternak_pro/shared/widgets/onboarding_buttom.dart';
import 'package:ternak_pro/shared/widgets/supplier_pakan.dart/hubungi_button.dart';

import '../../../services/api_service.dart';
import '../../../ui_pages/supplier_pakan/supplier_limbah_pakan_detail_page.dart';
import '../../theme.dart';
import '../custom_image_view.dart';

class SupplierPakanItem extends StatelessWidget {
  final String lokasi;
  final String imageUrl;
  final String name;
  final String noTelepon;
  final int harga;
  final bool isStok;
  final VoidCallback? onTap;

  const SupplierPakanItem({
    super.key,
    required this.lokasi,
    required this.imageUrl,
    required this.noTelepon,
    required this.name,
    required this.harga,
    required this.isStok,
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
      child: AspectRatio(
        aspectRatio: 0.65, // Sesuaikan dengan childAspectRatio di GridView
        child: Card(
          color: AppColors.bgLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: AppColors.grey20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.12,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CustomImageView(
                    imagePath: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeHolder: 'assets/home_assets/images/img_not_found.png',
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    child: SizedBox(
                      height: 32, // kira-kira tinggi 2 baris teks
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          name,
                          style: AppTextStyle.semiBold.copyWith(fontSize: 12),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'RP ${formatRupiah(harga)}', // gunakan formatRupiah
                      textAlign: TextAlign.left,
                      style: AppTextStyle.semiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.blue01,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Stok: ',
                            style: AppTextStyle.medium.copyWith(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: isStok ? "Tersedia" : "Habis",
                            style: AppTextStyle.medium.copyWith(
                              color: isStok ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/harga_pasar_assets/icons/ic_location.png',
                          width: 16.0,
                          height: 16.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(lokasi),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 15.0,
                        left: 8.0,
                        right: 8.0,
                      ),

                      child: FractionallySizedBox(
                        alignment: Alignment.center,
                        child: HubungiButton(text: 'Hubungi Penjual'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplierPakanList extends StatefulWidget {
  final String searchQuery;

  const SupplierPakanList({super.key, this.searchQuery = ''});

  @override
  _SupplierPakanListState createState() => _SupplierPakanListState();
}

class _SupplierPakanListState extends State<SupplierPakanList> {
  late Future<List<Map<String, dynamic>>> supplierPakanFuture;

  @override
  void initState() {
    super.initState();
    supplierPakanFuture = _fetchSupplierPakanData();
  }

  // Fetch data from the API
  Future<List<Map<String, dynamic>>> _fetchSupplierPakanData() async {
    try {
      List<Map<String, dynamic>> items = await ApiService()
          .getAllSuplierPakan();
      return items;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supplierPakanFuture, // Use the future for fetching data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          ); // Show loading spinner
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final items = snapshot.data!;

        // Filter based on search query
        final q = widget.searchQuery.trim().toLowerCase();
        final filtered = items.where((it) {
          final name = (it['judul'] as String).toLowerCase();
          final okQuery = q.isEmpty || name.contains(q);
          return okQuery;
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio:
                0.65, // Ensure this matches the AspectRatio in Card
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return SupplierPakanItem(
              lokasi: item['alamat_overview'],
              imageUrl: _firstImagePath(item['image_url']),
              noTelepon: item['no_tlp'].toString(),
              name: item['judul'],
              harga: item['harga'],
              isStok: item['is_stok'] == 1 ? true : false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SupplierLimbahPakanDetailPage.fromMap(item),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _firstImagePath(dynamic value) {
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.first.toString();
        }
      } on FormatException {
        // The API also returns semicolon-separated image paths.
      }
      final paths = value.split(';');
      return paths.first.trim();
    }
    return 'assets/home_assets/images/img_not_found.png';
  }
}
