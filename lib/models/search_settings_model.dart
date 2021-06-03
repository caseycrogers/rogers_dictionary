enum SortOrder {
  alphabetical,
  relevance,
}

class SearchSettingsModel {
  SearchSettingsModel(this._sortBy);

  SearchSettingsModel.empty() : this(_DEFAULT_SORT_ORDER);

  static const SortOrder _DEFAULT_SORT_ORDER = SortOrder.relevance;

  final SortOrder _sortBy;

  SearchSettingsModel copy({SortOrder? newSortBy}) {
    return SearchSettingsModel(newSortBy ?? _sortBy);
  }

  SortOrder get sortBy => _sortBy;

  @override
  int get hashCode => _sortBy.toString().hashCode;

  @override
  bool operator ==(Object other) =>
      other is SearchSettingsModel && hashCode == other.hashCode;
}
