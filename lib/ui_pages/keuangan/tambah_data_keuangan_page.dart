import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/tab_keuangan_cubit.dart';
import '../../models/KeuanganItem.dart';
import '../../services/api_service.dart';
import '../../shared/custom_loading.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/keuangan/custom_app_bar.dart';
import '../../shared/widgets/keuangan/custom_tab_bar.dart';
import '../../shared/widgets/onboarding_buttom.dart';

class TambahDataKeuanganPage extends StatefulWidget {
  const TambahDataKeuanganPage({super.key});

  @override
  TambahDataKeuanganPageState createState() => TambahDataKeuanganPageState();
}

class TambahDataKeuanganPageState extends State<TambahDataKeuanganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _dariController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  String _selectedAset = '';
  final ApiService _apiService = ApiService();
  String _userId = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserId();
  }

  List<Map<String, dynamic>> _optionAsset = [];

  Future<void> _loadUserId() async {
    final credential = await _apiService.loadCredentials();
    setState(() {
      _userId = credential['user_id'];
    });
    final asset = await _apiService.getAsset(_userId);
    _optionAsset = asset;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tanggalController.dispose();
    _totalController.dispose();
    _dariController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _saveKeuangan(String activePage) async {
    if (_isSaving) return;
    _isSaving = true;
    setState(() {
      _isLoading = true;
    });

    try {
      // Validasi input
      if (_tanggalController.text.isEmpty ||
          _totalController.text.isEmpty ||
          _dariController.text.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _isSaving = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap isi semua field wajib')),
        );
        return;
      }

      // Jika _selectedAset kosong ('') maka set menjadi -1
      // Coba untuk parsing _selectedAset menjadi int
      final asetId = int.tryParse(_selectedAset);

      // Konversi tanggal dari dd/MM/yyyy ke YYYY-MM-DD
      final inputFormat = DateFormat('dd/MM/yyyy');
      final outputFormat = DateFormat('yyyy-MM-dd');
      final tglKeuangan = inputFormat.parse(_tanggalController.text);
      final formattedTglKeuangan = outputFormat.format(tglKeuangan);

      // Buat KeuanganItem
      final keuanganItem = KeuanganItem(
        idKeuangan: 0, // Akan diisi oleh server
        isPengeluaran: activePage == 'pengeluaran',
        nominalTotal: int.parse(
          _totalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
        dariTujuan: _dariController.text,
        asetId: asetId ?? 0,
        namaAset: _selectedAset.isNotEmpty ? _selectedAset : '',
        tglKeuangan: DateTime.parse(formattedTglKeuangan),
        catatan: _catatanController.text,
      );

      // Simpan ke API
      await _apiService.storeKeuangan(
        keuanganItem,
        _userId,
        context,
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data keuangan berhasil disimpan')),
      );
      Navigator.pop(
        context,
        true,
      ); // Kembali ke halaman sebelumnya dengan hasil true
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _isSaving = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _keuanganErrorMessage(e),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }

  String _keuanganErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) return 'Gagal menyimpan data keuangan';
    if (message.length > 180) {
      return '${message.substring(0, 177)}...';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final int initialIndex = switch (args) {
      final Map m when m['initialIndex'] is int => m['initialIndex'] as int,
      _ => 0,
    };

    if (_isLoading) {
      return const Scaffold(body: Center(child: TernakProBoxLoading()));
    }

    return BlocProvider(
      create: (_) => TabKeuanganCubit(initialIndex),
      child: BlocConsumer<TabKeuanganCubit, int>(
        listener: (context, selectedIndex) {
          if (_tabController.index != selectedIndex) {
            _tabController.animateTo(selectedIndex);
          }
        },
        builder: (context, selectedIndex) {
          return Scaffold(
            backgroundColor: AppColors.bgLight,
            appBar: CustomAppBar(),
            body: Column(
              children: [
                CustomTabBar(
                  controller: _tabController,
                  onSwipe: (index) {
                    context.read<TabKeuanganCubit>().setKeuanganTab(index);
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Tab Pendapatan
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputKeuanganField(
                              label: 'Tanggal Mulai',
                              hintText: 'HH/BB/TTTT',
                              controller: _tanggalController,
                              isCalendar: true,
                            ),
                            CustomInputKeuanganField(
                              label: 'Total',
                              hintText: '2.000.000',
                              controller: _totalController,
                              isCalendar: false,
                              isHarga: true,
                              keyboardTipe: TextInputType.number,
                            ),
                            CustomInputKeuanganField(
                              label: 'Dari',
                              hintText: 'Ex: Penjualan Susu',
                              controller: _dariController,
                              isCalendar: false,
                              isHarga: false,
                            ),
                            CustomDropdownInputKeuangan(
                              label: 'Aset',
                              hintText: 'Pilih Aset',
                              options: _optionAsset,
                              selectedValue: _selectedAset,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAset =
                                      value; // Update selected asset
                                });
                              },
                            ),
                            CustomInputKeuanganField(
                              label: 'Catatan (Opsional)',
                              hintText: 'Tambahkan catatan jika diperlukan',
                              controller: _catatanController,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      // Tab Pengeluaran (sama dengan pendapatan untuk contoh ini)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputKeuanganField(
                              label: 'Tanggal Mulai',
                              hintText: 'HH/BB/TTTT',
                              controller: _tanggalController,
                              isCalendar: true,
                            ),
                            CustomInputKeuanganField(
                              label: 'Total',
                              hintText: '2.000.000',
                              controller: _totalController,
                              isCalendar: false,
                              isHarga: true,
                              keyboardTipe: TextInputType.number,
                            ),
                            CustomInputKeuanganField(
                              label: 'Untuk',
                              hintText: 'Ex: Pembelian Pakan',
                              controller: _dariController,
                              isCalendar: false,
                              isHarga: false,
                            ),
                            CustomDropdownInputKeuangan(
                              label: 'Aset',
                              hintText: 'Pilih Aset',
                              options: _optionAsset,
                              selectedValue: _selectedAset,
                              onChanged: (value) =>
                                  setState(() => _selectedAset = value),
                            ),
                            CustomInputKeuanganField(
                              label: 'Catatan (Opsional)',
                              hintText: 'Tambahkan catatan jika diperlukan',
                              controller: _catatanController,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomActionButton(
              activePage: selectedIndex == 0 ? 'pendapatan' : 'pengeluaran',
              onSave: () => _saveKeuangan(
                selectedIndex == 0 ? 'pendapatan' : 'pengeluaran',
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget untuk Dropdown
class CustomDropdownInputKeuangan extends StatefulWidget {
  final String label;
  final String hintText;
  final List<Map<String, dynamic>> options;
  final String selectedValue;
  final Function(String) onChanged;

  const CustomDropdownInputKeuangan({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<CustomDropdownInputKeuangan> createState() =>
      _CustomDropdownInputKeuanganState();
}

class _CustomDropdownInputKeuanganState
    extends State<CustomDropdownInputKeuangan> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  String _getSelectedName(String selectedValue) {
    // Mengonversi selectedValue menjadi int
    final int selectedId =
        int.tryParse(selectedValue) ?? -1; // Default ke -1 jika gagal

    // Mencari nama berdasarkan selectedValue (id)
    final option = widget.options.firstWhere(
      (option) =>
          option['id'] ==
          selectedId, // Membandingkan dengan id setelah di-convert
      orElse: () => {
        'nama': '',
      }, // Jika tidak ditemukan, kembalikan nama kosong
    );

    return option['nama'] ?? ''; // Mengembalikan nama jika ditemukan
  }

  String _getSelectedId(String selectedTitle) {
    // Mencari id berdasarkan selectedTitle (nama)
    final option = widget.options.firstWhere(
      (option) => option['nama'] == selectedTitle,
      orElse: () => {'id': -1}, // Jika tidak ditemukan, kembalikan id -1
    );

    return option['id'].toString(); // Mengembalikan id jika ditemukan
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
                Text(
                  widget.selectedValue.isEmpty
                      ? widget.hintText
                      : _getSelectedName(widget.selectedValue),
                  style: AppTextStyle.medium.copyWith(
                    fontSize: 14,
                    color: widget.selectedValue.isEmpty
                        ? AppColors.black01
                        : AppColors.black100,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    option['nama'].toString(),
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 16,
                      color: AppColors.black100,
                    ),
                  ),
                  value: option['id'].toString(),
                  groupValue: widget.selectedValue,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedValue = value;
                      });
                      widget.onChanged(value);
                      Navigator.of(context).pop();

                      // If "Khusus.." is selected, show the recurrence modal
                      if (value == _getSelectedId('Khusus..')) {
                        _showRecurrenceModal(context);
                      }

                      if (value == '0') {
                        _showRecurrenceModal(context);
                      }
                    }
                  },
                  activeColor: AppColors.green01,
                  visualDensity: VisualDensity.compact,
                  toggleable: true,
                  fillColor: WidgetStateProperty.all(AppColors.green01),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showRecurrenceModal(BuildContext context) {
    final TextEditingController _namaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Tambah Aset Baru',
            style: AppTextStyle.semiBold.copyWith(
              fontSize: 18,
              color: AppColors.black100,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Aset',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green01),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup modal
              },
              child: Text(
                'Batal',
                style: AppTextStyle.medium.copyWith(color: AppColors.black100),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final nama = _namaController.text.trim();
                if (nama.isNotEmpty) {
                  try {
                    // Panggil API Service untuk menyimpan tujuan ternak
                    final credentials = await ApiService().loadCredentials();
                    final userId = credentials['user_id'];
                    final newTujuanId = await ApiService.storeAsset(
                      userId,
                      nama,
                    );

                    // Perbarui selectedValue dengan ID baru
                    setState(() {
                      widget.onChanged(newTujuanId.toString());
                    });

                    // Tutup modal custom
                    Navigator.of(context).pop();

                    // Tutup dialog opsi
                    Navigator.pushReplacementNamed(
                      context,
                      '/tambah-data-keuangan',
                    );
                  } catch (e) {
                    // Tampilkan pesan error jika gagal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menambahkan asset: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama aset wajib diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green01,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Simpan',
                style: AppTextStyle.medium.copyWith(
                  color: AppColors.primaryWhite,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomRecurrenceModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const CustomRecurrenceModal({super.key, required this.onSave});

  @override
  State<CustomRecurrenceModal> createState() => _CustomRecurrenceModalState();
}

class _CustomRecurrenceModalState extends State<CustomRecurrenceModal> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class CustomInputKeuanganField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardTipe;
  final bool isCalendar;
  final bool isHarga;

  const CustomInputKeuanganField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardTipe = TextInputType.text,
    this.maxLines = 1,
    this.isCalendar = false,
    this.isHarga = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.semiBold.copyWith(
            fontSize: 14,
            color: AppColors.black100,
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          maxLines: maxLines,
          keyboardType: keyboardTipe,
          controller: controller,
          readOnly: isCalendar,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyle.medium.copyWith(
              fontSize: 14,
              color: AppColors.black01,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.black01),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 14,
            ),
            prefixText: isHarga ? 'Rp. ' : '',
            suffixIcon: isCalendar
                ? IconButton(
                    icon: Image.asset(
                      'assets/data_ternak_assets/icons/ic_calendar.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () async {
                      _showDatePicker(context);
                    },
                  )
                : null,
          ),
          inputFormatters: [if (isHarga) moneyFormatter()],
          onTap: isCalendar
              ? () async {
                  _showDatePicker(context);
                }
              : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  TextInputFormatter moneyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      final formatter = NumberFormat('#,##0', 'id_ID');
      String formatted = '';
      if (digitsOnly.isNotEmpty) {
        try {
          formatted = formatter.format(int.parse(digitsOnly));
        } catch (e) {
          formatted = oldValue.text;
        }
      }
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  void _showDatePicker(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      controller.text = formattedDate;
    }
  }
}

class BottomActionButton extends StatelessWidget {
  final String activePage;
  final VoidCallback onSave;

  const BottomActionButton({
    super.key,
    required this.activePage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ClipRect(
        child: Opacity(
          opacity: 1.0,
          child: OnboardingButton(
            previous: false,
            text: "Menyimpan",
            width: double.infinity,
            height: 30,
            onClick: onSave,
          ),
        ),
      ),
    );
  }
}
