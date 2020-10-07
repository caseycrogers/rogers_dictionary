import 'package:flutter/material.dart';

class ArticleList extends StatefulWidget {
  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final _articles = <String>[];
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary'),
      ),
      body: _buildArticles(),
    );
  }

  Widget _buildArticles() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i ) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index > 200) return null;
        if (index >= _articles.length) {
          var article = "";
          if ((index + 1) % 3 == 0) article += "fizz ";
          if ((index + 1) % 5 == 0) article += "buzz";
          if (((index + 1) % 3) * ((index + 1) % 5) != 0) article += (index + 1).toString();
          _articles.add(article);
        }
        return _buildRow(_articles[index]);
      },
    );
  }

  Widget _buildRow(String article) {
    return ListTile(
      title: Text(
        article,
        style: _biggerFont,
      ),
    );
  }
}