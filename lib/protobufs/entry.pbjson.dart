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
    const {'1': 'entry_id', '3': 1, '4': 1, '5': 13, '10': 'entryId'},
    const {'1': 'headword', '3': 2, '4': 1, '5': 11, '6': '.rogers_dictionary.Entry.Headword', '10': 'headword'},
    const {'1': 'related', '3': 3, '4': 3, '5': 9, '10': 'related'},
    const {'1': 'alternate_headwords', '3': 4, '4': 3, '5': 11, '6': '.rogers_dictionary.Entry.Headword', '10': 'alternateHeadwords'},
    const {'1': 'translations', '3': 5, '4': 3, '5': 11, '6': '.rogers_dictionary.Entry.Translation', '10': 'translations'},
  ],
  '3': const [Entry_Headword$json, Entry_Translation$json],
};

@$core.Deprecated('Use entryDescriptor instead')
const Entry_Headword$json = const {
  '1': 'Headword',
  '2': const [
    const {'1': 'is_alternate', '3': 1, '4': 1, '5': 8, '10': 'isAlternate'},
    const {'1': 'gender', '3': 2, '4': 1, '5': 9, '10': 'gender'},
    const {'1': 'headword_text', '3': 3, '4': 1, '5': 9, '10': 'headwordText'},
    const {'1': 'abbreviation', '3': 4, '4': 1, '5': 9, '10': 'abbreviation'},
    const {'1': 'naming_standard', '3': 5, '4': 1, '5': 9, '10': 'namingStandard'},
    const {'1': 'parenthetical_qualifier', '3': 6, '4': 1, '5': 9, '10': 'parentheticalQualifier'},
  ],
};

@$core.Deprecated('Use entryDescriptor instead')
const Entry_Translation$json = const {
  '1': 'Translation',
  '2': const [
    const {'1': 'part_of_speech', '3': 1, '4': 1, '5': 9, '10': 'partOfSpeech'},
    const {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    const {'1': 'pronunciation_override', '3': 3, '4': 1, '5': 9, '10': 'pronunciationOverride'},
    const {'1': 'irregular_inflections', '3': 4, '4': 3, '5': 9, '10': 'irregularInflections'},
    const {'1': 'dominant_headword_parenthetical_qualifier', '3': 5, '4': 1, '5': 9, '10': 'dominantHeadwordParentheticalQualifier'},
    const {'1': 'gender_and_plural', '3': 6, '4': 1, '5': 9, '10': 'genderAndPlural'},
    const {'1': 'naming_standard', '3': 7, '4': 1, '5': 9, '10': 'namingStandard'},
    const {'1': 'abbreviation', '3': 8, '4': 1, '5': 9, '10': 'abbreviation'},
    const {'1': 'parenthetical_qualifier', '3': 9, '4': 1, '5': 9, '10': 'parentheticalQualifier'},
    const {'1': 'disambiguation', '3': 10, '4': 1, '5': 9, '10': 'disambiguation'},
    const {'1': 'editorial_note', '3': 11, '4': 1, '5': 9, '10': 'editorialNote'},
    const {'1': 'example_phrases', '3': 12, '4': 3, '5': 9, '10': 'examplePhrases'},
    const {'1': 'opposite_headword', '3': 13, '4': 1, '5': 9, '10': 'oppositeHeadword'},
  ],
};

/// Descriptor for `Entry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entryDescriptor = $convert.base64Decode('CgVFbnRyeRIZCghlbnRyeV9pZBgBIAEoDVIHZW50cnlJZBI9CghoZWFkd29yZBgCIAEoCzIhLnJvZ2Vyc19kaWN0aW9uYXJ5LkVudHJ5LkhlYWR3b3JkUghoZWFkd29yZBIYCgdyZWxhdGVkGAMgAygJUgdyZWxhdGVkElIKE2FsdGVybmF0ZV9oZWFkd29yZHMYBCADKAsyIS5yb2dlcnNfZGljdGlvbmFyeS5FbnRyeS5IZWFkd29yZFISYWx0ZXJuYXRlSGVhZHdvcmRzEkgKDHRyYW5zbGF0aW9ucxgFIAMoCzIkLnJvZ2Vyc19kaWN0aW9uYXJ5LkVudHJ5LlRyYW5zbGF0aW9uUgx0cmFuc2xhdGlvbnMa8AEKCEhlYWR3b3JkEiEKDGlzX2FsdGVybmF0ZRgBIAEoCFILaXNBbHRlcm5hdGUSFgoGZ2VuZGVyGAIgASgJUgZnZW5kZXISIwoNaGVhZHdvcmRfdGV4dBgDIAEoCVIMaGVhZHdvcmRUZXh0EiIKDGFiYnJldmlhdGlvbhgEIAEoCVIMYWJicmV2aWF0aW9uEicKD25hbWluZ19zdGFuZGFyZBgFIAEoCVIObmFtaW5nU3RhbmRhcmQSNwoXcGFyZW50aGV0aWNhbF9xdWFsaWZpZXIYBiABKAlSFnBhcmVudGhldGljYWxRdWFsaWZpZXIa6wQKC1RyYW5zbGF0aW9uEiQKDnBhcnRfb2Zfc3BlZWNoGAEgASgJUgxwYXJ0T2ZTcGVlY2gSGAoHY29udGVudBgCIAEoCVIHY29udGVudBI1ChZwcm9udW5jaWF0aW9uX292ZXJyaWRlGAMgASgJUhVwcm9udW5jaWF0aW9uT3ZlcnJpZGUSMwoVaXJyZWd1bGFyX2luZmxlY3Rpb25zGAQgAygJUhRpcnJlZ3VsYXJJbmZsZWN0aW9ucxJZCilkb21pbmFudF9oZWFkd29yZF9wYXJlbnRoZXRpY2FsX3F1YWxpZmllchgFIAEoCVImZG9taW5hbnRIZWFkd29yZFBhcmVudGhldGljYWxRdWFsaWZpZXISKgoRZ2VuZGVyX2FuZF9wbHVyYWwYBiABKAlSD2dlbmRlckFuZFBsdXJhbBInCg9uYW1pbmdfc3RhbmRhcmQYByABKAlSDm5hbWluZ1N0YW5kYXJkEiIKDGFiYnJldmlhdGlvbhgIIAEoCVIMYWJicmV2aWF0aW9uEjcKF3BhcmVudGhldGljYWxfcXVhbGlmaWVyGAkgASgJUhZwYXJlbnRoZXRpY2FsUXVhbGlmaWVyEiYKDmRpc2FtYmlndWF0aW9uGAogASgJUg5kaXNhbWJpZ3VhdGlvbhIlCg5lZGl0b3JpYWxfbm90ZRgLIAEoCVINZWRpdG9yaWFsTm90ZRInCg9leGFtcGxlX3BocmFzZXMYDCADKAlSDmV4YW1wbGVQaHJhc2VzEisKEW9wcG9zaXRlX2hlYWR3b3JkGA0gASgJUhBvcHBvc2l0ZUhlYWR3b3Jk');
