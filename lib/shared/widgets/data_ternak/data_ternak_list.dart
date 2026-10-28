import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ternak_pro/services/api_service.dart';
import 'package:ternak_pro/shared/widgets/data_ternak/custom_drop_down_kelamin.dart';

import '../../custom_loading.dart';
import '../../theme.dart';
import '../custom_image_view.dart';
import '../onboarding_buttom.dart';
import 'custom_drop_down_sehat.dart';
import 'custom_weight_field.dart';

class DataTernakList extends StatefulWidget {
  final List<Map<String, dynamic>> ternakList;
  final VoidCallback onRefresh;

  const DataTernakList(this.ternakList, {super.key, required this.onRefresh});

  @override
  State<DataTernakList> createState() => _DataTernakListState();
}

class _DataTernakListState extends State<DataTernakList> {
  late List<Map<String, dynamic>> _ternakList;

  @override
  void initState() {
    super.initState();
    _ternakList = List.from(
      widget.ternakList,
    ); // Salin daftar untuk state lokal
  }

  void _updateTernakItem(int index, Map<String, dynamic> updatedData) {
    setState(() {
      _ternakList[index] = updatedData; // Perbarui item di daftar
    });
    widget.onRefresh(); // Memaksa FutureBuilder untuk memuat ulang data
  }

  Future<bool> _confirmDeleteTernak(int idTernak) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus ternak'),
        content: const Text('Anda yakin ingin menghapus ternak ini?'),
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

    if (result != true) return false;

    try {
      final credentials = await ApiService().loadCredentials();
      final userId = credentials['user_id'];
      if (userId is! String || userId.isEmpty) {
        throw Exception('Sesi pengguna tidak ditemukan');
      }

      await ApiService().deleteTernak(userId, idTernak);
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      return false;
    }
  }

  void _removeTernak(int index) {
    setState(() {
      _ternakList.removeAt(index);
    });
    widget.onRefresh();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ternak dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _ternakList.length,
      itemBuilder: (context, index) {
        final item = _ternakList[index];
        print('DATA TERNAK = $item');
        final idTernak = item['id_ternak'] as int;
        final tagId = item['tag_id'] as String;

        return Dismissible(
          key: Key('ternak_$idTernak'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return _confirmDeleteTernak(idTernak);
          },
          onDismissed: (direction) {
            _removeTernak(index);
          },
          child: CustomTernakItem(
            idTernak: idTernak,
            id: tagId,
            jenis: item['jenis_kelamin'],
            berat: item['berat']!.toString(),
            status: item['kondisi_ternak'],
            iconPath: item['icon_path'],
            onUpdate: (updatedData) => _updateTernakItem(index, updatedData),
            onDelete: () async {
              if (await _confirmDeleteTernak(idTernak) && mounted) {
                _removeTernak(index);
              }
            },
          ),
        );
      },
    );
  }
}

class CustomTernakItem extends StatelessWidget {
  final String id;
  final int idTernak;
  final String jenis;
  final String berat;
  final String status;
  final String iconPath;
  final Function(Map<String, dynamic>) onUpdate;
  final Future<void> Function() onDelete;

