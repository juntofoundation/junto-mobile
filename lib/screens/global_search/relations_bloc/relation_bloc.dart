import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/backend/repositories/user_repo.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:junto_beta_mobile/backend/user_data_provider.dart';

part 'relation_event.dart';
part 'relation_state.dart';

class RelationBloc extends Bloc<RelationEvent, RelationState> {
  RelationBloc(this.userRepo, this.userDataProvider)
      : super(InitialRelationState());

  final UserRepo userRepo;
  final UserDataProvider userDataProvider;
  int currentFollowingPos = 0;
  int currentFollowerPos = 0;
  int currentConnectionsPos = 0;
  int followingResultCount = 0;
  int followerResultCount = 0;
  int connectionResultCount = 0;
  String followingLastTimestamp;
  String followersLastTimestamp;
  String connectionsLastTimestamp;

  @override
  Stream<Transition<RelationEvent, RelationState>> transformEvents(
    Stream<RelationEvent> events,
    TransitionFunction<RelationEvent, RelationState> transitionFn,
  ) {
    final nonDebounceStream =
        events.where((event) => event is! FetchMoreRelationship);
    final debounceStream = events
        .where((event) => event is FetchMoreRelationship)
        .debounceTime(const Duration(milliseconds: 600));
    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
  }

  @override
  Stream<RelationState> mapEventToState(
    RelationEvent event,
  ) async* {
    if (event is FetchRealtionship) {
      yield* _mapFetchRealtionshipEventToState(event);
    } else if (event is FetchMoreRelationship) {
      yield* _mapFetchMoreRelationshipEventToState(event);
    }
  }

  Stream<RelationState> _mapFetchRealtionshipEventToState(
      FetchRealtionship event) async* {
    yield RelationLoadingState();

    try {
      List<UserProfile> _followers;
      List<UserProfile> _following;
      List<UserProfile> _connections;
      if (state is InitialRelationState || state is RelationErrorState) {
        _following = [];
        _followers = [];
        _connections = [];
      } else {
        final currentState = state as RelationLoadedState;
        _followers = currentState.followers;
        _following = currentState.following;
        _connections = currentState.connections;
      }

      for (var context in event.context) {
        if (context == RelationContext.follower) {
          currentFollowerPos = 0;
          final results = await userRepo.getFollowers(
            userDataProvider.userAddress,
            event.query,
            currentFollowerPos.toString(),
          );
          _followers = results['users'];
          followersLastTimestamp = results['last_timestamp'];
        } else if (context == RelationContext.following) {
          currentFollowingPos = 0;
          final results = await userRepo.getFollowingUsers(
            userDataProvider.userAddress,
            event.query,
            currentFollowingPos.toString(),
          );
          _following = results['users'];
          followingLastTimestamp = results['last_timestamp'];
        } else if (context == RelationContext.connections) {
          currentConnectionsPos = 0;
          final results = await userRepo.connectedUsers(
            userDataProvider.userAddress,
            event.query,
            currentConnectionsPos.toString(),
          );
          _connections = results['users'];
          connectionsLastTimestamp = results['last_timestamp'];
        }
      }

      yield RelationLoadedState(
        followers: _followers,
        following: _following,
        connections: _connections,
        followerResultCount: followerResultCount,
        followingResultCount: followingResultCount,
        connctionResultCount: connectionResultCount,
      );
    } catch (error, stack) {
      logger.logException(error, stack);
      yield RelationErrorState('Error while fetching relationships');
    }
  }

  Stream<RelationState> _mapFetchMoreRelationshipEventToState(
      FetchMoreRelationship event) async* {
    try {
      List<UserProfile> _followers = [];
      List<UserProfile> _following = [];
      List<UserProfile> _connections = [];
      if (event.context == RelationContext.follower &&
          _followers.length % 50 == 0) {
        currentFollowerPos += 50;
        final results = await userRepo.getFollowers(
          userDataProvider.userAddress,
          event.query,
          currentFollowerPos.toString(),
          followersLastTimestamp,
        );
        _followers = results['users'];
        followersLastTimestamp = results['last_timestamp'];
      } else if (event.context == RelationContext.following &&
          _following.length % 50 == 0) {
        currentFollowingPos += 50;
        final results = await userRepo.getFollowingUsers(
          userDataProvider.userAddress,
          event.query,
          currentFollowingPos.toString(),
          followingLastTimestamp,
        );
        _following = results['users'];
        followingLastTimestamp = results['last_timestamp'];
      } else if (event.context == RelationContext.connections &&
          _connections.length % 50 == 0) {
        currentConnectionsPos += 50;
        final results = await userRepo.connectedUsers(
          userDataProvider.userAddress,
          event.query,
          currentConnectionsPos.toString(),
          connectionsLastTimestamp,
        );
        _connections = results['users'];
        connectionsLastTimestamp = results['last_timestamp'];
      }
      final currentState = state as RelationLoadedState;

      yield RelationLoadedState(
        followers: [...currentState.followers, ..._followers],
        following: [...currentState.following, ..._following],
        connections: [...currentState.connections, ..._connections],
        followerResultCount: currentState.followerResultCount,
        followingResultCount: currentState.followingResultCount,
        connctionResultCount: currentState.connctionResultCount,
      );
    } catch (error, stack) {
      logger.logException(error, stack);
    }
  }

  Future<dynamic> getUserRelations() async {
    final dynamic userRelations = await userRepo.userRelations();

    return userRelations;
  }
}
