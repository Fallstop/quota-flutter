import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quota/state/books_model.dart';
import 'package:quota/state/quotes_model.dart';
import 'package:quota/widgets/quote.dart';
import 'package:quota/contants.dart';
import 'package:quota/widgets/book_args.dart';
import 'package:quota/state/supabase.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class QuoteView extends StatefulWidget {
  final List<Quote> quotes;
  final Book book;
  const QuoteView({super.key, required this.quotes, required this.book});

  @override
  State<QuoteView> createState() => _QuoteViewState();
}

class _QuoteViewState extends State<QuoteView> {

  bool _loading = false;
  bool _isOwner = false;
  late final TextEditingController _searchText;

  Future<void> _getQuotes([bool refresh = false]) async {
    try {
      if (!refresh) {
        setState(() {
          _isOwner = (supabase.auth.currentSession != null)
              ? supabase.auth.currentSession!.user.id == widget.book.owner
              : false;
          _loading = true;
        });
      }

      setState(() {
        _searchText.clear();
      });
    } catch (ex) {
      print(ex);
      if (mounted) {
        context.showErrorSnackBar(message: "Could not fetch quotes");
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getQuotes();
    _searchText = TextEditingController();
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  List<Quote> _filterQuotes() {
    final matches = extractAllSorted<Quote>(
        query: _searchText.text, choices: widget.quotes, getter: (e) => "${e.person} ${e.quote}", cutoff: 65);

    return matches.map((e) => e.choice).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Quote> filteredQuotes = _searchText.text.isEmpty ? widget.quotes : _filterQuotes();
    

    if (_loading) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), Text("Loading")],
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          await Provider.of<QuotesModel>(context, listen: false).refresh(context, widget.book.id);
          int foundQuotes = Provider.of<QuotesModel>(context, listen: false).quotesForBook(widget.book.id).length;
          context.showSnackBar(message: "Refreshed! Found $foundQuotes quotes.");
        },
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            itemBuilder: (BuildContext context, int i) => QuoteWidget(quote: filteredQuotes[i], isOwner: _isOwner),
            itemCount: filteredQuotes.length,
          ),
        ),
      );
    }
  }
}

class BookPage extends StatelessWidget {
  final String bookId;
  const BookPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BooksModel>(
      builder: (context, booksModel, child) {
        Book book = booksModel.bookById(bookId);

        return Scaffold(
          appBar: AppBar(
            title: Text(book.name),
            actions: () {
              List<Widget> children = [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // if (_search) {
                    //   setState(() {
                    //     _search = false;
                    //     _filteredQuotes = _quotes;
                    //     _searchText.clear();
                    //   });
                    // } else {
                    //   setState(() {
                    //     _search = true;
                    //   });
                    // }
                  },
                )
              ];

              if (book.isUserOwner()) {
                children.add(IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/settings", arguments: BookArgs(bookId));
                    },
                    icon: const Icon(Icons.settings)));
              }

              return children;
            }(),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.create),
            onPressed: () async {
              var result =
                  ((await Navigator.of(context).pushNamed("/new-quote", arguments: BookArgs(bookId))) ?? false) as bool;
              if (result) {}
            },
          ),
          body: Consumer<QuotesModel>(builder: (context, quotesModel, child) {
            List<Quote> quotes = quotesModel.quotesForBook(bookId);
            quotes.sort(
              (a, b) => b.date.compareTo(a.date),
            );
            return QuoteView(
              quotes: quotes,
              book: book,
            );
          }),
        );
      },
    );
  }
}


// _search
//               ? PreferredSize(
//                   preferredSize: const Size(double.infinity, 45),
//                   child: TextField(
//                     controller: _searchText,
//                     decoration: const InputDecoration(hintText: "Search", icon: Icon(Icons.search)),
//                     onChanged: (_) {
//                       if (_searchText.text != "") {
//                         _filterQuotes();
//                       } else {
//                         setState(() {
//                           _filteredQuotes = _quotes;
//                         });
//                       }
//                     },
//                   ))
//               : null,