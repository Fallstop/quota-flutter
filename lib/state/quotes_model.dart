import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quota/contants.dart';
import 'package:quota/state/supabase.dart';


class QuotesModel extends ChangeNotifier {
  final Map<String, List<Quote>> _quotesPerBook = {};

  bool loading = false;

  QuotesModel (BuildContext context) {
    refreshAll(context);
  }


  List<Quote> quotesForBook(String bookId) {
    return _quotesPerBook[bookId] ?? [];
  }

  bool hasQuotesForBook(String bookId) {
    return _quotesPerBook.containsKey(bookId);
  }

  Future<void> refresh(BuildContext context, String bookId) async {
    loading = true;
    notifyListeners();
    if (supabase.auth.currentSession == null) {
      return;
    }

    try {
      var quotes = (await supabase.from("quotes").select<List<Map<String, dynamic>>>().eq("book", bookId).order("date", ascending: true)).map(Quote.fromJson).toList();
      _quotesPerBook[bookId] = quotes;
    } catch (ex) {
      log("Could not fetch quotes", error: ex);
      context.showSnackBar(message: "Failed to fetch quotes");
    } finally {
      loading = false;
      notifyListeners();
    }

  }

  Future<void> refreshAll(BuildContext context) async {
    loading = true;
    notifyListeners();
    if (supabase.auth.currentSession == null) {
      return;
    }

    try {
      var quotes = (await supabase.from("quotes").select<List<Map<String, dynamic>>>()).map(Quote.fromJson).toList();
      _quotesPerBook.clear();
      for (var quote in quotes) {
        if (!_quotesPerBook.containsKey(quote.book)) {
          _quotesPerBook[quote.book] = [];
        }
        _quotesPerBook[quote.book]!.add(quote);
      }
    } catch (ex) {
      log("Could not fetch quotes", error: ex);
      context.showSnackBar(message: "Cloud not fetch quotes");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}