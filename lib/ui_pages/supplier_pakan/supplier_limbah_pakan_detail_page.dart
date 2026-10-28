import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/supplier_pakan.dart/expandable_detail_text.dart';

class SupplierLimbahPakanDetailPage extends StatefulWidget {
  final bool? isStok;
  final bool? isNego;
  final String imageUrlJoined;
  final String? mapsLink;
  final String? phoneNumber;

  // Tambahan untuk konten dinamis:
  final String judul;
  final String detail;
  final String khasiat;
  final int harga;
  final String alamatOverview;
  final String alamatLengkap;

  const SupplierLimbahPakanDetailPage({
    super.key,
    this.isStok = true,
    this.isNego = false,
    required this.imageUrlJoined,
    this.mapsLink,
    this.phoneNumber,
    required this.judul,
    required this.detail,
    required this.khasiat,
    required this.harga,
    required this.alamatOverview,
    required this.alamatLengkap,
  });

  /// Factory agar tinggal kirim Map `item` dari list
  factory SupplierLimbahPakanDetailPage.fromMap(Map<String, dynamic> item) {
    return SupplierLimbahPakanDetailPage(
      isStok: (item['is_stok'] == 1),
      isNego: (item['is_nego'] == 1),
      imageUrlJoined: (item['image_url'] as String?) ?? '',
      mapsLink: item['maps_link']?.toString(),
      phoneNumber: item['no_tlp']?.toString(),
      judul: item['judul']?.toString() ?? '',
      detail: item['detail']?.toString() ?? '',
      khasiat: item['khasiat']?.toString() ?? '',
      harga: (item['harga'] is int)
          ? item['harga'] as int
          : int.tryParse(item['harga'].toString()) ?? 0,
      alamatOverview: item['alamat_overview']?.toString() ?? '',
      alamatLengkap: item['alamat']?.toString() ?? '',
    );
  }

  @override
  State<SupplierLimbahPakanDetailPage> createState() =>
      _SupplierLimbahPakanDetailPageState();
}

