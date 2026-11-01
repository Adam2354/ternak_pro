class KeuanganItem {
  final int idKeuangan;
  final bool isPengeluaran;
  final int nominalTotal;
  final String dariTujuan;
  final int asetId;
  final String namaAset;
  final DateTime tglKeuangan;
  final String catatan;

  KeuanganItem({
    required this.idKeuangan,
    required this.isPengeluaran,
    required this.nominalTotal,
    required this.dariTujuan,
    required this.asetId,
    required this.namaAset,
    required this.tglKeuangan,
    required this.catatan,
  });

  factory KeuanganItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, String fieldName, {int fallback = 0}) {
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
      if (fieldName == 'id_keuangan') {
        throw FormatException('Field $fieldName tidak tersedia');
      }
      return fallback;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      return value?.toString().toLowerCase() == 'true' ||
          value?.toString() == '1';
    }

    final rawDate = json['tgl_keuangan']?.toString();
    if (rawDate == null || rawDate.isEmpty) {
      throw const FormatException('Field tgl_keuangan tidak tersedia');
    }

    return KeuanganItem(
      idKeuangan: parseInt(json['id_keuangan'] ?? json['id'], 'id_keuangan'),
      isPengeluaran: parseBool(json['is_pengeluaran']),
      nominalTotal: parseInt(json['nominal_total'], 'nominal_total'),
      dariTujuan: json['dari_tujuan']?.toString() ?? '',
      asetId: parseInt(json['aset_id'], 'aset_id'),
      namaAset: json['nama_aset']?.toString() ?? '',
      tglKeuangan: DateTime.parse(rawDate),
      catatan: json['catatan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_keuangan': idKeuangan,
      'is_pengeluaran': isPengeluaran,
      'nominal_total': nominalTotal,
      'dari_tujuan': dariTujuan,
      'aset_id': asetId,
      'nama_aset': namaAset,
      'tgl_keuangan': tglKeuangan.toIso8601String(),
      'catatan': catatan,
    };
  }
}
