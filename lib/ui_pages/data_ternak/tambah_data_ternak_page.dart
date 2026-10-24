import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ternak_pro/shared/custom_loading.dart';
import '../../services/api_service.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/onboarding_buttom.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Widget untuk Input Text
class CustomInputTernakField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final bool
  isCalendar; // Flag untuk menentukan apakah akan menampilkan DatePicker
  final TextInputType? keyboardType;
  final bool readOnly;

  const CustomInputTernakField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
    this.isCalendar = false, // Default false
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 3),
        TextField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          controller: controller,
          readOnly: isCalendar == true
              ? isCalendar
              : readOnly, // Make it read-only if it's a DatePicker
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14, color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black54),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 14),
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
                : null, // No icon if it's not a calendar
            fillColor: readOnly
                ? AppColors.grey20
                : Colors.white, // Add background color when read-only
            filled: readOnly, // Fill only if it's read-only
          ),
          onTap: isCalendar
              ? () async {
                  _showDatePicker(context);
                }
              : null, // If it's a calendar, show DatePicker on tap
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Function to show DatePicker dialog
  void _showDatePicker(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Format the selected date and set it in the controller
      String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      controller.text =
          formattedDate; // Update the text field with the selected date
    }
  }
}

class CustomDropdownInputTernak extends StatefulWidget {
  final String label;
  final String hintText;
  final List<Map<String, dynamic>> options;
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

class _CustomDropdownInputTernakState extends State<CustomDropdownInputTernak> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label dengan elipsis dan tooltip
        Tooltip(
          message: widget.label,
          child: Text(
            widget.label,
            style: AppTextStyle.semiBold.copyWith(
              fontSize: 14,
              color: AppColors.black100,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
                // Teks dropdown dengan elipsis dan tooltip
                Expanded(
                  child: Tooltip(
                    message: widget.selectedValue.isEmpty
                        ? widget.hintText
                        : widget.options.firstWhere(
                            (option) =>
                                option['id'].toString() == widget.selectedValue,
                            orElse: () => {'nama': widget.hintText},
                          )['nama'],
                    child: Text(
                      widget.selectedValue.isEmpty
                          ? widget.hintText
                          : widget.options.firstWhere(
                              (option) =>
                                  option['id'].toString() ==
                                  widget.selectedValue,
                              orElse: () => {'nama': widget.hintText},
                            )['nama'],
                      style: AppTextStyle.medium.copyWith(
                        fontSize: 14,
                        color: widget.selectedValue.isEmpty
                            ? AppColors.black01
                            : AppColors.black100,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                // Ikon dropdown (tetap di kanan)
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
                    option['nama'],
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 16,
                      color: AppColors.black100,
                    ),
                  ),
                  value: option['id'].toString(),
                  groupValue: widget.selectedValue,
                  onChanged: (String? value) {
                    if (value == '0') {
                      // Jika memilih id = 0, buka custom modal
                      _showCustomModal(context);
                    } else {
                      // Jika bukan id = 0, perbarui nilai dan tutup dialog
                      setState(() {
                        widget.onChanged(value!);
                      });
                      Navigator.of(context).pop();
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

  void _showCustomModal(BuildContext context) {
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
            'Tambah Tujuan Ternak',
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
                  labelText: 'Nama Tujuan Ternak',
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
                    final newTujuanId = await ApiService.storeTujuanTernak(
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
                      '/tambah-data-ternak',
                    );
                  } catch (e) {
                    // Tampilkan pesan error jika gagal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menambahkan tujuan ternak: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama tujuan ternak wajib diisi'),
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

// Header dengan ikon back
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
              // Back Icon Button
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
              SizedBox(width: 10),
              // Title Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Data Ternak',
                    style: AppTextStyle.medium.copyWith(
                      fontSize: 20,
                      color: AppColors.white100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Halaman Utama
class TambahDataTernakPage extends StatefulWidget {
  const TambahDataTernakPage({super.key});

  @override
  TambahDataTernakPageState createState() => TambahDataTernakPageState();
}

class TambahDataTernakPageState extends State<TambahDataTernakPage> {
  final TextEditingController _namaPeternakanController =
      TextEditingController();
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _jumlahHewanController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();

  bool _isChecked = false;
  String _selectedHewan = '';
  String _selectedRas = '';
  String _selectedTujuanTernak = '';
  String _selectedKondisi = '';
  String _selectedJenisKelamin = '';

  List<Map<String, dynamic>> _optionsHewan = [];
  List<Map<String, dynamic>> _optionsRas = [];
  List<Map<String, dynamic>> _optionsTujuanTernak = [];
  bool _isLoading = true;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName();
  }

  String _formatToYmd(String input) {
    try {
      final d = DateFormat('dd/MM/yyyy').parseStrict(input.trim());
      return DateFormat('yyyy-MM-dd').format(d);
    } catch (_) {
      return input; // fallback kalau user mengetik manual
    }
  }

  // Fungsi untuk mengambil nama dari SharedPreferences
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString(
      'name',
    ); // Ambil 'name' dari SharedPreferences

    // Jika 'name' tidak ditemukan, gunakan string default
    String defaultName = userName != null
        ? 'Peternakan $userName'
        : 'Peternakan';

    setState(() {
      _namaPeternakanController.text =
          defaultName; // Set nilai pada _namaPeternakanController
    });
  }

  Future<void> _loadData() async {
    try {
      await loadUserId();
      final hewan = await _apiService.getHewan();
      final ras = await _apiService.getRas();
      final tujuanTernak = await _apiService.getTujuanTernakListByUserId(
        userId,
      );
      setState(() {
        _optionsHewan = hewan;
        _optionsRas = ras;
        _optionsTujuanTernak = tujuanTernak;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> loadUserId() async {
    final credential = await _apiService.loadCredentials();
    setState(() {
      userId = credential['user_id'];
    });
  }

  Future<void> _saveData() async {
    // Validasi minimal sebelum kirim
    if (_selectedHewan.isEmpty ||
        _selectedRas.isEmpty ||
        _selectedTujuanTernak.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih hewan, ras, dan tujuan ternak terlebih dahulu'),
        ),
      );
      return;
    }
    if (_tanggalMulaiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai belum diisi')),
      );
      return;
    }

    // Map & konversi nilai
    final int hewanId = int.tryParse(_selectedHewan) ?? 0;
    final int rasId = int.tryParse(_selectedRas) ?? 0;
    final int tujuanTernakId = int.tryParse(_selectedTujuanTernak) ?? 0;

    final String tglMulaiYmd = _formatToYmd(_tanggalMulaiController.text);
    final int? usia = _usiaController.text.trim().isEmpty
        ? null
        : int.tryParse(_usiaController.text.trim());
    final double? berat = _beratController.text.trim().isEmpty
        ? null
        : double.tryParse(_beratController.text.trim());
    final int? jumlahHewan = _isChecked
        ? null
        : (_jumlahController.text.trim().isEmpty
              ? null
              : int.tryParse(_jumlahController.text.trim()));

    // Field individual
    final String? tagId = _isChecked
        ? (_jumlahHewanController.text.trim().isEmpty
              ? null
              : _jumlahHewanController.text.trim())
        : null;
    final String? kondisiTernak = _isChecked && _selectedKondisi.isNotEmpty
        ? _selectedKondisi
        : null;
    final String? jenisKelamin = _isChecked && _selectedJenisKelamin.isNotEmpty
        ? _selectedJenisKelamin
        : null;

    // Validasi cabang sederhana
    if (_isChecked) {
      // Individual
      if (tagId == null ||
          kondisiTernak == null ||
          jenisKelamin == null ||
          berat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lengkapi Tag, Kondisi, Jenis Kelamin, dan Berat untuk mode individu',
            ),
          ),
        );
        return;
      }
    } else {
      // Batch
      if (jumlahHewan == null || jumlahHewan < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah hewan minimal 1 untuk mode kelompok'),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final ok = await _apiService.storeTernak(
        context: context,
        userId: userId,
        namaTernak: _namaPeternakanController.text
            .trim(), // dipakai sebagai nama_ternak
        tglMulai: tglMulaiYmd,
        hewanId: hewanId,
        rasId: rasId,
        tujuanTernakId: tujuanTernakId,
        isIndividual: _isChecked,
        usia: usia, // null → default 0 di backend atau di service
        tagId: tagId, // wajib saat individual
        kondisiTernak: kondisiTernak, // wajib saat individual
        jenisKelamin: jenisKelamin, // wajib saat individual
        berat: berat ?? 0, // wajib saat individual
        jumlahHewan: jumlahHewan, // wajib saat batch
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (ok) {
        // Sukses → pindah halaman
        if (!mounted) return;
        Navigator.pushNamed(context, '/list-data-ternak-tugas');
      } else {
        // Harusnya tidak terjadi karena ok hanya true saat 201
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data ternak')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(
    //     body: Center(child: TernakProBoxLoading()),
    //   );
    // }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadData();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.12,
        ),
        child: _buildHeaderSection(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Peternakan
            CustomInputTernakField(
              label: 'Nama Peternakan',
              hintText: 'Masukkan Nama Peternakanmu',
              controller: _namaPeternakanController,
              readOnly: true,
            ),
            // Tanggal Mulai
            CustomInputTernakField(
              label: 'Tanggal Mulai',
              hintText: 'HH/BB/TTTT',
              controller: _tanggalMulaiController,
              isCalendar: true,
            ),
            // Pilih Hewan dan Ras
            Row(
              children: [
                Expanded(
                  child: CustomDropdownInputTernak(
                    label: 'Pilih Hewan',
                    hintText: 'Pilih salah satu',
                    options: _optionsHewan.isNotEmpty
                        ? _optionsHewan
                        : const [
                            {'id': '1', 'nama': 'Sapi'},
                            {'id': '2', 'nama': 'Kambing'},
                            {'id': '3', 'nama': 'Domba'},
                            {'id': '4', 'nama': 'Ayam'},
                            {'id': '5', 'nama': 'Bebek'},
                          ],
                    selectedValue: _selectedHewan,
                    onChanged: (value) =>
                        setState(() => _selectedHewan = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomDropdownInputTernak(
                    label: 'Pilih Ras',
                    hintText: 'Masukkan Ras',
                    options: _optionsRas,
                    selectedValue: _selectedRas,
                    onChanged: (value) => setState(() => _selectedRas = value),
                  ),
                ),
              ],
            ),
            // Dibesarkan untuk dan Usia
            Row(
              children: [
                Expanded(
                  child: CustomDropdownInputTernak(
                    label: 'Dibesarkan untuk',
                    hintText: 'Pilih salah satu',
                    options: _optionsTujuanTernak,
                    selectedValue: _selectedTujuanTernak,
                    onChanged: (value) =>
                        setState(() => _selectedTujuanTernak = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomInputTernakField(
                    label: 'Usia (Bulan)',
                    hintText: 'Masukkan usia (bulan)',
                    controller: _usiaController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const Text('Saya ingin mencatat ternak secara individu'),
              ],
            ),
            // Jika checkbox dicentang
            if (_isChecked) ...[
              CustomInputTernakField(
                label: 'Nomer Ternak (Tag)',
                hintText: 'Ketikan nomor ternak',
                controller: _jumlahHewanController,
              ),
              CustomDropdownInputTernak(
                label: 'Kondisi',
                hintText: 'Pilih salah satu',
                options: const [
                  {'id': 'Sehat', 'nama': 'Sehat'},
                  {'id': 'Sakit', 'nama': 'Sakit'},
                ],
                selectedValue: _selectedKondisi,
                onChanged: (value) => setState(() => _selectedKondisi = value),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomDropdownInputTernak(
                      label: 'Jenis Kelamin',
                      hintText: 'Pilih salah satu',
                      options: const [
                        {'id': 'Jantan', 'nama': 'Jantan'},
                        {'id': 'Betina', 'nama': 'Betina'},
                      ],
                      selectedValue: _selectedJenisKelamin,
                      onChanged: (value) =>
                          setState(() => _selectedJenisKelamin = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomInputTernakField(
                      label: 'Berat (Kg)',
                      hintText: 'Ex: 6',
                      controller: _beratController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomInputTernakField(
                label: 'Jumlah Hewan',
                hintText: 'Ketik Jumlah',
                controller: _jumlahController,
                keyboardType: TextInputType.number,
              ),
            ],
            // Catatan (Opsional)
            CustomInputTernakField(
              label: 'Catatan (Opsional)',
              hintText: 'Write a message',
              controller: _catatanController,
              maxLines: 4,
            ),
            // Simpan Button (disabled kalau daftar hewan kosong)
            OnboardingButton(
              previous: false,
              text:
                  "➞ Simpan", // Menggunakan emoji panah tebal dari respons sebelumnya
              width: double.infinity,
              isActive: _optionsHewan.isNotEmpty,
              onClick: _optionsHewan.isNotEmpty
                  ? _saveData
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Daftar hewan belum tersedia. Silakan coba lagi.',
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
