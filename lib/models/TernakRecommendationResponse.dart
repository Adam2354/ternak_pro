class TernakRecommendationResponse {
  final bool success;
  final String message;
  final String method;
  final String mode;
  final List<TernakRecommendationItem> recommendations;

  const TernakRecommendationResponse({
    required this.success,
    required this.message,
    required this.method,
    required this.mode,
    required this.recommendations,
  });

  factory TernakRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final rawRecommendations = data['recommendations'];
    final recommendations = rawRecommendations is List
        ? rawRecommendations
              .whereType<Map>()
              .map(
                (item) => TernakRecommendationItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <TernakRecommendationItem>[];

    return TernakRecommendationResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      method:
          data['method']?.toString() ?? json['method']?.toString() ?? 'VIKOR',
      mode: data['mode']?.toString() ?? json['mode']?.toString() ?? 'pure',
      recommendations: recommendations,
    );
  }
}

class TernakRecommendationItem {
  final int? index;
  final int? ranking;
  final String ternak;
  final String jenisHewan;
  final double qValue;
  final double? qValuePure;
  final bool feasible;
  final num modalMinimum;
  final num modalMinimalRealistis;
  final num modalAman;
  final num lahanMinimum;
  final num waktuPerawatan;
  final num pengalamanMinimum;
  final num roi;
  final num biayaAwal;
  final num biayaPerEkor;
  final num potensiKeuntungan;
  final String alasan;
  final String deskripsi;
  final List<String> kebutuhanPakan;
  final List<String> tips;
  final int estimasiEkor;
  final num modalEfektif;
  final num modalTerpakaiEstimasi;
  final num sisaModalEstimasi;
  final num kapasitasLahanEstimasi;
  final num minEkorMinimum;
  final num kecocokanKapasitasPersen;
  final String statusKelayakan;
  final num biayaKandangEstimasi;
  final num biayaVariabelPerEkor;
  final num biayaKandangTambahanPerEkor;
  final num biayaPerEkorEstimasi;
  final Map<String, dynamic> breakdownPerEkor;
  final Map<String, dynamic> breakdownTotalEstimasi;
  final Map<String, dynamic> breakdownBiaya;
  final num sisaModal;
  final num estimasiModal;
  final num estimasiBiayaPerEkor;
  final num potensiKeuntunganPerEkor;
  final num potensiKeuntunganTotal;
  final Map<String, dynamic> vikorDebug;

  const TernakRecommendationItem({
    required this.index,
    required this.ranking,
    required this.ternak,
    required this.jenisHewan,
    required this.qValue,
    required this.qValuePure,
    required this.feasible,
    required this.modalMinimum,
    required this.modalMinimalRealistis,
    required this.modalAman,
    required this.lahanMinimum,
    required this.waktuPerawatan,
    required this.pengalamanMinimum,
    required this.roi,
    required this.biayaAwal,
    required this.biayaPerEkor,
    required this.potensiKeuntungan,
    required this.alasan,
    required this.deskripsi,
    required this.kebutuhanPakan,
    required this.tips,
    required this.estimasiEkor,
    required this.modalEfektif,
    required this.modalTerpakaiEstimasi,
    required this.sisaModalEstimasi,
    required this.kapasitasLahanEstimasi,
    required this.minEkorMinimum,
    required this.kecocokanKapasitasPersen,
    required this.statusKelayakan,
    required this.biayaKandangEstimasi,
    required this.biayaVariabelPerEkor,
    required this.biayaKandangTambahanPerEkor,
    required this.biayaPerEkorEstimasi,
    required this.breakdownPerEkor,
    required this.breakdownTotalEstimasi,
    required this.breakdownBiaya,
    required this.sisaModal,
    required this.estimasiModal,
    required this.estimasiBiayaPerEkor,
    required this.potensiKeuntunganPerEkor,
    required this.potensiKeuntunganTotal,
    required this.vikorDebug,
  });

  factory TernakRecommendationItem.fromJson(Map<String, dynamic> json) {
    List<String> _stringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return const [];
    }

    Map<String, dynamic> _map(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return <String, dynamic>{};
    }

    num _num(dynamic value, [num fallback = 0]) {
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return TernakRecommendationItem(
      index: json['index'] is num
          ? (json['index'] as num).toInt()
          : int.tryParse(json['index']?.toString() ?? ''),
      ranking: json['ranking'] is num
          ? (json['ranking'] as num).toInt()
          : int.tryParse(json['ranking']?.toString() ?? ''),
      ternak:
          json['ternak']?.toString() ?? json['jenis_hewan']?.toString() ?? '',
      jenisHewan:
          json['jenis_hewan']?.toString() ?? json['ternak']?.toString() ?? '',
      qValue: _num(json['q_value'], 1.0).toDouble(),
      qValuePure: json['q_value_pure'] == null
          ? null
          : _num(json['q_value_pure']).toDouble(),
      feasible: json['feasible'] == true,
      modalMinimum: _num(json['modal_minimum']),
      modalMinimalRealistis: _num(json['modal_minimal_realistis']),
      modalAman: _num(json['modal_aman']),
      lahanMinimum: _num(json['lahan_minimum']),
      waktuPerawatan: _num(json['waktu_perawatan']),
      pengalamanMinimum: _num(json['pengalaman_minimum']),
      roi: _num(json['roi']),
      biayaAwal: _num(json['biaya_awal']),
      biayaPerEkor: _num(json['biaya_per_ekor']),
      potensiKeuntungan: _num(json['potensi_keuntungan']),
      alasan: json['alasan']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      kebutuhanPakan: _stringList(json['kebutuhan_pakan']),
      tips: _stringList(json['tips']),
      estimasiEkor: _num(json['estimasi_ekor']).toInt(),
      modalEfektif: _num(json['modal_efektif']),
      modalTerpakaiEstimasi: _num(json['modal_terpakai_estimasi']),
      sisaModalEstimasi: _num(json['sisa_modal_estimasi']),
      kapasitasLahanEstimasi: _num(json['kapasitas_lahan_estimasi']),
      minEkorMinimum: _num(json['min_ekor_minimum']),
      kecocokanKapasitasPersen: _num(json['kecocokan_kapasitas_persen']),
      statusKelayakan: json['status_kelayakan']?.toString() ?? '',
      biayaKandangEstimasi: _num(json['biaya_kandang_estimasi']),
      biayaVariabelPerEkor: _num(json['biaya_variabel_per_ekor']),
      biayaKandangTambahanPerEkor: _num(
        json['biaya_kandang_tambahan_per_ekor'],
      ),
      biayaPerEkorEstimasi: _num(json['biaya_per_ekor_estimasi']),
      breakdownPerEkor: _map(json['breakdown_per_ekor']),
      breakdownTotalEstimasi: _map(json['breakdown_total_estimasi']),
      breakdownBiaya: _map(json['breakdown_biaya']),
      sisaModal: _num(json['sisa_modal']),
      estimasiModal: _num(json['estimasi_modal']),
      estimasiBiayaPerEkor: _num(json['estimasi_biaya_per_ekor']),
      potensiKeuntunganPerEkor: _num(json['potensi_keuntungan_per_ekor']),
      potensiKeuntunganTotal: _num(json['potensi_keuntungan_total']),
      vikorDebug: _map(json['vikor_debug']),
    );
  }
}
