import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/search_options_menu.dart';

class SearchOptionsView extends StatefulWidget {
  final void Function(SearchOptions) onSearchChanged;

  SearchOptionsView({@required this.onSearchChanged});

  @override
  _SearchOptionsViewState createState() => _SearchOptionsViewState();
}

class _SearchOptionsViewState extends State<SearchOptionsView> {
  bool get _hasFocus => DictionaryPageModel.of(context).expandSearchOptions;

  set _hasFocus(bool value) => setState(
      () => DictionaryPageModel.of(context).expandSearchOptions = value);
  List<OverlayEntry> _overlayEntry = [];

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _hasFocus ? Colors.black26 : Colors.transparent,
        ),
        child: IconButton(
          splashColor: Colors.black26,
          onPressed: () {
            _toggle();
          },
          icon: Icon(Icons.more_vert),
          color: Colors.white,
        ),
      );

  List<OverlayEntry> _buildOverlayEntry() {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    RenderBox renderBox = context.findRenderObject();
    var upperLeft = renderBox.localToGlobal(Offset.zero);
    return [
      OverlayEntry(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _toggle(),
        ),
      ),
      OverlayEntry(
        builder: (context) => Positioned(
            top: upperLeft.dy + renderBox.size.height + 4.0,
            right: 0,
            width: 275,
            child: SearchOptionsMenu(dictionaryPageModel)),
      ),
    ];
  }

  void _toggle() {
    _hasFocus = !_hasFocus;
    if (_hasFocus) {
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insertAll(_overlayEntry);
      return;
    }
    _overlayEntry.forEach((e) => e.remove());
  }
}
