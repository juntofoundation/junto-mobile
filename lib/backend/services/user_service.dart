import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:junto_beta_mobile/api.dart';
import 'package:junto_beta_mobile/backend/services.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/models/perspective.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/utils/junto_exception.dart';
import 'package:junto_beta_mobile/utils/junto_http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class UserServiceCentralized implements UserService {
  const UserServiceCentralized(this.client);

  final JuntoHttp client;

  /// Creates a [Perspective] on the server. Function takes a single argument.
  @override
  Future<CentralizedPerspective> createPerspective(
      Perspective perspective) async {
    final Map<String, dynamic> _postBody = <String, dynamic>{
      'name': perspective.name,
      'members': perspective.members,
      'about': perspective.about,
    };
    final http.Response _serverResponse = await client.postWithoutEncoding(
      '/perspectives',
      body: _postBody,
    );
    final Map<String, dynamic> _body =
        JuntoHttp.handleResponse(_serverResponse);
    return CentralizedPerspective.fromMap(_body);
  }

  @override
  Future<UserProfile> addUserToPerspective(
      String perspectiveAddress, List<String> userAddress) async {
    final List<dynamic> users = <dynamic>[];
    userAddress.map(
      (String uid) => users.add(
        <String, dynamic>{'user_address': uid},
      ),
    );
    final http.Response _serverResponse = await client.postWithoutEncoding(
      '/perspectives/$perspectiveAddress/users',
      body: users,
    );

    final Map<String, dynamic> _body =
        JuntoHttp.handleResponse(_serverResponse);
    print(_body);

    return UserProfile.fromMap(_body);
  }

  @override
  Future<UserData> getUser(String userAddress) async {
    final http.Response _serverResponse =
        await client.get('/users/$userAddress');
    final Map<String, dynamic> _resultMap =
        JuntoHttp.handleResponse(_serverResponse);
    final UserData _userData = UserData.fromMap(_resultMap);
    return _userData;
  }

  @override
  Future<UserProfile> queryUser(String param, QueryType queryType) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String authKey = _prefs.getString('auth');

    final Uri _uri = Uri.http(
      END_POINT_without_prefix,
      '/users',
      _buildQueryParam(param, queryType),
    );

    final http.Response _serverResponse = await http.get(
      _uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'cookie': 'auth=$authKey',
      },
    );
    if (_serverResponse.statusCode == 200) {
      final Iterable<dynamic> _listData = json.decode(_serverResponse.body);

      if (_listData.isNotEmpty) {
        return UserProfile.fromMap(_listData.first);
      }
      throw JuntoException(
          'Unable to retrive user profile', _serverResponse.statusCode);
    }
    throw JuntoException('Forbidden, please log out and log back in',
        _serverResponse.statusCode);
  }

  @override
  Future<List<CentralizedPerspective>> getUserPerspective(
      String userAddress) async {
    final http.Response response =
        await client.get('/users/$userAddress/perspectives');
    final List<dynamic> _listData = JuntoHttp.handleResponse(response);
    final List<CentralizedPerspective> _results = _listData
        .map((dynamic data) => CentralizedPerspective.fromMap(data))
        .toList(growable: false);
    return _results;
  }

  @override
  Future<UserGroupsResponse> getUserGroups(String userAddress) async {
    final http.Response response =
        await client.get('/users/$userAddress/groups');
    print(response.body);
    final Map<String, dynamic> _responseMap =
        JuntoHttp.handleResponse(response);
    return UserGroupsResponse.fromMap(_responseMap);
  }

  @override
  Future<List<CentralizedExpressionResponse>> getUsersResonations(
    String userAddress,
  ) async {
    final http.Response response =
        await client.get('/users/$userAddress/resonations');
    final List<dynamic> _responseMap = JuntoHttp.handleResponse(response);
    return _responseMap
        .map(
          (dynamic data) =>
              CentralizedExpressionResponse.withCommentsAndResonations(data),
        )
        .toList();
  }

  @override
  Future<List<CentralizedExpressionResponse>> getUsersExpressions(
    String userAddress,
  ) async {
    final http.Response response = await client.get(
        '/users/$userAddress/expressions',
        queryParams: <String, String>{'pagination_position': '0'});
    final Map<String, dynamic> _responseMap =
        JuntoHttp.handleResponse(response);
    return <CentralizedExpressionResponse>[
      for (dynamic data in _responseMap['results'])
        CentralizedExpressionResponse.fromMap(data)
    ];
  }

  @override
  Future<UserData> readLocalUser() async {
    final LocalStorage _storage = LocalStorage('user-details');
    final bool isReady = await _storage.ready;
    if (isReady) {
      final dynamic data = _storage.getItem('data');
      if (data != null) {
        final UserData profile = UserData.fromMap(data);

        return profile;
      }
    }
    throw const JuntoException('Unable to read local user', -1);
  }

  @override
  Future<List<CentralizedPerspective>> userPerspectives(
      String userAddress) async {
    final http.Response _serverResponse =
        await client.get('/users/$userAddress/perspectives');
    final List<Map<String, dynamic>> items =
        JuntoHttp.handleResponse(_serverResponse);
    print(items);
    return items.map(
      (Map<String, dynamic> data) => CentralizedPerspective.fromMap(data),
    );
  }

  @override
  Future<UserProfile> createPerspectiveUserEntry(
    String userAddress,
    String perspectiveAddress,
  ) async {
    final Map<String, dynamic> _postBody = <String, dynamic>{
      'user_address': userAddress
    };
    final http.Response _serverResponse = await client.postWithoutEncoding(
        '/perspectives/$perspectiveAddress/users',
        body: _postBody);
    final Map<String, dynamic> _decodedResponse =
        JuntoHttp.handleResponse(_serverResponse);
    return UserProfile.fromMap(_decodedResponse);
  }

  @override
  Future<void> deletePerspectiveUserEntry(
    String userAddress,
    String perspectiveAddress,
  ) async {
    final http.Response _serverResponse =
        await client.delete('/perspectives/$perspectiveAddress/users');
    JuntoHttp.handleResponse(_serverResponse);
  }

  @override
  Future<List<UserProfile>> getPerspectiveUsers(
    String perspectiveAddress,
  ) async {
    final http.Response _serverResponse =
        await client.get('/perspectives/$perspectiveAddress/users');
    final List<dynamic> _results = JuntoHttp.handleResponse(_serverResponse);
    return <UserProfile>[
      for (dynamic data in _results) UserProfile.fromMap(data)
    ];
  }

  @override
  Future<void> connectUser(String userAddress) async {
    final http.Response _serverResponse = await client.postWithoutEncoding(
      '/users/$userAddress/connect',
    );
    JuntoHttp.handleResponse(_serverResponse);
  }

  @override
  Future<void> removeUserConnection(String userAddress) async {
    final http.Response _serverResponse = await client.delete(
      '/users/$userAddress/connect',
    );
    JuntoHttp.handleResponse(_serverResponse);
  }

  @override
  Future<List<UserProfile>> connectedUsers(String userAddress) async {
    final http.Response _serverResponse = await client.get(
      '/users/$userAddress/connections',
    );
    final List<dynamic> _results =
        await JuntoHttp.handleResponse(_serverResponse);

    final List<UserProfile> _resultsList = <UserProfile>[];

    // ignore: avoid_function_literals_in_foreach_calls
    _results.forEach((dynamic result) {
      _resultsList.add(
        UserProfile(
          address: result['user']['address'],
          bio: result['user']['bio'],
          username: result['user']['username'],
          name: result['user']['name'],
          profilePicture: <String>[],
          gender: List<String>.from(result['user']['gender']),
          location: List<String>.from(result['user']['location']),
          verified: true,
          website: List<String>.from(result['user']['website']),
        ),
      );
    });

    return _resultsList;
  }

  @override
  Future<List<UserProfile>> pendingConnections(String userAddress) async {
    final http.Response _serverResponse = await client.get(
      '/notifications',
    );
    final List<dynamic> _results = JuntoHttp.handleResponse(_serverResponse);
    return <UserProfile>[
      for (dynamic data in _results) UserProfile.fromMap(data)
    ];
  }

