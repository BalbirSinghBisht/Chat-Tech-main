import 'package:chatapp/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'SocialCountry_code.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<SocialCountryCode> elements;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;

  /// elements passed as favorite
  final List<SocialCountryCode> favoriteElements;

  SelectionDialog(this.elements, this.favoriteElements,
      {Key key,
      this.showCountryOnly,
      this.emptySearchBuilder,
      InputDecoration searchDecoration = const InputDecoration(),
      this.searchStyle,
      })
      : assert(searchDecoration != null, 'searchDecoration must not be null!'),
        this.searchDecoration =
            searchDecoration.copyWith(prefixIcon: Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  List<SocialCountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            text("Select Country Code",
                textColor: const Color(0xFF333333),
                fontSize: 20.0,
                fontFamily: 'Semibold'),
            TextField(
              style: widget.searchStyle,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFffffff),
                hintText: "Search",
              ),
              onChanged: _filterElements,
            )
          ],
        ),
        children: [
          Container(
              margin: EdgeInsets.only(top: 16),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                  children: [
                widget.favoriteElements.isEmpty
                    ? const DecoratedBox(decoration: BoxDecoration())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[]
                          ..addAll(widget.favoriteElements
                              .map(
                                (f) => SimpleDialogOption(
                                  child: _buildOption(f),
                                  onPressed: () {
                                    _selectItem(f);
                                  },
                                ),
                              )
                              .toList())
                          ..add(const Divider())),
              ]..addAll(filteredElements.isEmpty
                      ? [_buildEmptySearchWidget(context)]
                      : filteredElements.map((e) => SimpleDialogOption(
                            key: Key(e.toLongString()),
                            child: _buildOption(e),
                            onPressed: () {
                              _selectItem(e);
                            },
                          ))))),
        ],
      );

  Widget _buildOption(SocialCountryCode e) {
    return Container(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: text(e.toLongString(),
                        fontSize: 16.0,
                        textColor: Color(0xFF333333))),
                text(e.dialCode,
                    fontSize: 16.0,
                    textColor: Color(0xFF333333),
                    fontFamily: 'Semibold'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder(context);
    }

    return Center(child: Text('No Country Found'));
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              e.code.contains(s) ||
              e.dialCode.contains(s) ||
              e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(SocialCountryCode e) {
    Navigator.pop(context, e);
  }
}
