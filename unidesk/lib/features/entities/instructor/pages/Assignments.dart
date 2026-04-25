import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  static const Color kTeal = Color(0xFF2E9C9C);
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _assignments = [
    {
      'title': 'Assignment 1',
      'topic': 'Arrays & Linked Lists',
      'due': 'Due: May 20, 2024',
      'submitted': 42,
      'total': 62,
    },
    {
      'title': 'Assignment 2',
      'topic': 'Stacks & Queues',
      'due': 'Due: May 28, 2024',
      'submitted': 30,
      'total': 62,
    },
    {
      'title': 'Assignment 3',
      'topic': 'Trees',
      'due': 'Due: Jun 5, 2024',
      'submitted': 0,
      'total': 62,
    },
  ];

  final List<Map<String, dynamic>> _recentSubmissions = [
    {
      'name': 'Sara Ali',
      'date': 'Submitted on May 14, 2024',
      'submitted': true,
      'img': '5',
    },
    {
      'name': 'Omar Khaled',
      'date': 'Submitted on May 13, 2024',
      'submitted': true,
      'img': '7',
    },
    {
      'name': 'Hala Yasser',
      'date': 'Not Submitted',
      'submitted': false,
      'img': '9',
    },
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
            _buildTabBar(),
            const SizedBox(height: 20),
            _buildSectionHeader(context), // ✅ أضفنا context
            const SizedBox(height: 12),
            _buildAssignmentsCard(),
            const SizedBox(height: 20),
            const Text(
              'Recent Submissions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            _buildSubmissionsCard(),
            const SizedBox(height: 12),
            _buildViewAllButton(),
          ],
        ),
      ),
    );
  }

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
        children: ['My Assignments', 'Submitted'].asMap().entries.map((e) {
          final active = e.key == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? kTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF666666),
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Assignments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/instructor/add-assignment'), // ✅ مربوط
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text(
            'Add Assignment',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kTeal,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsCard() {
    return Container(
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
        children: _assignments.asMap().entries.map((e) {
          final i = e.key;
          final a = e.value;
          return Column(
            children: [
              _buildAssignmentRow(a),
              if (i < _assignments.length - 1)
                Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignmentRow(Map<String, dynamic> a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(a['topic'] as String,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(a['due'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${a['submitted']}/${a['total']}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text('Submitted',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsCard() {
    return Container(
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
        children: _recentSubmissions.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Column(
            children: [
              _buildSubmissionRow(s),
              if (i < _recentSubmissions.length - 1)
                Divider(height: 1, indent: 60, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionRow(Map<String, dynamic> s) {
    final submitted = s['submitted'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=${s['img']}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(s['date'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: submitted ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: Icon(submitted ? Icons.check : Icons.close,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
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
          'View All Submissions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}