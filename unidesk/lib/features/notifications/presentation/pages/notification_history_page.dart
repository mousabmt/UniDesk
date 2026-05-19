import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/notifications/presentation/providers/notification_provider.dart';

class NotificationHistoryPage extends StatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  State<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends State<NotificationHistoryPage> {
  var _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<NotificationProvider>().loadHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              )
            : provider.notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No notifications yet.')),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = provider.notifications[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    tileColor: item.isRead ? Colors.white : Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(item.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(item.body),
                        const SizedBox(height: 8),
                        Text(item.type, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          item.createdAt.toLocal().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: item.isRead
                        ? null
                        : const Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.blue,
                          ),
                    onTap: () {
                      provider.markAsRead(item.id);
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: provider.notifications.length,
              ),
      ),
    );
  }
}
