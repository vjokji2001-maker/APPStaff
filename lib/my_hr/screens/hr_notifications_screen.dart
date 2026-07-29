import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRNotificationsScreen extends StatefulWidget {
  const HRNotificationsScreen({super.key});
  @override
  State<HRNotificationsScreen> createState() => _HRNotificationsScreenState();
}

class _HRNotificationsScreenState extends State<HRNotificationsScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Announcement', 'Circular', 'Reminder', 'Alert'];
  late List<HRNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(HRMockData.notifications);
  }

  List<HRNotification> get _filtered =>
      _filter == 'All' ? _notifications : _notifications.where((n) => n.type == _filter).toList();

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications = _notifications.map((n) => HRNotification(
        id: n.id, title: n.title, body: n.body, type: n.type,
        time: n.time, isRead: true, actionRoute: n.actionRoute,
      )).toList();
    });
  }

  void _markRead(HRNotification notif) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == notif.id);
      if (idx != -1) {
        _notifications[idx] = HRNotification(
          id: notif.id, title: notif.title, body: notif.body,
          type: notif.type, time: notif.time, isRead: true, actionRoute: notif.actionRoute,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _filtered.where((n) => !n.isRead).toList();
    final read = _filtered.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(
          title: 'Notifications',
          subtitle: '$_unreadCount unread',
          actions: [
            if (_unreadCount > 0)
              GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                  child: Text('Mark all read', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        // Filter chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: _filters.map((f) {
              final sel = f == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? HRTheme.notifications : (isDark ? HRTheme.bgCardDark : Colors.white),
                    borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                    boxShadow: HRTheme.subtleShadow,
                  ),
                  child: Row(children: [
                    if (f != 'All') ...[
                      Icon(_typeIcon(f), size: 13, color: sel ? Colors.white : _typeColor(f)),
                      const SizedBox(width: 4),
                    ],
                    Text(f, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : HRTheme.textSecondary)),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(child: _filtered.isEmpty
            ? const HREmptyState(icon: Icons.notifications_off_outlined, title: 'No Notifications', subtitle: 'You are all caught up!')
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  if (unread.isNotEmpty) ...[
                    _groupHeader('Unread (${unread.length})', isDark),
                    ...unread.map((n) => _buildNotifCard(n, isDark)),
                  ],
                  if (read.isNotEmpty) ...[
                    _groupHeader('Earlier', isDark),
                    ...read.map((n) => _buildNotifCard(n, isDark)),
                  ],
                ],
              )),
      ]),
    );
  }

  Widget _groupHeader(String label, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700,
        color: isDark ? Colors.white60 : HRTheme.textSecondary)),
  );

  Widget _buildNotifCard(HRNotification n, bool isDark) {
    final color = _typeColor(n.type);
    return GestureDetector(
      onTap: () => _markRead(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.isRead ? (isDark ? HRTheme.bgCardDark : Colors.white) : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(HRTheme.radiusMD),
          border: n.isRead ? null : Border.all(color: color.withOpacity(0.2)),
          boxShadow: HRTheme.cardShadow,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
            child: Icon(_typeIcon(n.type), size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title, style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                color: isDark ? Colors.white : HRTheme.textPrimary,
              ))),
              if (!n.isRead)
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 3),
            Text(n.body, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text(n.type, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
              ),
              const Spacer(),
              Text(n.time, style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textHint)),
            ]),
          ])),
        ]),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Alert': return HRTheme.error;
      case 'Reminder': return HRTheme.warning;
      case 'Circular': return HRTheme.info;
      case 'Announcement': return HRTheme.teal;
      default: return HRTheme.primaryDark;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Alert': return Icons.error_rounded;
      case 'Reminder': return Icons.alarm_rounded;
      case 'Circular': return Icons.article_rounded;
      case 'Announcement': return Icons.campaign_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}
