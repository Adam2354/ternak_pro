import 'package:flutter/material.dart';

import '../../../models/DailyTaskItem.dart';
import '../../../services/api_service.dart';
import '../../custom_loading.dart';
import '../../theme.dart';
import '../custom_image_view.dart';
import '../data_ternak/show_tugas_edit_modal.dart';
import '../onboarding_buttom.dart';

Widget buildDailyTasks(
  BuildContext context,
  List<DailyTaskItem>? tasks,
  bool isLoading, {
  Future<bool> Function(DailyTaskItem task)? onDelete,
}) {
  return Container(
    margin: EdgeInsets.only(left: 24, right: 24, top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Hari Ini',
              style: AppTextStyle.semiBold.copyWith(fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/list-data-ternak-tugas',
                  arguments: {'initialIndex': 1},
                );
              },
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: AppTextStyle.semiBold.copyWith(
                      color: AppColors.green01,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isLoading) Center(child: TernakProBoxLoading()),
        if (tasks == null || tasks.isEmpty && !isLoading) SizedBox(height: 8),
        if (tasks == null || tasks.isEmpty && !isLoading)
          Container(
            padding: EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.green02,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomImageView(
                      imagePath: "assets/home_assets/icons/ic_task.png",
                      height: 36,
                      width: 36,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Belum Ada Tugas',
                  style: AppTextStyle.semiBold.copyWith(
                    color: AppColors.blackText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...tasks.map(
            (task) => buildTaskItem(context, task, onDelete: onDelete),
          ),
        SizedBox(height: 16),
        // GestureDetector(
        //   onTap: () {
        //     Navigator.pushNamed(context, '/tambah-data-tugas');
        //   },
        //   child: Container(
        //     width: double.infinity,
        //     padding: EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       gradient: AppColors.gradasi01WithOpacity20,
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         CustomImageView(
        //             imagePath: "assets/home_assets/icons/ic_plus.png",
        //             height: 20,
        //             width: 20,
        //           ),
        //           SizedBox(width: 4),
        //           Text(
        //             'Tambah Tugas',
        //             style: AppTextStyle.semiBold.copyWith(
        //               color: AppColors.black100,
        //               fontSize: 12,
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),
        OnboardingButton(
          previous: false,
          text: "+ Tambah Tugas",
          width: double.infinity,
          onClick: () => Navigator.pushNamed(context, '/tambah-data-tugas'),
        ),
      ],
    ),
  );
}

Widget buildTaskItem(
  BuildContext context,
  DailyTaskItem task, {
  Future<bool> Function(DailyTaskItem task)? onDelete,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double iconSize = (maxWidth * 0.07).clamp(
        24.0,
        36.0,
      ); // Responsif untuk ukuran ikon
      double fontSizeSmall = (maxWidth * 0.04).clamp(
        12.0,
        14.0,
      ); // Responsif untuk font

      return InkWell(
        onTap: () {
          showTugasEditModal(
            context,
            idTugas: task.idTugas,
            title: task.title,
            status: task.status,
            statusId: task.statusId,
            time: task.time,
            iconPath: task.iconPath,
            catatan: task.catatan,
            tglTugas: task.tglTugas, // Added
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
                      idTugas: task.idTugas,
                      userId: userId,
                      statusTugasId: statusId,
                      waktuTugas: formattedWaktuTugas,
                      catatan: catatan,
                      tglTugas: tglTugas, // Added
                      isHome: true,
                    );

                    // Debugging output
                    debugPrint(
                      'SAVE -> idTugas:${task.idTugas} title:${task.title} status:$status time:$time catatan:$catatan tglTugas:$tglTugas',
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
                        content: Text(
                          'Gagal memperbarui tugas: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
          );
        },
        child: Container(
          margin: EdgeInsets.only(top: 8),
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
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradasi01WithOpacity20,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomImageView(
                        imagePath: task.iconPath,
                        height: iconSize * 0.8,
                        width: iconSize * 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: fontSizeSmall,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            task.status == 'Sudah'
                                ? 'assets/home_assets/icons/ic_check_green.png'
                                : 'assets/home_assets/icons/ic_check_yellow.png',
                            width: 12,
                            height: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            task.status,
                            style: AppTextStyle.semiBold.copyWith(
                              fontSize: fontSizeSmall,
                              color: task.status == 'Tertunda'
                                  ? AppColors.yellow500
                                  : (task.status == 'Belum'
                                        ? AppColors.primaryRed
                                        : (task.status == 'Sudah'
                                              ? AppColors.green01
                                              : AppColors.primaryRed)),
                            ),
                          ),
                          SizedBox(width: 10),
                          Image.asset(
                            'assets/home_assets/icons/ic_dropdown.png',
                            width: 14,
                            height: 14,
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
                    task.status == 'Sudah'
                        ? 'assets/home_assets/icons/ic_clock_green.png'
                        : 'assets/home_assets/icons/ic_clock_red.png',
                    width: 12,
                    height: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    task.time,
                    style: AppTextStyle.medium.copyWith(
                      fontSize: fontSizeSmall,
                      color:
                          (task.status == 'Tertunda' || task.status == 'Belum')
                          ? AppColors.primaryRed
                          : (task.status == 'Sudah'
                                ? AppColors.green01
                                : AppColors.primaryRed),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: 'Menu tugas',
                    onSelected: (value) async {
                      if (value == 'delete' && onDelete != null) {
                        await onDelete(task);
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
    },
  );
}
