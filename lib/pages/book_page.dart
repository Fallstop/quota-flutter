import 'package:flutter/material.dart';
import 'package:quota/widgets/quote.dart';
import 'package:quota/contants.dart';
import 'package:quota/widgets/book_args.dart';
import 'package:quota/supabase.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class BookPage extends StatefulWidget {
  final Book book;
  const BookPage({super.key, required this.book});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<Quote> _quotes = [];
  List<Quote> _filteredQuotes = [];

  bool _loading = false;
  bool _isOwner = false;
  bool _search = false;
  late final TextEditingController _searchText;
  // late Book book;

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

      var quotes = refresh ? await widget.book.fetchQuotes() : await widget.book.quotes();
      quotes.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      setState(() {
        _quotes = quotes;
        _filteredQuotes = quotes;
        _search = false;
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

  Future<void> _filterQuotes() async {
    final matches = extractAllSorted<Quote>(
        query: _searchText.text, choices: _quotes, getter: (e) => "${e.person} ${e.quote}", cutoff: 65);

    setState(() {
      _filteredQuotes = matches.map((e) => e.choice).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.book.name),
          bottom: _search
              ? PreferredSize(
                  preferredSize: const Size(double.infinity, 45),
                  child: TextField(
                    controller: _searchText,
                    decoration: const InputDecoration(hintText: "Search", icon: Icon(Icons.search)),
                    onChanged: (_) {
                      if (_searchText.text != "") {
                        _filterQuotes();
                      } else {
                        setState(() {
                          _filteredQuotes = _quotes;
                        });
                      }
                    },
                  ))
              : null,
          actions: () {
            List<Widget> children = [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (_search) {
                    setState(() {
                      _search = false;
                      _filteredQuotes = _quotes;
                      _searchText.clear();
                    });
                  } else {
                    setState(() {
                      _search = true;
                    });
                  }
                },
              )
            ];

            if (_isOwner) {
              children.add(IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed("/settings", arguments: BookArgs(widget.book));
                  },
                  icon: const Icon(Icons.settings)));
            }

            return children;
          }(),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.create),
          onPressed: () async {
            var result = ((await Navigator.of(context).pushNamed("/new-quote", arguments: BookArgs(widget.book))) ??
                false) as bool;
            if (result) {
              await _getQuotes();
            }
          },
        ),
        body: _loading
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), Text("Loading")],
                ))
            : RefreshIndicator(
                onRefresh: () => _getQuotes(true),
                child: Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    itemBuilder: (BuildContext context, int i) =>
                        QuoteWidget(quote: _filteredQuotes[i], isOwner: _isOwner),
                    itemCount: _filteredQuotes.length,
                  ),
                ),
              ),
      );
}
