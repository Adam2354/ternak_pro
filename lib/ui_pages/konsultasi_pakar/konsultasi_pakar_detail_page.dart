import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';

class KonsultasiPakarDetailPage extends StatefulWidget {
  // ===== data yang diperlukan di halaman detail =====
  final int id;
  final String imageUrl;
  final String nama;
  final List<int> kategori; // sesuai data list kamu
  final int harga;
  final int durasi;
  final String noTlp;
  final String spealis;
  final String lokasiPraktik;
  final String pukulMulai; // "HH:mm:ss"
  final String pukulAkhir; // "HH:mm:ss"
  final String pendidikan; // dipisah dengan ';'
  final String pengalaman;
  final String fokusKonsultasi;
  final String? createdAt;
  final String? updatedAt;

  const KonsultasiPakarDetailPage({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.durasi,
    required this.noTlp,
    required this.spealis,
    required this.lokasiPraktik,
    required this.pukulMulai,
    required this.pukulAkhir,
    required this.pendidikan,
    required this.pengalaman,
    required this.fokusKonsultasi,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory agar tinggal kirim Map `item` dari list
  factory KonsultasiPakarDetailPage.fromMap(Map<String, dynamic> item) {
    return KonsultasiPakarDetailPage(
      id: item['id'] is int ? item['id'] : int.parse(item['id'].toString()),
      imageUrl: item['image_url']?.toString() ?? '',
      nama: item['nama']?.toString() ?? '',
      kategori:
          (item['kategori'] as List?)
              ?.map((e) => int.parse(e.toString()))
              .toList() ??
          const [],
      harga: item['harga'] is int
          ? item['harga']
          : int.tryParse(item['harga'].toString()) ?? 0,
      durasi: item['durasi'] is int
          ? item['durasi']
          : int.tryParse(item['durasi'].toString()) ?? 0,
      noTlp: item['no_tlp']?.toString() ?? '',
      spealis: item['spealis']?.toString() ?? '',
      lokasiPraktik: item['lokasi_praktik']?.toString() ?? '',
      pukulMulai: item['pukul_mulai']?.toString() ?? '00:00:00',
      pukulAkhir: item['pukul_akhir']?.toString() ?? '00:00:00',
      pendidikan: item['pendidikan']?.toString() ?? '',
      pengalaman: item['pengalaman']?.toString() ?? '',
      fokusKonsultasi: item['fokus_konsultasi']?.toString() ?? '',
      createdAt: item['created_at']?.toString(),
      updatedAt: item['updated_at']?.toString(),
    );
  }

  @override
  State<KonsultasiPakarDetailPage> createState() =>
      _KonsultasiPakarDetailPageState();
}

class _KonsultasiPakarDetailPageState extends State<KonsultasiPakarDetailPage> {
  String formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value).replaceAll(',', '.');
  }

  String formatNomor(String value) {
    // bersihkan spasi/strip
    String raw = value.replaceAll(RegExp(r'[^0-9]'), '');

    // kalau mulai dengan 62 → ganti jadi 0
    if (raw.startsWith('62')) {
      raw = '0' + raw.substring(2);
    }

    // potong jadi blok 4-4-4
    List<String> parts = [];
    for (int i = 0; i < raw.length; i += 4) {
      int end = (i + 4 < raw.length) ? i + 4 : raw.length;
      parts.add(raw.substring(i, end));
    }

    return parts.join('-');
  }

