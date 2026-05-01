import 'package:flutter/material.dart';

import '../widgets/instructor_surface_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const Color kTeal = Color(0xFF2E9C9C);

  DateTime _currentWeekStart = DateTime(2024, 5, 12);
  int _selectedDayIndex = 2;
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

  static const List<String> _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  DateTime dayAt(int index) => _currentWeekStart.add(Duration(days: index));

  String get _monthYear {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final selectedDay = dayAt(_selectedDayIndex);
    return '${months[selectedDay.month]} ${selectedDay.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Schedule',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          InstructorSurfaceCard(
            radius: 20,
            blurRadius: 4,
            shadowOffset: const Offset(0, 2),
            child: Column(
              children: [
                _buildMonthNav(),
                const SizedBox(height: 16),
                _buildWeekRow(),
                const SizedBox(height: 20),
                ..._events.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEventCard(entry.key, entry.value),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAddEventButton(),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _currentWeekStart =
                _currentWeekStart.subtract(const Duration(days: 7));
          }),
          child: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF444444)),
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
            _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
          }),
          child: const Icon(Icons.chevron_right, size: 28, color: Color(0xFF444444)),
        ),
      ],
    );
  }

  Widget _buildWeekRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = dayAt(index);
        final isSelected = index == _selectedDayIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedDayIndex = index),
          child: Column(
            children: [
              Text(
                _weekDays[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? kTeal : const Color(0xFF888888),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
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
                    color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEventCard(int index, Map<String, dynamic> event) {
    final isExpanded = _expandedIndex == index;
    final color = event['color'] as Color;
    final expandable = event['expandable'] as bool;

    return GestureDetector(
      onTap: () {
        if (expandable) {
          setState(() => _expandedIndex = isExpanded ? null : index);
        }
      },
      child: InstructorSurfaceCard(
        radius: 14,
        blurRadius: 3,
        shadowOffset: const Offset(0, 1),
        borderColor: Colors.grey.shade100,
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: isExpanded ? 132 : 86,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                          Icon(Icons.open_in_new, size: 18, color: Colors.grey.shade400)
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
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event['room'] as String,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                    if (expandable && isExpanded) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF8F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: kTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

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
}
