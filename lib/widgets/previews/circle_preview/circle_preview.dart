import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/app/custom_icons.dart';
import 'package:junto_beta_mobile/models/models.dart';
import 'package:junto_beta_mobile/widgets/image_wrapper.dart';

// This class renders a preview of a sphere
class CirclePreview extends StatelessWidget {
  const CirclePreview({
    @required this.group,
    this.diameter = 38,
  });

  final Group group;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          group.groupData.photo == ''
              ? Container(
                  alignment: Alignment.center,
                  height: diameter,
                  width: diameter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: const <double>[0.3, 0.9],
                      colors: <Color>[
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.primary
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    CustomIcons.newcollective,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: diameter / 1.5,
                  ),
                )
              : ClipOval(
                  child: ImageWrapper(
                      imageUrl: group.groupData.photo,
                      height: diameter,
                      width: diameter,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String _) {
                        return Container(
                          alignment: Alignment.center,
                          height: diameter,
                          width: diameter,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              stops: const <double>[0.3, 0.9],
                              colors: <Color>[
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(context).colorScheme.primary
                              ],
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            CustomIcons.newcollective,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: diameter / 1.5,
                          ),
                        );
                      }),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: .5,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('c/${group.groupData.sphereHandle}',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.subtitle1),
                  Text(
                    group.groupData.description,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
