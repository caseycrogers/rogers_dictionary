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
    const {'1': 'uid', '3': 1, '4': 1, '5': 9, '10': 'uid'},
    const {'1': 'order_id', '3': 2, '4': 1, '5': 13, '10': 'orderId'},
    const {'1': 'headword', '3': 3, '4': 1, '5': 11, '6': '.rogers_dictionary.Entry.Headword', '10': 'headword'},
    const {'1': 'related', '3': 4, '4': 3, '5': 9, '10': 'related'},
    const {'1': 'alternate_headwords', '3': 5, '4': 3, '5': 11, '6': '.rogers_dictionary.Entry.Headword', '10': 'alternateHeadwords'},
    const {'1': 'translations', '3': 6, '4': 3, '5': 11, '6': '.rogers_dictionary.Entry.Translation', '10': 'translations'},
  ],
  '3': const [Entry_Headword$json, Entry_Translation$json],
};

@$core.Deprecated('Use entryDescriptor instead')
const Entry_Headword$json = const {
  '1': 'Headword',
  '2': const [
    const {'1': 'is_alternate', '3': 1, '4': 1, '5': 8, '10': 'isAlternate'},
    const {'1': 'gender', '3': 2, '4': 1, '5': 9, '10': 'gender'},
    const {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
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
    const {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
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
final $typed_data.Uint8List entryDescriptor = $convert.base64Decode('CgVFbnRyeRIQCgN1aWQYASABKAlSA3VpZBIZCghvcmRlcl9pZBgCIAEoDVIHb3JkZXJJZBI9CghoZWFkd29yZBgDIAEoCzIhLnJvZ2Vyc19kaWN0aW9uYXJ5LkVudHJ5LkhlYWR3b3JkUghoZWFkd29yZBIYCgdyZWxhdGVkGAQgAygJUgdyZWxhdGVkElIKE2FsdGVybmF0ZV9oZWFkd29yZHMYBSADKAsyIS5yb2dlcnNfZGljdGlvbmFyeS5FbnRyeS5IZWFkd29yZFISYWx0ZXJuYXRlSGVhZHdvcmRzEkgKDHRyYW5zbGF0aW9ucxgGIAMoCzIkLnJvZ2Vyc19kaWN0aW9uYXJ5LkVudHJ5LlRyYW5zbGF0aW9uUgx0cmFuc2xhdGlvbnMa3wEKCEhlYWR3b3JkEiEKDGlzX2FsdGVybmF0ZRgBIAEoCFILaXNBbHRlcm5hdGUSFgoGZ2VuZGVyGAIgASgJUgZnZW5kZXISEgoEdGV4dBgDIAEoCVIEdGV4dBIiCgxhYmJyZXZpYXRpb24YBCABKAlSDGFiYnJldmlhdGlvbhInCg9uYW1pbmdfc3RhbmRhcmQYBSABKAlSDm5hbWluZ1N0YW5kYXJkEjcKF3BhcmVudGhldGljYWxfcXVhbGlmaWVyGAYgASgJUhZwYXJlbnRoZXRpY2FsUXVhbGlmaWVyGuUECgtUcmFuc2xhdGlvbhIkCg5wYXJ0X29mX3NwZWVjaBgBIAEoCVIMcGFydE9mU3BlZWNoEhIKBHRleHQYAiABKAlSBHRleHQSNQoWcHJvbnVuY2lhdGlvbl9vdmVycmlkZRgDIAEoCVIVcHJvbnVuY2lhdGlvbk92ZXJyaWRlEjMKFWlycmVndWxhcl9pbmZsZWN0aW9ucxgEIAMoCVIUaXJyZWd1bGFySW5mbGVjdGlvbnMSWQopZG9taW5hbnRfaGVhZHdvcmRfcGFyZW50aGV0aWNhbF9xdWFsaWZpZXIYBSABKAlSJmRvbWluYW50SGVhZHdvcmRQYXJlbnRoZXRpY2FsUXVhbGlmaWVyEioKEWdlbmRlcl9hbmRfcGx1cmFsGAYgASgJUg9nZW5kZXJBbmRQbHVyYWwSJwoPbmFtaW5nX3N0YW5kYXJkGAcgASgJUg5uYW1pbmdTdGFuZGFyZBIiCgxhYmJyZXZpYXRpb24YCCABKAlSDGFiYnJldmlhdGlvbhI3ChdwYXJlbnRoZXRpY2FsX3F1YWxpZmllchgJIAEoCVIWcGFyZW50aGV0aWNhbFF1YWxpZmllchImCg5kaXNhbWJpZ3VhdGlvbhgKIAEoCVIOZGlzYW1iaWd1YXRpb24SJQoOZWRpdG9yaWFsX25vdGUYCyABKAlSDWVkaXRvcmlhbE5vdGUSJwoPZXhhbXBsZV9waHJhc2VzGAwgAygJUg5leGFtcGxlUGhyYXNlcxIrChFvcHBvc2l0ZV9oZWFkd29yZBgNIAEoCVIQb3Bwb3NpdGVIZWFkd29yZA==');
