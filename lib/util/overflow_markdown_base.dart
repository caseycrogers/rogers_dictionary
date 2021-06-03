class MarkdownBase {
  const MarkdownBase(this.text, [this.overrideRules]);

  final String text;
  final List<OverrideRule>? overrideRules;

  List<MapEntry<MarkdownStyle, String>> constructSpans() {
    final List<MapEntry<MarkdownStyle, String>> spans = [];
    MarkdownStyle mdStyle = const MarkdownStyle();
    final StringBuffer buff = StringBuffer();
    int i = 0;
    // Index of user visible characters (excl. parentheses).
    var charIndex = 0;

    void addSpan(MarkdownStyle newMdStyle) {
      if (buff.isEmpty) {
        mdStyle = newMdStyle;
        return;
      }
      spans.add(
        MapEntry(
          mdStyle,
          buff.toString(),
        ),
      );
      buff.clear();
      mdStyle = newMdStyle;
    }

    while (i < text.length) {
      if ((overrideRules ?? []).any((o) => o.matchesStop(i, charIndex))) {
        addSpan(mdStyle.copyWith(clearOverride: true));
      }
      final char = text[i];
      // Skip parentheses BEFORE starting override styles.
      if (['(', ')'].contains(char)) {
        buff.write(char);
        i += 1;
        continue;
      }
      final OverrideRule? startOverride =
          // Cast is necessary so that `orElse` can return null.
          // ignore: unnecessary_cast
          (overrideRules ?? []).map((e) => e as OverrideRule?).firstWhere(
                (o) => o?.matchesStart(i, charIndex) ?? false,
                orElse: () => null,
              );
      if (startOverride != null) {
        addSpan(mdStyle.copyWith(overrideStyle: startOverride.styleIndex));
      }
      if (char == '\\') {
        assert(i != text.length,
            'Invalid escape character at end of string in $text');
        buff.write(text[i + 1]);
        charIndex += 1;
        i += 2;
        continue;
      }
      if (i + 1 < text.length && text.substring(i, i + 2) == '**') {
        addSpan(mdStyle.copyWith(isBold: !mdStyle.isBold));
        i += 2;
        continue;
      }
      if (char == '*') {
        addSpan(mdStyle.copyWith(isItalic: !mdStyle.isItalic));
        i += 1;
        continue;
      }
      if (char == '`') {
        addSpan(mdStyle.copyWith(isSubscript: !mdStyle.isSubscript));
        i += 1;
        continue;
      }
      buff.write(char);
      charIndex += 1;
      i += 1;
    }
    addSpan(mdStyle);
    assert(!mdStyle.isItalic, 'Unclosed italic mark in $text');
    assert(!mdStyle.isBold, 'Unclosed bold mark in $text');
    return spans;
  }

  List<String> strip({
    bool italics = false,
    bool bolds = false,
    bool subscripts = false,
  }) =>
      constructSpans()
          .where((e) =>
              !(italics && e.key.isItalic) &&
              !(bolds && e.key.isBold) &&
              !(subscripts && e.key.isSubscript))
          .map((e) => e.value)
          .toList();
}

class MarkdownStyle {
  const MarkdownStyle({
    this.isBold = false,
    this.isItalic = false,
    this.isSubscript = false,
    this.overrideStyle,
  });

  MarkdownStyle copyWith({
    bool? isBold,
    bool? isItalic,
    bool? isSubscript,
    int? overrideStyle,
    bool clearOverride = false,
  }) =>
      MarkdownStyle(
        isBold: isBold ?? this.isBold,
        isItalic: isItalic ?? this.isItalic,
        isSubscript: isSubscript ?? this.isSubscript,
        overrideStyle:
            clearOverride ? null : overrideStyle ?? this.overrideStyle,
      );

  final bool isBold;
  final bool isItalic;
  final bool isSubscript;
  final int? overrideStyle;

  bool get canWrap => overrideStyle == null;

  bool get isDefault => this is DefaultStyle;
}

class DefaultStyle extends MarkdownStyle {
  factory DefaultStyle() => _default;

  DefaultStyle._() : super();

  static final _default = DefaultStyle._();
}

class OverrideRule {
  OverrideRule({
    required this.styleIndex,
    required this.start,
    required this.stop,
  }) : assert(start != stop);

  int styleIndex;

  /// When to start applying the override style, inclusive.
  int start;

  /// When to stop applying the override style, exclusive.
  int stop;

  bool matchesStart(int index, int charIndex) => charIndex == start;

  bool matchesStop(int index, int charIndex) => charIndex == stop;
}
