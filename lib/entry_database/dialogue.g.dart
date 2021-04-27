// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialogue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dialogue _$DialogueFromJson(Map<String, dynamic> json) {
  return Dialogue(
    dialogueId: json['dialogue_id'] as int,
    englishChapter: json['english_chapter'] as String,
    spanishChapter: json['spanish_chapter'] as String,
    englishSubChapter: json['english_sub_chapter'] as String,
    spanishSubChapter: json['spanish_sub_chapter'] as String,
    englishContent: json['english_content'] as String,
    spanishContent: json['spanish_content'] as String,
  );
}

Map<String, dynamic> _$DialogueToJson(Dialogue instance) => <String, dynamic>{
      'dialogue_id': instance.dialogueId,
      'english_chapter': instance.englishChapter,
      'spanish_chapter': instance.spanishChapter,
      'english_sub_chapter': instance.englishSubChapter,
      'spanish_sub_chapter': instance.spanishSubChapter,
      'english_content': instance.englishContent,
      'spanish_content': instance.spanishContent,
    };
