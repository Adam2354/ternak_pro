
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/onboarding_buttom.dart';
import 'hasil_rekomendasi_ternak_page.dart';

class CustomInputRekomendasiTernakField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardTipe;
  final bool isHarga;

  const CustomInputRekomendasiTernakField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
    this.keyboardTipe = TextInputType.text,
    this.isHarga = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          maxLines: maxLines,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black54),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 14,
            ),
            prefixText: isHarga ? 'Rp. ' : '',
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          keyboardType: keyboardTipe,
          inputFormatters: [
            if (isHarga) _moneyFormatter(),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  TextInputFormatter _moneyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final digitsOnly =
          newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      final formatter = NumberFormat('#,##0', 'id_ID');
      String formatted = '';

      if (digitsOnly.isNotEmpty) {
        try {
          formatted = formatter.format(int.parse(digitsOnly));
        } catch (_) {
          formatted = oldValue.text;
        }
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length,
        ),
      );
    });
  }
}

class CustomDropdownInputTernak extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> options;
  final String selectedValue;
  final Function(String) onChanged;

  const CustomDropdownInputTernak({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<CustomDropdownInputTernak> createState() =>
      _CustomDropdownInputTernakState();
}

class _CustomDropdownInputTernakState
    extends State<CustomDropdownInputTernak> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownInputTernak oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedValue != widget.selectedValue) {
      selectedValue = widget.selectedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyle.semiBold.copyWith(
            fontSize: 14,
            color: AppColors.black100,
          ),
        ),
        const SizedBox(height: 3),
        GestureDetector(
          onTap: () => _showOptionsDialog(context),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black01),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.selectedValue.isEmpty
                        ? widget.hintText
                        : widget.selectedValue,
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 14,
                      color: widget.selectedValue.isEmpty
                          ? AppColors.black01
                          : AppColors.black100,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/home_assets/icons/ic_dropdown.png',
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.options.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 16,
                      color: AppColors.black100,
                    ),
                  ),
                  value: option,
                  groupValue: widget.selectedValue,
                  onChanged: (String? value) {
                    if (value == null) return;

                    setState(() {
                      selectedValue = value;
                    });

                    widget.onChanged(value);
                    Navigator.of(dialogContext).pop();
                  },
                  activeColor: AppColors.green01,
                  visualDensity: VisualDensity.compact,
                  fillColor: WidgetStateProperty.all(
                    AppColors.green01,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildHeaderSection(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.12,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: AppColors.gradasi01,
    ),
    child: Stack(
      children: [
        CustomImageView(
          imagePath: 'assets/home_assets/images/img_star.png',
          height: MediaQuery.of(context).size.height * 0.12,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 60,
          left: 24,
          right: 24,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/data_ternak_assets/icons/ic_back.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rekomendasi Ternak Potensial',
                  style: AppTextStyle.medium.copyWith(
                    fontSize: 20,
                    color: AppColors.white100,
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

class RekomendasiTernakPage extends StatefulWidget {
  const RekomendasiTernakPage({super.key});

  @override
  State<RekomendasiTernakPage> createState() =>
      _RekomendasiTernakPageState();
}

class _RekomendasiTernakPageState
    extends State<RekomendasiTernakPage> {
  final TextEditingController _panjangLahanController =
      TextEditingController();

  final TextEditingController _lebarLahanController =
      TextEditingController();

  final TextEditingController _modalController =
      TextEditingController();

  String _selectedPengalaman = '';
  String _selectedWaktuPerawatan = '';

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.12,
        ),
        child: _buildHeaderSection(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyle.regular.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Image.asset(
                      'assets/rekomendasi_ternak_assets/icons/ic_location_farm.png',
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomInputRekomendasiTernakField(
                        label: 'Panjang Lahan (Meter)',
                        hintText: '10',
                        controller: _panjangLahanController,
                        keyboardTipe: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomInputRekomendasiTernakField(
                        label: 'Lebar Lahan (Meter)',
                        hintText: '10',
                        controller: _lebarLahanController,
                        keyboardTipe: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/rekomendasi_ternak_assets/icons/ic_money_banyak.png',
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomInputRekomendasiTernakField(
                        label: 'Modal Tersedia',
                        hintText: '5.000.000',
                        controller: _modalController,
                        isHarga: true,
                        keyboardTipe: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/rekomendasi_ternak_assets/icons/ic_clock.png',
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomDropdownInputTernak(
                        label: 'Waktu Perawatan',
                        hintText: 'Pilih Salah Satu',
                        options: const [
                          '< 1 jam/hari',
                          '1 - 2 jam/hari',
                          '2 - 4 jam/hari',
                          '4 - 6 jam/hari',
                          '> 6 jam/hari',
                        ],
                        selectedValue: _selectedWaktuPerawatan,
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            _selectedWaktuPerawatan = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/rekomendasi_ternak_assets/icons/ic_farmer.png',
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomDropdownInputTernak(
                        label: 'Pengalaman Beternak',
                        hintText: 'Pilih Tingkatan',
                        options: const [
                          'Belum Pernah',
                          '< 1 Tahun',
                          '1 - 3 Tahun',
                          '3 - 5 Tahun',
                          '> 5 Tahun',
                        ],
                        selectedValue: _selectedPengalaman,
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            _selectedPengalaman = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomActionButton(
        onPressed: _handleGetRecommendation,
      ),
    );
  }

  Future<void> _handleGetRecommendation() async {
    // Mencegah permintaan ganda saat tombol ditekan berulang kali.
    if (_isLoading) return;

    if (_modalController.text.trim().isEmpty ||
        _panjangLahanController.text.trim().isEmpty ||
        _lebarLahanController.text.trim().isEmpty ||
        _selectedPengalaman.isEmpty ||
        _selectedWaktuPerawatan.isEmpty) {
      setState(() {
        _errorMessage = 'Semua field wajib diisi!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String normalizeNumber(String value) {
        return value.replaceAll(RegExp(r'[^0-9]'), '');
      }

      final modal = double.tryParse(
        normalizeNumber(_modalController.text),
      );

      final panjang = double.tryParse(
        normalizeNumber(_panjangLahanController.text),
      );

      final lebar = double.tryParse(
        normalizeNumber(_lebarLahanController.text),
      );

      if (modal == null || panjang == null || lebar == null) {
        if (!mounted) return;

        setState(() {
          _errorMessage = 'Input angka tidak valid.';
        });
        return;
      }

      if (modal <= 0 || panjang <= 0 || lebar <= 0) {
        if (!mounted) return;

        setState(() {
          _errorMessage =
              'Modal dan ukuran lahan harus lebih dari nol.';
        });
        return;
      }

      final luas = panjang * lebar;

      int waktu = 1;

      switch (_selectedWaktuPerawatan) {
        case '< 1 jam/hari':
          waktu = 1;
          break;
        case '1 - 2 jam/hari':
          waktu = 2;
          break;
        case '2 - 4 jam/hari':
          waktu = 3;
          break;
        case '4 - 6 jam/hari':
          waktu = 4;
          break;
        case '> 6 jam/hari':
          waktu = 5;
          break;
      }

      String pengalaman = 'belum';

      switch (_selectedPengalaman) {
        case 'Belum Pernah':
          pengalaman = 'belum';
          break;
        case '< 1 Tahun':
          pengalaman = 'kurang_1_tahun';
          break;
        case '1 - 3 Tahun':
          pengalaman = '1_3_tahun';
          break;
        case '3 - 5 Tahun':
          pengalaman = '3_5_tahun';
          break;
        case '> 5 Tahun':
          pengalaman = 'lebih_5_tahun';
          break;
      }

      final response = await ApiService().getRekomendasiTernak(
        modal: modal,
        lahan: luas,
        waktu: waktu,
        pengalaman: pengalaman,
      );

      // Pengguna mungkin menutup halaman saat API sedang dipanggil.
      if (!mounted) return;

      final rawData = response['data'];

      if (rawData is! Map) {
        throw Exception(
          'Format respons rekomendasi tidak valid.',
        );
      }

      final recommendationData =
          Map<String, dynamic>.from(rawData);

      if (recommendationData['recommendations'] is! List) {
        throw Exception(
          'Data rekomendasi tidak ditemukan pada respons API.',
        );
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (routeContext) {
            return HasilRekomendasiTernakPage(
              recommendationData: recommendationData,
              userModal: modal,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat rekomendasi: $e';
      });
    } finally {
      // Jangan panggil setState jika halaman sudah ditutup.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _panjangLahanController.dispose();
    _lebarLahanController.dispose();
    _modalController.dispose();
    super.dispose();
  }
}

class BottomActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BottomActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ClipRect(
        child: Opacity(
          opacity: 1,
          child: OnboardingButton(
            previous: false,
            text: 'Lihat Rekomendasi ➜',
            width: double.infinity,
            onClick: onPressed,
          ),
        ),
      ),
    );
  }
}
