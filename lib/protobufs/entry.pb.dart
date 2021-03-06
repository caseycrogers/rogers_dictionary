///
//  Generated code. Do not modify.
//  source: lib/protobufs/entry.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Entry_Headword extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Entry.Headword', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'rogers_dictionary'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isAlternate', protoName: 'isAlternate')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'headwordText', protoName: 'headwordText')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'abbreviation')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'namingStandard', protoName: 'namingStandard')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'parentheticalQualifier', protoName: 'parentheticalQualifier')
    ..hasRequiredFields = false
  ;

  Entry_Headword._() : super();
  factory Entry_Headword({
    $core.bool? isAlternate,
    $core.String? headwordText,
    $core.String? abbreviation,
    $core.String? namingStandard,
    $core.String? parentheticalQualifier,
  }) {
    final _result = create();
    if (isAlternate != null) {
      _result.isAlternate = isAlternate;
    }
    if (headwordText != null) {
      _result.headwordText = headwordText;
    }
    if (abbreviation != null) {
      _result.abbreviation = abbreviation;
    }
    if (namingStandard != null) {
      _result.namingStandard = namingStandard;
    }
    if (parentheticalQualifier != null) {
      _result.parentheticalQualifier = parentheticalQualifier;
    }
    return _result;
  }
  factory Entry_Headword.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Entry_Headword.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Entry_Headword clone() => Entry_Headword()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Entry_Headword copyWith(void Function(Entry_Headword) updates) => super.copyWith((message) => updates(message as Entry_Headword)) as Entry_Headword; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Entry_Headword create() => Entry_Headword._();
  Entry_Headword createEmptyInstance() => create();
  static $pb.PbList<Entry_Headword> createRepeated() => $pb.PbList<Entry_Headword>();
  @$core.pragma('dart2js:noInline')
  static Entry_Headword getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Entry_Headword>(create);
  static Entry_Headword? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isAlternate => $_getBF(0);
  @$pb.TagNumber(1)
  set isAlternate($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsAlternate() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsAlternate() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get headwordText => $_getSZ(1);
  @$pb.TagNumber(2)
  set headwordText($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeadwordText() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeadwordText() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get abbreviation => $_getSZ(2);
  @$pb.TagNumber(3)
  set abbreviation($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAbbreviation() => $_has(2);
  @$pb.TagNumber(3)
  void clearAbbreviation() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get namingStandard => $_getSZ(3);
  @$pb.TagNumber(4)
  set namingStandard($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNamingStandard() => $_has(3);
  @$pb.TagNumber(4)
  void clearNamingStandard() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get parentheticalQualifier => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentheticalQualifier($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasParentheticalQualifier() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentheticalQualifier() => clearField(5);
}

class Entry_Translation extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Entry.Translation', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'rogers_dictionary'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'partOfSpeech', protoName: 'partOfSpeech')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'content')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'irregularInflections', protoName: 'irregularInflections')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dominantHeadwordParentheticalQualifier', protoName: 'dominantHeadwordParentheticalQualifier')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'genderAndPlural', protoName: 'genderAndPlural')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'namingStandard', protoName: 'namingStandard')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'abbreviation')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'parentheticalQualifier', protoName: 'parentheticalQualifier')
    ..aOS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'editorialNote', protoName: 'editorialNote')
    ..pPS(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'examplePhrases', protoName: 'examplePhrases')
    ..aOS(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'oppositeHeadword')
    ..hasRequiredFields = false
  ;

  Entry_Translation._() : super();
  factory Entry_Translation({
    $core.String? partOfSpeech,
    $core.String? content,
    $core.Iterable<$core.String>? irregularInflections,
    $core.String? dominantHeadwordParentheticalQualifier,
    $core.String? genderAndPlural,
    $core.String? namingStandard,
    $core.String? abbreviation,
    $core.String? parentheticalQualifier,
    $core.String? editorialNote,
    $core.Iterable<$core.String>? examplePhrases,
    $core.String? oppositeHeadword,
  }) {
    final _result = create();
    if (partOfSpeech != null) {
      _result.partOfSpeech = partOfSpeech;
    }
    if (content != null) {
      _result.content = content;
    }
    if (irregularInflections != null) {
      _result.irregularInflections.addAll(irregularInflections);
    }
    if (dominantHeadwordParentheticalQualifier != null) {
      _result.dominantHeadwordParentheticalQualifier = dominantHeadwordParentheticalQualifier;
    }
    if (genderAndPlural != null) {
      _result.genderAndPlural = genderAndPlural;
    }
    if (namingStandard != null) {
      _result.namingStandard = namingStandard;
    }
    if (abbreviation != null) {
      _result.abbreviation = abbreviation;
    }
    if (parentheticalQualifier != null) {
      _result.parentheticalQualifier = parentheticalQualifier;
    }
    if (editorialNote != null) {
      _result.editorialNote = editorialNote;
    }
    if (examplePhrases != null) {
      _result.examplePhrases.addAll(examplePhrases);
    }
    if (oppositeHeadword != null) {
      _result.oppositeHeadword = oppositeHeadword;
    }
    return _result;
  }
  factory Entry_Translation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Entry_Translation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Entry_Translation clone() => Entry_Translation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Entry_Translation copyWith(void Function(Entry_Translation) updates) => super.copyWith((message) => updates(message as Entry_Translation)) as Entry_Translation; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Entry_Translation create() => Entry_Translation._();
  Entry_Translation createEmptyInstance() => create();
  static $pb.PbList<Entry_Translation> createRepeated() => $pb.PbList<Entry_Translation>();
  @$core.pragma('dart2js:noInline')
  static Entry_Translation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Entry_Translation>(create);
  static Entry_Translation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get partOfSpeech => $_getSZ(0);
  @$pb.TagNumber(1)
  set partOfSpeech($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPartOfSpeech() => $_has(0);
  @$pb.TagNumber(1)
  void clearPartOfSpeech() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get irregularInflections => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get dominantHeadwordParentheticalQualifier => $_getSZ(3);
  @$pb.TagNumber(4)
  set dominantHeadwordParentheticalQualifier($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDominantHeadwordParentheticalQualifier() => $_has(3);
  @$pb.TagNumber(4)
  void clearDominantHeadwordParentheticalQualifier() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get genderAndPlural => $_getSZ(4);
  @$pb.TagNumber(5)
  set genderAndPlural($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGenderAndPlural() => $_has(4);
  @$pb.TagNumber(5)
  void clearGenderAndPlural() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get namingStandard => $_getSZ(5);
  @$pb.TagNumber(6)
  set namingStandard($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasNamingStandard() => $_has(5);
  @$pb.TagNumber(6)
  void clearNamingStandard() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get abbreviation => $_getSZ(6);
  @$pb.TagNumber(7)
  set abbreviation($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAbbreviation() => $_has(6);
  @$pb.TagNumber(7)
  void clearAbbreviation() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get parentheticalQualifier => $_getSZ(7);
  @$pb.TagNumber(8)
  set parentheticalQualifier($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasParentheticalQualifier() => $_has(7);
  @$pb.TagNumber(8)
  void clearParentheticalQualifier() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get editorialNote => $_getSZ(8);
  @$pb.TagNumber(9)
  set editorialNote($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasEditorialNote() => $_has(8);
  @$pb.TagNumber(9)
  void clearEditorialNote() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<$core.String> get examplePhrases => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get oppositeHeadword => $_getSZ(10);
  @$pb.TagNumber(11)
  set oppositeHeadword($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasOppositeHeadword() => $_has(10);
  @$pb.TagNumber(11)
  void clearOppositeHeadword() => clearField(11);
}

class Entry extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Entry', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'rogers_dictionary'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'entryId', $pb.PbFieldType.OU3, protoName: 'entryId')
    ..aOM<Entry_Headword>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'headword', subBuilder: Entry_Headword.create)
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'related')
    ..pc<Entry_Headword>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'alternateHeadwords', $pb.PbFieldType.PM, protoName: 'alternateHeadwords', subBuilder: Entry_Headword.create)
    ..pc<Entry_Translation>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'translations', $pb.PbFieldType.PM, subBuilder: Entry_Translation.create)
    ..hasRequiredFields = false
  ;

  Entry._() : super();
  factory Entry({
    $core.int? entryId,
    Entry_Headword? headword,
    $core.Iterable<$core.String>? related,
    $core.Iterable<Entry_Headword>? alternateHeadwords,
    $core.Iterable<Entry_Translation>? translations,
  }) {
    final _result = create();
    if (entryId != null) {
      _result.entryId = entryId;
    }
    if (headword != null) {
      _result.headword = headword;
    }
    if (related != null) {
      _result.related.addAll(related);
    }
    if (alternateHeadwords != null) {
      _result.alternateHeadwords.addAll(alternateHeadwords);
    }
    if (translations != null) {
      _result.translations.addAll(translations);
    }
    return _result;
  }
  factory Entry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Entry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Entry clone() => Entry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Entry copyWith(void Function(Entry) updates) => super.copyWith((message) => updates(message as Entry)) as Entry; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Entry create() => Entry._();
  Entry createEmptyInstance() => create();
  static $pb.PbList<Entry> createRepeated() => $pb.PbList<Entry>();
  @$core.pragma('dart2js:noInline')
  static Entry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Entry>(create);
  static Entry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entryId => $_getIZ(0);
  @$pb.TagNumber(1)
  set entryId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => clearField(1);

  @$pb.TagNumber(2)
  Entry_Headword get headword => $_getN(1);
  @$pb.TagNumber(2)
  set headword(Entry_Headword v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeadword() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeadword() => clearField(2);
  @$pb.TagNumber(2)
  Entry_Headword ensureHeadword() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<$core.String> get related => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<Entry_Headword> get alternateHeadwords => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<Entry_Translation> get translations => $_getList(4);
}

