import 'package:algolia/algolia.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/entry_database/entry_database.dart';

class AlgoliaDatabase extends EntryDatabase {
  Algolia _algolia = Algolia.init(
    applicationId: '4Z50QMD69C',
    apiKey: 'fbb606e10fa287ee999e2f39538b0577',
  );

  @override
  Stream<Entry> getEntries({String searchString, String startAfter}) async* {
    int page = 0;
    while (true) {
      var snapshot = await _algolia.instance
          .index('english_entries')
          .search(searchString)
          .setPage(page)
          .setHitsPerPage(10)
          .getObjects();
      if (snapshot.empty) {
        return;
      }
      for (var entry in snapshot.hits.map(_objectSnapToEntry)) {
        yield entry;
      }
      page++;
    }
  }

  @override
  Future<Entry> getEntry(String urlEncodedHeadword) {
    return _algolia.instance.index('english_entries').getObjectsByIds(
        [urlEncodedHeadword]).then((lst) => _objectSnapToEntry(lst.single));
  }

  Entry _objectSnapToEntry(AlgoliaObjectSnapshot snapshot) {
    return Entry.fromJson(snapshot.data);
  }
}
