import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/instructor_surface_card.dart';

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
    },
    {
      'name': 'Omar Khaled',
      'date': 'Submitted on May 13, 2024',
      'submitted': true,
    },
    {
      'name': 'Hala Yasser',
      'date': 'Not Submitted',
      'submitted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0F0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTabBar(),
          const SizedBox(height: 20),
          _buildSectionHeader(context),
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
    );
  }

  Widget _buildTabBar() {
    return InstructorSurfaceCard(
      radius: 30,
      padding: const EdgeInsets.all(4),
      blurRadius: 3,
      shadowOffset: const Offset(0, 1),
      borderColor: const Color(0xFFE7EFEF),
      child: Row(
        children: ['My Assignments', 'Submitted'].asMap().entries.map((entry) {
          final active = entry.key == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? kTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.value,
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
          onPressed: () => context.push('/instructor/add-assignment'),
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
    return InstructorSurfaceCard(
      radius: 16,
      blurRadius: 3,
      shadowOffset: const Offset(0, 1),
      child: Column(
        children: _assignments.asMap().entries.map((entry) {
          final index = entry.key;
          final assignment = entry.value;
          return Column(
            children: [
              _buildAssignmentRow(assignment),
              if (index < _assignments.length - 1)
                Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignmentRow(Map<String, dynamic> assignment) {
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
                  assignment['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment['topic'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment['due'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${assignment['submitted']}/${assignment['total']}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Submitted',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsCard() {
    return InstructorSurfaceCard(
      radius: 16,
      blurRadius: 3,
      shadowOffset: const Offset(0, 1),
      child: Column(
        children: _recentSubmissions.asMap().entries.map((entry) {
          final index = entry.key;
          final submission = entry.value;
          return Column(
            children: [
              _buildSubmissionRow(submission),
              if (index < _recentSubmissions.length - 1)
                Divider(height: 1, indent: 60, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionRow(Map<String, dynamic> submission) {
    final submitted = submission['submitted'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE6F5F5),
            child: Text(
              _initialsFor(submission['name'] as String),
              style: const TextStyle(
                color: kTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  submission['date'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
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
            child: Icon(
              submitted ? Icons.check : Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return InstructorSurfaceCard(
      radius: 14,
      blurRadius: 3,
      shadowOffset: const Offset(0, 1),
      padding: EdgeInsets.zero,
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
