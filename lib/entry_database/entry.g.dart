// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    json['articleId'] as int,
    json['article'] as String,
    (json['translations'] as List)?.map((e) => e as String)?.toList(),
    (json['partsOfSpeech'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'articleId': instance.articleId,
      'article': instance.article,
      'translations': instance.translations,
      'partsOfSpeech': instance.partsOfSpeech,
    };
