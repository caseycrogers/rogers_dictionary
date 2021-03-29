import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'dialogue.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Dialogue {
  // Run the following to rebuild generated files:
  // flutter pub run build_runner build --delete-conflicting-outputs
  final int dialogueId;
  final String englishChapter;
  final String spanishChapter;
  final String englishSubChapter;
  final String spanishSubChapter;

  final String englishContent;
  final String spanishContent;

  Dialogue({
    @required this.dialogueId,
    @required this.englishChapter,
    @required this.spanishChapter,
    @required this.englishSubChapter,
    @required this.spanishSubChapter,
    @required this.englishContent,
    @required this.spanishContent,
  });

  factory Dialogue.fromJson(Map<String, dynamic> json) =>
      _$DialogueFromJson(json);

  Map<String, dynamic> toJson() => _$DialogueToJson(this);
}
