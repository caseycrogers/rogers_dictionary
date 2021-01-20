// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    entryId: json['entry_id'] as int,
    headword: json['headword'] == null
        ? null
        : Headword.fromJson(json['headword'] as Map<String, dynamic>),
    runOnParents:
        (json['run_on_parents'] as List)?.map((e) => e as String)?.toList(),
    runOns: (json['run_ons'] as List)?.map((e) => e as String)?.toList(),
    alternateHeadwords: (json['alternate_headwords'] as List)
        ?.map((e) =>
            e == null ? null : Headword.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    translations: (json['translations'] as List)
        ?.map((e) =>
            e == null ? null : Translation.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'entry_id': instance.entryId,
      'headword': instance.headword?.toJson(),
      'run_on_parents': instance.runOnParents,
      'run_ons': instance.runOns,
      'alternate_headwords':
          instance.alternateHeadwords?.map((e) => e?.toJson())?.toList(),
      'translations': instance.translations?.map((e) => e?.toJson())?.toList(),
    };

Headword _$HeadwordFromJson(Map<String, dynamic> json) {
  return Headword(
    headwordText: json['headword_text'] as String,
    abbreviation: json['abbreviation'] as String,
    namingStandard: json['naming_standard'] as String,
    parentheticalQualifier: json['parenthetical_qualifier'] as String,
    isDominant: json['is_dominant'] as bool,
  );
}

Map<String, dynamic> _$HeadwordToJson(Headword instance) => <String, dynamic>{
      'is_dominant': instance.isDominant,
      'headword_text': instance.headwordText,
      'abbreviation': instance.abbreviation,
      'naming_standard': instance.namingStandard,
      'parenthetical_qualifier': instance.parentheticalQualifier,
    };

Translation _$TranslationFromJson(Map<String, dynamic> json) {
  return Translation(
    partOfSpeech: json['part_of_speech'] as String,
    irregularInflections: json['irregular_inflections'] as String,
    dominantHeadwordParentheticalQualifier:
        json['dominant_headword_parenthetical_qualifier'] as String,
    translationText: json['translation_text'] as String,
    genderAndPlural: json['gender_and_plural'] as String,
    translationNamingStandard: json['translation_naming_standard'] as String,
    translationAbbreviation: json['translation_abbreviation'] as String,
    translationParentheticalQualifier:
        json['translation_parenthetical_qualifier'] as String,
    examplePhrases:
        (json['example_phrases'] as List)?.map((e) => e as String)?.toList(),
    editorialNote: json['editorial_note'] as String,
  );
}

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'part_of_speech': instance.partOfSpeech,
      'irregular_inflections': instance.irregularInflections,
      'dominant_headword_parenthetical_qualifier':
          instance.dominantHeadwordParentheticalQualifier,
      'translation_text': instance.translationText,
      'gender_and_plural': instance.genderAndPlural,
      'translation_naming_standard': instance.translationNamingStandard,
      'translation_abbreviation': instance.translationAbbreviation,
      'translation_parenthetical_qualifier':
          instance.translationParentheticalQualifier,
      'example_phrases': instance.examplePhrases,
      'editorial_note': instance.editorialNote,
    };
