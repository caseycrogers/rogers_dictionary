import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/search_options_view.dart';

class SearchOptionsButton extends StatefulWidget {
  @override
  _SearchOptionsButtonState createState() => _SearchOptionsButtonState();
}

class _SearchOptionsButtonState extends State<SearchOptionsButton> {
  OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isMounted ? Colors.white10 : Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(Icons.more_vert),
        color: Colors.white,
        onPressed: () => _toggle(),
      ),
    );
  }

  OverlayEntry _buildOverlayEntry() {
    var searchPageModel = SearchPageModel.readFrom(context);
    RenderBox renderBox = context.findRenderObject();
    var upperLeft = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (_) => Positioned(
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
              child: SearchOptionsView(context),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      if (_isMounted) {
        _overlayEntry.remove();
        _overlayEntry = null;
        return;
      }
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
    });
  }

  bool get _isMounted => _overlayEntry != null;
}
