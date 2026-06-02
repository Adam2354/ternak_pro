import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/theme.dart';

class HasilRekomendasiTernakPage extends StatelessWidget {
  final Map<String, dynamic> recommendationData;
  final double userModal;

  const HasilRekomendasiTernakPage({
    super.key,
    required this.recommendationData,
    required this.userModal,
  });

  String _formatCurrency(dynamic value) {
    final number = value is num
        ? value.toInt()
        : double.tryParse(value.toString())?.toInt() ?? 0;
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  String _formatWaktu(dynamic value) {
    switch (int.tryParse(value.toString()) ?? 0) {
      case 1:
        return '< 1 jam/hari';
      case 2:
        return '1 - 2 jam/hari';
      case 3:
        return '2 - 4 jam/hari';
      case 4:
        return '4 - 6 jam/hari';
      case 5:
        return '> 6 jam/hari';
      default:
        return '-';
    }
  }

  String _formatPengalaman(dynamic value) {
    switch (int.tryParse(value.toString()) ?? 0) {
      case 1:
        return 'Belum Pernah / Pemula';
      case 2:
        return 'Kurang 1 Tahun';
      case 3:
        return '1 - 3 Tahun';
      case 4:
        return '3 - 5 Tahun';
      case 5:
        return '> 5 Tahun';
      default:
        return '-';
    }
  }

  String _formatLahan(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    return '$number m²';
  }

  String _resolveTernakImagePath(String ternak) {
    final normalized = ternak.toLowerCase();

    if (normalized.contains('ayam')) {
      return 'assets/Ayam Petelur.jpg';
    }

    if (normalized.contains('sapi') || normalized.contains('lembu')) {
      return 'assets/Sapi Limosin.jpg';
    }

    if (normalized.contains('kambing') || normalized.contains('etawa')) {
      return 'assets/kambing Etawa.jpg';
    }

    if (normalized.contains('bebek') || normalized.contains('itik')) {
      return 'assets/Bebek Petelur.jpg';
    }

    if (normalized.contains('domba')) {
      return 'assets/Domba Ternak.jpg';
    }

    return 'assets/Sapi Limosin.jpg';
  }

  Widget _buildTernakImageSection(
    Map<String, dynamic> item,
    Color accentColor,
  ) {
    final String ternak =
        item['ternak']?.toString() ??
        item['jenis_hewan']?.toString() ??
        'Ternak';
    final String? imageUrl = item['image_url']?.toString();
    final String fallbackAsset = _resolveTernakImagePath(ternak);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: accentColor.withOpacity(0.08),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    );
                  },
                )
              else
                Image.asset(
                  fallbackAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.30),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        ternak,
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 12,
                          color: AppColors.blackText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Foto Ternak',
                        style: AppTextStyle.semiBold.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parseNumber(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  dynamic _resolveValue(
    Map<String, dynamic> item,
    List<String> keys, [
    dynamic fallback = 0,
  ]) {
    for (final key in keys) {
      final value = item[key];
      if (value != null &&
          value.toString().isNotEmpty &&
          value.toString() != '0') {
        return value;
      }
    }

    return fallback;
  }

  String _formatEstimateCount(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    if (number <= 0) {
      return '-';
    }
    return '$number ekor';
  }

  Widget _buildCostBreakdownSection(
    Map<String, dynamic> item,
    bool modalCukup,
  ) {
    final breakdown = item['breakdown_biaya'];
    final breakdownMap = breakdown is Map
        ? Map<String, dynamic>.from(breakdown)
        : <String, dynamic>{};

    final biayaTotalPerEkor = _resolveValue(item, [
      'biaya_per_ekor_estimasi',
      'estimasi_biaya_per_ekor',
      'biaya_total_per_ekor',
      'modal_minimum',
      'biaya_awal',
      'modal_awal',
      'biaya',
    ]);

    final estimasiEkor = item['estimasi_ekor'] ?? 0;
    final dynamic sisaModalRaw = item['sisa_modal'];

    double? sisaModal;
    if (sisaModalRaw != null) {
      sisaModal = (sisaModalRaw is num)
          ? sisaModalRaw.toDouble()
          : double.tryParse(sisaModalRaw.toString());
    }

    // If API didn't provide sisa_modal or it's zero, compute a fallback
    // using user provided modal minus estimated total cost.
    // Prefer sum(breakdown_biaya) as biaya per ekor when available.
    double biayaPerEkor = 0.0;
    if (breakdownMap.isNotEmpty) {
      double sum = 0.0;
      breakdownMap.forEach((_, v) {
        if (v is num) {
          sum += v.toDouble();
        } else {
          sum += double.tryParse(v.toString()) ?? 0.0;
        }
      });

      final estEkor = int.tryParse(estimasiEkor.toString()) ?? 0;
      // Two interpretations:
      // A) breakdown values already per-ekor -> candidateA = sum
      // B) breakdown values are totals for all ekor -> candidateB = sum / estEkor
      final candidateA = sum;
      final candidateB = (estEkor > 0) ? (sum / estEkor) : candidateA;

      // Choose candidate that yields a sensible sisa_modal (prefer non-negative)
      double chooseCandidate() {
        final user = userModal;
        if (user <= 0) return candidateB > 0 ? candidateB : candidateA;

        final totalA = candidateA * estEkor;
        final totalB = candidateB * estEkor;
        final sisaA = user - totalA;
        final sisaB = user - totalB;

        // Prefer the candidate that gives non-negative sisa if possible
        if (sisaB >= 0 && sisaA < 0) return candidateB;
        if (sisaA >= 0 && sisaB < 0) return candidateA;

        // Otherwise choose the one with larger remaining budget (less negative)
        if (sisaB > sisaA) return candidateB;
        return candidateA;
      }

      biayaPerEkor = chooseCandidate();
    }

    if (biayaPerEkor == 0.0) {
      biayaPerEkor = (biayaTotalPerEkor is num)
          ? (biayaTotalPerEkor as num).toDouble()
          : double.tryParse(biayaTotalPerEkor.toString()) ?? 0.0;
    }

    // Debug prints to help tune heuristics
    try {
      print(
        'DEBUG biaya_per_ekor: $biayaPerEkor, biayaTotalPerEkor: $biayaTotalPerEkor, estimasiEkor: $estimasiEkor, userModal: $userModal',
      );
    } catch (_) {}

    if ((sisaModal == null || sisaModal == 0) && userModal > 0) {
      final estEkor = int.tryParse(estimasiEkor.toString()) ?? 0;
      final estimatedTotalCost = biayaPerEkor * estEkor;
      final computed = userModal - estimatedTotalCost;
      sisaModal = computed.isFinite ? computed : 0.0;
    }

    // Jika estimasi 0 -> tampilkan pesan ringkas dan jangan tampilkan sisa/modal/breakdown
    if (estimasiEkor == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF3B4B4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Estimasi Kapasitas Modal',
              Icons.payments_outlined,
            ),
            const SizedBox(height: 10),
            Text(
              modalCukup
                  ? 'Modal minimum tercapai, tetapi belum cukup untuk memulai minimal 1 ekor setelah alokasi 85% modal'
                  : 'Belum memenuhi modal minimum untuk memulai ternak ini',
              style: AppTextStyle.semiBold.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimasi biaya dan kapasitas ternak didasarkan pada rata-rata peternakan rakyat di wilayah Jawa tahun 2025–2026 dan dapat berubah sesuai kondisi pasar.',
              style: AppTextStyle.regular.copyWith(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E8F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Estimasi Kapasitas Modal',
            Icons.payments_outlined,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Biaya / Ekor',
                  value: _formatCurrency(biayaTotalPerEkor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoCard(
                  title: 'Estimasi Ekor',
                  value: _formatEstimateCount(estimasiEkor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (sisaModal != null)
            _buildDetailRow('Sisa Modal', _formatCurrency(sisaModal)),
          if (breakdownMap.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Breakdown Biaya',
              style: AppTextStyle.extraBold.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...breakdownMap.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: AppTextStyle.regular.copyWith(fontSize: 13),
                      ),
                    ),
                    Text(
                      _formatCurrency(entry.value),
                      style: AppTextStyle.semiBold.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Estimasi biaya dan kapasitas ternak didasarkan pada rata-rata peternakan rakyat di wilayah Jawa tahun 2025–2026 dan dapat berubah sesuai kondisi pasar.',
            style: AppTextStyle.regular.copyWith(
              fontSize: 12,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _sortedRecommendations(List recommendations) {
    final items = recommendations
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    items.sort((left, right) {
      final leftEstimasi = int.tryParse(left['estimasi_ekor'].toString()) ?? 0;
      final rightEstimasi =
          int.tryParse(right['estimasi_ekor'].toString()) ?? 0;

      final leftFeasible = leftEstimasi > 0;
      final rightFeasible = rightEstimasi > 0;

      if (leftFeasible != rightFeasible) {
        return leftFeasible ? -1 : 1;
      }

      final leftQ = double.tryParse(left['q_value'].toString()) ?? 1.0;
      final rightQ = double.tryParse(right['q_value'].toString()) ?? 1.0;

      return leftQ.compareTo(rightQ);
    });

    return items.asMap().entries.map((entry) {
      final item = Map<String, dynamic>.from(entry.value);
      item['ranking'] = entry.key + 1;
      return item;
    }).toList();
  }

  List<Color> _buildHeaderGradient(Color accentColor) {
    return [
      Color.lerp(accentColor, Colors.white, 0.18) ?? accentColor,
      accentColor,
      Color.lerp(accentColor, Colors.black, 0.08) ?? accentColor,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recommendations = _sortedRecommendations(
      recommendationData['recommendations'] ?? [],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFB),

      appBar: AppBar(
        title: Text('Hasil Rekomendasi Ternak', style: AppTextStyle.semiBold),
        backgroundColor: const Color(0xFFF5FAFB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Tampilkan JSON mentah',
            icon: Icon(Icons.bug_report_outlined, color: AppColors.blackText),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Raw recommendation data'),
                  content: SingleChildScrollView(
                    child: SelectableText(
                      const JsonEncoder.withIndent(
                        '  ',
                      ).convert(recommendationData),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: recommendations.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return _buildRecommendationCard(context, item, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets_outlined,
                size: 44,
                color: Colors.teal.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada rekomendasi',
              style: AppTextStyle.extraBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah input modal, lahan, waktu, atau pengalaman peternak.',
              textAlign: TextAlign.center,
              style: AppTextStyle.regular.copyWith(color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    final List<Color> cardColors = [
      const Color(0xFF0EA5A4),
      Colors.orange,
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
    ];

    final Color accentColor = cardColors[index % cardColors.length];
    // =====================================
    // Q VALUE
    // =====================================

    final double qValue = double.tryParse(item['q_value'].toString()) ?? 1.0;
    final NumberFormat qFormatter = NumberFormat('0.0000', 'id_ID');
    final String rankingLabel = _resolveValue(item, [
      'ranking',
    ], index + 1).toString();

    final int estimasiEkor =
        int.tryParse(item['estimasi_ekor'].toString()) ?? 0;
    final bool feasible = (item['feasible'] is bool
        ? item['feasible'] as bool
        : estimasiEkor > 0);

    // =====================================
    // KECOCOKAN
    // =====================================

    final double kecocokanPersen = _parseNumber(
      _resolveValue(item, [
        'kecocokan',
        'kecocokan_kapasitas_persen',
        'kesesuaian_kondisi',
      ], 0),
    );

    final String kecocokan = kecocokanPersen.clamp(0, 100).toStringAsFixed(0);

    // =====================================
    // STATUS KELAYAKAN
    // =====================================

    final String statusKelayakan = _resolveValue(item, [
      'status_kelayakan',
    ], feasible ? 'Kurang Direkomendasikan' : 'Belum Layak Dimulai').toString();

    final double modalMinimum = _parseNumber(item['modal_minimum']);
    final bool modalCukup = userModal >= modalMinimum;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =================================
          // HEADER CARD
          // =================================
          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: _buildHeaderGradient(accentColor),
              ),

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),

                topRight: Radius.circular(24),
              ),
            ),

            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,

                  backgroundColor: Colors.white,

                  child: Text(
                    '#$rankingLabel',

                    style: AppTextStyle.extraBold.copyWith(
                      color: accentColor,

                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        item['ternak'] ?? 'Ternak',

                        style: AppTextStyle.extraBold.copyWith(
                          fontSize: 22,

                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,

                        children: [
                          _buildPill(
                            label: 'Kecocokan $kecocokan%',

                            backgroundColor: Colors.white24,

                            textColor: Colors.white,
                          ),

                          _buildPill(
                            label: statusKelayakan,

                            backgroundColor: Colors.white24,

                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =================================
          // BODY
          // =================================
          Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =============================
                // GAMBAR TERNAK
                // =============================
                _buildTernakImageSection(item, accentColor),

                const SizedBox(height: 18),

                // =============================
                // PENJELASAN VIKOR
                // =============================
                Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Metode VIKOR',

                        style: AppTextStyle.extraBold.copyWith(fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sistem rekomendasi ini menggunakan metode '
                        'VIKOR (VIseKriterijumska Optimizacija '
                        'I Kompromisno Resenje) untuk menentukan '
                        'alternatif ternak terbaik berdasarkan modal, '
                        'lahan, waktu perawatan, dan pengalaman beternak.',

                        style: AppTextStyle.regular.copyWith(height: 1.5),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Nilai Q adalah indeks ranking VIKOR: semakin kecil '
                        'nilainya, semakin baik posisi rekomendasinya. '
                        'Kecocokan kapasitas ditampilkan terpisah dari Q.',

                        style: AppTextStyle.semiBold.copyWith(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =============================
                // INFO CARD
                // =============================
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Q VIKOR',

                        value: qFormatter.format(qValue),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _buildInfoCard(
                        title: 'ROI',

                        value: '${_resolveValue(item, ['roi'])}%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildCostBreakdownSection(item, modalCukup),

                const SizedBox(height: 18),

                // =============================
                // ALASAN
                // =============================
                _buildSectionTitle(
                  'Alasan Rekomendasi',
                  Icons.fact_check_outlined,
                ),

                const SizedBox(height: 6),

                Text(
                  item['alasan'] ?? '-',

                  style: AppTextStyle.regular.copyWith(
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 18),

                // =============================
                // DESKRIPSI
                // =============================
                _buildSectionTitle('Deskripsi', Icons.notes_outlined),

                const SizedBox(height: 6),

                Text(
                  item['deskripsi'] ?? '-',

                  style: AppTextStyle.regular.copyWith(
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 18),

                // =============================
                // DETAIL
                // =============================
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: const Color(0xFFE8EEF2)),
                  ),

                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Modal Minimum',
                        _formatCurrency(
                          _resolveValue(item, [
                            'modal_minimum',
                            'biaya_awal',
                            'modal_awal',
                            'biaya',
                          ]),
                        ),
                      ),

                      _buildDetailRow(
                        'Lahan Minimum',
                        _formatLahan(item['lahan_minimum']),
                      ),

                      _buildDetailRow(
                        'Waktu Perawatan',
                        _formatWaktu(item['waktu_perawatan']),
                      ),

                      _buildDetailRow(
                        'Pengalaman',
                        _formatPengalaman(item['pengalaman_minimum']),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: modalCukup
                        ? const Color(0xFFEAFBF1)
                        : const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: modalCukup
                          ? const Color(0xFFB7E4C7)
                          : const Color(0xFFF3B4B4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modalCukup
                            ? 'Modal tersedia mencukupi'
                            : 'Modal tersedia belum mencukupi',
                        style: AppTextStyle.extraBold.copyWith(
                          fontSize: 14,
                          color: modalCukup
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Modal Anda: ${_formatCurrency(userModal)} • Minimal ternak ini: ${_formatCurrency(modalMinimum)}',
                        style: AppTextStyle.regular.copyWith(
                          fontSize: 13,
                          height: 1.4,
                          color: modalCukup
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                      if (!modalCukup) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Hasil ini tetap tampil karena sistem VIKOR memberi bobot kecocokan keseluruhan, bukan filter modal keras.',
                          style: AppTextStyle.semiBold.copyWith(
                            fontSize: 12,
                            height: 1.4,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ] else if (estimasiEkor == 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Modal cukup untuk modal minimum, tetapi belum cukup untuk memulai 1 ekor setelah cadangan operasional 85%.',
                          style: AppTextStyle.semiBold.copyWith(
                            fontSize: 12,
                            height: 1.4,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =============================
                // PAKAN
                // =============================
                _buildSectionTitle(
                  'Kebutuhan Pakan',
                  Icons.grass_outlined,
                  color: Colors.green,
                ),

                const SizedBox(height: 8),

                ...((item['kebutuhan_pakan'] as List<dynamic>?) ?? const [])
                    .map(
                      (pakan) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(fontSize: 18, height: 1.3),
                            ),

                            Expanded(
                              child: Text(
                                pakan.toString(),

                                style: AppTextStyle.regular.copyWith(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                const SizedBox(height: 18),

                // =============================
                // TIPS
                // =============================
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: Colors.orange.shade100),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.orange),

                          const SizedBox(width: 8),

                          Text(
                            'Tips Beternak',

                            style: AppTextStyle.extraBold.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ...((item['tips'] as List<dynamic>?) ?? const []).map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(fontSize: 18, height: 1.3),
                              ),

                              Expanded(
                                child: Text(
                                  tip.toString(),

                                  style: AppTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyle.semiBold.copyWith(fontSize: 12, color: textColor),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.blackText, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyle.extraBold.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyle.medium.copyWith(fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyle.extraBold.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.medium),
          Text(value, style: AppTextStyle.semiBold),
        ],
      ),
    );
  }
}