  String toWhatsappNumber(String number) {
    // bersihkan non-digit
    String raw = number.replaceAll(RegExp(r'[^0-9]'), '');

    // kalau mulai dengan 0 → ganti ke 62
    if (raw.startsWith('0')) {
      raw = '62' + raw.substring(1);
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.4,
        ),
        child: _buildHeaderSection(context, widget.imageUrl),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nama,
                    style: AppTextStyle.semiBold.copyWith(
                      fontSize: 24,
                      color: AppColors.black100,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'RP ${formatRupiah(widget.harga)} / ${widget.durasi} menit',
                    textAlign: TextAlign.left,
                    style: AppTextStyle.semiBold.copyWith(
                      fontSize: 20,
                      color: AppColors.blue01,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset(
                        'assets/supplier_pakan_assets/icons/ic_calling.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'No. Telp: ${formatNomor(widget.noTlp ?? '08')}',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.black100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset(
                        'assets/konsultasi_pakan_assets/icons/ic_clock.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "${widget.pukulMulai} - ${widget.pukulAkhir}"
                        ' WIB',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.black100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/supplier_pakan_assets/icons/ic_location.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Lokasi Praktik',
                            style: AppTextStyle.semiBold.copyWith(
                              fontSize: 16,
                              color: AppColors.black100,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.lokasiPraktik,
                        style: AppTextStyle.medium.copyWith(
                          fontSize: 14,
                          color: AppColors.black100,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  Divider(color: AppColors.grey20, thickness: 1),
                  const SizedBox(height: 15),

                  _FilledActionButton(
                    width: double.infinity,
                    height: 50,
                    iconPath:
                        'assets/supplier_pakan_assets/icons/ic_message.png',
                    iconSize: 16,
                    label: 'Chat Whatsapp',
                    labelSize: 16,
                    color: AppColors.green01,
                    onTap: () async {
                      final phone = widget.noTlp ?? '';
                      if (phone.isEmpty) {
                        SnackBar(content: Text('Nomor telepon tidak tersedia'));
                        return;
                      }

                      final whatsappNumber = toWhatsappNumber(phone);
                      final url = Uri.parse('https://wa.me/$whatsappNumber');

                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode
                              .externalApplication, // buka app WA kalau ada
                        );
                      } else {
                        SnackBar(content: Text('Tidak bisa membuka WhatsApp'));
                      }
                    },
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Detail Dokter Spesialis',
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 16,
                      color: AppColors.black100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Pendidikan:',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.black100,
                        ),
                      ),
                      ...widget.pendidikan
                          .split(';')
                          .where((e) => e.trim().isNotEmpty)
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 6,
                                left: 16,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ",
                                    style: AppTextStyle.extraBold.copyWith(
                                      fontSize: 14,
                                      color: AppColors.black100,
                                    ), // bullet
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      point.trim(),
                                      style: AppTextStyle.medium.copyWith(
                                        fontSize: 14,
                                        color: AppColors.black100,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Pengalaman:',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.black100,
                        ),
                      ),
                      Text(
                        widget.pengalaman,
                        style: AppTextStyle.medium.copyWith(
                          fontSize: 14,
                          color: AppColors.black100,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Fokus Konsultasi:',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.black100,
                        ),
                      ),
                      Text(
                        widget.fokusKonsultasi,
                        style: AppTextStyle.medium.copyWith(
                          fontSize: 14,
                          color: AppColors.black100,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                  const SizedBox(height: 55),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Header (tetap) =====================
Widget _buildHeaderSection(BuildContext context, imageURL) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.4,
    width: double.infinity,
    decoration: BoxDecoration(gradient: AppColors.gradasi01),
    child: Stack(
      children: [
        CustomImageView(
          imagePath: "assets/home_assets/images/img_star.png",
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 32,
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRect(
            child: Image.network(
              normalizeAssetUrl(imageURL),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  'assets/data_ternak_assets/icons/ic_back.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FilledActionButton extends StatelessWidget {
  final double width;
  final double height;
  final String iconPath;
  final double iconSize;
  final String label;
  final double labelSize;
  final Color color;
  final VoidCallback onTap;

  const _FilledActionButton({
    required this.width,
    required this.height,
    required this.iconPath,
    required this.iconSize,
    required this.label,
    required this.labelSize,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconPath.startsWith('http')
                ? Image.network(normalizeAssetUrl(iconPath), height: iconSize)
                : Image.asset(iconPath, height: iconSize),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyle.medium.copyWith(
                    color: AppColors.primaryWhite,
                    fontSize: labelSize,
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
