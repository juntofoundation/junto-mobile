import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/notifications/notifications_handler.dart';
import 'package:junto_beta_mobile/screens/notifications/widgets/notification_placeholder.dart';
import 'package:junto_beta_mobile/screens/notifications/widgets/notification_tile.dart';
import 'package:provider/provider.dart';

class NotificationsRelationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Consumer<NotificationsHandler>(
          builder: (context, data, child) {
            final notifications = data.notifications;
            List relationsNotifications = [];
            for (final notification in notifications) {
              if (notification.notificationType !=
                      NotificationType.NewComment &&
                  notification.notificationType !=
                      NotificationType.NewMention) {
                relationsNotifications.add(notification);
              }
            }
            if (relationsNotifications.isNotEmpty) {
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  if (notifications.length > 0 &&
                      item.notificationType != NotificationType.NewComment &&
                      item.notificationType != NotificationType.NewMention) {
                    if (item.notificationType ==
                            NotificationType.GroupJoinRequest &&
                        item.creator != null &&
                        item.creator.username.isNotEmpty) {
                      return NotificationTile(item: item);
                    } else if (item.notificationType !=
                            NotificationType.GroupJoinRequest &&
                        item.user != null &&
                        item.user.username.isNotEmpty) {
                      return NotificationTile(item: item);
                    }
                    return SizedBox();
                  } else {
                    return SizedBox();
                  }
                },
              );
            } else {
              return NotificationPlaceholder();
            }
          },
        )),
      ],
    );
  }
}
