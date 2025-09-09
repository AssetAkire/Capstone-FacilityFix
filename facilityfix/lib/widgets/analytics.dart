import 'package:flutter/material.dart';

/// Weekly analytics line chart card (Repair vs Maintenance).
/// - Left Y-axis: 20, 15, 10, 5, 0 (top -> bottom)
/// - Grid lines align with those levels
/// - Tap/drag: shows vertical guide + tooltip,
///             AND left-side "line indicators" that point to the exact Y value.
class WeeklyAnalyticsChartCard extends StatefulWidget {
  const WeeklyAnalyticsChartCard({
    super.key,
    this.title = 'Repair and Maintenance',
    required this.xLabels,            // ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
    required this.repairCounts,       // [4, 6, 3, 10, 2, 5, 1]
    required this.maintenanceCounts,  // [2, 1, 6, 7, 3, 2, 8]
    this.maxY,                        // if null, auto (rounded to multiple of 5, at least 20)
    this.highlightIndex,              // optional index to emphasize (e.g. today)
    this.height = 300,
    this.cardColor = Colors.white,
    this.borderColor = const Color(0xFFE5E6E8),
    this.gridColor = const Color(0xFFF1F5F9),
    this.repairColor = const Color(0xFF24D063),
    this.maintenanceColor = const Color(0xFF2563EB),
    this.titleStyle = const TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  }) : assert(xLabels.length == repairCounts.length &&
              xLabels.length == maintenanceCounts.length,
              'xLabels, repairCounts, and maintenanceCounts must be same length');

  final String title;
  final List<String> xLabels;
  final List<num> repairCounts;
  final List<num> maintenanceCounts;
  final int? maxY;
  final int? highlightIndex;
  final double height;

  final Color cardColor;
  final Color borderColor;
  final Color gridColor;
  final Color repairColor;
  final Color maintenanceColor;
  final TextStyle titleStyle;

  @override
  State<WeeklyAnalyticsChartCard> createState() => _WeeklyAnalyticsChartCardState();
}

class _WeeklyAnalyticsChartCardState extends State<WeeklyAnalyticsChartCard> {
  static const double _leftAxisWidth = 40;

  int? _hoverIndex;       // current selected day index (tap/drag)
  Offset? _hoverPos;      // chart-space point for tooltip anchor
  _ChartGeometry? _lastGeom; // cached geometry for mapping

