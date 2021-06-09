///
//  Generated code. Do not modify.
//  source: lib/protobufs/entry.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use entryDescriptor instead')
const Entry$json = const {
  '1': 'Entry',
  '2': const [
    const {'1': 'entryId', '3': 1, '4': 1, '5': 13, '10': 'entryId'},
    const {'1': 'headword', '3': 2, '4': 1, '5': 11, '6': '.rogers_dictionary.Entry.Headword', '10': 'headword'},
    const {'1': 'related', '3': 3, '4': 3, '5': 9, '10': 'related'},
    const {'1': 'alternateHeadwords', '3': 4, '4': 3, '5': 11, '6': '.rogers_dictionary.Entry.Headword', '10': 'alternateHeadwords'},
    const {'1': 'translations', '3': 5, '4': 3, '5': 11, '6': '.rogers_dictionary.Entry.Translation', '10': 'translations'},
  ],
  '3': const [Entry_Headword$json, Entry_Translation$json],
};

@$core.Deprecated('Use entryDescriptor instead')
const Entry_Headword$json = const {
  '1': 'Headword',
  '2': const [
    const {'1': 'isAlternate', '3': 1, '4': 1, '5': 8, '10': 'isAlternate'},
    const {'1': 'headwordText', '3': 2, '4': 1, '5': 9, '10': 'headwordText'},
    const {'1': 'abbreviation', '3': 3, '4': 1, '5': 9, '10': 'abbreviation'},
    const {'1': 'namingStandard', '3': 4, '4': 1, '5': 9, '10': 'namingStandard'},
    const {'1': 'parentheticalQualifier', '3': 5, '4': 1, '5': 9, '10': 'parentheticalQualifier'},
  ],
};

@$core.Deprecated('Use entryDescriptor instead')
const Entry_Translation$json = const {
  '1': 'Translation',
  '2': const [
    const {'1': 'partOfSpeech', '3': 1, '4': 1, '5': 9, '10': 'partOfSpeech'},
    const {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    const {'1': 'irregularInflections', '3': 3, '4': 3, '5': 9, '10': 'irregularInflections'},
    const {'1': 'dominantHeadwordParentheticalQualifier', '3': 4, '4': 1, '5': 9, '10': 'dominantHeadwordParentheticalQualifier'},
    const {'1': 'genderAndPlural', '3': 5, '4': 1, '5': 9, '10': 'genderAndPlural'},
    const {'1': 'namingStandard', '3': 6, '4': 1, '5': 9, '10': 'namingStandard'},
    const {'1': 'abbreviation', '3': 7, '4': 1, '5': 9, '10': 'abbreviation'},
    const {'1': 'parentheticalQualifier', '3': 8, '4': 1, '5': 9, '10': 'parentheticalQualifier'},
    const {'1': 'editorialNote', '3': 9, '4': 1, '5': 9, '10': 'editorialNote'},
    const {'1': 'examplePhrases', '3': 10, '4': 3, '5': 9, '10': 'examplePhrases'},
    const {'1': 'opposite_headword', '3': 11, '4': 1, '5': 9, '10': 'oppositeHeadword'},
  ],
};

/// Descriptor for `Entry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryDescriptor = $convert.base64Decode('CgVFbnRyeRIYCgdlbnRyeUlkGAEgASgNUgdlbnRyeUlkEj0KCGhlYWR3b3JkGAIgASgLMiEucm9nZXJzX2RpY3Rpb25hcnkuRW50cnkuSGVhZHdvcmRSCGhlYWR3b3JkEhgKB3JlbGF0ZWQYAyADKAlSB3JlbGF0ZWQSUQoSYWx0ZXJuYXRlSGVhZHdvcmRzGAQgAygLMiEucm9nZXJzX2RpY3Rpb25hcnkuRW50cnkuSGVhZHdvcmRSEmFsdGVybmF0ZUhlYWR3b3JkcxJICgx0cmFuc2xhdGlvbnMYBSADKAsyJC5yb2dlcnNfZGljdGlvbmFyeS5FbnRyeS5UcmFuc2xhdGlvblIMdHJhbnNsYXRpb25zGtQBCghIZWFkd29yZBIgCgtpc0FsdGVybmF0ZRgBIAEoCFILaXNBbHRlcm5hdGUSIgoMaGVhZHdvcmRUZXh0GAIgASgJUgxoZWFkd29yZFRleHQSIgoMYWJicmV2aWF0aW9uGAMgASgJUgxhYmJyZXZpYXRpb24SJgoObmFtaW5nU3RhbmRhcmQYBCABKAlSDm5hbWluZ1N0YW5kYXJkEjYKFnBhcmVudGhldGljYWxRdWFsaWZpZXIYBSABKAlSFnBhcmVudGhldGljYWxRdWFsaWZpZXIagAQKC1RyYW5zbGF0aW9uEiIKDHBhcnRPZlNwZWVjaBgBIAEoCVIMcGFydE9mU3BlZWNoEhgKB2NvbnRlbnQYAiABKAlSB2NvbnRlbnQSMgoUaXJyZWd1bGFySW5mbGVjdGlvbnMYAyADKAlSFGlycmVndWxhckluZmxlY3Rpb25zElYKJmRvbWluYW50SGVhZHdvcmRQYXJlbnRoZXRpY2FsUXVhbGlmaWVyGAQgASgJUiZkb21pbmFudEhlYWR3b3JkUGFyZW50aGV0aWNhbFF1YWxpZmllchIoCg9nZW5kZXJBbmRQbHVyYWwYBSABKAlSD2dlbmRlckFuZFBsdXJhbBImCg5uYW1pbmdTdGFuZGFyZBgGIAEoCVIObmFtaW5nU3RhbmRhcmQSIgoMYWJicmV2aWF0aW9uGAcgASgJUgxhYmJyZXZpYXRpb24SNgoWcGFyZW50aGV0aWNhbFF1YWxpZmllchgIIAEoCVIWcGFyZW50aGV0aWNhbFF1YWxpZmllchIkCg1lZGl0b3JpYWxOb3RlGAkgASgJUg1lZGl0b3JpYWxOb3RlEiYKDmV4YW1wbGVQaHJhc2VzGAogAygJUg5leGFtcGxlUGhyYXNlcxIrChFvcHBvc2l0ZV9oZWFkd29yZBgLIAEoCVIQb3Bwb3NpdGVIZWFkd29yZA==');
