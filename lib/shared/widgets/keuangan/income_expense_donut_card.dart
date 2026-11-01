import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

class IncomeExpenseDonutCard extends StatelessWidget {
  const IncomeExpenseDonutCard({
    super.key,
    required this.totalPendapatan,
    required this.totalPengeluaran,
  });

  final num totalPendapatan;
  final num totalPengeluaran;

  @override
  Widget build(BuildContext context) {
    final total = (totalPendapatan + totalPengeluaran).toDouble().clamp(
      1,
      double.infinity,
    );
    final pIncome = (totalPendapatan / total);
    final pExpense = (totalPengeluaran / total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51), // ~0.2
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final donutSize = constraints.maxWidth < 360 ? 96.0 : 110.0;
          final legend = _LegendAndTotals(
            income: totalPendapatan.toDouble(),
            expense: totalPengeluaran.toDouble(),
            incomeColor: const Color(0xFF1F73FF),
            expenseColor: const Color(0xFFE53935),
          );

          return Row(
            children: [
              SizedBox(
                width: donutSize,
                height: donutSize,
                child: CustomPaint(
                  painter: _DonutPainter(
                    incomeRatio: pIncome,
                    expenseRatio: pExpense,
                    incomeColor: const Color(0xFF1F73FF),
                    expenseColor: const Color(0xFFE53935),
                    bgColor: const Color(0xFFE9F0FF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: legend),
            ],
          );
        },
      ),
    );
  }
}

class _LegendAndTotals extends StatelessWidget {
  const _LegendAndTotals({
    required this.income,
    required this.expense,
    required this.incomeColor,
    required this.expenseColor,
  });

  final double income;
  final double expense;
  final Color incomeColor;
  final Color expenseColor;

  String get rupiah {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    // NumberFormat sudah kasih titik ribuan otomatis
    return f.currencySymbol; // "Rp. "
  }

  String _fmt(num v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Pendapatan
        Row(
          children: [
            _Dot(color: incomeColor),
            const SizedBox(width: 8),
            Text(
              'Total Pendapatan',
              style: text.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _fmt(income),
                style: text.titleMedium?.copyWith(
                  color: incomeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_downward, size: 18, color: incomeColor),
          ],
        ),

        const SizedBox(height: 16),

        // Total Pengeluaran
        Row(
          children: [
            _Dot(color: expenseColor),
            const SizedBox(width: 8),
            Text(
              'Total Pengeluaran',
              style: text.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _fmt(expense),
                style: text.titleMedium?.copyWith(
                  color: expenseColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_upward, size: 18, color: expenseColor),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Custom painter untuk donut + label persen di segmen
class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.incomeRatio,
    required this.expenseRatio,
    required this.incomeColor,
    required this.expenseColor,
    required this.bgColor,
  });

  final double incomeRatio; // 0..1
  final double expenseRatio; // 0..1
  final Color incomeColor;
  final Color expenseColor;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.35
      ..strokeCap = StrokeCap.butt
      ..color = bgColor;

    // background ring
    canvas.drawCircle(center, radius * 0.8, ring);

    // arcs
    final arcPaintIncome = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth
      ..strokeCap = StrokeCap.butt
      ..color = incomeColor;

    final arcPaintExpense = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth
      ..strokeCap = StrokeCap.butt
      ..color = expenseColor;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.8);
    const startAngle = -math.pi / 2; // mulai dari atas

    final sweepIncome = (incomeRatio * 2 * math.pi).clamp(0.0, 2 * math.pi);
    final sweepExpense = (expenseRatio * 2 * math.pi).clamp(0.0, 2 * math.pi);

    // gambar income dulu (biru besar)
    if (sweepIncome > 0) {
      canvas.drawArc(rect, startAngle, sweepIncome, false, arcPaintIncome);
    }
    // lanjutkan dari akhir income
    if (sweepExpense > 0) {
      canvas.drawArc(
        rect,
        startAngle + sweepIncome,
        sweepExpense,
        false,
        arcPaintExpense,
      );
    }

    // Persen pada masing-masing arc
    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr, // ✅ benar
    );

    void drawPercent(double ratio, Color color, double offsetAngle) {
      if (ratio <= 0) return;
      final midAngle = startAngle + offsetAngle + (ratio * 2 * math.pi) / 2;
      final r = radius * 0.8;
      final labelPos = Offset(
        center.dx + (r) * math.cos(midAngle),
        center.dy + (r) * math.sin(midAngle),
      );

      tp.text = TextSpan(
        text: '${(ratio * 100).round()}%',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
      tp.layout();
      final pos = labelPos - Offset(tp.width / 2, tp.height / 2);
      // bubble background (biar mirip contoh)
      final bubble = Paint()..color = color;
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: labelPos,
          width: tp.width + 12,
          height: tp.height + 6,
        ),
        const Radius.circular(999),
      );
      canvas.drawRRect(bubbleRect, bubble);
      tp.paint(canvas, pos);
    }

    // 83% di biru, 17% di merah (otomatis dari ratio)
    drawPercent(incomeRatio, incomeColor, 0);
    drawPercent(expenseRatio, expenseColor, sweepIncome);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.incomeRatio != incomeRatio ||
        old.expenseRatio != expenseRatio ||
        old.incomeColor != incomeColor ||
        old.expenseColor != expenseColor;
  }
}
