///
//  Generated code. Do not modify.
//  source: lib/protobufs/dialogues.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

// Dart imports:
import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dialogueChapterDescriptor instead')
const DialogueChapter$json = const {
  '1': 'DialogueChapter',
  '2': const [
    const {'1': 'chapter_id', '3': 1, '4': 1, '5': 13, '10': 'chapterId'},
    const {'1': 'english_title', '3': 2, '4': 1, '5': 9, '10': 'englishTitle'},
    const {'1': 'spanish_title', '3': 3, '4': 1, '5': 9, '10': 'spanishTitle'},
    const {'1': 'dialogue_sub_chapters', '3': 4, '4': 3, '5': 11, '6': '.rogers_dictionary.DialogueChapter.SubChapter', '10': 'dialogueSubChapters'},
  ],
  '3': const [DialogueChapter_SubChapter$json, DialogueChapter_Dialogue$json],
};

@$core.Deprecated('Use dialogueChapterDescriptor instead')
const DialogueChapter_SubChapter$json = const {
  '1': 'SubChapter',
  '2': const [
    const {'1': 'english_title', '3': 1, '4': 1, '5': 9, '10': 'englishTitle'},
    const {'1': 'spanish_title', '3': 2, '4': 1, '5': 9, '10': 'spanishTitle'},
    const {'1': 'dialogues', '3': 3, '4': 3, '5': 11, '6': '.rogers_dictionary.DialogueChapter.Dialogue', '10': 'dialogues'},
  ],
};

@$core.Deprecated('Use dialogueChapterDescriptor instead')
const DialogueChapter_Dialogue$json = const {
  '1': 'Dialogue',
  '2': const [
    const {'1': 'englishContent', '3': 1, '4': 1, '5': 9, '10': 'englishContent'},
    const {'1': 'spanishContent', '3': 2, '4': 1, '5': 9, '10': 'spanishContent'},
  ],
};

/// Descriptor for `DialogueChapter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dialogueChapterDescriptor = $convert.base64Decode('Cg9EaWFsb2d1ZUNoYXB0ZXISHQoKY2hhcHRlcl9pZBgBIAEoDVIJY2hhcHRlcklkEiMKDWVuZ2xpc2hfdGl0bGUYAiABKAlSDGVuZ2xpc2hUaXRsZRIjCg1zcGFuaXNoX3RpdGxlGAMgASgJUgxzcGFuaXNoVGl0bGUSYQoVZGlhbG9ndWVfc3ViX2NoYXB0ZXJzGAQgAygLMi0ucm9nZXJzX2RpY3Rpb25hcnkuRGlhbG9ndWVDaGFwdGVyLlN1YkNoYXB0ZXJSE2RpYWxvZ3VlU3ViQ2hhcHRlcnMaoQEKClN1YkNoYXB0ZXISIwoNZW5nbGlzaF90aXRsZRgBIAEoCVIMZW5nbGlzaFRpdGxlEiMKDXNwYW5pc2hfdGl0bGUYAiABKAlSDHNwYW5pc2hUaXRsZRJJCglkaWFsb2d1ZXMYAyADKAsyKy5yb2dlcnNfZGljdGlvbmFyeS5EaWFsb2d1ZUNoYXB0ZXIuRGlhbG9ndWVSCWRpYWxvZ3VlcxpaCghEaWFsb2d1ZRImCg5lbmdsaXNoQ29udGVudBgBIAEoCVIOZW5nbGlzaENvbnRlbnQSJgoOc3BhbmlzaENvbnRlbnQYAiABKAlSDnNwYW5pc2hDb250ZW50');
