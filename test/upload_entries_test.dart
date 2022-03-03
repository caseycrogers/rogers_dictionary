import 'package:rogers_dictionary/util/entry_utils.dart';

import 'package:test/test.dart';

void main() {
  test('Can add transitive relateds', () {
    final EntryBuilder a = _mockEntryBuilder(uid: 'a');
    final EntryBuilder b = _mockEntryBuilder(uid: 'b');
    final EntryBuilder c = _mockEntryBuilder(uid: 'c');
    // The child adds its transitive parent.
    b.addTransitiveRelated(a);
    c.addTransitiveRelated(a);
    expect(a.related, unorderedEquals(<EntryBuilder>[b, c]));
    expect(b.related, unorderedEquals(<EntryBuilder>[a, c]));
    expect(c.related, unorderedEquals(<EntryBuilder>[a, b]));

    final EntryBuilder c_0 = _mockEntryBuilder(uid: 'c_0');
    final EntryBuilder c_1 = _mockEntryBuilder(uid: 'c_1');
    c_0.addTransitiveRelated(c);
    c_1.addTransitiveRelated(c);
    expect(a.related, unorderedEquals(<EntryBuilder>[b, c]));
    expect(b.related, unorderedEquals(<EntryBuilder>[a, c]));
    expect(c.related, unorderedEquals(<EntryBuilder>[a, b, c_0, c_1]));
    expect(c_0.related, unorderedEquals(<EntryBuilder>[c, c_1]));
    expect(c_1.related, unorderedEquals(<EntryBuilder>[c, c_0]));
  });
}

EntryBuilder _mockEntryBuilder({String? uid}) {
  return EntryBuilder()
      .uid(uid ?? '0FAKEUID')
      .orderId(0)
      .headword(uid ?? '0FAKEUID', '', '');
}
