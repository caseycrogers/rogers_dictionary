enum SortOrder {
  alphabetical,
  relevance,
}

class SearchOptions {
  static const SortOrder _DEFAULT_SORT_ORDER = SortOrder.relevance;
  static const bool _DEFAULT_IGNORE_ACCENTS = true;

  SortOrder _sortBy;
  bool _ignoreAccents;

  SortOrder get sortBy => _sortBy;

  bool get ignoreAccents => _ignoreAccents;

  SearchOptions._(this._sortBy, this._ignoreAccents);

  SearchOptions copyWith({SortOrder newSortBy, bool newIgnoreAccents}) {
    return SearchOptions._(
        newSortBy ?? _sortBy, newIgnoreAccents ?? _ignoreAccents);
  }

  static SearchOptions empty() =>
      SearchOptions._(_DEFAULT_SORT_ORDER, _DEFAULT_IGNORE_ACCENTS);

  @override
  int get hashCode => _sortBy.toString().hashCode ^ _ignoreAccents.hashCode;

  @override
  bool operator ==(o) => o is SearchOptions && this.hashCode == o.hashCode;
}
