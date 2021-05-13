///
//  Generated code. Do not modify.
//  source: lib/protobufs/dialogues.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use dialogueChapterDescriptor instead')
const DialogueChapter$json = const {
  '1': 'DialogueChapter',
  '2': const [
    const {'1': 'chapterId', '3': 1, '4': 1, '5': 13, '10': 'chapterId'},
    const {'1': 'englishTitle', '3': 2, '4': 1, '5': 9, '10': 'englishTitle'},
    const {'1': 'spanishTitle', '3': 3, '4': 1, '5': 9, '10': 'spanishTitle'},
    const {'1': 'dialogueSubChapters', '3': 4, '4': 3, '5': 11, '6': '.rogers_dictionary.DialogueChapter.SubChapter', '10': 'dialogueSubChapters'},
  ],
  '3': const [DialogueChapter_SubChapter$json, DialogueChapter_Dialogue$json],
};

@$core.Deprecated('Use dialogueChapterDescriptor instead')
const DialogueChapter_SubChapter$json = const {
  '1': 'SubChapter',
  '2': const [
    const {'1': 'englishTitle', '3': 1, '4': 1, '5': 9, '10': 'englishTitle'},
    const {'1': 'spanishTitle', '3': 2, '4': 1, '5': 9, '10': 'spanishTitle'},
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
final $typed_data.Uint8List dialogueChapterDescriptor = $convert.base64Decode('Cg9EaWFsb2d1ZUNoYXB0ZXISHAoJY2hhcHRlcklkGAEgASgNUgljaGFwdGVySWQSIgoMZW5nbGlzaFRpdGxlGAIgASgJUgxlbmdsaXNoVGl0bGUSIgoMc3BhbmlzaFRpdGxlGAMgASgJUgxzcGFuaXNoVGl0bGUSXwoTZGlhbG9ndWVTdWJDaGFwdGVycxgEIAMoCzItLnJvZ2Vyc19kaWN0aW9uYXJ5LkRpYWxvZ3VlQ2hhcHRlci5TdWJDaGFwdGVyUhNkaWFsb2d1ZVN1YkNoYXB0ZXJzGp8BCgpTdWJDaGFwdGVyEiIKDGVuZ2xpc2hUaXRsZRgBIAEoCVIMZW5nbGlzaFRpdGxlEiIKDHNwYW5pc2hUaXRsZRgCIAEoCVIMc3BhbmlzaFRpdGxlEkkKCWRpYWxvZ3VlcxgDIAMoCzIrLnJvZ2Vyc19kaWN0aW9uYXJ5LkRpYWxvZ3VlQ2hhcHRlci5EaWFsb2d1ZVIJZGlhbG9ndWVzGloKCERpYWxvZ3VlEiYKDmVuZ2xpc2hDb250ZW50GAEgASgJUg5lbmdsaXNoQ29udGVudBImCg5zcGFuaXNoQ29udGVudBgCIAEoCVIOc3BhbmlzaENvbnRlbnQ=');
