class DailyTaskItem {
  final int idTugas;
  final String title;
  final String status;
  final int statusId;
  final String catatan;
  final String time;
  final String tglTugas;
  final String iconPath;

  DailyTaskItem({
    required this.idTugas,
    required this.title,
    required this.status,
    required this.statusId,
    required this.catatan,
    required this.time,
    required this.tglTugas,
    required this.iconPath,
  });

  // Fungsi untuk membuat objek DailyTaskItem dari JSON
  factory DailyTaskItem.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        json['status_tugas'] ?? json['status'] ?? json['status_tugas_name'];
    final parsedStatus = rawStatus is Map
        ? (rawStatus['nama'] ?? rawStatus['name'] ?? '').toString()
        : rawStatus?.toString() ?? '';
    final status = switch (parsedStatus.toLowerCase()) {
      'sudah' || 'selesai' || 'completed' => 'Sudah',
      'tertunda' || 'pending' => 'Tertunda',
      'belum' || 'belum selesai' || 'incomplete' => 'Belum',
      _ => parsedStatus,
    };

    return DailyTaskItem(
      idTugas: int.tryParse(json['id_tugas'].toString()) ?? 0,
      title: json['nama_tugas']?.toString() ?? 'No Title',
      statusId: int.tryParse(json['status_tugas_id'].toString()) ?? 0,
      status: status.isEmpty ? 'Belum' : status,
      time: json['waktu_tugas']?.toString() ?? 'No Time',
      tglTugas: json['tgl_tugas']?.toString() ?? '2025-01-01',
      catatan: json['catatan']?.toString() ?? '',
      iconPath: json['icon_path'] ?? 'assets/home_assets/icons/ic_default.png',
    );
  }

  // Fungsi untuk mengonversi DailyTaskItem kembali ke Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id_tugas': idTugas,
      'nama_tugas': title,
      'status_tugas_id': statusId,
      'status_tugas': status,
      'catatan': catatan,
      'waktu_tugas': time,
      'tgl_tugas': tglTugas,
      'icon_path': iconPath,
    };
  }
}