  @override
  Widget build(BuildContext context) {
    final computedMax = _niceMax(_maxOf([
      ...widget.repairCounts.map((e) => e.toDouble()),
      ...widget.maintenanceCounts.map((e) => e.toDouble()),
    ]));
    final yMax = (widget.maxY ?? computedMax).toDouble();

    // Build descending ticks: yMax..0 step 5 (top -> bottom), always include 0.
    final ySteps = _buildDescendingSteps(yMax.toInt());

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: ShapeDecoration(
        color: widget.cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: widget.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(widget.title, style: widget.titleStyle),
            const SizedBox(height: 8),

            // Chart + LEFT-side Y labels
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Row(
                        children: [
                          // LEFT Y-axis (descending)
                          _YAxisLeftLabels(ySteps: ySteps, width: _leftAxisWidth),
                          const SizedBox(width: 6),

                          // Chart canvas
                          Expanded(
                            child: _ChartInteractive(
                              xLabels: widget.xLabels,
                              repairCounts: widget.repairCounts.map((e) => e.toDouble()).toList(),
                              maintenanceCounts: widget.maintenanceCounts.map((e) => e.toDouble()).toList(),
                              yMax: yMax,
                              ySteps: ySteps,
                              gridColor: widget.gridColor,
                              repairColor: widget.repairColor,
                              maintenanceColor: widget.maintenanceColor,
                              highlightIndex: widget.highlightIndex,
                              leftAxisWidth: _leftAxisWidth,
                              onGeometry: (g) => _lastGeom = g,
                              onHover: (i, pos) {
                                setState(() {
                                  _hoverIndex = i;
                                  _hoverPos = pos;
                                });
                              },
                            ),
                          ),

                          // right padding for tooltip clamp
                          const SizedBox(width: 6),
                        ],
                      ),

                      // Tooltip + vertical guide + LEFT axis indicators
                      if (_hoverIndex != null && _hoverPos != null && _lastGeom != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _TooltipAndAxisIndicatorsPainter(
                                geom: _lastGeom!,
                                index: _hoverIndex!,
                                anchor: _hoverPos!,
                                xLabel: widget.xLabels[_hoverIndex!],
                                repair: widget.repairCounts[_hoverIndex!].toDouble(),
                                maintenance: widget.maintenanceCounts[_hoverIndex!].toDouble(),
                                repairColor: widget.repairColor,
                                maintenanceColor: widget.maintenanceColor,
                                leftAxisWidth: _leftAxisWidth,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // X-axis (days)
            _XAxisLabels(
              labels: widget.xLabels,
              highlightIndex: widget.highlightIndex,
              leftAxisWidth: _leftAxisWidth,
            ),
            const SizedBox(height: 10),

            // Legend BELOW the chart
            Row(
              children: [
                SeriesLineIndicator(color: widget.repairColor),
                const SizedBox(width: 6),
                const Text(
                  'Repair',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 16),
                SeriesLineIndicator(color: widget.maintenanceColor),
                const SizedBox(width: 6),
                const Text(
                  'Maintenance',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static double _maxOf(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

  // round up to a nice max: multiple of 5, at least 20
  static int _niceMax(double raw) {
    final ceil = raw.ceil();
    final rounded = ((ceil <= 20 ? 20 : ceil) + 4) ~/ 5 * 5;
    return rounded;
  }

  /// Top->bottom descending ticks by 5: e.g. [20,15,10,5,0]
  static List<int> _buildDescendingSteps(int maxY) {
    final top = ((maxY + 4) ~/ 5) * 5; // round up to /5
    final steps = <int>[];
    for (int v = top; v >= 0; v -= 5) {
      steps.add(v);
    }
    if (steps.last != 0) steps.add(0);
    return steps;
  }
}

/* ---------------- LEFT Axis & X Axis ---------------- */

class _YAxisLeftLabels extends StatelessWidget {
  const _YAxisLeftLabels({required this.ySteps, required this.width});
  final List<int> ySteps; // already descending
  final double width;

  static const _style = TextStyle(
    color: Color(0xFF64748B),
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ySteps
            .map((v) => Align(
                  alignment: Alignment.centerRight,
                  child: Text('$v', style: _style),
                ))
            .toList(),
      ),
    );
  }
}

class _XAxisLabels extends StatelessWidget {
  const _XAxisLabels({
    required this.labels,
    required this.highlightIndex,
    required this.leftAxisWidth,
  });

  final List<String> labels;
  final int? highlightIndex;
  final double leftAxisWidth;

  static const _axisStyle = TextStyle(
    color: Color(0xFF64748B),
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  TextStyle _highlighted() => const TextStyle(
        color: Color(0xFF2563EB),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.6,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: leftAxisWidth + 6), // align with chart start
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (i) {
              return Flexible(
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: (highlightIndex != null && i == highlightIndex)
                      ? _highlighted()
                      : _axisStyle,
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

/* ---------------- Line Indicator (legend sample) ---------------- */

/// Outlined outer circle + inner filled dot + short stroked line.
class SeriesLineIndicator extends StatelessWidget {
  const SeriesLineIndicator({
    super.key,
    required this.color,
    this.dotSize = 12,
    this.innerDotSize = 5,
    this.lineLength = 56,
    this.strokeWidth = 2,
  });

  final Color color;
  final double dotSize;
  final double innerDotSize;
  final double lineLength;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: dotSize + 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outlined circle with inner fill
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1),
                ),
              ),
              Container(
                width: innerDotSize,
                height: innerDotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(width: 6),
          // Stroked line
          CustomPaint(
            size: Size(lineLength, strokeWidth),
            painter: _StrokeLinePainter(color: color, strokeWidth: strokeWidth),
          ),
        ],
      ),
    );
  }
}

class _StrokeLinePainter extends CustomPainter {
  _StrokeLinePainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(covariant _StrokeLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/* ---------------- Interactive Chart ---------------- */

class _ChartInteractive extends StatefulWidget {
  const _ChartInteractive({
    required this.xLabels,
    required this.repairCounts,
    required this.maintenanceCounts,
    required this.yMax,
    required this.ySteps,
    required this.gridColor,
    required this.repairColor,
    required this.maintenanceColor,
    required this.highlightIndex,
    required this.leftAxisWidth,
    required this.onGeometry,
    required this.onHover,
  });

  final List<String> xLabels;
  final List<double> repairCounts;
  final List<double> maintenanceCounts;
  final double yMax;
  final List<int> ySteps; // descending
  final Color gridColor;
  final Color repairColor;
  final Color maintenanceColor;
  final int? highlightIndex;
  final double leftAxisWidth;

  final void Function(_ChartGeometry geom) onGeometry;
  final void Function(int? index, Offset? anchor) onHover;

  @override
  State<_ChartInteractive> createState() => _ChartInteractiveState();
}

class _ChartInteractiveState extends State<_ChartInteractive> {
  _ChartGeometry? _geom;

  void _updateHover(Offset local) {
    if (_geom == null) return;
    final g = _geom!;
    final dx = g.xStep;
    if (dx <= 0 || widget.xLabels.isEmpty) return;

    final clampedX = local.dx.clamp(g.chartRect.left, g.chartRect.right);
    final rel = (clampedX - g.chartRect.left) / dx;
    int idx = rel.round().clamp(0, widget.xLabels.length - 1);

    final anchor = Offset(
      g.chartRect.left + dx * idx,
      g.valueToDy((widget.repairCounts[idx] + widget.maintenanceCounts[idx]) / 2),
    );

    widget.onHover(idx, anchor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (e) => _updateHover(e.localPosition),
      onPanDown: (e) => _updateHover(e.localPosition),
      onPanUpdate: (e) => _updateHover(e.localPosition),
      onPanEnd: (_) => widget.onHover(null, null),
      onTapCancel: () => widget.onHover(null, null),
      child: CustomPaint(
        painter: _ChartPainter(
          xLabels: widget.xLabels,
          repairCounts: widget.repairCounts,
          maintenanceCounts: widget.maintenanceCounts,
          yMax: widget.yMax,
          ySteps: widget.ySteps,
          gridColor: widget.gridColor,
          repairColor: widget.repairColor,
          maintenanceColor: widget.maintenanceColor,
          highlightIndex: widget.highlightIndex,
          leftAxisWidth: widget.leftAxisWidth,
          onGeometry: (g) {
            _geom = g;
            widget.onGeometry(g);
          },
        ),
      ),
    );
  }
}

/* ---------------- Painters & Geometry ---------------- */

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.xLabels,
    required this.repairCounts,
    required this.maintenanceCounts,
    required this.yMax,
    required this.ySteps, // descending
    required this.gridColor,
    required this.repairColor,
    required this.maintenanceColor,
    required this.highlightIndex,
    required this.leftAxisWidth,
    required this.onGeometry,
  });

  final List<String> xLabels;
  final List<double> repairCounts;
  final List<double> maintenanceCounts;
  final double yMax;
  final List<int> ySteps; // descending
  final Color gridColor;
  final Color repairColor;
  final Color maintenanceColor;
  final int? highlightIndex;
  final double leftAxisWidth;

  final void Function(_ChartGeometry geom) onGeometry;

  @override
  void paint(Canvas canvas, Size size) {
    // Leave room at bottom for X labels (22 px)
    final chartRect = Rect.fromLTWH(0, 0, size.width, size.height - 22);

    final geom = _ChartGeometry(
      chartRect: chartRect,
      yMax: yMax,
      count: xLabels.length,
    );
    onGeometry(geom);

    // Grid lines (horizontal) at each tick value
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final step in ySteps) {
      final dy = geom.valueToDy(step.toDouble());
      canvas.drawLine(Offset(chartRect.left, dy), Offset(chartRect.right, dy), gridPaint);
    }

    // Draw series (maintenance behind, repair on top)
    _drawSeries(canvas, geom, maintenanceCounts, maintenanceColor);
    _drawSeries(canvas, geom, repairCounts, repairColor);

    // Optional vertical highlight (today, etc.)
    if (highlightIndex != null &&
        highlightIndex! >= 0 &&
        highlightIndex! < xLabels.length) {
      final x = geom.chartRect.left + geom.xStep * highlightIndex!;
      final highlightPaint = Paint()
        ..color = maintenanceColor.withOpacity(0.12)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, chartRect.top), Offset(x, chartRect.bottom), highlightPaint);
    }
  }

