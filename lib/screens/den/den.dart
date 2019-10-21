import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/custom_icons.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/providers/provider.dart';
import 'package:junto_beta_mobile/screens/den/den_collection_preview.dart';
import 'package:junto_beta_mobile/screens/den/den_create_collection.dart';
import 'package:junto_beta_mobile/widgets/expression_preview/expression_preview.dart';
import 'package:junto_beta_mobile/widgets/junto_app_delegate.dart';
import 'package:provider/provider.dart';
import 'package:async/async.dart' show AsyncMemoizer;

/// Displays the user's DEN or "profile screen"
class JuntoDen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JuntoDenState();
}

class JuntoDenState extends State<JuntoDen> {
  String profilePicture = 'assets/images/junto-mobile__eric.png';
  final ValueNotifier<UserProfile> _profile = ValueNotifier<UserProfile>(
    UserProfile(username: '', bio: '', firstName: '', lastName: ''),
  );
  bool publicExpressionsActive = true;
  bool publicCollectionActive = false;
  bool privateExpressionsActive = true;
  bool privateCollectionActive = false;

  PageController controller;
  AsyncMemoizer<UserProfile> userMemoizer;
  List<CentralizedExpressionResponse> expressions;
  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
    userMemoizer = AsyncMemoizer<UserProfile>();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    userMemoizer = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _retrieveUserInfo();
    expressions = Provider.of<CollectiveProvider>(context).collectiveExpressions;
  }

  Future<void> _retrieveUserInfo() async {
    final UserProvider _userProvider = Provider.of<UserProvider>(context);
    final UserProfile _results = await userMemoizer.runOnce(() => _userProvider.readLocalUser());
    _profile.value = _results;
  }

  void _togglePublicDomain(String domain) {
    if (domain == 'expressions') {
      setState(() {
        publicExpressionsActive = true;
        publicCollectionActive = false;
      });
    } else if (domain == 'collection') {
      setState(() {
        publicExpressionsActive = false;
        publicCollectionActive = true;
      });
    }
  }

  void _togglePrivateDomain(String domain) {
    if (domain == 'expressions') {
      setState(() {
        privateExpressionsActive = true;
        privateCollectionActive = false;
      });
    } else if (domain == 'collection') {
      setState(() {
        privateExpressionsActive = false;
        privateCollectionActive = true;
      });
    }
  }

  Widget _buildDenList() {
    if (publicExpressionsActive) {
      return ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: const <Widget>[SizedBox()],
      );
    } else if (publicCollectionActive == true) {
      return ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[DenCollectionPreview()],
      );
    } else {
      return const SizedBox();
    }
  }

  final List<String> _tabs = <String>['Open Den', 'Private Den'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            ValueListenableBuilder<UserProfile>(
              valueListenable: _profile,
              builder: (BuildContext context, UserProfile snapshot, _) {
                return JuntoDenAppbar(
                  handle: snapshot.username,
                  name: '${snapshot.firstName} ${snapshot.lastName}',
                  profilePicture: profilePicture,
                  bio: snapshot.bio,
                );
              },
            ),
            SliverPersistentHeader(
              delegate: JuntoAppBarDelegate(
                TabBar(
                  labelPadding: const EdgeInsets.all(0),
                  isScrollable: true,
                  labelColor: const Color(0xff333333),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff333333),
                  ),
                  indicatorWeight: 0.0001,
                  tabs: _tabs
                      .map((String name) => Container(
                          margin: const EdgeInsets.only(right: 24),
                          color: Colors.white,
                          child: Tab(
                            text: name,
                          )))
                      .toList(),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          children: <Widget>[
            ValueListenableBuilder<UserProfile>(
              valueListenable: _profile,
              builder: (BuildContext context, UserProfile snapshot, _) {
                return UserExpressions(
                  key: const PageStorageKey<String>('public-user-expressions'),
                  privacy: 'Public',
                  userProfile: snapshot,
                );
              },
            ),
            ValueListenableBuilder<UserProfile>(
              valueListenable: _profile,
              builder: (BuildContext context, UserProfile snapshot, _) {
                return UserExpressions(
                  key: const PageStorageKey<String>('private-user-expressions'),
                  privacy: 'Private',
                  userProfile: snapshot,
                );
              },
            ),
            // _buildOpenDen(),
            // _buildPrivateDen(),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenDen() {
    if (publicExpressionsActive) {
      return ListView(
        children: <Widget>[
          DenToggle(
            onLotusTap: () => _togglePublicDomain('expressions'),
            onCollectionsTap: () => _togglePublicDomain('collection'),
            active: publicCollectionActive,
          ),
          ExpressionPreview(
            expression: expressions[0],
          ),
          ExpressionPreview(
            expression: expressions[1],
          ),
          ExpressionPreview(
            expression: expressions[0],
          ),
          ExpressionPreview(
            expression: expressions[1],
          ),
        ],
      );
    } else if (publicCollectionActive) {
      return ListView(
        children: <Widget>[
          DenToggle(
            onLotusTap: () => _togglePublicDomain('expressions'),
            onCollectionsTap: () => _togglePublicDomain('collection'),
            active: publicCollectionActive,
          ),
          _buildDenList()
        ],
      );
    }
    return Container();
  }

  Widget _buildPrivateDen() {
    if (privateExpressionsActive) {
      return ListView(
        children: <Widget>[
          ExpressionPreview(
            expression: expressions[0],
          ),
          ExpressionPreview(
            expression: expressions[1],
          ),
          ExpressionPreview(
            expression: expressions[0],
          ),
          ExpressionPreview(
            expression: expressions[1],
          ),
        ],
      );
    } else if (privateCollectionActive) {
      return ListView(
        children: <Widget>[
          DenToggle(
            onCollectionsTap: () => _togglePrivateDomain('expressions'),
            onLotusTap: () => _togglePrivateDomain('collection'),
            active: privateCollectionActive,
          ),
          _buildDenList()
        ],
      );
    }
    return Container();
  }
}

/// Linear list of expressions created by the given [userProfile].
class UserExpressions extends StatefulWidget {
  const UserExpressions({
    Key key,
    @required this.userProfile,
    @required this.privacy,
  }) : super(key: key);

  /// [UserProfile] of the user
  final UserProfile userProfile;

  /// Either Public or Private;
  final String privacy;

  @override
  _UserExpressionsState createState() => _UserExpressionsState();
}

class _UserExpressionsState extends State<UserExpressions> {
  UserProvider _userProvider;
  AsyncMemoizer<List<CentralizedExpressionResponse>> memoizer = AsyncMemoizer<List<CentralizedExpressionResponse>>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context);
  }

  Future<List<CentralizedExpressionResponse>> getExpressions() {
    return memoizer.runOnce(
      () => _userProvider.getUsersExpressions(
        widget.userProfile.address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return FutureBuilder<List<CentralizedExpressionResponse>>(
      future: getExpressions(),
      builder: (BuildContext context, AsyncSnapshot<List<CentralizedExpressionResponse>> snapshot) {
        if (snapshot.hasData) {
          final List<CentralizedExpressionResponse> _data = snapshot.data
              .where((CentralizedExpressionResponse expression) => expression.privacy == widget.privacy)
              .toList(growable: false);
          return ListView.builder(
            itemCount: _data.length,
            itemBuilder: (BuildContext context, int index) {
              return ExpressionPreview(
                expression: _data[index],
              );
            },
          );
        }
        if (snapshot.hasError) {
          return Container(
            height: media.size.height,
            width: media.size.width,
            child: const Center(
              child: Text('Error occured :('),
            ),
          );
        }
        return Container(
          height: media.size.height,
          width: media.size.width,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class DenToggle extends StatelessWidget {
  const DenToggle({
    Key key,
    @required this.onCollectionsTap,
    @required this.onLotusTap,
    @required this.active,
  }) : super(key: key);

  final VoidCallback onCollectionsTap;
  final VoidCallback onLotusTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(2.5),
                height: 30,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: onLotusTap,
                      child: Container(
                        height: 30,
                        // half width of parent container minus horizontal padding
                        width: 37.5,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : const Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          CustomIcons.half_lotus,
                          size: 12,
                          color: active ? const Color(0xff555555) : const Color(0xff999999),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onCollectionsTap,
                      child: Container(
                        height: 30,
                        // half width of parent container minus horizontal padding
                        width: 37.5,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : const Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.collections,
                          size: 12,
                          color: active ? const Color(0xff555555) : const Color(0xff999999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              active
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute<dynamic>(
                            builder: (BuildContext context) => DenCreateCollection(),
                          ),
                        );
                      },
                      child: Container(
                        width: 38,
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: const Color(0xff555555),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          )
        ],
      ),
    );
  }
}
