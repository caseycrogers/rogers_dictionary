// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    entryId: json['entry_id'] as int,
    headword: Headword.fromJson(json['headword'] as Map<String, dynamic>),
    related:
        (json['related'] as List<dynamic>?)?.map((e) => e as String).toList(),
    alternateHeadwords: (json['alternate_headwords'] as List<dynamic>?)
        ?.map((e) => Headword.fromJson(e as Map<String, dynamic>))
        .toList(),
    translations: (json['translations'] as List<dynamic>)
        .map((e) => Translation.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) {
  final val = <String, dynamic>{
    'entry_id': instance.entryId,
    'headword': instance.headword.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('related', instance.related);
  writeNotNull('alternate_headwords',
      instance.alternateHeadwords?.map((e) => e.toJson()).toList());
  val['translations'] = instance.translations.map((e) => e.toJson()).toList();
  return val;
}

Headword _$HeadwordFromJson(Map<String, dynamic> json) {
  return Headword(
    headwordText: json['headword_text'] as String,
    isDominant: json['is_dominant'] as bool,
    abbreviation: json['abbreviation'] as String?,
    namingStandard: json['naming_standard'] as String?,
    parentheticalQualifier: json['parenthetical_qualifier'] as String?,
  );
}

Map<String, dynamic> _$HeadwordToJson(Headword instance) {
  final val = <String, dynamic>{
    'is_dominant': instance.isDominant,
    'headword_text': instance.headwordText,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('abbreviation', instance.abbreviation);
  writeNotNull('naming_standard', instance.namingStandard);
  writeNotNull('parenthetical_qualifier', instance.parentheticalQualifier);
  return val;
}

Translation _$TranslationFromJson(Map<String, dynamic> json) {
  return Translation(
    partOfSpeech: json['part_of_speech'] as String,
    translationText: json['translation_text'] as String,
    irregularInflections: json['irregular_inflections'] as String?,
    dominantHeadwordParentheticalQualifier:
        json['dominant_headword_parenthetical_qualifier'] as String?,
    genderAndPlural: json['gender_and_plural'] as String?,
    translationNamingStandard: json['translation_naming_standard'] as String?,
    translationAbbreviation: json['translation_abbreviation'] as String?,
    translationParentheticalQualifier:
        json['translation_parenthetical_qualifier'] as String?,
    examplePhrases: (json['example_phrases'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    editorialNote: json['editorial_note'] as String?,
  );
}

Map<String, dynamic> _$TranslationToJson(Translation instance) {
  final val = <String, dynamic>{
    'part_of_speech': instance.partOfSpeech,
    'translation_text': instance.translationText,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('irregular_inflections', instance.irregularInflections);
  writeNotNull('dominant_headword_parenthetical_qualifier',
      instance.dominantHeadwordParentheticalQualifier);
  writeNotNull('gender_and_plural', instance.genderAndPlural);
  writeNotNull(
      'translation_naming_standard', instance.translationNamingStandard);
  writeNotNull('translation_abbreviation', instance.translationAbbreviation);
  writeNotNull('translation_parenthetical_qualifier',
      instance.translationParentheticalQualifier);
  writeNotNull('example_phrases', instance.examplePhrases);
  writeNotNull('editorial_note', instance.editorialNote);
  return val;
}
