import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme.dart';
import '../custom_image_view.dart';

Widget _buildTaskIcon(String iconPath) {
  final resolvedPath = normalizeAssetUrl(iconPath);
  final isNetworkImage =
      resolvedPath.startsWith('http://') || resolvedPath.startsWith('https://');

  return isNetworkImage
      ? Image.network(resolvedPath, width: 40, height: 40, fit: BoxFit.contain)
      : Image.asset(resolvedPath, width: 40, height: 40, fit: BoxFit.contain);
}

Future<Map<String, dynamic>?> showTugasEditModal(
  BuildContext context, {
  required String title,
  required int idTugas,
  required String status,
  required int statusId,
  required String catatan,
  required String time, // format "HH:mm"
  required String iconPath,
  required String tglTugas,
  required void Function({
    required String status,
    required int statusId,
    required String time,
    required String catatan,
    required String tglTugas,
  })
  onSave,
}) async {
  // Format date for display (e.g., dd/MM/yyyy)
  String formatDisplayDate(String? date) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date ?? '');
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  ValueNotifier<String> statusNotifier = ValueNotifier(status);
  ValueNotifier<String> timeNotifier = ValueNotifier(time);
  ValueNotifier<String> tglTugasNotifier = ValueNotifier(
    formatDisplayDate(tglTugas),
  );
  TextEditingController catatanController = TextEditingController(
    text: catatan,
  );

  final Color teal = const Color(0xFF00C4B4);
  final Color tealDark = const Color(0xFF089E96);
  final Color border = const Color(0xFF00C4B4);

  // Format date for submission (e.g., yyyy-MM-dd)
  String _formatSubmissionDate(String? date) {
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(date ?? '');
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  // Dialog option item
  Widget _buildDialogOption(
    String value,
    ValueNotifier<String> statusNotifier,
  ) {
    return GestureDetector(
      onTap: () {
        statusNotifier.value = value;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Image.asset(
              value == 'Sudah'
                  ? 'assets/home_assets/icons/ic_check_green.png'
                  : (value == 'Tertunda'
                        ? 'assets/home_assets/icons/ic_check_yellow.png'
                        : 'assets/home_assets/icons/ic_check_yellow.png'),
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 10),
            Text(
              value,
              style: AppTextStyle.medium.copyWith(
                fontSize: 16,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the custom dropdown dialog
  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: 150,
            child: Column(
              children: <Widget>[
                _buildDialogOption('Tertunda', statusNotifier),
                _buildDialogOption('Sudah', statusNotifier),
                _buildDialogOption('Belum', statusNotifier),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _pillInput({Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border, width: 1.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: teal, width: 2),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final init = () {
      try {
        final parts = timeNotifier.value.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (_) {
        return now;
      }
    }();
    final picked = await showTimePicker(context: context, initialTime: init);
    if (picked != null) {
      final dt = DateTime(0, 1, 1, picked.hour, picked.minute);
      timeNotifier.value = DateFormat('HH:mm').format(dt);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = () {
      try {
        return DateFormat('yyyy-MM-dd').parse(tglTugas);
      } catch (_) {
        return now;
      }
    }();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      tglTugasNotifier.value = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  await showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(89),
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
                // Tombol close
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
                // Icon header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: _buildTaskIcon(iconPath)),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black100,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Label: Status Perawatan
                Text(
                  'Status Perawatan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Status perawatan (custom dialog)
                ValueListenableBuilder<String>(
                  valueListenable: statusNotifier,
                  builder: (context, status, _) {
                    return GestureDetector(
                      onTap: () => _showCustomDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: teal),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              status == 'Sudah'
                                  ? 'assets/home_assets/icons/ic_check_green.png'
                                  : (status == 'Tertunda'
                                        ? 'assets/home_assets/icons/ic_check_yellow.png'
                                        : 'assets/home_assets/icons/ic_check_yellow.png'),
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.black100,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                // Label: Tanggal Tugas
                Text(
                  'Tanggal Tugas',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Input: Tanggal Tugas
                ValueListenableBuilder<String>(
                  valueListenable: tglTugasNotifier,
                  builder: (context, tglTugas, _) {
                    return TextFormField(
                      controller: TextEditingController(text: tglTugas),
                      readOnly: true,
                      onTap: () => _pickDate(context),
                      decoration: _pillInput(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _pickDate(context),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                // Label: Waktu
                Text(
                  'Waktu',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Input: Waktu
                ValueListenableBuilder<String>(
                  valueListenable: timeNotifier,
                  builder: (context, time, _) {
                    return TextFormField(
                      controller: TextEditingController(text: time),
                      readOnly: true,
                      onTap: () => _pickTime(context),
                      decoration: _pillInput(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.schedule),
                          onPressed: () => _pickTime(context),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                // Label: Catatan (Opsional)
                Text(
                  'Catatan (Opsional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Catatan
                TextField(
                  controller: catatanController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan jika diperlukan',
                    contentPadding: EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // Tombol simpan gradien
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _GradientButton(
                      text: 'Simpan Perubahan',
                      start: teal,
                      end: tealDark,
                      radius: 16,
                      onTap: () {
                        onSave(
                          status: statusNotifier.value,
                          statusId: statusNotifier.value == 'Belum'
                              ? 1
                              : (statusNotifier.value == 'Tertunda' ? 2 : 3),
                          time: timeNotifier.value,
                          catatan: catatanController.text.trim(),
                          tglTugas: _formatSubmissionDate(
                            tglTugasNotifier.value,
                          ),
                        );
                        final updatedData = {
                          'id_tugas': idTugas,
                          'title': title,
                          'status': statusNotifier.value,
                          'status_id': statusNotifier.value == 'Belum'
                              ? 1
                              : (statusNotifier.value == 'Tertunda' ? 2 : 3),
                          'catatan': catatanController.text.trim(),
                          'time': timeNotifier.value,
                          'icon_path': iconPath,
                          'tgl_tugas': _formatSubmissionDate(
                            tglTugasNotifier.value,
                          ),
                        };
                        Navigator.of(context).pop(updatedData);
                      },
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

  return null;
}

class _GradientButton extends StatelessWidget {
  final String text;
  final Color start, end;
  final double radius;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    required this.start,
    required this.end,
    required this.onTap,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [start, end]),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