  const CustomTernakItem({
    super.key,
    required this.id,
    required this.idTernak,
    required this.jenis,
    required this.berat,
    required this.iconPath,
    required this.status,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final updatedData = await showDataTernakDialog(
          context,
          id,
          idTernak,
          jenis,
          berat,
          status,
          iconPath,
        );
        if (updatedData != null) {
          onUpdate(updatedData);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon sapi (fixed width)
            CustomImageView(
              imagePath: iconPath,
              width: 50,
              height: 50,
              placeHolder: 'assets/home_assets/images/img_not_found.png',
            ),
            const SizedBox(width: 8),
            // Teks ID dengan scroll dan tooltip
            Expanded(
              child: _buildScrollableText(
                context,
                text: id,
                style: AppTextStyle.extraBold.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Teks Jenis dengan scroll dan tooltip
            Expanded(
              child: _buildScrollableText(
                context,
                text: jenis,
                style: AppTextStyle.semiBold.copyWith(
                  fontSize: 14,
                  color: jenis == 'Jantan'
                      ? AppColors.green01
                      : AppColors.purple,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Teks Berat dengan scroll dan tooltip
            Expanded(
              child: _buildScrollableText(
                context,
                text: "$berat Kg",
                style: AppTextStyle.semiBold.copyWith(
                  fontSize: 14,
                  color: AppColors.blue01,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bagian status + ikon (tetap di ujung kanan)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  status == 'Sehat'
                      ? 'assets/home_assets/icons/ic_check_green.png'
                      : 'assets/home_assets/icons/ic_check_yellow.png',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 4),
                // Teks Status dengan scroll dan tooltip
                _buildScrollableText(
                  context,
                  text: status,
                  style: AppTextStyle.semiBold.copyWith(
                    fontSize: 14,
                    color: status == 'Sehat'
                        ? AppColors.green01
                        : (status == 'Sakit'
                              ? AppColors.primaryRed
                              : AppColors.yellow500),
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/home_assets/icons/ic_dropdown.png',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: 'Menu ternak',
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                  child: Image.asset(
                    'assets/home_assets/icons/ic_more.png',
                    width: 18,
                    height: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk teks yang bisa di-scroll jika terpotong, dengan tooltip
  Widget _buildScrollableText(
    BuildContext context, {
    required String text,
    required TextStyle style,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung apakah teks terpotong menggunakan TextPainter
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        // Widget teks dengan tooltip
        Widget textWidget = Text(
          text,
          style: style,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );

        // Jika teks terpotong, bungkus dengan SingleChildScrollView
        if (isOverflowing) {
          textWidget = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(text, style: style, maxLines: 1),
          );
        }

        // Bungkus dengan Tooltip untuk menampilkan teks lengkap
        return Tooltip(
          message: text, // Teks lengkap ditampilkan saat long press
          child: textWidget,
        );
      },
    );
  }
}

Future<Map<String, dynamic>?> showDataTernakDialog(
  BuildContext context,
  String tagId,
  int idTernak,
  String jenis,
  String berat,
  String status,
  String iconPath,
) async {
  TextEditingController noteController = TextEditingController();
  ValueNotifier<String> jenisKelaminNotifier = ValueNotifier(jenis);
  ValueNotifier<String> kondisiTernakNotifier = ValueNotifier(status);
  ValueNotifier<String> beratNotifier = ValueNotifier(berat);

  // Fungsi untuk menampilkan overlay loading
  void showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah menutup dialog dengan tap di luar
      builder: (BuildContext context) {
        return Stack(
          children: [
            ModalBarrier(
              color: Colors.black.withOpacity(
                0.4,
              ), // Efek freeze semi-transparan
              dismissible: false, // Tidak bisa ditutup dengan tap
            ),
            const Center(
              child: TernakProBoxLoading(), // Loading indicator di tengah
            ),
          ],
        );
      },
    );
  }

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.bgLight,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        contentPadding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and title section (close button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                // Cow image section
                Center(
                  child: CustomImageView(
                    imagePath: iconPath,
                    height: 100,
                    placeHolder: 'assets/home_assets/images/img_not_found.png',
                  ),
                ),
                // Ternak ID, Gender, and Weight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: tagId,
                        child: AutoSizeText(
                          tagId,
                          style: AppTextStyle.extraBold.copyWith(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          minFontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Tooltip(
                        message: jenis,
                        child: AutoSizeText(
                          jenis,
                          style: AppTextStyle.semiBold.copyWith(
                            fontSize: 24,
                            color: jenis == 'Jantan'
                                ? AppColors.green01
                                : AppColors.purple,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          minFontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Tooltip(
                        message: "$berat Kg",
                        child: AutoSizeText(
                          "$berat Kg",
                          style: AppTextStyle.extraBold.copyWith(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          minFontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Kondisi Section
                CustomDropDownKelamin(
                  status: jenis,
                  onChanged: (value) {
                    jenisKelaminNotifier.value = value;
                  },
                ),
                const SizedBox(height: 16),
                // Kondisi Section
                CustomDropdownSehat(
                  status: status,
                  onChanged: (value) {
                    kondisiTernakNotifier.value = value;
                  },
                ),
                const SizedBox(height: 16),
                // Berat Badan Section
                CustomWeightField(
                  berat: berat,
                  onChanged: (value) {
                    beratNotifier.value = value;
                  },
                ),
                const SizedBox(height: 16),
                // Catatan Section (Optional)
                Tooltip(
                  message: 'Catatan (Opsional)',
                  child: AutoSizeText(
                    'Catatan (Opsional)',
                    style: AppTextStyle.semiBold.copyWith(
                      fontSize: 14,
                      color: AppColors.black100,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Tulis Catatan Di sini',
                    hintMaxLines: 4,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.white06),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                  minLines: 3,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Center(
                  child: OnboardingButton(
                    previous: false,
                    text: "Simpan Perubahan",
                    width: double.infinity,
                    onClick: () async {
                      // Tampilkan loading overlay
                      showLoadingOverlay(context);
                      try {
                        // Panggil API untuk menyimpan perubahan
                        await ApiService().updateDataTernak(
                          userId: (await ApiService()
                              .loadCredentials())['user_id'],
                          idTernak: idTernak,
                          jenisKelamin: jenisKelaminNotifier.value,
                          kondisiTernak: kondisiTernakNotifier.value,
                          berat: beratNotifier.value,
                          catatan: noteController.text.isEmpty
                              ? null
                              : noteController.text,
                        );

                        // Kembalikan data yang diperbarui untuk refresh
                        final updatedData = {
                          'id_ternak': idTernak,
                          'tag_id': tagId,
                          'jenis_kelamin': jenisKelaminNotifier.value,
                          'berat': double.parse(beratNotifier.value),
                          'kondisi_ternak': kondisiTernakNotifier.value,
                          'catatan': noteController.text.isEmpty
                              ? null
                              : noteController.text,
                        };

                        // Tutup loading overlay
                        Navigator.of(context).pop();
                        // Tutup dialog dan kembalikan data
                        Navigator.of(context).pop(updatedData);
                        Navigator.pushReplacementNamed(
                          context,
                          '/list-data-ternak-tugas',
                        );
                      } catch (e) {
                        // Tutup loading overlay
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menyimpan perubahan: $e'),
                            backgroundColor: AppColors.primaryRed,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result;
}
