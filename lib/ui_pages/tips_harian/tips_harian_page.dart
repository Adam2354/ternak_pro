import 'package:flutter/material.dart';
import 'package:ternak_pro/shared/custom_loading.dart';
import 'package:ternak_pro/shared/theme.dart';
import '../../models/TipsItem.dart';
import '../../shared/widgets/tips_harian/custom_app_bar.dart';
import '../../shared/widgets/custom_image_view.dart';
import 'package:ternak_pro/services/api_service.dart'; // Sesuaikan path ke ApiService

class TipsHarianPage extends StatefulWidget {
  const TipsHarianPage({super.key});

  @override
  State<TipsHarianPage> createState() => _TipsHarianPageState();
}

class _TipsHarianPageState extends State<TipsHarianPage> {
  final ApiService _apiService = ApiService();
  late Future<List<TipsItem>> _tipsFuture;
  late Future<List<Map<String, dynamic>>> _kategoriFuture;
  String selectedKategoriId = '1';

  @override
  void initState() {
    super.initState();
    _tipsFuture = _apiService.getTipsItem();
    _kategoriFuture = _apiService.getTipsKategoris();
  }

  List<TipsItem> _filterTips(List<TipsItem> tips) {
    if (selectedKategoriId == '1') return tips;
    return tips
        .where((tip) => tip.kategori.contains(int.parse(selectedKategoriId)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: CustomAppBar('Tips Harian'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- KATEGORI (horizontal) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _kategoriFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: TernakProBoxLoading());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data kategori'));
                }

                final kategoriList = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kategoriList.map((k) {
                      final id = k['kategori_id'].toString();
                      final name = k['kategori_name'] as String;
                      return GestureDetector(
                        onTap: () => setState(() => selectedKategoriId = id),
                        child: TipsKategoriItem(
                          isActive: selectedKategoriId == id,
                          title: name,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // --- LIST ITEM TIPS ---
          Expanded(
            child: FutureBuilder<List<TipsItem>>(
              future: _tipsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: TernakProBoxLoading());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data tips'));
                }

                final filteredTips = _filterTips(snapshot.data!);
                return ListView.builder(
                  itemCount: filteredTips.length,
                  itemBuilder: (context, index) {
                    final item = filteredTips[index];
                    return TipsOnlyItem(
                      imageUrl: item.imageUrl,
                      kategori: item.kategoriDetail,
                      title: item.judul,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/tips-harian-detail',
                          arguments: item,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TipsOnlyItem extends StatelessWidget {
  final String imageUrl;
  final String kategori;
  final String title;
  final VoidCallback? onTap;

  const TipsOnlyItem({
    super.key,
    required this.imageUrl,
    required this.kategori,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 24, top: 13, bottom: 30),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.black10,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageView(
                  imagePath: imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeHolder: 'assets/home_assets/images/img_not_found.png',
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue0120,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      kategori,
                      style: AppTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: AppColors.blue01,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    title,
                    style: AppTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: AppColors.black04,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class TipsKategoriItem extends StatelessWidget {
  final bool isActive;
  final String title;

  const TipsKategoriItem({
    super.key,
    required this.isActive,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.green01),
        color: isActive ? AppColors.green01 : AppColors.bgLight,
      ),
      child: Text(
        title,
        style: AppTextStyle.regular.copyWith(
          fontSize: 12,
          color: isActive ? AppColors.bgLight : AppColors.green01,
        ),
      ),
    );
  }
}
