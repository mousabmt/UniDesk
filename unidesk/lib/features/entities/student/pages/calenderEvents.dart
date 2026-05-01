import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/language/langProvider.dart';

import '../providers_std/CalenderProvider.dart';

class CalenderEvents extends StatefulWidget {
  const CalenderEvents({super.key});

  @override
  State<CalenderEvents> createState() => _CalenderEventsState();
}

class _CalenderEventsState extends State<CalenderEvents> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CalenderProvider>().loadIfNeeded(),
    );
  }

  void _prevMonth() =>
      setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1));

  void _nextMonth() =>
      setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1));

  List<DateTime> _daysInMonth(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int m) => const [
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
        'December'
      ][m];

  String _formatDue(DateTime d) {
    final local = d.toLocal();
    final diff = local.difference(DateTime.now()).inDays;
    final dateText =
        '${_monthName(local.month).substring(0, 3)} ${local.day}, ${local.year}';
    if (diff == 0) return 'Due: today';
    if (diff == 1) return 'Due: tomorrow';
    return 'Due: $dateText';
  }

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    final h = local.hour > 12 ? local.hour - 12 : local.hour == 0 ? 12 : local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final schedule = context.watch<CalenderProvider>();

    return Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: _buildBody(schedule, lang),
    );
  }

  Widget _buildBody(CalenderProvider provider, LangProvider lang) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<CalenderProvider>().refresh(),
              child: Text(lang.translate('retry')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CalenderProvider>().refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildCalendar(provider.deadlines),
          const SizedBox(height: 24),
          _buildSectionHeader('Assignment Deadlines', Icons.assignment_outlined),
          const SizedBox(height: 10),
          if (provider.deadlines.isEmpty)
            _buildEmpty('No upcoming deadlines')
          else
            ...provider.deadlines.map(_buildDeadlineCard),
          const SizedBox(height: 24),
          _buildSectionHeader('Reminders', Icons.notifications_outlined),
          const SizedBox(height: 10),
          if (provider.lectures.isEmpty)
            _buildEmpty('No upcoming lectures')
          else
            ...provider.lectures.map(_buildLectureCard),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<DeadlineModel> deadlines) {
    final days = _daysInMonth(_focusedDay);
    final firstWeekday = days.first.weekday % 7;
    final today = DateTime.now();
    const accent = Color(0xFF5B2630);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              onPressed: _prevMonth,
              color: const Color(0xFF6B7280),
            ),
            Text(
              '${_monthName(_focusedDay.month)} ${_focusedDay.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 22),
              onPressed: _nextMonth,
              color: const Color(0xFF6B7280),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: days.length + firstWeekday,
          itemBuilder: (_, i) {
            if (i < firstWeekday) return const SizedBox();
            final day = days[i - firstWeekday];
            final isToday = _isSameDay(day, today);
            final isSelected = _isSameDay(day, _selectedDay);
            final hasDeadline = deadlines.any((d) => _isSameDay(d.dueDate, day));

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDay = day);
                context.read<CalenderProvider>().loadForDate(day);
              },
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? accent
                            : isToday
                                ? accent.withOpacity(0.12)
                                : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                    if (hasDeadline && !isSelected)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      );

  Widget _buildEmpty(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            msg,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ),
      );

  Widget _buildDeadlineCard(DeadlineModel d) {
    const tileColor = Color(0xFF6BCB77);
    final courseLabel = d.courseName ?? d.courseId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_note_rounded, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$courseLabel - ${d.title}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDue(d.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: d.isSoon ? const Color(0xFFD32F2F) : const Color(0xFF6B7280),
                    fontWeight: d.isSoon ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (d.isSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD32F2F), width: 0.5),
              ),
              child: const Text(
                'Soon',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLectureCard(LectureModel l) {
    const tileColor = Color(0xFF6BCB77);
    final courseLabel = l.courseName ?? l.courseId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.alarm, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$courseLabel - ${l.type}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.room,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatTime(l.startTime)} - ${_formatTime(l.endTime)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          if (l.isUpcoming)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE65100), width: 0.5),
              ),
              child: const Text(
                'Soon',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFE65100),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
