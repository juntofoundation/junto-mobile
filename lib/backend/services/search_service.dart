import 'package:dio/dio.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/backend/services.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:junto_beta_mobile/models/group_model.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/utils/junto_http.dart';
import 'package:junto_beta_mobile/utils/utils.dart';
import 'package:meta/meta.dart';

@immutable
class SearchServiceCentralized with RFC3339 implements SearchService {
  const SearchServiceCentralized(this.client);

  final JuntoHttp client;

  @override
  Future<QueryResults<UserProfile>> searchMembers(
    String query, {
    QueryUserBy username = QueryUserBy.FULLNAME,
    int paginationPosition = 0,
    String lastTimeStamp,
  }) async {
    final Map<String, String> _queryParam = <String, String>{
      'pagination_position': paginationPosition.toString(),
    };

    if (lastTimeStamp != null) {
      _queryParam.putIfAbsent('last_timestamp', () => lastTimeStamp);
    }

    if (username == QueryUserBy.USERNAME) {
      _queryParam.putIfAbsent('username', () => query);
    } else if (username == QueryUserBy.FULLNAME) {
      _queryParam.putIfAbsent('name', () => query);
    } else {
      _queryParam.putIfAbsent('username', () => query);
      _queryParam.putIfAbsent('name', () => query);
    }

    final Response _serverResponse = await client.get(
      '/search/users',
      queryParams: _queryParam,
    );
    final Map<String, dynamic> _results = JuntoHttp.handleResponse(
      _serverResponse,
    );
    final List<UserProfile> _users = <UserProfile>[
      for (dynamic data in _results['results']) UserProfile.fromJson(data)
    ];
    return QueryResults<UserProfile>(
      results: _users,
      lastTimestamp: _results['last_timestamp'],
    );
  }

  @override
  Future<QueryResults<Channel>> searchChannel(
    String query, {
    int paginationPosition = 0,
    DateTime lastTimeStamp,
  }) async {
    final Map<String, String> _queryParam = <String, String>{
      'pagination_position': paginationPosition.toString(),
      'name': query,
    };

    final Response _serverResponse = await client.get(
      '/search/channels',
      queryParams: _queryParam,
    );
    print(_serverResponse.data);
    final Map<String, dynamic> _results = JuntoHttp.handleResponse(
      _serverResponse,
    );
    final List<Channel> _users = <Channel>[
      for (dynamic data in _results['results']) Channel.fromJson(data)
    ];
    return QueryResults<Channel>(
        results: _users,
        lastTimestamp: _results['last_timestamp'],
        resultCount: _results['result_count']);
  }

  @override
  Future<QueryResults<Group>> searchSphere(
    String query, {
    int paginationPosition = 0,
    DateTime lastTimeStamp,
    bool handle,
  }) async {
    final Map<String, String> _queryParam = <String, String>{
      'pagination_position': paginationPosition.toString(),
    };
    if (handle) {
      _queryParam.putIfAbsent('handle', () => query);
    } else {
      _queryParam.putIfAbsent('name', () => query);
    }

    final Response _serverResponse = await client.get(
      '/search/spheres',
      queryParams: _queryParam,
    );
    logger.logDebug(_serverResponse.statusCode.toString());
    final Map<String, dynamic> _results = JuntoHttp.handleResponse(
      _serverResponse,
    );
    final List<Group> _users = <Group>[
      for (dynamic data in _results['results']) Group.fromJson(data)
    ];
    return QueryResults<Group>(
      results: _users,
      lastTimestamp: _results['last_timestamp'],
    );
  }
}
