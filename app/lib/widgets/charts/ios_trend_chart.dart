import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/project_analytics.dart';
import '../../shared/theme.dart';

class IosTrendChart extends StatefulWidget {
  const IosTrendChart({
    super.key,
    required this.points,
    this.lineColor,
    this.height = 180,
    this.valueFormatter,
    this.onScrub,
    this.unit = '',
  });

  final List<TimeSeriesPoint> points;
  final Color? lineColor;
  final double height;
  final String Function(double)? valueFormatter;
  final void Function(TimeSeriesPoint?)? onScrub;
  final String unit;

  @override
  State<IosTrendChart> createState() => _IosTrendChartState();
}

class _IosTrendChartState extends State<IosTrendChart> {
  int? _scrubIndex;

  void _handleDrag(Offset localPos, double chartWidth) {
    if (widget.points.isEmpty || chartWidth <= 0) return;
    final clampedX = localPos.dx.clamp(0.0, chartWidth);
    final ratio = clampedX / chartWidth;
    final newIndex = (ratio * (widget.points.length - 1)).round().clamp(0, widget.points.length - 1);

    if (_scrubIndex != newIndex) {
      HapticFeedback.selectionClick();
      setState(() {
        _scrubIndex = newIndex;
      });
      widget.onScrub?.call(widget.points[newIndex]);
    }
  }

  void _clearScrub() {
    if (_scrubIndex != null) {
      setState(() {
        _scrubIndex = null;
      });
      widget.onScrub?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final themeColor = widget.lineColor ?? hh.accent;

    if (widget.points.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No activity recorded for this period',
            style: hh.subhead().copyWith(color: hh.textTertiary),
          ),
        ),
      );
    }

    final activePoint = _scrubIndex != null ? widget.points[_scrubIndex!] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top scrub info bar (shows scrubbed point or default range)
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: HHSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (activePoint != null) ...[
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatScrubDate(activePoint.timestamp),
                      style: hh.caption().copyWith(color: hh.textSecondary),
                    ),
                  ],
                ),
                Text(
                  widget.valueFormatter != null
                      ? widget.valueFormatter!(activePoint.value)
                      : '${_formatNumber(activePoint.value)} ${widget.unit}'.trim(),
                  style: hh.headline().copyWith(
                        color: hh.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
              ] else ...[
                Text(
                  'Trend',
                  style: hh.caption().copyWith(color: hh.textTertiary),
                ),
                Text(
                  'Touch & drag to inspect',
                  style: hh.caption2().copyWith(color: hh.textTertiary),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Interactive Graph Canvas
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) =>
                    _handleDrag(details.localPosition, constraints.maxWidth),
                onHorizontalDragUpdate: (details) =>
                    _handleDrag(details.localPosition, constraints.maxWidth),
                onHorizontalDragEnd: (_) => _clearScrub(),
                onHorizontalDragCancel: _clearScrub,
                onTapDown: (details) =>
                    _handleDrag(details.localPosition, constraints.maxWidth),
                onTapUp: (_) => _clearScrub(),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, widget.height),
                  painter: _IosChartPainter(
                    points: widget.points,
                    lineColor: themeColor,
                    separatorColor: hh.separator,
                    fillColor: themeColor.withValues(alpha: 0.18),
                    scrubIndex: _scrubIndex,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // Bottom Axis Labels
        if (widget.points.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatAxisDate(widget.points.first.timestamp),
                  style: hh.caption2().copyWith(color: hh.textTertiary),
                ),
                if (widget.points.length > 2)
                  Text(
                    _formatAxisDate(widget.points[widget.points.length ~/ 2].timestamp),
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                Text(
                  _formatAxisDate(widget.points.last.timestamp),
                  style: hh.caption2().copyWith(color: hh.textTertiary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatScrubDate(DateTime dt) {
    return DateFormat('d MMM, HH:mm').format(dt.toLocal());
  }

  String _formatAxisDate(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    if (now.difference(local).inHours < 24) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat('d MMM').format(local);
  }

  static String _formatNumber(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
    return val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
  }
}

class _IosChartPainter extends CustomPainter {
  const _IosChartPainter({
    required this.points,
    required this.lineColor,
    required this.separatorColor,
    required this.fillColor,
    this.scrubIndex,
  });

  final List<TimeSeriesPoint> points;
  final Color lineColor;
  final Color separatorColor;
  final Color fillColor;
  final int? scrubIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final w = size.width;
    final h = size.height;
    const padTop = 14.0;
    const padBottom = 8.0;
    final drawHeight = h - padTop - padBottom;

    // Find min and max
    double minVal = points.first.value;
    double maxVal = points.first.value;
    for (final p in points) {
      if (p.value < minVal) minVal = p.value;
      if (p.value > maxVal) maxVal = p.value;
    }

    if (maxVal == minVal) {
      maxVal += 1.0;
    }
    // Give 10% breathing room above
    maxVal = maxVal + (maxVal - minVal) * 0.12;

    // 1. Draw subtle horizontal grid baselines (0.5px iOS style)
    final gridPaint = Paint()
      ..color = separatorColor.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 2; i++) {
      final y = padTop + (drawHeight * i / 2);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Map coordinates
    final offsets = <Offset>[];
    final stepX = w / (points.length - 1 == 0 ? 1 : points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = (i * stepX).clamp(0.0, w);
      final normY = (points[i].value - minVal) / (maxVal - minVal);
      final y = padTop + (1.0 - normY) * drawHeight;
      offsets.add(Offset(x, y.clamp(padTop, h - padBottom)));
    }

    // 3. Build Smooth Monotone Cubic Spline Path
    final path = Path();
    final fillPath = Path();

    path.moveTo(offsets.first.dx, offsets.first.dy);
    fillPath.moveTo(offsets.first.dx, h);
    fillPath.lineTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = i > 0 ? offsets[i - 1] : offsets[i];
      final p1 = offsets[i];
      final p2 = offsets[i + 1];
      final p3 = i < offsets.length - 2 ? offsets[i + 2] : p2;

      // Catmull-Rom to Cubic Bezier control points
      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    fillPath.lineTo(offsets.last.dx, h);
    fillPath.close();

    // 4. Fill with vertical gradient (accent @ 18% -> transparent)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fillColor,
        fillColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, padTop, w, drawHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw Stroke line
    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // 6. Draw Interactive Scrubber if active
    if (scrubIndex != null && scrubIndex! < offsets.length) {
      final activeOffset = offsets[scrubIndex!];

      // Vertical hairline indicator
      final hairLinePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.45)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(activeOffset.dx, padTop),
        Offset(activeOffset.dx, h),
        hairLinePaint,
      );

      // Outer glow circle
      final outerGlowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activeOffset, 9.0, outerGlowPaint);

      // Inner stroke circle (halo)
      final haloPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activeOffset, 5.0, haloPaint);

      // Solid core dot
      final coreDotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activeOffset, 3.5, coreDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IosChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.scrubIndex != scrubIndex;
  }
}
