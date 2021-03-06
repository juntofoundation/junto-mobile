import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/generated/l10n.dart';
import 'package:junto_beta_mobile/widgets/filter_drawer_new/filter_drawer_new.dart';

class FilterDrawerButton extends StatelessWidget {
  const FilterDrawerButton({
    this.collectiveScreen = false,
    Key key,
  }) : super(key: key);
  final bool collectiveScreen;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: S.of(context).toggle_filter_drawer,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            isScrollControlled: true,
            builder: (BuildContext context) => FilterDrawerNew(
              collectiveScreen: collectiveScreen,
            ),
          );
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/junto-mobile__filter.png',
            height: 17,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
