import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:quota/state/books_model.dart';
import 'package:quota/state/quotes_model.dart';
import 'package:quota/state/supabase.dart';
import 'package:quota/widgets/book.dart';
import 'package:quota/widgets/new_book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../contants.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late TextEditingController _bookNameController;

  Future<void> _signOut() async {
    provider.Provider.of<BooksModel>(context, listen: false).clear();
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void initState() {
    super.initState();
    _bookNameController = TextEditingController();
    // provider.Provider.of<BooksModel>(context, listen: false).refresh(context);
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    super.dispose();
  }

  Widget _booksView(BuildContext context, BooksModel booksModel, QuotesModel quotesModel, Widget? child) {
    final loading = booksModel.loading;

    // If the books are still loading, return a loading spinner
    if (loading) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  "Loading",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ]));
    }

    List<Book> books = booksModel.books;
    String user_email = supabase.auth.currentUser!.email ?? "";
    // Sort first putting the books owned by the user first, then alphabetically
    books.sort((a, b) {
      if (a.ownerEmail == user_email && b.ownerEmail != user_email) {
        return -1;
      } else if (a.ownerEmail != user_email && b.ownerEmail == user_email) {
        return 1;
      } else {
        return a.name.compareTo(b.name);
      }
    });

    // Add all books owned by other users
    List<Widget> bookCards = books
        .map(
          (book) => BookWidget(book: book, quoteCount: quotesModel.quotesForBook(book.id).length),
        )
        .toList();

    return ListView(
      children: [
        ...bookCards,
        const SizedBox(
          height: 50,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select book"), actions: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ),
      ]),
      floatingActionButton: const NewBookWidget(),
      body: RefreshIndicator(
        onRefresh: () async {
          log("Wow! Refreshing!");
          await provider.Provider.of<QuotesModel>(context, listen: false).refreshAll(context);
          await provider.Provider.of<BooksModel>(context, listen: false).refresh(context);
          log("Wow! Refreshed!");
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: provider.Consumer2<BooksModel, QuotesModel>(
            builder: _booksView,
          ),
        ),
      ),
    );
  }
}
