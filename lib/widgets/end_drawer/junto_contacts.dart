import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/widgets/settings_popup.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/models/user_model.dart';
import 'package:junto_beta_mobile/widgets/dialogs/single_action_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:junto_beta_mobile/widgets/avatars/member_avatar_placeholder.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'junto_invite_appbar.dart';

class JuntoContacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JuntoContactsState();
  }
}

class JuntoContactsState extends State<JuntoContacts> {
  PermissionStatus contactsPermission;
  TextEditingController searchController;
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  UserData _userProfile;
  List<String> numbers = [];

  void selectContacts(Contact contact) {
    setState(() {
      if (numbers.contains(contact.phones.first.value)) {
        numbers.remove(contact.phones.first.value);
      } else {
        numbers.add(contact.phones.first.value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // instantiate text editing controller
    searchController = TextEditingController();
    // Get user information to display username in SMS
    getUserInformation();

    // Retrieve user contacts
    getContacts();
  }

  Future<void> getUserInformation() async {
    final UserData userProfile =
        await Provider.of<UserDataProvider>(context, listen: false).userProfile;
    setState(() {
      _userProfile = userProfile;
    });
  }

  Future<void> getContacts() async {
    // Determine permissions to access user contacts
    final permission = await _getPermission();

    if (permission.isGranted) {
      // Retrieve contacts from agent's device
      Iterable<Contact> contacts = await ContactsService.getContacts();

      // Create a temp list
      final List<Contact> tempContactsAsList = [];

      // Ignore null contacts
      await contacts.forEach((Contact contact) {
        if (contact != null) {
          tempContactsAsList.add(contact);
        }
      });

      // Convert Iterable to List
      List<Contact> contactsAsList = await tempContactsAsList.toList();

      // Sort list alphabetically
      contactsAsList.sort((a, b) {
        if (a.displayName != null && b.displayName != null) {
          return a.displayName.compareTo(b.displayName);
        }
        return 0;
      });

      setState(() {
        _contacts = contactsAsList;
        _filteredContacts = List.from(_contacts);
      });
    } else {
      Timer(Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          builder: (context) => SettingsPopup(
            buildContext: context,
            // TODO: @Eric - Need to update the text
            text: 'Access not granted to access contacts',
            onTap: AppSettings.openAppSettings,
          ),
        );
      });
    }
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted ||
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      setState(() {
        contactsPermission = permissionStatus[Permission.contacts];
      });
      return permissionStatus[Permission.contacts] ?? PermissionStatus.limited;
    } else {
      setState(() {
        contactsPermission = permission;
      });
      return permission;
    }
  }

  void filterSearchResults(String query) {
    List<Contact> searchList = [];
    searchList.addAll(_contacts);
    final String queryLowercase = query.toLowerCase();

    if (queryLowercase.isNotEmpty) {
      final List<Contact> filteredSearchList = [];

      searchList.forEach((Contact contact) {
        if (contact.displayName != null &&
            contact.displayName.toLowerCase().contains(queryLowercase)) {
          filteredSearchList.add(contact);
        }
      });

      setState(() {
        _filteredContacts.clear();
        _filteredContacts.addAll(filteredSearchList);
      });
    } else {
      setState(() {
        _filteredContacts.clear();
        _filteredContacts.addAll(_contacts);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: JuntoInviteAppBar(
          userProfile: _userProfile,
        ),
      ),
      body: Column(
        children: [
          JuntoContactsSearch(
            searchController: searchController,
            filterSearchResults: filterSearchResults,
          ),
          if (_filteredContacts.isNotEmpty || _filteredContacts != null)
            JuntoContactsList(
              filteredContacts: _filteredContacts,
              userProfile: _userProfile,
              contactsPermission: contactsPermission,
              selectContacts: selectContacts,
              selectedNumbers: numbers,
            ),
          if (numbers.length > 0)
            GestureDetector(
              onTap: () async {
                String uri;
                if (Platform.isIOS) {
                  uri = Uri.encodeFull(
                      "sms:${numbers.join(',')}&body=Hey! I started using this more authentic and nonprofit social media platform called Junto. Here's an invite to their private beta - you can connect with me @${_userProfile.user.username}. https://junto.typeform.com/to/k7BUVK8f");
                } else if (Platform.isAndroid) {
                  uri = Uri.encodeFull(
                      "sms:${numbers.join(',')}?body=Hey! I started using this more authentic and nonprofit social media platform called Junto. Here's an invite to their private beta - you can connect with me @${_userProfile.user.username}. https://junto.typeform.com/to/k7BUVK8f");
                }

                if (await canLaunch(uri)) {
                  await launch(uri);
                } else {
                  await SingleActionDialog(
                    context: context,
                    dialogText: 'Sorry, something is up. Try again.',
                  );
                }
                ;
              },
              child: Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: Colors.green,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 24.0,
                      width: 24.0,
                      margin: EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          numbers.length.toString(),
                          style: TextStyle(color: Colors.green, fontSize: 16.0),
                        ),
                      ),
                    ),
                    Text(
                      'Invite to Junto',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ],
                )),
              ),
            )
        ],
      ),
    );
  }
}

class JuntoContactsList extends StatelessWidget {
  const JuntoContactsList({
    this.contactsPermission = PermissionStatus.limited,
    this.filteredContacts,
    this.userProfile,
    this.selectedNumbers,
    this.selectContacts,
  });
  final PermissionStatus contactsPermission;
  final List<Contact> filteredContacts;
  final UserData userProfile;
  final List<String> selectedNumbers;
  final Function selectContacts;

  @override
  Widget build(BuildContext context) {
    if (contactsPermission != PermissionStatus.granted) {
      return Expanded(
        child: Center(
          child: Transform.translate(
            offset: Offset(0.0, -50.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'You need to allow us to access your contacts to use this feature. Please update your settings.',
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (BuildContext context, int index) {
            final Contact contact = filteredContacts.elementAt(index);
            String number;

            if (contact.phones.isNotEmpty && contact.phones != null) {
              number = contact.phones.first.value;
            } else {
              number = '';
            }

            if (contact.displayName != null && number.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  selectContacts(contact);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: .5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              MemberAvatarPlaceholder(
                                diameter: 45,
                              ),
                              if (selectedNumbers
                                  .contains(contact.phones.first.value))
                                Positioned(
                                  bottom: 0.0,
                                  right: 0.0,
                                  child: Container(
                                    height: 18.0,
                                    width: 18.0,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.displayName,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                number,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox(height: 1);
            }
          },
        ),
      );
    }
  }
}

class JuntoContactsSearch extends StatelessWidget {
  const JuntoContactsSearch({
    this.searchController,
    this.filterSearchResults,
  });

  final TextEditingController searchController;
  final Function filterSearchResults;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        scrollPadding: const EdgeInsets.all(0),
        controller: searchController,
        onChanged: (String value) {
          filterSearchResults(value);
        },
        buildCounter: (
          BuildContext context, {
          int currentLength,
          int maxLength,
          bool isFocused,
        }) =>
            null,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0.0),
          hintText: 'Search contacts',
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        cursorColor: Theme.of(context).primaryColor,
        cursorWidth: 1,
        maxLines: 1,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).primaryColor,
        ),
        maxLength: 80,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
