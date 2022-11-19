// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/clients/text_to_speech.dart';
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/util/color_utils.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/dictionary_progress_indicator.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/buttons/inline_icon_button.dart';
import 'package:rogers_dictionary/widgets/on_error_stream_builder.dart';

class PronunciationButton extends StatelessWidget {
  PronunciationButton({
    Key? key,
    required this.text,
    required this.pronunciation,
    required this.mode,
  }) : super(key: key);

  final String text;
  final TranslationMode mode;
  final String? pronunciation;

  final ValueNotifier<Stream<PlaybackInfo>?> _currPlaybackStream =
      ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Stream<PlaybackInfo>?>(
      valueListenable: _currPlaybackStream,
      builder: (context, playbackStream, _) {
        late final Widget currButton;
        if (playbackStream == null) {
          currButton = _PlayButton(
            text,
            pronunciation ?? text,
            mode,
            _currPlaybackStream,
          );
        } else {
          currButton = _PlayingButton(text, mode, playbackStream, () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _currPlaybackStream.value = null;
            });
          });
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 20),
          child: currButton,
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton(
    this.text,
    this.pronunciationText,
    this.mode,
    this._currPlaybackStream, {
    Key? key,
  }) : super(key: key);

  final String text;
  final String pronunciationText;
  final TranslationMode mode;
  final ValueNotifier<Stream<PlaybackInfo>?> _currPlaybackStream;

  @override
  Widget build(BuildContext context) {
    return InlineIconButton(
      Icons.volume_up,
      onPressed: () {
        _currPlaybackStream.value =
            DictionaryApp.textToSpeech.playAudio(text, pronunciationText, mode);
        DictionaryApp.analytics.logEvent(
          name: 'play_audio',
          parameters: {
            'text': pronunciationText,
            'mode': mode.toString().split('.').last,
          },
        );
      },
    );
  }
}

class _PlayingButton extends StatelessWidget {
  const _PlayingButton(
    this.text,
    this.mode,
    this._playbackStream,
    this._onDone, {
    Key? key,
  }) : super(key: key);

  final String text;
  final TranslationMode mode;
  final Stream<PlaybackInfo> _playbackStream;
  final VoidCallback _onDone;

  @override
  Widget build(BuildContext context) {
    return LoggingStreamBuilder<PlaybackInfo>(
      stream: _playbackStream,
      builder: (context, snap) {
        if (snap.hasError) {
          String message = snap.error.toString();
          if (snap.error is TimeoutException) {
            message = i18n.audioPlaybackTimeoutMsg.get(context);
          }
          DictionaryApp.snackBarNotifier.showErrorMessage(
              message: message, extraText: snap.error.toString());
          _onDone();
        }
        if (snap.connectionState == ConnectionState.done) {
          _onDone();
        }
        if (snap.data == null) {
          return Container(
            // Copied from the inline icon button implementation.
            margin: const EdgeInsets.symmetric(horizontal: kPad / 2),
            width: IconTheme.of(context).size!,
            height: IconTheme.of(context).size,
            padding: const EdgeInsets.all(4),
            child: const _LoadingIndicator(),
          );
        }
        final PlaybackInfo info = snap.data!;
        // Currently playing.
        return ProgressGradient(
          child: _StopButton(
            _onDone,
            text,
            mode,
          ),
          style: IndicatorStyle.circular,
          progress: info.position.inMilliseconds / info.duration.inMilliseconds,
        );
      },
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton(
    this._onDone,
    this.text,
    this.mode, {
    Key? key,
  }) : super(key: key);

  final VoidCallback _onDone;
  final String text;
  final TranslationMode mode;

  @override
  Widget build(BuildContext context) {
    return InlineIconButton(
      Icons.stop,
      // We need to make this opaque as it should fully occlude the indicator
      // under it
      color:
          Theme.of(context).iconTheme.color!.bake(Theme.of(context).cardColor),
      onPressed: () {
        _onDone();
        DictionaryApp.textToSpeech.stopIfPlaying(text, mode);
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AdaptiveMaterial.secondaryOnColorOf(context)!,
        ),
      ),
    );
  }
}
