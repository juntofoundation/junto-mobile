import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:junto_beta_mobile/widgets/custom_parsed_text.dart';
import 'package:provider/provider.dart';
import 'package:junto_beta_mobile/models/expression.dart';
import 'package:junto_beta_mobile/screens/create/create_templates/audio_service.dart';
import 'package:junto_beta_mobile/widgets/audio/audio_preview.dart';
import 'package:junto_beta_mobile/widgets/image_wrapper.dart';
import 'package:junto_beta_mobile/widgets/utils/hex_color.dart';

class AudioOpen extends StatefulWidget {
  AudioOpen(this.expression);

  final Comment expression;

  @override
  _AudioOpenState createState() => _AudioOpenState();
}

class _AudioOpenState extends State<AudioOpen> {
  Widget _displayAudioOpen() {
    final audioTitle = widget.expression.expressionData.title.trim();
    final audioGradients = widget.expression.expressionData.gradient;
    final audioPhoto = widget.expression.expressionData.photo;
    final audioCaption = widget.expression.expressionData.caption.trim();
    if (audioGradients.isEmpty && audioPhoto.isEmpty) {
      return AudioOpenDefault(
        title: audioTitle,
        caption: audioCaption,
      );
    } else if (audioPhoto.isNotEmpty) {
      return AudioOpenWithPhoto(
        title: audioTitle,
        photo: audioPhoto,
        caption: audioCaption,
      );
    } else if (audioGradients.isNotEmpty && audioGradients.length == 2) {
      return AudioOpenWithGradients(
        gradients: audioGradients,
        title: audioTitle,
        caption: audioCaption,
      );
    } else {
      return AudioOpenDefault(
        title: audioTitle,
        caption: audioCaption,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioRecording = widget.expression.expressionData.audio;
      Provider.of<AudioService>(context, listen: false)
        ..initializeFromWeb(audioRecording);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(builder: (context, audio, child) {
      return _displayAudioOpen();
    });
  }
}

class AudioOpenTitle extends StatelessWidget {
  AudioOpenTitle({this.title, this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class AudioOpenCaption extends StatelessWidget {
  const AudioOpenCaption({this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: CustomParsedText(
        caption,
        selectable: false,
        defaultTextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 17,
        ),
        mentionTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AudioOpenDefault extends StatelessWidget {
  AudioOpenDefault({
    this.title,
    this.caption,
  });

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            mainAxisAlignment: title.isNotEmpty
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title.isNotEmpty)
                AudioOpenTitle(
                  title: title,
                  color: Theme.of(context).primaryColor,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AudioPlaybackRow(hasBackground: false),
              ),
            ],
          ),
        ),
        if (caption.isNotEmpty) AudioOpenCaption(caption: caption),
      ],
    );
  }
}

class AudioOpenWithGradients extends StatelessWidget {
  AudioOpenWithGradients({
    this.title,
    this.caption,
    this.gradients,
  });

  final String title;
  final String caption;
  final List<String> gradients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * .17,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: const <double>[
                  0.1,
                  0.9
                ],
                colors: <Color>[
                  HexColor.fromHex(gradients[0]),
                  HexColor.fromHex(gradients[1]),
                ]),
          ),
          child: Container(
            color: Colors.black45,
            padding: const EdgeInsets.symmetric(vertical: 20),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * .17,
            ),
            child: Column(
              mainAxisAlignment: title.isNotEmpty
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title.isNotEmpty)
                  AudioOpenTitle(
                    title: title,
                    color: Colors.white,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: AudioPlaybackRow(
                    hasBackground: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (caption.isNotEmpty) AudioOpenCaption(caption: caption),
      ],
    );
  }
}

class AudioOpenWithPhoto extends StatelessWidget {
  AudioOpenWithPhoto({this.title, this.caption, this.photo});

  final String title;
  final String caption;
  final String photo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              foregroundDecoration: BoxDecoration(color: Colors.black38),
              width: MediaQuery.of(context).size.width,
              child: ImageWrapper(
                imageUrl: photo,
                placeholder: (BuildContext context, String _) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 2 / 3,
                    color: Theme.of(context).dividerColor,
                  );
                },
              ),
            ),
            if (title.isNotEmpty)
              Positioned(
                top: 25,
                left: 0,
                right: 0,
                child: AudioOpenTitle(
                  title: title,
                  color: Colors.white,
                ),
              ),
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: AudioPlaybackRow(
                  hasBackground: true,
                ),
              ),
            )
          ],
        ),
        if (caption.isNotEmpty) AudioOpenCaption(caption: caption),
      ],
    );
  }
}
