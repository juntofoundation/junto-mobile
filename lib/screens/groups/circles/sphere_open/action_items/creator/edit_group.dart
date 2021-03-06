import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/app/logger/logger.dart';
import 'package:junto_beta_mobile/backend/repositories.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/screens/groups/circles/bloc/circle_bloc.dart';
import 'package:junto_beta_mobile/utils/junto_exception.dart';
import 'package:junto_beta_mobile/utils/junto_overlay.dart';
import 'package:junto_beta_mobile/widgets/settings_popup.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junto_beta_mobile/widgets/image_cropper.dart';
import 'package:junto_beta_mobile/widgets/avatars/group_avatar_placeholder.dart';
import 'package:junto_beta_mobile/widgets/dialogs/single_action_dialog.dart';
import 'package:junto_beta_mobile/widgets/avatars/group_avatar.dart';

class EditCircle extends StatefulWidget {
  const EditCircle({
    Key key,
    @required this.sphere,
  }) : super(key: key);
  final Group sphere;

  @override
  _EditCircleState createState() => _EditCircleState();
}

class _EditCircleState extends State<EditCircle> {
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  File imageFile;
  List<File> groupPicture = <File>[];
  String _photoKey = '';

  GroupDataSphere get _groupData => widget.sphere.groupData;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _groupData.name,
    );
    _descriptionController = TextEditingController(
      text: _groupData.description,
    );
    print(imageFile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateGroup() async {
    JuntoLoader.showLoader(context);

    final String name = _nameController.text;
    final String desc = _descriptionController.text;

    // check if user uploaded profile pictures
    if (groupPicture != null && groupPicture.isNotEmpty) {
      try {
        _photoKey = await Provider.of<ExpressionRepo>(context, listen: false)
            .createPhoto(
          false,
          '.png',
          groupPicture[0],
        );
      } catch (error) {
        print('test: $error');
        JuntoLoader.hide();
      }
    }

    final Group updatedGroup = widget.sphere.copyWith(
      groupData: GroupDataSphere(
        name: name,
        description: desc,
        principles: '',
        photo: _photoKey.length > 0 ? _photoKey : null,
        sphereHandle: _groupData.sphereHandle,
      ),
    );

    try {
      context.read<CircleBloc>().add(UpdateCircle(group: updatedGroup));
      JuntoLoader.hide();
      Navigator.pop(context);
    } on JuntoException catch (e, s) {
      logger.logException(e, s);
      JuntoLoader.hide();
      showDialog(
        context: context,
        builder: (BuildContext context) => const SingleActionDialog(
          dialogText: 'Hmm, something went wrong.',
        ),
      );
    }
  }

  Future<void> _onPickPressed() async {
    final imagePicker = ImagePicker();
    final permission =
        Platform.isAndroid ? Permission.storage : Permission.photos;
    if (await permission.request().isGranted) {
      final pickedImage =
          await imagePicker.getImage(source: ImageSource.gallery);
      final File image = File(pickedImage.path);
      if (image == null) {
        return;
      }
      final File cropped =
          await ImageCroppingDialog.show(context, image, aspectRatios: <String>[
        '3:2',
      ]);
      if (cropped == null) {
        return;
      }
      setState(() {
        imageFile = cropped;
        groupPicture.add(imageFile);
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => SettingsPopup(
          buildContext: context,
          // TODO: @Eric - Need to update the text
          text: 'Access not granted to access gallery',
          onTap: AppSettings.openAppSettings,
        ),
      );
    }
  }

  Widget _displayCurrentProfilePicture() {
    if (_groupData != null &&
        _groupData.photo.isNotEmpty &&
        imageFile == null) {
      return GroupAvatar(
        diameter: 45,
        profilePicture: _groupData.photo,
      );
    } else if (_groupData != null && imageFile != null) {
      return ClipOval(
        child: Container(
          height: 45.0,
          width: 45.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return const GroupAvatarPlaceholder(diameter: 45);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CircleBloc, CircleState>(builder: (context, state) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            automaticallyImplyLeading: false,
            brightness: Theme.of(context).brightness,
            elevation: 0,
            titleSpacing: 0,
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      width: 60,
                      height: 42,
                      alignment: Alignment.centerLeft,
                      color: Colors.transparent,
                      child: Icon(
                        CustomIcons.back,
                        color: Theme.of(context).primaryColorDark,
                        size: 17,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'Edit Circle',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_nameController.text != '' &&
                          _descriptionController.text != '') {
                        if (imageFile == null &&
                            _nameController.text == _groupData.name &&
                            _descriptionController.text ==
                                _groupData.description) {
                          return;
                        } else {
                          _updateGroup();
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.centerRight,
                      color: Colors.transparent,
                      width: 60,
                      height: 42,
                      child: Text(
                        'Save',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(.75),
              child: Container(
                height: .75,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: .75,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      GestureDetector(
                        onTap: _onPickPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: .75),
                            ),
                          ),
                          child: Row(children: <Widget>[
                            _displayCurrentProfilePicture(),
                            const SizedBox(width: 10),
                            Text(
                              'Edit group photo',
                              style: Theme.of(context).textTheme.caption,
                            )
                          ]),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: .75),
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name',
                          ),
                          maxLines: null,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: .75),
                          ),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Bio / Purpose',
                          ),
                          maxLines: null,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
