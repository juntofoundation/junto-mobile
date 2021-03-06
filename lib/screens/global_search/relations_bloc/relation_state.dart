part of 'relation_bloc.dart';

@immutable
abstract class RelationState {}

class InitialRelationState extends RelationState {}

class EmptyRelationState extends RelationState {}

class RelationLoadingState extends RelationState {}

class RelationErrorState extends RelationState {
  final String message;

  RelationErrorState(this.message);
}

@immutable
class RelationLoadedState extends RelationState {
  final List<UserProfile> following;
  final List<UserProfile> followers;
  final List<UserProfile> connections;
  final int followerResultCount;
  final int followingResultCount;
  final int connctionResultCount;

  RelationLoadedState({
    this.followerResultCount,
    this.followingResultCount,
    this.connctionResultCount,
    this.following,
    this.followers,
    this.connections,
  });
}
