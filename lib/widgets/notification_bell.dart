import 'package:flutter/material.dart';

import '../core/auth/auth_session.dart';
import '../core/notifications/notification_store.dart';
import '../core/theme/app_colors.dart';
import '../screens/notifications/notifications_screen.dart';

class NotificationBell
    extends StatefulWidget {
  const NotificationBell({
    super.key,
  });

  @override
  State<NotificationBell> createState() =>
      _NotificationBellState();
}

class _NotificationBellState
    extends State<NotificationBell> {
  final _store =
      NotificationStore.instance;

  final _session =
      AuthSession.instance;

  @override
  Widget build(
    BuildContext context,
  ) {
    final unread =
        _store.unreadCountForUser(
      _session.currentUser.id,
    );

    return IconButton(
      tooltip:
          'الإشعارات',
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const NotificationsScreen(),
          ),
        );

        if (mounted) {
          setState(() {});
        }
      },
      icon: Stack(
        clipBehavior:
            Clip.none,
        children: [
          const Icon(
            Icons
                .notifications_outlined,
            size: 24,
          ),
          if (unread > 0)
            Positioned(
              right: -2,
              top: -3,
              child: Container(
                constraints:
                    const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 4,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.like,
                  borderRadius:
                      BorderRadius.circular(
                    999,
                  ),
                  border:
                      Border.all(
                    color:
                        AppColors.background,
                    width: 2,
                  ),
                ),
                child: Text(
                  unread > 9
                      ? '9+'
                      : '$unread',
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
