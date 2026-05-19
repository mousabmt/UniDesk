import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static const Color kTeal = Color(0xFF2E9C9C);
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'name': 'Sara Ali',
      'msg': 'Thank you, doctor!',
      'time': '10:30 AM',
      'unread': 2,
      'img': '1',
    },
    {
      'name': 'Ahmed Hassan',
      'msg': 'Can you explain question 3?',
      'time': 'Yesterday',
      'unread': 1,
      'img': '3',
    },
    {
      'name': 'Lina Mohamed',
      'msg': 'I have a question about the assignment.',
      'time': 'May 12',
      'unread': 0,
      'img': '5',
    },
    {
      'name': 'Omar Khaled',
      'msg': 'When is the next lecture?',
      'time': 'May 12',
      'unread': 0,
      'img': '7',
    },
    {
      'name': 'Hala Yasser',
      'msg': 'Okay, thanks!',
      'time': 'May 10',
      'unread': 0,
      'img': '9',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 8),
              ..._messages.asMap().entries.map((e) {
                final m = e.value;
                return Column(
                  children: [
                    Divider(height: 24, color: Colors.grey.shade100),
                    _buildMessageRow(m),
                  ],
                );
              }),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade100),
              const SizedBox(height: 8),
              _buildNewMessageButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.tune, color: Colors.grey.shade600, size: 20),
        ),
      ],
    );
  }

  Widget _buildMessageRow(Map<String, dynamic> m) {
    final hasUnread = (m['unread'] as int) > 0;
    return GestureDetector(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=${m['img']}',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m['msg'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                m['time'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              if (hasUnread)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: kTeal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${m['unread']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewMessageButton() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.edit_outlined, color: kTeal, size: 20),
          SizedBox(width: 8),
          Text(
            'New Message',
            style: TextStyle(
              color: kTeal,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}