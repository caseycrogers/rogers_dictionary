// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';

class DictionarySearchBar extends StatefulWidget {
  const DictionarySearchBar();

  @override
  _DictionarySearchBarState createState() => _DictionarySearchBarState();
}

class _DictionarySearchBarState extends State<DictionarySearchBar> {
  late TextEditingController _controller;

  late SearchModel _searchModel;

  bool _shouldInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchModel = DictionaryModel.instance.translationModel.value.searchModel;

    if (_shouldInit) {
      _controller = TextEditingController(text: _searchModel.searchString);
      // Bidirectional listen. This won't create an infinite loop because it
      // only notifies listeners if the value is new.
      _controller.addListener(_onTextChanged);
      _searchModel.entrySearchModel.currSearchString
          .addListener(_onSearchChanged);
      _shouldInit = false;
    }
  }

  @override
  void dispose() {
    _searchModel.entrySearchModel.currSearchString
        .removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TranslationModel>(
      valueListenable: DictionaryModel.instance.translationModel,
      builder: (context, translationPage, child) {
        return child!;
      },
      child: _DictionarySearchBarBase(
        controller: _controller,
      ),
    );
  }

  // Listener to update model if the local text has changed.
  void _onTextChanged() {
    final EntrySearchModel entrySearchModel = DictionaryModel
        .instance.currTranslationModel.searchModel.entrySearchModel;
    final bool oldIsEmpty = entrySearchModel.isEmpty;
    DictionaryModel.instance.currTranslationModel.searchModel.entrySearchModel
        .onSearchStringChanged(
      context: context,
      newSearchString: _controller.text,
    );
    if (oldIsEmpty != _controller.text.isEmpty) {
      setState(() {});
    }
  }

  // Listener to update local text if the model has changed.
  void _onSearchChanged() {
    final EntrySearchModel entrySearchModel = DictionaryModel
        .instance.currTranslationModel.searchModel.entrySearchModel;
    final String oldText = _controller.text;
    if (oldText != entrySearchModel.searchString) {
      _controller.text = entrySearchModel.searchString;
    }
    if (oldText.isEmpty != entrySearchModel.isEmpty) {
      setState(() {});
    }
  }
}

class _DictionarySearchBarBase extends StatelessWidget {
  const _DictionarySearchBarBase({
    Key? key,
    this.controller,
  }) : super(key: key);

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(vertical: kPad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: AdaptiveMaterial(
          adaptiveColor: AdaptiveColor.surface,
          child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller?.text.isNotEmpty ?? false
                  ? IconButton(
                      onPressed: () {
                        controller?.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              hintStyle: const TextStyle(color: Colors.grey),
              hintText: '${i18n.search.get(context)}...',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
