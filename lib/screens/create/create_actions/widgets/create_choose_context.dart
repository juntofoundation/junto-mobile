import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/models/group_model.dart';

class ChooseExpressionContext extends StatelessWidget {
  const ChooseExpressionContext({
    this.expressionContext,
    this.currentExpressionContext,
    this.selectExpressionContext,
    this.group,
    this.gotoGroupSelection,
  });
  final ExpressionContext expressionContext;
  final ExpressionContext currentExpressionContext;
  final Function selectExpressionContext;
  final Group group;
  final Function gotoGroupSelection;

  Map<String, dynamic> _expressionContextTraits(BuildContext context) {
    dynamic icon;
    String socialContext;
    String description;
    switch (expressionContext) {
      case ExpressionContext.Collective:
        socialContext = 'Collective';
        description = 'Share publicy on Junto';
        icon = Icon(
          CustomIcons.newcollective,
          color: Colors.white,
          size: 33,
        );
        break;
      case ExpressionContext.MyPack:
        socialContext = 'My Pack';
        description = 'Share to just my Pack members';
        icon = Icon(
          CustomIcons.newpacks,
          color: Colors.white,
          size: 28,
        );
        break;
      case ExpressionContext.CommunityCenter:
        socialContext = 'Community Center';
        description = 'Share your feedback with the team and community';
        icon = Image.asset(
          'assets/images/junto-mobile__sprout.png',
          height: 18,
          color: Colors.white,
        );
        break;
      // TODO: @eric - Copy needs to be updated
      case ExpressionContext.Group:
        socialContext = 'Group';
        description = group != null
            ? 'Share to just ${group.groupData.name}'
            : 'Share to any of your joined group';
        icon = Image.asset(
          'assets/images/junto-mobile__sprout.png',
          height: 18,
          color: Colors.white,
        );
        break;
      default:
        socialContext = 'Collective';
        description = 'Share publicy on Junto';
        icon = Icon(
          CustomIcons.newcollective,
          color: Colors.white,
          size: 33,
        );
        break;
    }
    return {
      'icon': icon,
      'social_context': socialContext,
      'description': description,
    };
  }

  @override
  Widget build(BuildContext context) {
    print(expressionContext);
    print(currentExpressionContext);
    return GestureDetector(
      onTap: () {
        if (expressionContext == ExpressionContext.Group) {
          gotoGroupSelection();
        }
        selectExpressionContext(expressionContext);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              width: .75,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: const <double>[0.2, 0.9],
                      colors: <Color>[
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(1000),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _expressionContextTraits(context)['icon'],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _expressionContextTraits(context)['social_context'],
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _expressionContextTraits(context)['description'],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Radio(
              onChanged: selectExpressionContext,
              value: expressionContext,
              groupValue: currentExpressionContext,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
