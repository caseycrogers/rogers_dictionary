import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'package:rogers_dictionary/util/default_map.dart';

part 'dialogue_chapter.g.dart';

@immutable
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DialogueChapter {
  // Run the following to rebuild generated files:
  // flutter pub run build_runner build --delete-conflicting-outputs
  final int chapterId;
  final String englishTitle;
  final String spanishTitle;
  final List<DialogueSubChapter> subChapters;

  DialogueChapter({
    @required this.chapterId,
    @required this.englishTitle,
    @required this.spanishTitle,
    @required List<DialogueSubChapter> subChapters,
  }) : subChapters = List.from(subChapters, growable: false);

  bool get hasSubChapters =>
      subChapters.any((subChapter) => subChapter.englishTitle.isNotEmpty);

  factory DialogueChapter.fromJson(Map<String, dynamic> json) =>
      _$DialogueChapterFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueChapterToJson(this);
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DialogueSubChapter {
  final String englishTitle;
  final String spanishTitle;

  final List<Dialogue> dialogues;

  DialogueSubChapter({
    @required this.englishTitle,
    @required this.spanishTitle,
    @required List<Dialogue> dialogues,
  })  : assert(dialogues != null && dialogues.isNotEmpty),
        dialogues = List.from(dialogues, growable: false);

  factory DialogueSubChapter.fromJson(Map<String, dynamic> json) =>
      _$DialogueSubChapterFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueSubChapterToJson(this);
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class Dialogue {
  final String englishContent;
  final String spanishContent;

  Dialogue({this.englishContent, this.spanishContent});

  factory Dialogue.fromJson(Map<String, dynamic> json) =>
      _$DialogueFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueToJson(this);
}

class DialogueChapterBuilder {
  final int chapterId;
  final String englishTitle;
  final String spanishTitle;

  final Map<String, DialogueSubChapterBuilder> subChapters = {};

  DialogueChapterBuilder({
    @required this.chapterId,
    @required this.englishTitle,
    @required this.spanishTitle,
  });

  DialogueChapter build() => DialogueChapter(
        chapterId: chapterId,
        englishTitle: englishTitle,
        spanishTitle: spanishTitle,
        subChapters: subChapters.values.map((b) => b.build()).toList(),
      );

  DialogueChapterBuilder addDialogue(
    String englishSubChapter,
    String spanishSubchapter,
    String englishDialogue,
    String spanishDialogue,
  ) {
    subChapters
        .getOrElse(
            englishSubChapter,
            DialogueSubChapterBuilder(
                englishTitle: englishSubChapter,
                spanishTitle: spanishSubchapter))
        .addDialogue(englishDialogue, spanishDialogue);
    return this;
  }
}

class DialogueSubChapterBuilder {
  final String englishTitle;
  final String spanishTitle;

  List<Dialogue> dialogues = [];

  DialogueSubChapterBuilder({
    @required this.englishTitle,
    @required this.spanishTitle,
  });

  DialogueSubChapterBuilder addDialogue(
      String englishContent, String spanishContent) {
    dialogues.add(Dialogue(
      englishContent: englishContent,
      spanishContent: spanishContent,
    ));
    return this;
  }

  DialogueSubChapter build() => DialogueSubChapter(
      englishTitle: englishTitle,
      spanishTitle: spanishTitle,
      dialogues: dialogues);
}
