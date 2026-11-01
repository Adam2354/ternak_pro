import 'package:flutter/material.dart';

import '../../theme.dart';
import '../custom_image_view.dart';

class KonsultasiItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onPressed;

  // Custom colors
  final Color backgroundColor;
  final Color titleColor;
  final Color bgDescColor;

  const KonsultasiItemCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFEFFFFC),
    this.titleColor = const Color(0xFF10B3A4),
    this.bgDescColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth; // Lebar layar yang tersedia
        double imageWidth =
            screenWidth *
            0.15; // Menyesuaikan lebar gambar (15% dari lebar layar)
        double paddingBetween =
            screenWidth * 0.03; // Padding antara elemen (3% dari lebar layar)
        double fontSizeTitle = (screenWidth * 0.04).clamp(
          14.0,
          18.0,
        ); // Ukuran font judul
        double fontSizeDescription = (screenWidth * 0.01).clamp(
          12.0,
          16.0,
        ); // Ukuran font deskripsi

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 100,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ikon
                  Padding(
                    padding: EdgeInsets.only(
                      left: paddingBetween,
                      right: paddingBetween,
                      top: 16,
                      bottom: 16,
                    ),
                    child: imagePath.startsWith('http')
                        ? Image.network(
                            normalizeAssetUrl(imagePath),
                            width: imageWidth,
                            fit: BoxFit.scaleDown,
                          )
                        : Image.asset(
                            imagePath,
                            width: imageWidth,
                            fit: BoxFit.scaleDown,
                          ),
                  ),

                  // Text + Button
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: bgDescColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              title,
                              style: AppTextStyle.semiBold.copyWith(
                                color: titleColor,
                                fontSize: fontSizeTitle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    description,
                                    style: AppTextStyle.regular.copyWith(
                                      color: AppColors.blackText,
                                      fontSize: fontSizeDescription,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: onPressed,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          screenWidth *
                                          0.05, // Padding horizontal dinamis
                                      vertical:
                                          screenWidth *
                                          0.02, // Padding vertikal dinamis
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.gradasi01,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Lihat",
                                      style: AppTextStyle.medium.copyWith(
                                        color: Colors.white,
                                        fontSize: (screenWidth * 0.03).clamp(
                                          10.0,
                                          12.0,
                                        ), // Ukuran font tombol
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
