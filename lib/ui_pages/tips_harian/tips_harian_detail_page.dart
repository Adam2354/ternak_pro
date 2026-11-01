import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ternak_pro/shared/custom_loading.dart';
import 'package:ternak_pro/shared/theme.dart';
import '../../models/TipsItem.dart';
import '../../shared/widgets/tips_harian/custom_app_bar.dart';
import '../../shared/widgets/custom_image_view.dart';

class TipsHarianDetailPage extends StatefulWidget {
  const TipsHarianDetailPage({super.key});

  @override
  State<TipsHarianDetailPage> createState() => _TipsHarianDetailPageState();
}

class _TipsHarianDetailPageState extends State<TipsHarianDetailPage> {
  bool isLoading = true;
  TipsItem? detailData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is TipsItem) {
        setState(() {
          detailData = args;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: TernakProBoxLoading()));
    }

    if (detailData == null) {
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: CustomAppBar(detailData!.kategoriDetail),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detailData!.judul,
              style: AppTextStyle.semiBold.copyWith(
                fontSize: 20,
                color: AppColors.black03,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.green01),
                      ),
                      child: Text(
                        detailData!.kategoriDetail,
                        style: AppTextStyle.regular.copyWith(
                          fontSize: 12,
                          color: AppColors.green01,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      detailData!.createdAt != null
                          ? '${detailData!.createdAt!.day} ${_getMonthName(detailData!.createdAt!.month)} ${detailData!.createdAt!.year}'
                          : 'Tanggal tidak tersedia',
                      style: AppTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: AppColors.black04,
                      ),
                    ),
                  ],
                ),
                Text(
                  detailData!.author ?? 'Anonim',
                  style: AppTextStyle.regular.copyWith(
                    fontSize: 12,
                    color: AppColors.black01,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                normalizeAssetUrl(detailData!.imageUrl),
                width: double.infinity,
                height: 215,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/placeholder_image.png',
                    width: double.infinity,
                    height: 215,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Html(
              data: detailData!.konten,
              style: {
                "p": Style(
                  color: AppColors.black04,
                  fontSize: FontSize(14),
                  lineHeight: LineHeight.number(1.5),
                  margin: Margins.only(bottom: 12),
                ),
                "h3": Style(
                  color: AppColors.black03,
                  fontWeight: FontWeight.w700,
                  fontSize: FontSize(18),
                  margin: Margins.only(top: 12, bottom: 8),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mendapatkan nama bulan dalam bahasa Indonesia
  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
