import 'package:flutter/material.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  static const Color kTeal = Color(0xFF2E9C9C);

  final List<Map<String, dynamic>> _announcements = const [
    {
      'title': 'Exam Schedule',
      'desc': 'The final exam schedule has been published. Please check it.',
      'date': 'May 12, 2024',
      'bgColor': Color(0xFFF0EAFA),
      'iconColor': Color(0xFF7C4DCC),
      'icon': Icons.campaign_outlined,
    },
    {
      'title': 'Class Cancelled',
      'desc': 'The lecture on May 16 is cancelled.',
      'date': 'May 10, 2024',
      'bgColor': Color(0xFFFFF4E5),
      'iconColor': Color(0xFFF5A623),
      'icon': Icons.warning_amber_rounded,
    },
    {
      'title': 'New Assignment',
      'desc': 'Assignment 4 has been published.',
      'date': 'May 8, 2024',
      'bgColor': Color(0xFFEAEEFA),
      'iconColor': Color(0xFF4A6FD4),
      'icon': Icons.description_outlined,
    },
    {
      'title': 'Project Guidelines',
      'desc': 'Please read the project guidelines carefully.',
      'date': 'May 5, 2024',
      'bgColor': Color(0xFFE5F5F5),
      'iconColor': Color(0xFF2E9C9C),
      'icon': Icons.info_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      // ✅ شيلنا _buildHeader و_buildBottomNav
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
              _buildNewAnnouncementButton(),
              const SizedBox(height: 20),
              ..._announcements.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAnnouncementCard(a),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewAnnouncementButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'New Announcement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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

  Widget _buildAnnouncementCard(Map<String, dynamic> a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: a['bgColor'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              a['icon'] as IconData,
              color: a['iconColor'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a['desc'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  a['date'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}