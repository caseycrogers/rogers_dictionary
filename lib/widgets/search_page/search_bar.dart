import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/adaptive_material/adaptive_material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar();

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;
  late bool _isEmpty;

  bool _shouldInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final SearchModel searchPageModel =
        DictionaryModel.of(context).translationModel.value.searchPageModel;

    if (_shouldInit) {
      _controller = TextEditingController(text: searchPageModel.searchString);
      _controller.addListener(_onChanged);
      _isEmpty = searchPageModel.searchString.isEmpty;
      _shouldInit = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TranslationModel>(
      valueListenable: DictionaryModel.of(context).translationModel,
      builder: (context, translationPage, child) {
        return child!;
      },
      child: _SearchBarBase(controller: _controller),
    );
  }

  void _onChanged() {
    DictionaryModel.of(context)
        .currTranslationModel
        .searchPageModel
        .entrySearchModel
        .onSearchStringChanged(
          context: context,
          newSearchString: _controller.text,
        );
    if (_isEmpty != _controller.text.isEmpty) {
      setState(() => _isEmpty = _controller.text.isEmpty);
    }
  }
}

class _SearchBarBase extends StatelessWidget {
  const _SearchBarBase({Key? key, this.controller}) : super(key: key);

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(vertical: kPad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: TextField(
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyText2!.fontSize,
            ),
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
              hintText: '${i18n.search.get(context)}...',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
