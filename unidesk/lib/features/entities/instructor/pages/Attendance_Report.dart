import 'package:flutter/material.dart';
import 'dart:math';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  static const Color kTeal = Color(0xFF2E9C9C);

  String _selectedCourse = 'CS301 - Data Structures';
  String _selectedPeriod = 'This Semester';

  final List<String> _courses = [
    'CS301 - Data Structures',
    'CS302 - Algorithms',
    'CS401 - Operating Systems',
  ];

  final List<String> _periods = [
    'This Semester',
    'Last Semester',
    'This Month',
  ];

  final List<Map<String, dynamic>> _students = [
    {'name': 'Sara Ali',     'pct': 92, 'img': '5'},
    {'name': 'Ahmed Hassan', 'pct': 65, 'img': '3'},
    {'name': 'Lina Mohamed', 'pct': 88, 'img': '47'},
    {'name': 'Omar Khaled',  'pct': 70, 'img': '7'},
    {'name': 'Hala Yasser',  'pct': 60, 'img': '9'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0F0),
      // ✅ شيلنا _buildHeader و_buildBottomNav
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersCard(),
            const SizedBox(height: 16),
            _buildOverallCard(),
            const SizedBox(height: 20),
            const Text(
              'Students Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            _buildStudentsCard(),
            const SizedBox(height: 12),
            _buildViewFullReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
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
          const Text('Select Course',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const SizedBox(height: 6),
          _buildDropdown(_selectedCourse, _courses, (v) {
            setState(() => _selectedCourse = v!);
          }),
          const SizedBox(height: 14),
          const Text('Select Period',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const SizedBox(height: 6),
          _buildDropdown(_selectedPeriod, _periods, (v) {
            setState(() => _selectedPeriod = v!);
          }),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF444444)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
          items: items
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOverallCard() {
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
            'Overall Attendance',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _DonutPainter(0.85),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('85%',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A))),
                        Text('Average',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF888888))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(kTeal, 'Present', '85%'),
                  const SizedBox(height: 12),
                  _legendItem(const Color(0xFFFF6B6B), 'Absent', '15%'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        const SizedBox(width: 12),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildStudentsCard() {
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
        children: _students.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Column(
            children: [
              _buildStudentRow(s),
              if (i < _students.length - 1) const SizedBox(height: 14),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> s) {
    final pct = s['pct'] as int;
    Color barColor = kTeal;
    if (pct < 70) {
      barColor = const Color(0xFFFF6B6B);
    } else if (pct < 80) barColor = const Color(0xFFF5A623);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?img=${s['img']}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['name'] as String,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('$pct%',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildViewFullReport() {
    return Container(
      width: double.infinity,
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
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'View Full Report',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333)),
        ),
      ),
    );
  }
}

// ── Donut Chart Painter ──────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double value;
  const _DonutPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    const kTeal = Color(0xFF2E9C9C);
    const absent = Color(0xFFFF6B6B);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(cx, cy) - 8;
    const strokeW = 12.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    paint.color = absent;
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    paint.color = kTeal;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2,
      2 * pi * value,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}