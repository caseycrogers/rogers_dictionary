// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    orderByField: json['order_by_field'] as String,
    entryId: json['entry_id'] as int,
    headword: json['headword'] as String,
    runOnParent: json['run_on_parent'] as String,
    runOns: (json['run_ons'] as List)?.map((e) => e as String)?.toList(),
    headwordAbbreviation: json['headword_abbreviation'] as String,
    alternateHeadwords: (json['alternate_headwords'] as List)
        ?.map((e) => e as String)
        ?.toList(),
    alternateHeadwordNamingStandards:
        (json['alternate_headword_naming_standards'] as List)
            ?.map((e) => e as String)
            ?.toList(),
    translations: (json['translations'] as List)
        ?.map((e) =>
            e == null ? null : Translation.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'order_by_field': instance.orderByField,
      'entry_id': instance.entryId,
      'headword': instance.headword,
      'run_on_parent': instance.runOnParent,
      'run_ons': instance.runOns,
      'headword_abbreviation': instance.headwordAbbreviation,
      'alternate_headwords': instance.alternateHeadwords,
      'alternate_headword_naming_standards':
          instance.alternateHeadwordNamingStandards,
      'translations': instance.translations?.map((e) => e?.toJson())?.toList(),
    };

Translation _$TranslationFromJson(Map<String, dynamic> json) {
  return Translation(
    partOfSpeech: json['part_of_speech'] as String,
    irregularInflections: json['irregular_inflections'] as String,
    headwordParentheticalQualifier:
        json['headword_parenthetical_qualifier'] as String,
    translation: json['translation'] as String,
    genderAndPlural: json['gender_and_plural'] as String,
    translationNamingStandard: json['translation_naming_standard'] as String,
    translationAbbreviation: json['translation_abbreviation'] as String,
    translationParentheticalQualifier:
        json['translation_parenthetical_qualifier'] as String,
    examplePhrase: json['example_phrase'] as String,
    editorialNote: json['editorial_note'] as String,
  );
}

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'part_of_speech': instance.partOfSpeech,
      'irregular_inflections': instance.irregularInflections,
      'headword_parenthetical_qualifier':
          instance.headwordParentheticalQualifier,
      'translation': instance.translation,
      'gender_and_plural': instance.genderAndPlural,
      'translation_naming_standard': instance.translationNamingStandard,
      'translation_abbreviation': instance.translationAbbreviation,
      'translation_parenthetical_qualifier':
          instance.translationParentheticalQualifier,
      'example_phrase': instance.examplePhrase,
      'editorial_note': instance.editorialNote,
    };