//TODO(Nash): This should send back a success result of either true or false.
  @override
  Future<void> respondToConnection(String userAddress, bool response) async {
    final http.Response _serverResponse = await client.postWithoutEncoding(
      '/users/$userAddress/connect/respond',
      body: <String, dynamic>{
        'status': response,
      },
    );
    JuntoHttp.handleResponse(_serverResponse);
  }

  @override
  Future<UserData> updateUser(
      Map<String, dynamic> user, String userAddress) async {
    print('calling update user');
    final String encodedUser = json.encode(user);
    final http.Response _serverResponse =
        await client.patch('/users/' + userAddress, body: encodedUser);
    print(_serverResponse.statusCode);
    print(_serverResponse.body);
    final Map<String, dynamic> _data =
        JuntoHttp.handleResponse(_serverResponse);
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final String _userMapToString = json.encode(_data);

    _prefs.remove('user_data');
    _prefs.setString('user_data', _userMapToString);
    return UserData.fromMap(_data);
  }

  /// Private function which returns the correct query param for the given
  /// [QueryType]
  Map<String, dynamic> _buildQueryParam(String param, QueryType queryType) {
    if (queryType == QueryType.address) {
      return <String, String>{
        'address': param,
      };
    } else if (queryType == QueryType.email) {
      return <String, String>{
        'email': param,
      };
    } else {
      return <String, String>{
        'username': param,
      };
    }
  }
}
