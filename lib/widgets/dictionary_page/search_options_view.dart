import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/search_options_menu.dart';

class SearchOptionsView extends StatefulWidget {
  final void Function(SearchSettingsModel) onSearchChanged;

  SearchOptionsView({@required this.onSearchChanged});

  @override
  _SearchOptionsViewState createState() => _SearchOptionsViewState();
}

class _SearchOptionsViewState extends State<SearchOptionsView> {
  OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Container();
    //return Selector<SearchPageModel, bool>(
    //  selector: (context, searchPageModel) =>
    //      searchPageModel.entrySearchModel.expandSearchOptions,
    //  builder: (context, hasFocus, _) => Container(
    //    margin: EdgeInsets.symmetric(horizontal: 4.0),
    //    decoration: BoxDecoration(
    //      shape: BoxShape.circle,
    //      color: hasFocus ? Colors.black26 : Colors.transparent,
    //    ),
    //    child: IconButton(
    //      icon: Icon(Icons.more_vert),
    //      color: Colors.white,
    //      onPressed: () => _toggle(),
    //    ),
    //  ),
    //);
  }

  OverlayEntry _buildOverlayEntry() {
    var bilingualModel = BilingualSearchPageModel.of(context);
    RenderBox renderBox = context.findRenderObject();
    var upperLeft = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) => Positioned(
        child: Stack(
          children: [
            Container(
              color: Colors.black38,
              child: GestureDetector(
                onTap: _toggle,
              ),
            ),
            Positioned(
              top: upperLeft.dy + renderBox.size.height + 4.0,
              right: 0,
              width: 275,
              child: SearchOptionsMenu(bilingualModel.currSettingsModel),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle() {}
}
