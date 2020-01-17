import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/models/models.dart';

class SearchRepo extends SearchService {
  SearchRepo(this._searchService);

  final SearchService _searchService;

  @override
  Future<QueryResults<UserProfile>> searchMembers(String query,
      {bool username = false,
      int paginationPosition = 0,
      DateTime lastTimeStamp}) {
    return _searchService.searchMembers(
      query,
      paginationPosition: paginationPosition,
      lastTimeStamp: lastTimeStamp,
    );
  }

  @override
  Future<QueryResults<String>> searchChannel(String query, {int paginationPosition = 0, DateTime lastTimeStamp}) {
    // TODO: implement searchChannel
    throw UnimplementedError();
  }

  @override
  Future<QueryResults<Group>> searchSphere(String query, {int paginationPosition = 0, DateTime lastTimeStamp}) {
    // TODO: implement searchSphere
    throw UnimplementedError();
  }
}
