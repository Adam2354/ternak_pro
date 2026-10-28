import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../shared/custom_loading.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/onboarding_buttom.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Widget untuk Input Text
class CustomInputTugasField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final bool isCalendar; // Flag to determine if it's a DatePicker
  final bool isClock;
  final TimeOfDay? defaultTime; // Flag to determine if it's a TimePicker

  const CustomInputTugasField({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.defaultTime,
    required this.controller,
    required this.isCalendar,
    required this.isClock,
  });

  @override
  CustomInputTugasFieldState createState() => CustomInputTugasFieldState();
}

class CustomInputTugasFieldState extends State<CustomInputTugasField> {
  @override
  void initState() {
    super.initState();
    // Set default time in the controller if it's a TimePicker and controller is empty
    if (widget.isClock &&
        widget.controller.text.isEmpty &&
        widget.defaultTime != null) {
      final formattedTime = DateFormat('HH:mm').format(
        DateTime(0, 0, 0, widget.defaultTime!.hour, widget.defaultTime!.minute),
      );
      widget.controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 3),
        TextField(
          maxLines: widget.maxLines,
          controller: widget.controller,
          readOnly:
              widget.isCalendar ||
              widget.isClock, // Make it read-only for DatePicker or TimePicker
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(fontSize: 14, color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black54),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            suffixIcon: widget.isCalendar
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
                : widget.isClock
                ? IconButton(
                    icon: Image.asset(
                      'assets/data_ternak_assets/icons/ic_clock.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () async {
                      _showTimePicker(context);
                    },
                  )
                : null, // No icon if neither DatePicker nor TimePicker
          ),
          onTap: widget.isCalendar
              ? () async {
                  _showDatePicker(context);
                }
              : widget.isClock
              ? () async {
                  _showTimePicker(context);
                }
              : null, // If it's a calendar or clock, show the respective picker on tap
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Function to show TimePicker dialog
  void _showTimePicker(BuildContext context) async {
    TimeOfDay initialTime = widget.defaultTime ?? TimeOfDay(hour: 6, minute: 0);
    if (widget.controller.text.isNotEmpty) {
      try {
        final parsedTime = DateFormat('HH:mm').parse(widget.controller.text);
        initialTime = TimeOfDay(
          hour: parsedTime.hour,
          minute: parsedTime.minute,
        );
      } catch (e) {
        initialTime = widget.defaultTime ?? TimeOfDay(hour: 6, minute: 0);
      }
    }

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      String formattedTime = DateFormat(
        'HH:mm',
      ).format(DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute));
      widget.controller.text = formattedTime;
    }
  }

  // Function to show DatePicker dialog
  void _showDatePicker(BuildContext context) async {
    // Parse the existing date from the controller, if available
    DateTime initialDate = DateTime.now();
    if (widget.controller.text.isNotEmpty) {
      try {
        // Assuming the date format in the controller is "dd/MM/yyyy"
        initialDate = DateFormat('dd/MM/yyyy').parse(widget.controller.text);
      } catch (e) {
        // If parsing fails, fall back to current date
        initialDate = DateTime.now();
      }
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Format the selected date and set it in the controller
      String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      widget.controller.text =
          formattedDate; // Update the text field with the selected date
    }
  }
}

