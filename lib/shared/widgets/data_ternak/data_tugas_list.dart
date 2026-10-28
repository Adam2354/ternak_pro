import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../theme.dart';
import '../custom_image_view.dart';
import 'show_tugas_edit_modal.dart';

class CustomTugasItem extends StatelessWidget {
  final String title;
  final int idTugas;
  final int statusId;
  final String status;
  final String catatan;
  final String time;
  final String iconPath;
  final String tglTugas; // Added
  final Future<bool> Function() onDelete;

  const CustomTugasItem({
    super.key,
    required this.title,
    required this.status,
    required this.statusId,
    required this.time,
    required this.iconPath,
    required this.catatan,
    required this.idTugas,
    required this.tglTugas, // Added
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showTugasEditModal(
          context,
          idTugas: idTugas,
          title: title,
          status: status,
          statusId: statusId,
          time: time,
          iconPath: iconPath,
          catatan: catatan,
          tglTugas: tglTugas, // Added
          onSave:
              ({
                required String status,
                required int statusId,
                required String time,
                required String catatan,
                required String tglTugas, // Added
              }) async {
                try {
                  // Load credentials (e.g., user_id) for the API call
                  final credentials = await ApiService().loadCredentials();
                  final userId = credentials['user_id'];

                  final formattedWaktuTugas = "$time:00";

                  // Call API to update the task
                  await ApiService().updateDataTugas(
                    context: context,
                    idTugas: idTugas,
                    userId: userId,
                    statusTugasId: statusId,
                    waktuTugas: formattedWaktuTugas,
                    catatan: catatan,
                    tglTugas: tglTugas, // Added
                    isHome: false,
                  );

                  // Debugging output
                  debugPrint(
                    'SAVE -> idTugas:$idTugas title:$title status:$status time:$time catatan:$catatan tglTugas:$tglTugas',
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tugas berhasil diperbarui'),
                      backgroundColor: AppColors.green01,
                    ),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui tugas: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 8, left: 16, right: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradasi01WithOpacity20,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomImageView(
                      imagePath: iconPath,
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.semiBold.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          status == 'Sudah'
                              ? 'assets/home_assets/icons/ic_check_green.png'
                              : 'assets/home_assets/icons/ic_check_yellow.png',
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          status,
                          style: AppTextStyle.semiBold.copyWith(
                            fontSize: 12,
                            color: status == 'Tertunda'
                                ? AppColors.yellow500
                                : (status == 'Belum'
                                      ? AppColors.primaryRed
                                      : (status == 'Sudah'
                                            ? AppColors.green01
                                            : AppColors.primaryRed)),
                            // Gunakan warna default jika status tidak cocok
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {},
                          child: Image.asset(
                            'assets/home_assets/icons/ic_dropdown.png',
                            width: 14,
                            height: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Image.asset(
                  status == 'Sudah'
                      ? 'assets/home_assets/icons/ic_clock_green.png'
                      : 'assets/home_assets/icons/ic_clock_red.png',
                  width: 12,
                  height: 12,
                ),
                SizedBox(width: 4),
                Text(
                  time,
                  style: AppTextStyle.medium.copyWith(
                    fontSize: 12,
                    color: (status == 'Tertunda' || status == 'Belum')
                        ? AppColors.primaryRed
                        : (status == 'Sudah'
                              ? AppColors.green01
                              : AppColors
                                    .primaryRed), // Gunakan warna default jika status tidak cocok
                  ),
                ),
                // SizedBox(width: 2),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: 'Menu tugas',
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
}
