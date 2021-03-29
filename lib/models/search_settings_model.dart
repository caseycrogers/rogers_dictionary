enum SortOrder {
  alphabetical,
  relevance,
}

class SearchSettingsModel {
  static const SortOrder _DEFAULT_SORT_ORDER = SortOrder.relevance;
  static const bool _DEFAULT_IGNORE_ACCENTS = true;

  SortOrder _sortBy;
  bool _ignoreAccents;

  SortOrder get sortBy => _sortBy;

  bool get ignoreAccents => _ignoreAccents;

  SearchSettingsModel(this._sortBy, this._ignoreAccents);

  SearchSettingsModel copy({SortOrder newSortBy, bool newIgnoreAccents}) {
    return SearchSettingsModel(
        newSortBy ?? _sortBy, newIgnoreAccents ?? _ignoreAccents);
  }

  static SearchSettingsModel empty() =>
      SearchSettingsModel(_DEFAULT_SORT_ORDER, _DEFAULT_IGNORE_ACCENTS);

  @override
  int get hashCode => _sortBy.toString().hashCode ^ _ignoreAccents.hashCode;

  @override
  bool operator ==(o) =>
      o is SearchSettingsModel && this.hashCode == o.hashCode;
}
