import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:quota/contants.dart';
import 'package:quota/state/quotes_model.dart';
import 'package:quota/state/supabase.dart';

class BooksModel extends ChangeNotifier {
  List<Book> _books = [];
  List<Book> get books {
    return _books;
  }

  bool _loading = false;
  bool get loading {
    return _loading;
  }

  BooksModel (BuildContext context) {
    refresh(context);
  }

  Book bookById(String id) {
    return _books.firstWhere((element) => element.id == id);
  }

  Future<void> refresh(BuildContext context, {bool alsoRefreshQuotes = false}) async {

    if (supabase.auth.currentSession == null) {
      return;
    }

    _loading = true;

    try {
      if (alsoRefreshQuotes) {
        await provider.Provider.of<QuotesModel>(context, listen: false).refreshAll(context);
      }
      
      var books = (await supabase.from("books").select<List<Map<String, dynamic>>>()).map(Book.fromSupabase).toList();


      _books = books;
    } catch (ex) {
      log("Could not fetch books", error: ex);
      context.showSnackBar(message: "Cloud not fetch books");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _books = [];
  }
}
