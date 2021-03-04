import 'dart:io';

import 'package:async/async.dart' show AsyncMemoizer;
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/app/palette.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/groups/circles/create_sphere/create_sphere_page_one.dart';
import 'package:junto_beta_mobile/screens/groups/circles/create_sphere/create_sphere_page_two.dart';
import 'package:junto_beta_mobile/utils/junto_exception.dart';
import 'package:junto_beta_mobile/utils/junto_overlay.dart';
import 'package:junto_beta_mobile/widgets/dialogs/single_action_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/screens/groups/circles/bloc/circle_bloc.dart';

class CreateSphere extends StatefulWidget {
  const CreateSphere({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CreateSphereState();
  }
}

class CreateSphereState extends State<CreateSphere> {
  ValueNotifier<File> imageFile = ValueNotifier<File>(null);
  int _currentIndex = 0;
  String sphereName;
  String sphereHandle;
  String sphereDescription;

  PageController createSphereController;
  TextEditingController sphereNameController;
  TextEditingController sphereHandleController;
  TextEditingController sphereDescriptionController;
  String _currentPrivacy = 'Public';

  GlobalKey<FormState> _formKey;

  final List<String> _sphereMembers = <String>[];
  final List<String> _tabs = <String>['Subscriptions', 'Connections'];
  final AsyncMemoizer<Map<String, dynamic>> _memoizer =
      AsyncMemoizer<Map<String, dynamic>>();

  Future<void> _createSphere() async {
    JuntoLoader.showLoader(context);

    // instantiate sphere image key
    String sphereImageKey = '';

    // check if user uploaded a photo for the sphere
    if (imageFile.value != null) {
      try {
        final String _photoKey =
            await Provider.of<ExpressionRepo>(context, listen: false)
                .createPhoto(true, '.png', imageFile.value);
        sphereImageKey = _photoKey;
      } catch (error) {
        print(error);
        JuntoLoader.hide();
      }
    }

    // create sphere body
    final SphereModel sphere = SphereModel(
      name: sphereName,
      description: sphereDescription,
      facilitators: <String>[],
      photo: sphereImageKey,
      members: _sphereMembers,
      principles: '',
      sphereHandle: sphereHandle,
      privacy: _currentPrivacy,
    );

    try {
      final response = await Provider.of<GroupRepo>(context, listen: false)
          .createSphere(sphere);
      context.bloc<CircleBloc>().add(CreateCircleEvent(response));
      JuntoLoader.hide();
      Navigator.pop(context);
    } on JuntoException catch (error) {
      JuntoLoader.hide();
      showDialog(
        context: context,
        builder: (BuildContext context) => SingleActionDialog(
          dialogText: error.message,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    createSphereController = PageController();
    sphereNameController = TextEditingController();
    sphereHandleController = TextEditingController();
    sphereDescriptionController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    createSphereController.dispose();
    sphereNameController.dispose();
    sphereHandleController.dispose();
    sphereDescriptionController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getUserRelationships() async {
    return _memoizer.runOnce(
      () => Provider.of<UserRepo>(context, listen: false).userRelations(),
    );
  }

  void _validateSphereCreation() {
    if (_formKey.currentState.validate()) {
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }
      createSphereController.nextPage(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      return;
    }
  }

  void sphereAddMember(UserProfile member) {
    setState(() {
      if (!_sphereMembers.contains(member.address)) {
        _sphereMembers.add(member.address);
      }
    });
  }

  void _sphereRemoveMember(UserProfile member) {
    setState(() {
      _sphereMembers.remove(member.address);
    });
  }

  Widget _createSphereThree() {
    return ListView(
      children: <Widget>[
        _spherePrivacy('Public',
            'Anyone can join this community, read its expressions, and share to it.'),
      ],
    );
  }

  Widget _spherePrivacy(String privacyLayer, String privacyDescription) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPrivacy = privacyLayer;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: .75,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      privacyLayer,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      privacyDescription,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: kThemeChangeDuration,
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _currentPrivacy == privacyLayer
                        ? <Color>[
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.primary
                          ]
                        : <Color>[Colors.white, Colors.white],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  border: Border.all(
                    color: Theme.of(context).backgroundColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: .75,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (_currentIndex == 0)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                color: Colors.transparent,
                width: 48,
                alignment: Alignment.centerLeft,
                child: Icon(
                  CustomIcons.back,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          if (_currentIndex != 0)
            GestureDetector(
              onTap: () {
                createSphereController.previousPage(
                  curve: Curves.easeIn,
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                color: Colors.transparent,
                width: 60,
                alignment: Alignment.centerLeft,
                child: Icon(
                  CustomIcons.back,
                  size: 17,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          if (_currentIndex == 0)
            Text(
              'Create',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
            ),
          if (_currentIndex == 1)
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: CreateCommunityButton(
                cta: _createSphere,
                title: 'Create',
              ),
            ),
          if (_currentIndex != 1)
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: CreateCommunityButton(
                cta: _onNextPress,
                title: 'Next',
              ),
            ),
        ],
      ),
    );
  }

  void _onNextPress() {
    if (_currentIndex == 0) {
      setState(() {
        sphereName = sphereNameController.value.text;
        sphereHandle = sphereHandleController.value.text;
        sphereDescription = sphereDescriptionController.value.text;
      });
      _validateSphereCreation();
      return;
    }
    createSphereController.nextPage(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 300),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CircleBloc, CircleState>(
      builder: (context, state) {
        return Container(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * .9,
            color: Theme.of(context).backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildAppBar(),
                Expanded(
                  child: PageView(
                    controller: createSphereController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (int index) {
                      setState(() {
                        print(index);
                        _currentIndex = index;
                      });
                    },
                    children: <Widget>[
                      CreateSpherePageOne(
                        formKey: _formKey,
                        sphereDescriptionController:
                            sphereDescriptionController,
                        sphereHandleController: sphereHandleController,
                        sphereNameController: sphereNameController,
                        imageFile: imageFile,
                      ),
                      CreateSpherePageTwo(
                        future: getUserRelationships(),
                        addMember: sphereAddMember,
                        removeMember: _sphereRemoveMember,
                        selectedMembers: _sphereMembers,
                        tabs: _tabs,
                      ),
                      _createSphereThree()
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class CreateCommunityButton extends StatelessWidget {
  const CreateCommunityButton({
    this.cta,
    this.title,
  });

  final Function cta;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cta,
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
