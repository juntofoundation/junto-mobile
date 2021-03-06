import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/models/expression_query_params.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/utils/junto_exception.dart';
import 'package:meta/meta.dart';

part 'pack_event.dart';
part 'pack_state.dart';

class PackBloc extends Bloc<PackEvent, PackState> {
  PackBloc(this.expressionRepo, this.groupRepo, {this.initialGroup})
      : super(PackInitial());

  final ExpressionRepo expressionRepo;
  final GroupRepo groupRepo;
  final String initialGroup;
  String _currentGroup;
  String _lastTimestamp;

  Map<String, String> _params;
  int _currentPos = 0;
  int _membersPos = 0;
  String _lastMemberTimeStamp;

  @override
  Stream<PackState> mapEventToState(
    PackEvent event,
  ) async* {
    if (event is FetchPacks) {
      yield* _mapFetchPacksToState(event);
    }
    if (event is RefreshPacks) {
      yield* _mapRefreshPacksToState(event);
    }
    if (event is DeletePackExpression) {
      yield* _mapDeletePackExpression(event);
    }
    if (event is FetchMorePacks) {
      yield* _mapFetchMorePacksToState(event);
    }
    if (event is FetchMorePacksMembers) {
      yield* _mapFetchMoreMembersToState(event);
    }
  }

  Stream<PackState> _mapFetchPacksToState(FetchPacks event) async* {
    if (event.group != null) {
      _currentGroup = event.group;
    }
    final Group group = await groupRepo.getGroup(_currentGroup ?? initialGroup);
    _currentGroup = group.address;
    _params = <String, String>{
      'context': group.address,
      'context_type': 'Group',
      'pagination_position': _currentPos.toString(),
      if (event.channel != null) 'channels[0]': event.channel,
    };
    try {
      yield PacksLoading();
      final _results = await _fetchExpressionAndMembers();
      QueryResults<ExpressionResponse> publicQueryResults = _results[0];
      QueryResults<ExpressionResponse> privateQueryResults = _results[1];
      List<Users> members = _results[2];
      yield PacksLoaded(
        publicQueryResults,
        privateQueryResults,
        members,
        group,
      );
    } on JuntoException catch (error) {
      yield PacksError(error.message);
    } catch (e, s) {
      logger.logException(e, s);
      yield PacksError();
    }
  }

  Stream<PackState> _mapRefreshPacksToState(RefreshPacks refreshEvent) async* {
    try {
      if (state is PacksLoaded) {
        _currentPos = 0;
        _lastTimestamp = null;
        final _results = await _fetchExpressionAndMembers();
        QueryResults<ExpressionResponse> publicQueryResults = _results[0];
        QueryResults<ExpressionResponse> privateQueryResults = _results[1];
        List<Users> members = _results[2];
        final PacksLoaded currentResults = state as PacksLoaded;
        yield PacksLoaded(
          publicQueryResults,
          privateQueryResults,
          members,
          currentResults.pack,
        );
      }
    } on JuntoException catch (e, s) {
      logger.logException(e, s);
      yield PacksError();
    }
  }

  Stream<PackState> _mapFetchMorePacksToState(FetchMorePacks event) async* {
    _currentPos = _currentPos + 50;
    _params['pagination_position'] = '$_currentPos';
    _params['last_timestamp'] = _lastTimestamp;

    try {
      if (_params != null && state is PacksLoaded) {
        final PacksLoaded currentResults = state as PacksLoaded;
        yield PacksLoaded(
          currentResults.publicExpressions,
          currentResults.privateExpressions,
          currentResults.groupMemebers,
          currentResults.pack,
        );

        final _results = await _fetchExpressionAndMembers();
        QueryResults<ExpressionResponse> publicQueryResults = _results[0];
        QueryResults<ExpressionResponse> privateQueryResults = _results[1];
        List<Users> members = _results[2];

        if (publicQueryResults.results.length > 1) {
          currentResults.publicExpressions.results
              .addAll(publicQueryResults.results);
        }
        if (privateQueryResults.results.length > 1) {
          currentResults.privateExpressions.results
              .addAll(privateQueryResults.results);
        }

        yield PacksLoaded(
          currentResults.publicExpressions,
          currentResults.privateExpressions,
          members,
          currentResults.pack,
        );
      }
    } on JuntoException catch (error) {
      yield PacksError(error.message);
    } catch (e, s) {
      logger.logException(e, s);
      yield PacksError();
    }
  }