  void _drawSeries(Canvas canvas, _ChartGeometry g, List<double> values, Color color) {
    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final p = Offset(g.chartRect.left + g.xStep * i, g.valueToDy(values[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Points: white outer + colored inner (ring+dot)
    final outer = Paint()..color = Colors.white;
    final inner = Paint()..color = color;
    for (int i = 0; i < values.length; i++) {
      final p = Offset(g.chartRect.left + g.xStep * i, g.valueToDy(values[i]));
      canvas.drawCircle(p, 6, outer);
      canvas.drawCircle(p, 3, inner);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.xLabels != xLabels ||
      old.repairCounts != repairCounts ||
      old.maintenanceCounts != maintenanceCounts ||
      old.yMax != yMax ||
      old.ySteps != ySteps ||
      old.gridColor != gridColor ||
      old.repairColor != repairColor ||
      old.maintenanceColor != maintenanceColor ||
      old.highlightIndex != highlightIndex ||
      old.leftAxisWidth != leftAxisWidth;
}

class _ChartGeometry {
  _ChartGeometry({
    required this.chartRect,
    required this.yMax,
    required this.count,
  }) : xStep = count > 1 ? chartRect.width / (count - 1) : chartRect.width;

  final Rect chartRect;
  final double yMax;
  final int count;
  final double xStep;

  double valueToDy(double v) =>
      chartRect.bottom - (v / yMax) * chartRect.height;
}

/// Draws:
/// - Vertical guide at hovered X
/// - Left-axis "line indicators" at Y positions for Repair/Maintenance
/// - Tooltip bubble above the anchor point
class _TooltipAndAxisIndicatorsPainter extends CustomPainter {
  _TooltipAndAxisIndicatorsPainter({
    required this.geom,
    required this.index,
    required this.anchor,
    required this.xLabel,
    required this.repair,
    required this.maintenance,
    required this.repairColor,
    required this.maintenanceColor,
    required this.leftAxisWidth,
  });

  final _ChartGeometry geom;
  final int index;
  final Offset anchor;
  final String xLabel;
  final double repair;
  final double maintenance;
  final Color repairColor;
  final Color maintenanceColor;
  final double leftAxisWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Vertical guide line at selected index
    final x = geom.chartRect.left + geom.xStep * index;
    final guide = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(x, geom.chartRect.top), Offset(x, geom.chartRect.bottom), guide);

    // 2) LEFT-axis indicators pointing to the exact Y positions
    _drawAxisIndicator(canvas, geom.valueToDy(repair), repairColor);
    _drawAxisIndicator(canvas, geom.valueToDy(maintenance), maintenanceColor);

    // 3) Tooltip bubble above anchor
    _drawTooltip(canvas, size);
  }

  void _drawAxisIndicator(Canvas canvas, double y, Color color) {
    // Place the indicator inside the left axis area.
    // Circle center:
    final cx = leftAxisWidth - 14; // near the chart edge
    final cy = y;

    // Short line extending into the chart
    final lineStart = Offset(cx + 8, cy);
    final lineEnd = Offset(cx + 8 + 24, cy);

    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // line
    canvas.drawLine(lineStart, lineEnd, stroke);

    // outlined circle + inner dot
    final outer = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 6, outer);
    canvas.drawCircle(Offset(cx, cy), 6, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = color);
  }

  void _drawTooltip(Canvas canvas, Size size) {
    final textStyle = const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600);
    final subStyle = const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500);

    final lines = <InlineSpan>[
      TextSpan(text: '$xLabel\n', style: subStyle),
      TextSpan(text: 'Repair: ${repair.toStringAsFixed(0)}\n', style: textStyle),
      TextSpan(text: 'Maintenance: ${maintenance.toStringAsFixed(0)}', style: textStyle),
    ];

    final tp = TextPainter(
      text: TextSpan(children: lines),
      textDirection: TextDirection.ltr,
    )..layout();

    const pad = EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    final bubbleSize = Size(tp.width + pad.horizontal, tp.height + pad.vertical);

    double bx = (geom.chartRect.left + geom.xStep * index) - bubbleSize.width / 2;
    double by = (anchor.dy - 16) - bubbleSize.height;

    bx = bx.clamp(leftAxisWidth + 4.0, size.width - bubbleSize.width - 4.0);
    by = by.clamp(4.0, size.height - bubbleSize.height - 4.0);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bx, by, bubbleSize.width, bubbleSize.height),
      const Radius.circular(8),
    );

    final bg = Paint()..color = const Color(0xFF111827).withOpacity(0.95);
    canvas.drawRRect(rrect, bg);

    tp.paint(canvas, Offset(bx + pad.left, by + pad.top));
  }

  @override
  bool shouldRepaint(covariant _TooltipAndAxisIndicatorsPainter old) =>
      old.index != index ||
      old.anchor != anchor ||
      old.xLabel != xLabel ||
      old.repair != repair ||
      old.maintenance != maintenance ||
      old.repairColor != repairColor ||
      old.maintenanceColor != maintenanceColor ||
      old.leftAxisWidth != leftAxisWidth;
}
