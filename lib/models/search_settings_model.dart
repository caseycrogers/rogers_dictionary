enum SortOrder {
  alphabetical,
  relevance,
}

class SearchSettingsModel {
  SearchSettingsModel(this._sortBy, this._ignoreAccents);

  SearchSettingsModel.empty()
      : this(_DEFAULT_SORT_ORDER, _DEFAULT_IGNORE_ACCENTS);

  static const SortOrder _DEFAULT_SORT_ORDER = SortOrder.relevance;
  static const bool _DEFAULT_IGNORE_ACCENTS = true;

  final SortOrder _sortBy;
  final bool _ignoreAccents;

  SearchSettingsModel copy({SortOrder? newSortBy, bool? newIgnoreAccents}) {
    return SearchSettingsModel(
        newSortBy ?? _sortBy, newIgnoreAccents ?? _ignoreAccents);
  }

  SortOrder get sortBy => _sortBy;

  bool get ignoreAccents => _ignoreAccents;

  @override
  int get hashCode => _sortBy.toString().hashCode ^ _ignoreAccents.hashCode;

  @override
  bool operator ==(Object other) =>
      other is SearchSettingsModel && hashCode == other.hashCode;
}
