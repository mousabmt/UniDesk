import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color kTeal = Color(0xFF2E9C9C);

  final List<Map<String, dynamic>> _menuItems = const [
    {
      'icon': Icons.person_outline,
      'label': 'Personal Information',
    },
    {
      'icon': Icons.lock_outline,
      'label': 'Change Password',
    },
    {
      'icon': Icons.notifications_outlined,
      'label': 'Notification Settings',
    },
    {
      'icon': Icons.privacy_tip_outlined,
      'label': 'Privacy',
    },
    {
      'icon': Icons.help_outline,
      'label': 'Help & Support',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0F0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  _buildProfileCard(),
                  const SizedBox(height: 16),

                  // Menu Items
                  _buildMenuCard(),
                  const SizedBox(height: 16),

                  // Log Out
                  _buildLogOutButton(),
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
            child: const Icon(Icons.arrow_back,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Text(
            'Profile',
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

  // ── Profile Card ──────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Avatar + Info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFE8F4F4),
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=51',
                ),
              ),
              const SizedBox(width: 16),

              // Name / Dept / Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Ahmad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Computer Science Department',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'ahmad@university.edu',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu Card ─────────────────────────────────────────────────
  Widget _buildMenuCard() {
    return Container(
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
      child: Column(
        children: _menuItems.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (i < _menuItems.length - 1)
                Divider(
                  height: 1,
                  indent: 56,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: const Color(0xFF555555),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Text(
                item['label'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Log Out Button ────────────────────────────────────────────
  Widget _buildLogOutButton() {
    return Container(
      width: double.infinity,
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
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFE53935),
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false),
              _navItem(Icons.grid_view_outlined, 'Courses', false),
              _navItem(
                  Icons.calendar_today_outlined, 'Attendance', false),
              _navItem(
                  Icons.assignment_outlined, 'Assignments', false),
              _navItem(Icons.menu, 'More', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) =>
      Column(
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