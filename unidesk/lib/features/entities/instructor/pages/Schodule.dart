import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const Color kTeal = Color(0xFF2E9C9C);

  DateTime _currentWeekStart = DateTime(2024, 5, 12); // Sunday
  int _selectedDayIndex = 2; // Tuesday (index 2)
  int? _expandedIndex;

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'CS301 - Data Structures',
      'time': '10:00 AM - 11:30 AM',
      'room': 'Room 2203',
      'color': kTeal,
      'expandable': false,
    },
    {
      'title': 'Stat210 - Statistics II',
      'time': '1:00 PM - 2:30 PM',
      'room': 'Room 2203',
      'color': Color(0xFFF5A623),
      'expandable': false,
    },
    {
      'title': 'Office Hours',
      'time': '2:30 PM - 3:30 PM',
      'room': 'Room 2210',
      'color': Color(0xFF7C8FD4),
      'expandable': true,
      'detail': 'Ask questions and get help regarding the course.',
    },
  ];

  List<String> get _weekDays => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  DateTime dayAt(int i) => _currentWeekStart.add(Duration(days: i));

  String get _monthYear {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final d = dayAt(_selectedDayIndex);
    return '${months[d.month]} ${d.year}';
  }

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
                children: [
                  // Calendar Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildMonthNav(),
                        const SizedBox(height: 16),
                        _buildWeekRow(),
                        const SizedBox(height: 20),
                        ..._events.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildEventCard(e.key, e.value),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAddEventButton(),
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
            'Schedule',
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

  // ── Month Navigation ──────────────────────────────────────────
  Widget _buildMonthNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _currentWeekStart =
                _currentWeekStart.subtract(const Duration(days: 7));
          }),
          child: const Icon(Icons.chevron_left,
              size: 28, color: Color(0xFF444444)),
        ),
        Text(
          _monthYear,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _currentWeekStart =
                _currentWeekStart.add(const Duration(days: 7));
          }),
          child: const Icon(Icons.chevron_right,
              size: 28, color: Color(0xFF444444)),
        ),
      ],
    );
  }

  // ── Week Row ──────────────────────────────────────────────────
  Widget _buildWeekRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = dayAt(i);
        final isSelected = i == _selectedDayIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedDayIndex = i),
          child: Column(
            children: [
              Text(
                _weekDays[i],
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? kTeal : const Color(0xFF888888),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? kTeal : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Event Card ────────────────────────────────────────────────
  Widget _buildEventCard(int index, Map<String, dynamic> event) {
    final isExpanded = _expandedIndex == index;
    final color = event['color'] as Color;
    final expandable = event['expandable'] as bool;

    return GestureDetector(
      onTap: () {
        if (expandable) {
          setState(() =>
              _expandedIndex = isExpanded ? null : index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event['title'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (!expandable)
                            Icon(Icons.open_in_new,
                                size: 18,
                                color: Colors.grey.shade400)
                          else
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 22,
                              color: Colors.grey.shade500,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['time'] as String,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event['room'] as String,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500),
                      ),

                      // Expandable detail
                      if (expandable && isExpanded) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: kTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.info_outline,
                                    color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event['detail'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add Event Button ──────────────────────────────────────────
  Widget _buildAddEventButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Add New Event',
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