// Widget untuk Dropdown
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
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
    // Ganti 'user_id' dengan ID pengguna yang sesuai
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
        SizedBox(height: 3),
        GestureDetector(
          onTap: () {
            _showOptionsDialog(context);
          },
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
        SizedBox(height: 16),
      ],
    );
  }

  void _showCustomModal(BuildContext context) {
    final TextEditingController _namaController = TextEditingController();
    String? selectedIcon; // Menyimpan ikon yang dipilih

    // Daftar ikon yang tersedia dalam format assets
    final List<String> iconNames = [
      'ic_snack',
      'ic_shield',
      // Tambahkan ikon lainnya di sini
    ];

    final icons = [
      {'path': 'assets/home_assets/icons/ic_snack.png', 'name': 'ic_snack'},
      {'path': 'assets/home_assets/icons/ic_shield.png', 'name': 'ic_shield'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get screen size for responsive calculations
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        // Calculate dynamic crossAxisCount based on screen width
        final crossAxisCount = (screenWidth / 100).floor().clamp(3, 5);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primaryWhite,
          child: Container(
            padding: const EdgeInsets.all(16),
            // Make dialog height and width responsive
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.4,
              minHeight: 300,
              maxWidth:
                  screenWidth * 0.45, // Ensure dialog fits within screen width
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Judul dialog
                  Text(
                    'Tambah Jenis Tugas',
                    style: AppTextStyle.semiBold.copyWith(
                      fontSize: 18,
                      color: AppColors.black100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input nama jenis tugas
                  TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Jenis Tugas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.green01),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid untuk memilih ikon
                  SizedBox(
                    // Constrain GridView height to prevent overflow
                    height: (120 * (icons.length / crossAxisCount).ceil())
                        .toDouble(),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return GridView.builder(
                          shrinkWrap:
                              true, // Prevent GridView from expanding infinitely
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                screenWidth /
                                crossAxisCount, // Adjust item width dynamically
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 1, // Square items
                          ),
                          itemCount: icons.length,
                          itemBuilder: (context, index) {
                            final icon = icons[index];
                            return buildIconSelector(
                              iconPath: icon['path']!,
                              iconName: icon['name']!,
                              isSelected: selectedIcon == icon['path'],
                              onTap: () {
                                setState(() {
                                  selectedIcon = icon['path'];
                                });
                              },
                              maxIconSize: 50.0,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol Simpan dan Batal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Batal',
                          style: AppTextStyle.medium.copyWith(
                            color: AppColors.black100,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Prevent double-tap with a simple debounce
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          final nama = _namaController.text.trim();
                          if (nama.isNotEmpty && selectedIcon != null) {
                            try {
                              final credentials = await ApiService()
                                  .loadCredentials();
                              final userId = credentials['user_id'];
                              final newTujuanId =
                                  await ApiService.storeJenisTugas(
                                    userId,
                                    nama,
                                    selectedIcon!,
                                  );

                              setState(() {
                                widget.onChanged(newTujuanId.toString());
                              });

                              Navigator.of(context).pop();

                              // Tutup dialog opsi
                              Navigator.pushReplacementNamed(
                                context,
                                '/tambah-data-tugas',
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menambahkan jenis tugas: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Harap isi nama jenis tugas dan pilih ikon',
                                ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildIconSelector({
    required String iconPath,
    required String iconName,
    required bool isSelected,
    required VoidCallback onTap,
    required double maxIconSize, // Pass maxIconSize to control scaling
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on parent constraints
        final double parentWidth = constraints.maxWidth * 0.4;

        // Responsive icon size: 15% of parent width, clamped between 24 and maxIconSize
        final double iconSize = (parentWidth * 0.8).clamp(24.0, maxIconSize);

        // Responsive font size: 30% of iconSize, clamped between 8 and 10
        final double fontSize = (iconSize * 0.3).clamp(8.0, 10.0);

        // Ensure container doesn’t exceed parent bounds, reduced for compactness
        final double containerSize = parentWidth.clamp(24.0, 48.0);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: containerSize,
            height: containerSize,
            transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.green01.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.green01 : Colors.transparent,
                width: 1.5, // Reduced border width for compactness
              ),
              borderRadius: BorderRadius.circular(6), // Slightly smaller radius
            ),
            child: ClipRect(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: iconSize,
                          maxHeight: iconSize,
                        ),
                        child: iconPath.startsWith('http')
                            ? Image.network(
                                normalizeAssetUrl(iconPath),
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.error, size: iconSize * 0.5),
                              )
                            : Image.asset(
                                iconPath,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.error, size: iconSize * 0.5),
                              ),
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      SizedBox(
                        width: containerSize * 0.85, // Slightly reduced width
                        child: Text(
                          iconName
                              .replaceAll('ic_', '')
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: fontSize,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: 2, // Adjusted for smaller container
                      right: 2,
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.green01,
                        size: iconSize * 0.30, // Smaller checkmark
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
                        _showCustomModal(context);
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomRecurrenceModal(
          onSave: (recurrenceData) {
            // Ambil data recurrence
            final days = (recurrenceData['days']?.isEmpty ?? true)
                ? 'sabtu' // Jika days kosong atau null, set default ke 'sabtu'
                : recurrenceData['days']?.join(
                    ';',
                  ); // Jika ada data, gabungkan dengan separator ';'

            // Jika recurrenceType adalah "Tidak Pernah", set repetition menjadi 0
            if (recurrenceData['type'] == 'Tidak Pernah') {
              recurrenceData['repetition'] = 0;
            }

            // Simpan data pengulangan ke SharedPreferences
            ApiService().savePengulanganTemps(
              recurrenceData['count'],
              recurrenceData['frequency'],
              days,
              recurrenceData['repetition'],
              recurrenceData['count'] * recurrenceData['repetition'],
              recurrenceData['date'] ?? '-',
            );
            Navigator.pop(context);
          },
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
  String _selectedFrequency = 'Minggu';
  int _frequencyCount = 1;
  // Key unik untuk tiap hari
  final List<Map<String, String>> _days = const [
    {'key': 'senin', 'label': 'S'},
    {'key': 'selasa', 'label': 'S'},
    {'key': 'rabu', 'label': 'R'},
    {'key': 'kamis', 'label': 'K'},
    {'key': 'jumat', 'label': 'J'},
    {'key': 'sabtu', 'label': 'S'},
    {'key': 'minggu', 'label': 'M'},
  ];

  final Set<String> _selectedDays = {};
  String _recurrenceType = 'Tidak Pernah';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _repetitionController = TextEditingController(
    text: '1',
  );

  // Palet & util kecil
  final Color _teal = const Color(0xFF00C4B4);
  final Color _outline = const Color(0xFF2EA6C4);
  final Color _card = Colors.white;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd MMMM yyyy').format(DateTime.now());
  }

  // void _selectDay(String d) {
  //   setState(() {
  //     _selectedDays.contains(d) ? _selectedDays.remove(d) : _selectedDays.add(d);
  //   });
  // }

  Future<void> _pickDate() async {
    DateTime init = DateTime.now();
    try {
      init = DateFormat('dd MMMM yyyy').parse(_dateController.text);
    } catch (_) {}
    final res = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (res != null) {
      _dateController.text = DateFormat('dd MMMM yyyy').format(res);
      setState(() {});
    }
  }

  String formatDate(String date) {
    try {
      // Parse tanggal dari format "dd MMMM yyyy" (misalnya "05 September 2025")
      DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(date);

      // Format ke "yyyy-MM-dd" (misalnya "2025-09-05")
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      // Jika terjadi error dalam parsing, kembalikan "-" sebagai fallback
      return '-';
    }
  }

  void _save() {
    final formattedDate = formatDate(_dateController.text.toString());
    widget.onSave({
      'frequency': _selectedFrequency,
      'count': _frequencyCount,
      'days': _selectedDays,
      'type': _recurrenceType,
      'date': formattedDate,
      'repetition': int.tryParse(_repetitionController.text) ?? 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Skala responsif (disain referensi 360)
        final w = c.maxWidth;
        final base = w.clamp(320, 480);
        final s = base / 360.0;

        final radiusCard = 24.0 * s;
        final titleStyle = TextStyle(
          fontSize: 16 * s,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
        final labelStyle = TextStyle(fontSize: 14 * s, color: Colors.black87);

        // final chipSize = (44 * s).clamp(36, 52).toDouble();
        // final chipText = TextStyle(fontSize: (14 * s).clamp(12, 16));
        final inputPadV = (12 * s).clamp(10, 16).toDouble();
        final inputPadH = (14 * s).clamp(12, 18).toDouble();
        final smallGap = (8 * s).toDouble();
        final gap = (12 * s).toDouble();
        final bigGap = (16 * s).toDouble();

        // Dekorasi input “pill”
        InputDecoration pillInput({Widget? suffixIcon}) => InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: inputPadV,
            horizontal: inputPadH,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * s),
            borderSide: BorderSide(color: _outline, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * s),
            borderSide: BorderSide(color: _teal, width: 2),
          ),
          suffixIcon: suffixIcon,
        );

        return Container(
          margin: EdgeInsets.all(0 * s),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(radiusCard),
            border: Border.all(color: const Color(0x1F000000)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 16 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ulangi Setiap
                Text('Ulangi Setiap', style: titleStyle),
                SizedBox(height: smallGap),
                Row(
                  children: [
                    // Box angka
                    SizedBox(
                      width: (64 * s).clamp(52, 72),
                      child: TextFormField(
                        initialValue: '$_frequencyCount',
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(
                          () => _frequencyCount = int.tryParse(v) ?? 1,
                        ),
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: pillInput(),
                      ),
                    ),
                    SizedBox(width: smallGap),
                    // Dropdown periode
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        items: const ['Minggu', 'Hari', 'Bulan', 'Tahun']
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedFrequency = v!),
                        decoration: pillInput(
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down,
                            color: _outline,
                          ),
                        ),
                        icon: const SizedBox.shrink(),
                        style: TextStyle(
                          fontSize: 14 * s,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: bigGap),

                // Ulangi Pada
                Text('Ulangi Pada', style: titleStyle),
                SizedBox(height: smallGap),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final gap = 8.0;
                    final chipSize = ((w - gap * 6) / 7).clamp(32.0, 56.0);

                    return SizedBox(
                      height: chipSize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _days.map((day) {
                          final key = day['key']!;
                          final label = day['label']!;
                          final selected = _selectedDays.contains(key);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedDays.remove(key);
                                } else {
                                  _selectedDays.add(key);
                                }
                              });
                            },
                            child: Container(
                              width: chipSize,
                              height: chipSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected ? _teal : Colors.transparent,
                                border: Border.all(color: _outline, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: (chipSize * 0.38).clamp(12, 16),
                                  color: selected ? Colors.white : _outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                SizedBox(height: bigGap),

                // Berakhir
                Text('Berakhir', style: titleStyle),
                SizedBox(height: smallGap),

                Theme(
                  data: Theme.of(context).copyWith(
                    radioTheme: RadioThemeData(
                      fillColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? _teal
                            : _outline,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: 'Tidak Pernah',
                        groupValue: _recurrenceType,
                        onChanged: (v) => setState(() => _recurrenceType = v!),
                        title: Text('Tidak Pernah', style: labelStyle),
                      ),

                      // Pada tanggal
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: 'Pada tanggal',
                        groupValue: _recurrenceType,
                        onChanged: (v) => setState(() => _recurrenceType = v!),
                        title: Row(
                          children: [
                            Text('Pada tanggal', style: labelStyle),
                            SizedBox(width: gap),
                            Flexible(
                              child: TextFormField(
                                controller: _dateController,
                                onTap: _pickDate,
                                style: TextStyle(fontSize: 14 * s),
                                decoration: pillInput(
                                  suffixIcon: IconButton(
                                    onPressed: _pickDate,
                                    icon: Icon(
                                      Icons.calendar_today,
                                      size: 18 * s,
                                      color: _outline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Setelah n kekerapan
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: 'Setelah',
                        groupValue: _recurrenceType,
                        onChanged: (v) => setState(() => _recurrenceType = v!),
                        title: Row(
                          children: [
                            Text('Setelah', style: labelStyle),
                            SizedBox(width: gap),
                            SizedBox(
                              width: (64 * s).clamp(52, 72),
                              child: TextFormField(
                                controller: _repetitionController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16 * s,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: pillInput(),
                              ),
                            ),
                            SizedBox(width: gap),
                            Text('kekerapan', style: labelStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: bigGap),

                // Tombol gradien Lanjutkan
                SizedBox(
                  width: double.infinity,
                  height: (48 * s).clamp(44, 56),
                  child: OnboardingButton(
                    previous: false,
                    text: "Lanjutkan",
                    width: double.infinity,
                    height: 30,
                    onClick: _save,
                  ),
                ),
              ],
            ),
          ),
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
                    'Tambah Data Tugas',
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
class TambahDataTugasPage extends StatefulWidget {
  const TambahDataTugasPage({super.key});

  @override
  TambahDataTugasPageState createState() => TambahDataTugasPageState();
}

class TambahDataTugasPageState extends State<TambahDataTugasPage> {
  final TextEditingController _waktuPerawatanController =
      TextEditingController();
  final TextEditingController _tanggalPerawatanController =
      TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  List<Map<String, dynamic>> _optionsJenisTugas =
      []; // Menyimpan options di state lokal
  List<Map<String, dynamic>> _optionsPengulanganTugas =
      []; // Menyimpan options di state lokal
  List<Map<String, dynamic>> _optionsStatusTugas =
      []; // Menyimpan options di state lokal

  final ApiService _apiService = ApiService();
  String userId = '';

  String _selectedTugas = '';
  String _selectedStatus = '';
  String _selectedPengulangan = '1'; // Default ke "Tidak Pernah" (id: 1)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Mendapatkan daftar jenis tugas dari API
  Future<void> loadUserId() async {
    final credential = await _apiService.loadCredentials();
    userId = credential['user_id'];
  }

  Future<void> _saveData() async {
    // Validasi minimal sebelum kirim
    if (_selectedTugas.isEmpty ||
        _selectedStatus.isEmpty ||
        _selectedPengulangan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih jenis tugas, status, dan pengulangan terlebih dahulu',
          ),
        ),
      );
      return;
    }

    if (_tanggalPerawatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal tugas belum diisi')),
      );
      return;
    }

    if (_waktuPerawatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Waktu tugas belum diisi')));
      return;
    }

    // Mengonversi nilai yang dipilih menjadi int
    final jenisTugasId =
        int.tryParse(_selectedTugas) ?? 1; // Default ke 0 jika invalid
    final statusTugasId =
        int.tryParse(_selectedStatus) ?? 1; // Default ke 0 jika invalid
    final pengulanganId =
        int.tryParse(_selectedPengulangan) ?? 1; // Default ke 0 jika invalid

    // Pastikan nilai yang dipilih valid (bukan null atau empty)
    if (jenisTugasId == 0 || statusTugasId == 0 || pengulanganId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pastikan semua pilihan sudah diisi dengan benar'),
        ),
      );
      return;
    }

    // Mengonversi tglTugas dari dd/MM/yyyy menjadi yyyy-MM-dd
    final tglTugasInput = _tanggalPerawatanController.text.trim();
    DateTime? parsedTglTugas;
    try {
      parsedTglTugas = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(tglTugasInput); // Parse ke DateTime
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tanggal salah! Harus dd/MM/yyyy')),
      );
      return;
    }

    // Menyiapkan data untuk dikirim
    final waktuTugas = _waktuPerawatanController.text;
    final formattedWaktuTugas = (waktuTugas.length == 5)
        ? "$waktuTugas:00"
        : waktuTugas;
    final catatan = _catatanController.text;
    final isPengingat = true; // Atur sesuai input

    setState(() => _isLoading = true);
    try {
      // Memanggil API untuk menyimpan tugas
      final ok = await _apiService.storeTugas(
        context: context,
        userId: userId,
        jenisTugasId: jenisTugasId,
        tglTugas: parsedTglTugas.toString(),
        waktuTugas: formattedWaktuTugas,
        statusTugasId: statusTugasId,
        catatan: catatan,
        pengulanganId: pengulanganId,
        isPengingat: isPengingat,
      );

      setState(() => _isLoading = false);

      if (ok) {
        // Sukses → pindah halaman
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/list-data-ternak-tugas',
          arguments: {'initialIndex': 1},
        );
      } else {
        // Harusnya tidak terjadi karena ok hanya true saat 201
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data tugas')),
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

  Future<void> _loadAllData() async {
    try {
      // Jalankan semua Future secara paralel dan tunggu hingga selesai
      await Future.wait([
        _getJenisTugas(),
        _getPengulanganTugas(),
        _getStatusTugas(),
      ]);

      // Setelah semua Future selesai, ubah _isLoading menjadi false
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Tangani error jika ada
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getJenisTugas() async {
    await loadUserId();
    final options = await _apiService.getJenisTugasListByUserId(userId);
    setState(() {
      _optionsJenisTugas = options;
    });
  }

  Future<void> _getPengulanganTugas() async {
    await loadUserId();
    final options = await _apiService.getPengulanganTugas();
    setState(() {
      _optionsPengulanganTugas = options;
    });
  }

  Future<void> _getStatusTugas() async {
    await loadUserId();
    final options = await _apiService.getStatusTugas();
    setState(() {
      _optionsStatusTugas = options;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: TernakProBoxLoading()));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.12,
        ),
        child: _buildHeaderSection(
          context,
        ), // Menggunakan header yang sudah dibuat
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Peternakan
            CustomDropdownInputTernak(
              label: 'Jenis Tugas Perawatan',
              hintText: 'Pilih jenis tugas',
              options: _optionsJenisTugas, // Contoh pilihan
              selectedValue: _selectedTugas,
              onChanged: (value) => setState(() => _selectedTugas = value),
            ),

            Row(
              children: [
                // Tanggal Mulai
                Expanded(
                  child: CustomInputTugasField(
                    label: 'Tanggal Perawatan',
                    hintText: 'HH/BB/TTTT',
                    controller: _tanggalPerawatanController,
                    isCalendar: true,
                    isClock: false,
                  ),
                ),

                SizedBox(width: 8),

                // Pilih Ras
                Expanded(
                  child: CustomInputTugasField(
                    label: 'Waktu',
                    hintText: '06:00',
                    controller: _waktuPerawatanController,
                    isCalendar: false,
                    isClock: true,
                  ),
                ),
              ],
            ),

            // Nama Peternakan
            CustomDropdownInputTernak(
              label: 'Status Perawatan',
              hintText: 'Pilih Salah Satu',
              options: _optionsStatusTugas,
              selectedValue: _selectedStatus,
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),

            // Nama Peternakan
            CustomDropdownInputTernak(
              label: 'Jenis Tugas Perawatan',
              hintText: 'Pilih jenis tugas',
              options: _optionsPengulanganTugas,
              selectedValue: _selectedPengulangan,
              onChanged: (value) =>
                  setState(() => _selectedPengulangan = value),
            ),

            // Catatan (Opsional)
            CustomInputTugasField(
              label: 'Catatan (Opsional)',
              hintText: 'Tambahkan catatan jika diperlukan',
              controller: _catatanController,
              maxLines: 4,
              isCalendar: false,
              isClock: false,
            ),

            // Simpan Button
            OnboardingButton(
              previous: false,
              text: "Simpan",
              width: double.infinity,
              onClick: _saveData,
            ),
          ],
        ),
      ),
    );
  }
}
