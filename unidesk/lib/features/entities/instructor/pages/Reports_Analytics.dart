
import 'package:flutter/material.dart';

import '../widgets/instructor_surface_card.dart';

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  static const Color kTeal = Color(0xFF2E9C9C);

  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Attendance', 'Performance'];

  final List<Map<String, dynamic>> _chartData = [
    {'month': 'Mar', 'value': 75.0},
    {'month': 'Apr', 'value': 78.0},
    {'month': 'May', 'value': 80.0},
    {'month': 'Jun', 'value': 83.0},
    {'month': 'Jul', 'value': 85.0},
  ];

  final List<Map<String, dynamic>> _performers = [
    {'rank': 1, 'name': 'Sara Ali', 'gpa': '3.90'},
    {'rank': 2, 'name': 'Lina Mohamed', 'gpa': '3.75'},
    {'rank': 3, 'name': 'Omar Khaled', 'gpa': '3.60'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InstructorSurfaceCard(
            radius: 20,
            blurRadius: 4,
            shadowOffset: const Offset(0, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTabBar(),
                const SizedBox(height: 20),
                ..._buildSectionsForTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionsForTab() {
    switch (_selectedTab) {
      case 1:
        return [
          _buildAttendanceTrend(),
          const SizedBox(height: 20),
          _buildOverviewCards(),
          const SizedBox(height: 16),
          _buildExportButton(),
        ];
      case 2:
        return [
          _buildTopPerformers(),
          const SizedBox(height: 20),
          _buildOverviewCards(),
          const SizedBox(height: 16),
          _buildViewFullReport(),
        ];
      case 0:
      default:
        return [
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildAttendanceTrend(),
          const SizedBox(height: 20),
          _buildTopPerformers(),
          const SizedBox(height: 16),
          _buildViewFullReport(),
          const SizedBox(height: 12),
          _buildExportButton(),
        ];
    }
  }

  Widget _buildTabBar() {
    return InstructorSurfaceCard(
      radius: 30,
      padding: const EdgeInsets.all(4),
      blurRadius: 3,
      shadowOffset: const Offset(0, 1),
      borderColor: const Color(0xFFE7EFEF),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final active = index == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? kTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
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
      child: InstructorSurfaceCard(
        radius: 14,
        blurRadius: 3,
        shadowOffset: const Offset(0, 1),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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

  Widget _buildAttendanceTrend() {
    return InstructorSurfaceCard(
      radius: 16,
      blurRadius: 3,
      shadowOffset: const Offset(0, 1),
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
          RepaintBoundary(
            child: SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _LineChartPainter(_chartData),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        InstructorSurfaceCard(
          radius: 16,
          blurRadius: 3,
          shadowOffset: const Offset(0, 1),
          child: Column(
            children: _performers.asMap().entries.map((entry) {
              final index = entry.key;
              final performer = entry.value;
              return Column(
                children: [
                  _performerRow(performer),
                  if (index < _performers.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _performerRow(Map<String, dynamic> performer) {
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
              '${performer['rank']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rankColors[performer['rank'] - 1],
                
                ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE6F5F5),
            child: Text(
              _initialsFor(performer['name'] as String),
              style: const TextStyle(
                color: kTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              performer['name'] as String,
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
              'GPA ${performer['gpa']}',
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

  Widget _buildViewFullReport() {
    return GestureDetector(
      onTap: () {},
      child: const InstructorSurfaceCard(
        radius: 14,
        blurRadius: 3,
        shadowOffset: Offset(0, 1),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'View Full Report',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }

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

  static String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1 || parts.last.isEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter(this.data);

  final List<Map<String, dynamic>> data;

  @override
  void paint(Canvas canvas, Size size) {
    const kTeal = Color(0xFF2E9C9C);

    final minVal = 70.0;
    final maxVal = 90.0;
    final chartH = size.height - 30;
    final stepX = size.width / (data.length - 1);

    double toY(double value) =>
        chartH - ((value - minVal) / (maxVal - minVal)) * chartH;

    final points = List.generate(
      data.length,
      (index) => Offset(index * stepX, toY((data[index]['value'] as double))),
    );

    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 =
          Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      fillPath.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
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
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }
    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        6,
        Paint()
          ..color = kTeal.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        points[i],
        4,
        Paint()
          ..color = kTeal
          ..style = PaintingStyle.fill,
      );

      final pct = '${data[i]['value'].toInt()}%';
      final valuePainter = TextPainter(
        text: TextSpan(
          text: pct,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(
        canvas,
        Offset(points[i].dx - valuePainter.width / 2, points[i].dy - valuePainter.height - 8),
      );

      final monthPainter = TextPainter(
        text: TextSpan(
          text: data[i]['month'] as String,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      monthPainter.paint(
        canvas,
        Offset(points[i].dx - monthPainter.width / 2, chartH + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
