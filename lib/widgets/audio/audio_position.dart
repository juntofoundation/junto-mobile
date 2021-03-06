import 'package:flutter/material.dart';
import 'package:junto_beta_mobile/screens/create/create_templates/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:junto_beta_mobile/utils/extensions/duration_ext.dart';

class AudioPosition extends StatelessWidget {
  const AudioPosition({
    Key key,
    this.hasBackground = false,
  }) : super(key: key);

  final bool hasBackground;
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audio, child) {
        return Text(
          '${getCurrentPosition(audio)} / ${getMaxDuration(audio)}',
          style: TextStyle(
            fontSize: 14,
            color:
                hasBackground ? Colors.white : Theme.of(context).primaryColor,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  String getCurrentPosition(AudioService audio) {
    Duration max;
    if (audio.recordingAvailable) {
      max = audio.recordingDuration;
    } else {
      max = audio.maxDuration;
    }

    if (audio.currentPosition != null) {
      return formatDuration(audio.currentPosition.secondCeilRounder(max));
    }

    return '0:00';
  }

  String getMaxDuration(AudioService audio) {
    if (audio.recordingAvailable) {
      return formatDuration(audio.recordingDuration.secondFloorRounder());
    } else {
      return formatDuration(audio.maxDuration.secondFloorRounder());
    }
  }

  String formatDuration(Duration duration) {
    final min = duration.inMinutes;
    final sec = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