class _SupplierLimbahPakanDetailPageState
    extends State<SupplierLimbahPakanDetailPage> {
  int _currentImage = 0;
  final PageController _pageController = PageController();

  List<String> get _imageList => (widget.imageUrlJoined)
      .split(';')
      .where((e) => e.trim().isNotEmpty)
      .map((e) => e.trim())
      .toList();

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
          MediaQuery.of(context).size.height * 0.12,
        ),
        child: _buildHeaderSection(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============== 1) CAROUSEL DENGAN INDIKATOR, TINGGI KONSISTEN ===============
            _buildImageCarousel(context),

            const SizedBox(height: 15),
            Padding(
              // Perbaikan: EdgeInsetsGeometry.symmetric -> EdgeInsets.symmetric
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.judul,
                    style: AppTextStyle.semiBold.copyWith(
                      fontSize: 18,
                      color: AppColors.black100,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // =============== 3) ROW HARGA & STOK RESPONSIF/DINAMIS ===============
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Jika sempit, perkecil teks secara proporsional
                      final bool isNarrow = constraints.maxWidth < 360;
                      final double priceFont = isNarrow ? 16 : 18;
                      final double chipFont = isNarrow ? 14 : 16;
                      final double stockFont = isNarrow ? 16 : 18;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Kelompok harga + chip "Nego"
                          Flexible(
                            flex: 6,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'RP ${formatRupiah(widget.harga)}',
                                    textAlign: TextAlign.left,
                                    style: AppTextStyle.semiBold.copyWith(
                                      fontSize: priceFont,
                                      color: AppColors.blue01,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  widget.isNego == true
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: AppColors.gradasi01,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Text(
                                            'Nego',
                                            style: AppTextStyle.medium.copyWith(
                                              color: AppColors.white100,
                                              fontSize: chipFont,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Stok
                          Flexible(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Stok: ',
                                      style: AppTextStyle.medium.copyWith(
                                        color: Colors.black,
                                        fontSize: stockFont,
                                      ),
                                    ),
                                    TextSpan(
                                      text: (widget.isStok ?? true)
                                          ? "Tersedia"
                                          : "Habis",
                                      style: AppTextStyle.medium.copyWith(
                                        color: (widget.isStok ?? true)
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: stockFont,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Image.asset(
                        'assets/supplier_pakan_assets/icons/ic_calling.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'No. Telp: ${formatNomor(widget.phoneNumber ?? '08')}',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 16,
                          color: AppColors.black100,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/supplier_pakan_assets/icons/ic_calling.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Alamat Supplier:',
                            style: AppTextStyle.semiBold.copyWith(
                              fontSize: 16,
                              color: AppColors.black100,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.alamatLengkap,
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

                  // =============== 2) TOMBOL MAPS & HUBUNGI LEBIH RAPI ===============
                  // Wrap membuatnya responsif (berpindah baris bila sempit) TANPA menghilangkan elemen
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool veryNarrow = constraints.maxWidth < 360;
                      final double btnHeight = 50;
                      final double iconSize = veryNarrow ? 14 : 16;
                      final double fontSize = veryNarrow ? 12 : 14;
                      final double buttonGap = 12;

                      // minta masing2 tombol mencoba ambil 0.5 lebar minus gap agar konsisten
                      final double targetWidth =
                          (constraints.maxWidth - buttonGap) / 2;

                      return Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 12,
                        spacing: buttonGap,
                        children: [
                          _OutlinedActionButton(
                            width: targetWidth,
                            height: btnHeight,
                            iconPath:
                                'assets/supplier_pakan_assets/icons/ic_location.png',
                            iconSize: iconSize,
                            label: 'Lokasi Maps',
                            labelSize: fontSize,
                            color: AppColors.green01,
                            onTap: () async {
                              final link = widget.mapsLink;
                              if (link != null && link.isNotEmpty) {
                                final Uri uri = Uri.parse(link);

                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  SnackBar(
                                    content: Text(
                                      'Tidak bisa membuka Data Lokasi',
                                    ),
                                  );
                                }
                              } else {
                                SnackBar(
                                  content: Text(
                                    'Tidak bisa menemukan Data Lokasi',
                                  ),
                                );
                              }
                            },
                          ),
                          _FilledActionButton(
                            width: targetWidth,
                            height: btnHeight,
                            iconPath:
                                'assets/supplier_pakan_assets/icons/ic_message.png',
                            iconSize: iconSize,
                            label: 'Hubungi Penjual',
                            labelSize: fontSize,
                            color: AppColors.green01,
                            onTap: () async {
                              final phone = widget.phoneNumber ?? '';
                              if (phone.isEmpty) {
                                SnackBar(
                                  content: Text('Nomor telepon tidak tersedia'),
                                );
                                return;
                              }

                              final whatsappNumber = toWhatsappNumber(phone);
                              final url = Uri.parse(
                                'https://wa.me/$whatsappNumber',
                              );

                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode
                                      .externalApplication, // buka app WA kalau ada
                                );
                              } else {
                                SnackBar(
                                  content: Text('Tidak bisa membuka WhatsApp'),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // ===================== Detail Produk =====================
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Produk',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 18,
                          color: AppColors.black100,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ExpandableDetailText(text: widget.detail, trimLines: 3),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ===================== Khasiat =====================
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khasiat Untuk Ternak',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 18,
                          color: AppColors.black100,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Pecah string khasiat jadi list
                      ...widget.khasiat
                          .split(';')
                          .where((e) => e.trim().isNotEmpty)
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ",
                                    style: AppTextStyle.extraBold.copyWith(
                                      fontSize: 16,
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

                  const SizedBox(height: 55),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Carousel builder =====================
  Widget _buildImageCarousel(BuildContext context) {
    final double fixedHeight = 240; // tinggi seragam untuk semua gambar
    final images = _imageList.isEmpty
        ? ['https://hawariyyun.my.id/assets/images/sekam.jpg']
        : _imageList;

    return SizedBox(
      height: fixedHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // PageView (gambar)
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (idx) => setState(() => _currentImage = idx),
            itemBuilder: (context, index) {
              final imagePath = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(imagePath, fixedHeight),
              );
            },
          ),

          // Indikator di atas gambar
          Positioned(
            bottom: 12, // jarak dari bawah gambar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImage == i
                        ? AppColors.green01
                        : AppColors.grey3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath, double height) {
    final resolvedPath = normalizeAssetUrl(imagePath);
    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      return Image.network(
        resolvedPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/home_assets/images/img_not_found.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
        ),
      );
    }

    return Image.asset(
      resolvedPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
    );
  }
}

// ===================== Header (tetap) =====================
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
              Text(
                'Detail Produk',
                style: AppTextStyle.medium.copyWith(
                  fontSize: 20,
                  color: AppColors.white100,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ===================== Tombol Action (rapi & konsisten) =====================
class _OutlinedActionButton extends StatelessWidget {
  final double width;
  final double height;
  final String iconPath;
  final double iconSize;
  final String label;
  final double labelSize;
  final Color color;
  final VoidCallback onTap;

  const _OutlinedActionButton({
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
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: Colors.transparent,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconPath.startsWith('http')
                ? Image.network(iconPath, height: iconSize)
                : Image.asset(iconPath, height: iconSize),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyle.medium.copyWith(
                    color: color,
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
                ? Image.network(iconPath, height: iconSize)
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