  Stream<PackState> _mapFetchMoreMembersToState(event) async* {
    try {
      final currentState = state as PacksLoaded;
      final publicExpressions = currentState.publicExpressions;
      final privateExpressions = currentState.privateExpressions;
      final currentMembers = currentState.groupMemebers;
      yield PacksLoaded(
        publicExpressions,
        privateExpressions,
        currentMembers,
        currentState.pack,
      );

      _membersPos += 50;
      final ExpressionQueryParams _params = ExpressionQueryParams(
        paginationPosition: '$_membersPos',
        lastTimestamp: _lastMemberTimeStamp,
      );
      final _updatedMembers = await _getMembers(_currentGroup, _params);
      if (_updatedMembers.results.length > 1) {
        currentMembers.addAll(_updatedMembers.results);
        yield PacksLoaded(
          publicExpressions,
          privateExpressions,
          currentMembers,
          currentState.pack,
        );
      }
    } catch (error, stack) {
      logger.logException(error, stack);
      yield PacksError();
    }
  }

  Stream<PackState> _mapDeletePackExpression(
      DeletePackExpression event) async* {
    try {
      await expressionRepo.deleteExpression(event.expressionAddress);
      final currentState = state as PacksLoaded;
      final publicExpressions = currentState.publicExpressions.results.toList();
      publicExpressions
          .removeWhere((element) => element.address == event.expressionAddress);
      final privateExpression =
          currentState.privateExpressions.results.toList();
      privateExpression
          .removeWhere((element) => element.address == event.expressionAddress);

      final publicResults = QueryResults<ExpressionResponse>(
        lastTimestamp: currentState.publicExpressions.lastTimestamp,
        results: publicExpressions,
        resultCount: publicExpressions.length,
      );
      final privateResults = QueryResults<ExpressionResponse>(
        lastTimestamp: currentState.privateExpressions.lastTimestamp,
        results: privateExpression,
        resultCount: privateExpression.length,
      );
      yield PacksLoaded(
        publicResults,
        privateResults,
        currentState.groupMemebers,
        currentState.pack,
      );
    } catch (error, stack) {
      logger.logException(error, stack);
      yield PacksError();
    }
    ;
  }

  Future<List> _fetchExpressionAndMembers() async {
    final QueryResults<ExpressionResponse> results =
        await expressionRepo.getPackExpressions(
      _params,
    );
    final members = await _getMembers(
        _currentGroup, ExpressionQueryParams(paginationPosition: '0'));

    List<ExpressionResponse> _public = results.results
        .where((element) => element.privacy == 'Public')
        .toList();
    List<ExpressionResponse> _private = results.results
        .where((element) => element.privacy == 'Private')
        .toList();

    _lastTimestamp = results.lastTimestamp;

    final publicQueryResults = QueryResults(
      results: _public,
      lastTimestamp: results.lastTimestamp,
    );
    final privateQueryResults = QueryResults(
      results: _private,
      lastTimestamp: results.lastTimestamp,
    );
    logger.logInfo(
        'Fetched ${publicQueryResults.results.length} public query results and ${privateQueryResults.results.length} private query results');

    return [publicQueryResults, privateQueryResults, members.results];
  }

  Future<QueryResults<Users>> _getMembers(
      final String groupAddress, ExpressionQueryParams params) async {
    final result = await groupRepo.getGroupMembers(groupAddress, params);
    _lastMemberTimeStamp = result.lastTimestamp;
    return result;
  }

  @override
  String toString() => 'PackBloc';
}
