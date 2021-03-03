part of 'circle_bloc.dart';

abstract class CircleEvent {
  const CircleEvent();
}

class FetchMyCircle extends CircleEvent {}

class RefreshCircle extends CircleEvent {}

class UpdateCircle extends CircleEvent {
  final Group group;

  UpdateCircle({
    this.group,
  });
}

class LeaveCircle extends CircleEvent {
  final String sphereAdress;
  final String userAddress;

  LeaveCircle({
    this.sphereAdress,
    this.userAddress,
  });
}

class DeleteCircle extends CircleEvent {
  final String sphereAddress;

  DeleteCircle({
    this.sphereAddress,
  });
}

class LoadCircleMembers extends CircleEvent {
  final String sphereAddress;

  LoadCircleMembers({
    this.sphereAddress,
  });
}

class LoadCircleMembersMore extends CircleEvent {
  final String sphereAddress;

  LoadCircleMembersMore({
    this.sphereAddress,
  });
}

class AddMemberToCircle extends CircleEvent {
  final String sphereAddress;
  final List<UserProfile> user;
  // Can be one of these values: Admin | Member
  final String permissionLevel;

  AddMemberToCircle({
    this.sphereAddress,
    this.user,
    this.permissionLevel,
  });
}

class RemoveMemberFromCircle extends CircleEvent {
  final String sphereAdress;
  final String userAddress;

  RemoveMemberFromCircle({
    this.sphereAdress,
    this.userAddress,
  });
}
