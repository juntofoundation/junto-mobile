import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:junto_beta_mobile/models/group_model.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/models/user_model.dart';

import 'expression_slim_model.dart';

part 'junto_notification.freezed.dart';
part 'junto_notification.g.dart';

enum NotificationType {
  ConnectionNotification,
  GroupJoinRequest,
  NewComment,
  NewSubscription,
  NewConnection,
  NewPackJoin,
  NewMention,
}

//We store notifications list in Hive as json not as an object
/// JuntoNotification model retrieved from API and used in views to show in app notifications
///
/// Depending on type there can be different fields available
///
/// - For [NotificationType.connectionNotification] it's [user]
/// - For [NotificationType.groupJoinRequests] it's [group] and [creator]
/// - For [NotificationType.newComment] it's [user] and [expression]
/// - For [NotificationType.newSubscription] it's [user]
/// - For [NotificationType.newConnection] it's [user]
/// - For [NotificationType.newPackJoin] it's [user]
@freezed
abstract class JuntoNotification with _$JuntoNotification {
  factory JuntoNotification(
    String address,
    NotificationType notificationType,
    DateTime createdAt, {
    @JsonKey(fromJson: JuntoNotification.userFromJson, toJson: JuntoNotification.userToJson)
        UserProfile user,
    @JsonKey(fromJson: JuntoNotification.groupFromJson, toJson: JuntoNotification.groupToJson)
        Group group,
    @JsonKey(fromJson: JuntoNotification.userFromJson, toJson: JuntoNotification.userToJson)
        UserProfile creator,
    ExpressionSlimModel commentExpression,
    ExpressionSlimModel sourceExpression,
    @Default(true) bool unread,
  }) = _Notification;

  factory JuntoNotification.fromJson(Map<String, dynamic> json) =>
      _$JuntoNotificationFromJson(json);

// These methods are here because in these models there are factory constructors
// and instance methods used for fromMap and toMap calls
  static Group groupFromJson(Map<String, dynamic> json) {
    if (json != null) {
      return Group.fromJson(json);
    }
    return null;
  }

  static Map<String, dynamic> groupToJson(Group obj) => obj?.toJson();

  static UserProfile userFromJson(Map<String, dynamic> json) {
    if (json != null) {
      return UserProfile.fromJson(json);
    }
    return null;
  }

  static Map<String, dynamic> userToJson(UserProfile obj) => obj?.toJson();
}

class JuntoNotificationAdapter extends TypeAdapter<JuntoNotification> {
  @override
  final typeId = 6;

  @override
  JuntoNotification read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final data = fields[0] as String;
    final notification = JuntoNotification.fromJson(jsonDecode(data));
    return notification;
  }

  @override
  void write(BinaryWriter writer, JuntoNotification obj) {
    final json = jsonEncode(obj.toJson());
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(json);
  }
}

class NotificationPrefsModel {
  NotificationPrefsModel({
    this.comment,
    this.connection,
    this.connectionRequest,
    this.general,
    this.groupJoinRequest,
    this.mention,
    this.packRelation,
    this.subscribe,
  });

  factory NotificationPrefsModel.disabled() {
    return NotificationPrefsModel(
      comment: false,
      connection: false,
      connectionRequest: false,
      general: false,
      groupJoinRequest: false,
      mention: false,
      packRelation: false,
      subscribe: false,
    );
  }

  factory NotificationPrefsModel.enabled() {
    return NotificationPrefsModel(
      comment: true,
      connection: true,
      connectionRequest: true,
      general: true,
      groupJoinRequest: true,
      mention: true,
      packRelation: true,
      subscribe: true,
    );
  }

  NotificationPrefsModel copyWith({
    bool comment,
    bool connection,
    bool connectionRequest,
    bool general,
    bool groupJoinRequest,
    bool mention,
    bool packRelation,
    bool subscribe,
  }) {
    return NotificationPrefsModel(
      comment: comment ?? this.comment,
      connection: connection ?? this.connection,
      connectionRequest: connectionRequest ?? this.connectionRequest,
      general: general ?? this.general,
      groupJoinRequest: groupJoinRequest ?? this.groupJoinRequest,
      mention: mention ?? this.mention,
      packRelation: packRelation ?? this.packRelation,
      subscribe: subscribe ?? this.subscribe,
    );
  }

  @HiveField(0)
  bool comment;
  @HiveField(1)
  bool connection;
  @HiveField(2)
  bool connectionRequest;
  @HiveField(3)
  bool general;
  @HiveField(4)
  bool groupJoinRequest;
  @HiveField(5)
  bool mention;
  @HiveField(6)
  bool packRelation;
  @HiveField(7)
  bool subscribe;

  factory NotificationPrefsModel.fromMap(Map<String, dynamic> json) =>
      NotificationPrefsModel(
        comment: json["comment"],
        connection: json["connection"],
        connectionRequest: json["connection_request"],
        general: json["general"],
        groupJoinRequest: json["group_join_request"],
        mention: json["mention"],
        packRelation: json["pack_relation"],
        subscribe: json["subscribe"],
      );

  Map<String, dynamic> toMap() => {
        "comment": comment,
        "connection": connection,
        "connection_request": connectionRequest,
        "general": general,
        "group_join_request": groupJoinRequest,
        "mention": mention,
        "pack_relation": packRelation,
        "subscribe": subscribe,
      };
}
