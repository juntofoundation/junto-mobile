import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/groups/circles/sphere_open/sphere_open_members/sphere_open_members.dart';
import 'package:junto_beta_mobile/widgets/avatars/member_avatar.dart';
import 'package:readmore/readmore.dart';

class SphereOpenAbout extends StatelessWidget {
  const SphereOpenAbout({
    this.group,
    this.circleCreator,
    this.members = const <Users>[],
    this.relationToGroup,
    this.totalMembers,
    this.totalFacilitators,
  });

  final UserProfile circleCreator;
  final List<Users> members;
  final Map<String, dynamic> relationToGroup;
  final int totalMembers;
  final int totalFacilitators;

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: <Widget>[
        CircleBio(
          group: group,
        ),
        if (members != null)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute<dynamic>(
                  builder: (BuildContext context) => SphereOpenMembers(
                    group: group,
                    relationToGroup: relationToGroup,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: .5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleMembers(
                    members: members,
                    totalMembers: totalMembers,
                  ),
                  if (circleCreator != null)
                    CircleFacilitators(
                      members: members,
                      circleCreator: circleCreator,
                    ),
                  SeeAllMembers()
                ],
              ),
            ),
          ),
        if (members == null) const SizedBox()
      ],
    );
  }
}

class CircleBio extends StatelessWidget {
  const CircleBio({this.group});
  final Group group;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: .5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bio & Purpose',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                ReadMoreText(
                  group.groupData.description,
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  trimExpandedText: ' Close',
                  trimCollapsedText: '...Show More',
                  delimiter: '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleMembers extends StatelessWidget {
  const CircleMembers({
    this.members,
    this.totalMembers = 0,
  });

  final List<Users> members;
  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Members (${totalMembers ?? 0})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          color: Colors.transparent,
          margin: const EdgeInsets.only(bottom: 15),
          child: Row(children: <Widget>[
            for (Users user in members)
              if (members.indexOf(user) < 7)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: MemberAvatar(
                    profilePicture: user.user.profilePicture,
                    diameter: 28,
                  ),
                ),
          ]),
        ),
      ],
    );
  }
}

class CircleFacilitators extends StatelessWidget {
  const CircleFacilitators({
    this.members,
    this.circleCreator,
  });

  final List<Users> members;
  final UserProfile circleCreator;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Facilitators',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.transparent,
          child: Row(children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: MemberAvatar(
                profilePicture: circleCreator.profilePicture,
                diameter: 28,
              ),
            ),
            for (Users user in members)
              if (user.permissionLevel == 'Admin')
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: MemberAvatar(
                    profilePicture: user.user.profilePicture,
                    diameter: 28,
                  ),
                ),
          ]),
        ),
      ],
    );
  }
}

class SeeAllMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: .5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'See All',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColorLight,
            size: 17,
          )
        ],
      ),
    );
  }
}
