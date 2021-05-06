// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialogue_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DialogueChapter _$DialogueChapterFromJson(Map<String, dynamic> json) {
  return DialogueChapter(
    chapterId: json['chapter_id'] as int,
    englishTitle: json['english_title'] as String,
    spanishTitle: json['spanish_title'] as String,
    subChapters: (json['sub_chapters'] as List<dynamic>)
        .map((e) => DialogueSubChapter.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DialogueChapterToJson(DialogueChapter instance) =>
    <String, dynamic>{
      'chapter_id': instance.chapterId,
      'english_title': instance.englishTitle,
      'spanish_title': instance.spanishTitle,
      'sub_chapters': instance.subChapters.map((e) => e.toJson()).toList(),
    };

DialogueSubChapter _$DialogueSubChapterFromJson(Map<String, dynamic> json) {
  return DialogueSubChapter(
    englishTitle: json['english_title'] as String,
    spanishTitle: json['spanish_title'] as String,
    dialogues: (json['dialogues'] as List<dynamic>)
        .map((e) => Dialogue.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DialogueSubChapterToJson(DialogueSubChapter instance) =>
    <String, dynamic>{
      'english_title': instance.englishTitle,
      'spanish_title': instance.spanishTitle,
      'dialogues': instance.dialogues.map((e) => e.toJson()).toList(),
    };

Dialogue _$DialogueFromJson(Map<String, dynamic> json) {
  return Dialogue(
    englishContent: json['english_content'] as String,
    spanishContent: json['spanish_content'] as String,
  );
}

Map<String, dynamic> _$DialogueToJson(Dialogue instance) => <String, dynamic>{
      'english_content': instance.englishContent,
      'spanish_content': instance.spanishContent,
    };
