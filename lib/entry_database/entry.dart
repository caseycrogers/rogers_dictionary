import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class Entry {
  final int id;
  final String article;
  final List<String> translations;

  Entry(this.id, this.article, this.translations);

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);
}