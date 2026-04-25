import 'package:flutter/material.dart';
import 'dart:math';

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  static const Color kTeal = Color(0xFF2E9C9C);
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Attendance', 'Performance'];

  // Chart data
  final List<Map<String, dynamic>> _chartData = [
    {'month': 'Mar', 'value': 75.0},
    {'month': 'Apr', 'value': 78.0},
    {'month': 'May', 'value': 80.0},
    {'month': 'Jun', 'value': 83.0},
    {'month': 'Jul', 'value': 85.0},
  ];

  // Top performers
  final List<Map<String, dynamic>> _performers = [
    {'rank': 1, 'name': 'Sara Ali',      'gpa': '3.90', 'img': '68'},
    {'rank': 2, 'name': 'Lina Mohamed', 'gpa': '3.75', 'img': '47'},
    {'rank': 3, 'name': 'Omar Khaled',  'gpa': '3.60', 'img': '12'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildAttendanceTrend(),
                  const SizedBox(height: 20),
                  _buildTopPerformers(),
                  const SizedBox(height: 16),
                  _buildViewFullReport(),
                  const SizedBox(height: 12),
                  _buildExportButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Text(
            'Reports & Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = i == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? kTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF666666),
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Overview Cards ────────────────────────────────────────────
  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard('85%', 'Avg. Attendance'),
            const SizedBox(width: 10),
            _statCard('3.45', 'Avg. GPA'),
            const SizedBox(width: 10),
            _statCard('62', 'Total Students'),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTeal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Attendance Trend Chart ────────────────────────────────────
  Widget _buildAttendanceTrend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _LineChartPainter(_chartData),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Performers ────────────────────────────────────────────
  Widget _buildTopPerformers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performers',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _performers.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return Column(
                children: [
                  _performerRow(p),
                  if (i < _performers.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _performerRow(Map<String, dynamic> p) {
    final rankColors = [
      const Color(0xFFE6A817),
      const Color(0xFF888888),
      const Color(0xFFCD7F32),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${p['rank']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rankColors[p['rank'] - 1],
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=${p['img']}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p['name'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'GPA ${p['gpa']}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── View Full Report ──────────────────────────────────────────
  Widget _buildViewFullReport() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'View Full Report',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  // ── Export Button ─────────────────────────────────────────────
  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.description_outlined, color: Colors.white),
        label: const Text(
          'Export Report (PDF)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kTeal,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false),
              _navItem(Icons.grid_view_outlined, 'Courses', false),
              _navItem(Icons.calendar_today_outlined, 'Attendance', false),
              _navItem(Icons.assignment_outlined, 'Assignments', false),
              _navItem(Icons.menu, 'More', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 24,
              color: isActive ? kTeal : const Color(0xFF888888)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? kTeal : const Color(0xFF888888),
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      );
}

// ── Line Chart Painter ────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  const _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const kTeal = Color(0xFF2E9C9C);

    final minVal = 70.0;
    final maxVal = 90.0;
    final chartH = size.height - 30; // leave room for labels
    final stepX = size.width / (data.length - 1);

    // Helper: value → Y
    double toY(double v) =>
        chartH - ((v - minVal) / (maxVal - minVal)) * chartH;

    final points = List.generate(
      data.length,
      (i) => Offset(i * stepX, toY((data[i]['value'] as double))),
    );

    // ── Filled area ──────────────────────────────────────────────
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 =
          Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    fillPath
      ..lineTo(points.last.dx, chartH)
      ..lineTo(points.first.dx, chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kTeal.withOpacity(0.25),
            kTeal.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );

    // ── Line ─────────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = kTeal
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 =
          Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // ── Dots + Labels ─────────────────────────────────────────────
    for (int i = 0; i < points.length; i++) {
      // outer ring
      canvas.drawCircle(
          points[i],
          6,
          Paint()
            ..color = kTeal.withOpacity(0.2)
            ..style = PaintingStyle.fill);
      // inner dot
      canvas.drawCircle(
          points[i],
          4,
          Paint()
            ..color = kTeal
            ..style = PaintingStyle.fill);

      // percentage label
      final pct = '${data[i]['value'].toInt()}%';
      final tp = TextPainter(
        text: TextSpan(
          text: pct,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset(points[i].dx - tp.width / 2,
              points[i].dy - tp.height - 8));

      // month label
      final ml = TextPainter(
        text: TextSpan(
          text: data[i]['month'] as String,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      ml.paint(
          canvas,
          Offset(
              points[i].dx - ml.width / 2, chartH + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}