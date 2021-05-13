///
//  Generated code. Do not modify.
//  source: lib/protobufs/dialogues.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class DialogueChapter_SubChapter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DialogueChapter.SubChapter', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'rogers_dictionary'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'englishTitle', protoName: 'englishTitle')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'spanishTitle', protoName: 'spanishTitle')
    ..pc<DialogueChapter_Dialogue>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dialogues', $pb.PbFieldType.PM, subBuilder: DialogueChapter_Dialogue.create)
    ..hasRequiredFields = false
  ;

  DialogueChapter_SubChapter._() : super();
  factory DialogueChapter_SubChapter({
    $core.String? englishTitle,
    $core.String? spanishTitle,
    $core.Iterable<DialogueChapter_Dialogue>? dialogues,
  }) {
    final _result = create();
    if (englishTitle != null) {
      _result.englishTitle = englishTitle;
    }
    if (spanishTitle != null) {
      _result.spanishTitle = spanishTitle;
    }
    if (dialogues != null) {
      _result.dialogues.addAll(dialogues);
    }
    return _result;
  }
  factory DialogueChapter_SubChapter.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DialogueChapter_SubChapter.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DialogueChapter_SubChapter clone() => DialogueChapter_SubChapter()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DialogueChapter_SubChapter copyWith(void Function(DialogueChapter_SubChapter) updates) => super.copyWith((message) => updates(message as DialogueChapter_SubChapter)) as DialogueChapter_SubChapter; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DialogueChapter_SubChapter create() => DialogueChapter_SubChapter._();
  DialogueChapter_SubChapter createEmptyInstance() => create();
  static $pb.PbList<DialogueChapter_SubChapter> createRepeated() => $pb.PbList<DialogueChapter_SubChapter>();
  @$core.pragma('dart2js:noInline')
  static DialogueChapter_SubChapter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DialogueChapter_SubChapter>(create);
  static DialogueChapter_SubChapter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get englishTitle => $_getSZ(0);
  @$pb.TagNumber(1)
  set englishTitle($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnglishTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnglishTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get spanishTitle => $_getSZ(1);
  @$pb.TagNumber(2)
  set spanishTitle($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSpanishTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpanishTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<DialogueChapter_Dialogue> get dialogues => $_getList(2);
}

class DialogueChapter_Dialogue extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DialogueChapter.Dialogue', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'rogers_dictionary'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'englishContent', protoName: 'englishContent')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'spanishContent', protoName: 'spanishContent')
    ..hasRequiredFields = false
  ;

  DialogueChapter_Dialogue._() : super();
  factory DialogueChapter_Dialogue({
    $core.String? englishContent,
    $core.String? spanishContent,
  }) {
    final _result = create();
    if (englishContent != null) {
      _result.englishContent = englishContent;
    }
    if (spanishContent != null) {
      _result.spanishContent = spanishContent;
    }
    return _result;
  }
  factory DialogueChapter_Dialogue.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DialogueChapter_Dialogue.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DialogueChapter_Dialogue clone() => DialogueChapter_Dialogue()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DialogueChapter_Dialogue copyWith(void Function(DialogueChapter_Dialogue) updates) => super.copyWith((message) => updates(message as DialogueChapter_Dialogue)) as DialogueChapter_Dialogue; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DialogueChapter_Dialogue create() => DialogueChapter_Dialogue._();
  DialogueChapter_Dialogue createEmptyInstance() => create();
  static $pb.PbList<DialogueChapter_Dialogue> createRepeated() => $pb.PbList<DialogueChapter_Dialogue>();
  @$core.pragma('dart2js:noInline')
  static DialogueChapter_Dialogue getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DialogueChapter_Dialogue>(create);
  static DialogueChapter_Dialogue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get englishContent => $_getSZ(0);
  @$pb.TagNumber(1)
  set englishContent($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnglishContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnglishContent() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get spanishContent => $_getSZ(1);
  @$pb.TagNumber(2)
  set spanishContent($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSpanishContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpanishContent() => clearField(2);
}

class DialogueChapter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DialogueChapter', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'rogers_dictionary'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'chapterId', $pb.PbFieldType.OU3, protoName: 'chapterId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'englishTitle', protoName: 'englishTitle')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'spanishTitle', protoName: 'spanishTitle')
    ..pc<DialogueChapter_SubChapter>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dialogueSubChapters', $pb.PbFieldType.PM, protoName: 'dialogueSubChapters', subBuilder: DialogueChapter_SubChapter.create)
    ..hasRequiredFields = false
  ;

  DialogueChapter._() : super();
  factory DialogueChapter({
    $core.int? chapterId,
    $core.String? englishTitle,
    $core.String? spanishTitle,
    $core.Iterable<DialogueChapter_SubChapter>? dialogueSubChapters,
  }) {
    final _result = create();
    if (chapterId != null) {
      _result.chapterId = chapterId;
    }
    if (englishTitle != null) {
      _result.englishTitle = englishTitle;
    }
    if (spanishTitle != null) {
      _result.spanishTitle = spanishTitle;
    }
    if (dialogueSubChapters != null) {
      _result.dialogueSubChapters.addAll(dialogueSubChapters);
    }
    return _result;
  }
  factory DialogueChapter.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DialogueChapter.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DialogueChapter clone() => DialogueChapter()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DialogueChapter copyWith(void Function(DialogueChapter) updates) => super.copyWith((message) => updates(message as DialogueChapter)) as DialogueChapter; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DialogueChapter create() => DialogueChapter._();
  DialogueChapter createEmptyInstance() => create();
  static $pb.PbList<DialogueChapter> createRepeated() => $pb.PbList<DialogueChapter>();
  @$core.pragma('dart2js:noInline')
  static DialogueChapter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DialogueChapter>(create);
  static DialogueChapter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get chapterId => $_getIZ(0);
  @$pb.TagNumber(1)
  set chapterId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChapterId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChapterId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get englishTitle => $_getSZ(1);
  @$pb.TagNumber(2)
  set englishTitle($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEnglishTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnglishTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get spanishTitle => $_getSZ(2);
  @$pb.TagNumber(3)
  set spanishTitle($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSpanishTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpanishTitle() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<DialogueChapter_SubChapter> get dialogueSubChapters => $_getList(3);
}

