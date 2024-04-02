import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quota/books_model.dart';
import 'package:quota/contants.dart';
import 'package:quota/supabase.dart';
import 'package:quota/widgets/book_args.dart';

class NewBookWidget extends StatefulWidget {
  const NewBookWidget({
    super.key,
  });

  @override
  State<NewBookWidget> createState() => _NewBookState();
}

class _NewBookState extends State<NewBookWidget> {
  final _bookNameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _bookNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog<bool>(context: context, builder: (context) => NewBookDialog(bookNameController: _bookNameController))
            .then(
          (result) {
            log(result.toString());
            if (result ?? false) {
              // The Dialog was closed with OK.
              if (_bookNameController.text.trim() == "") {
                context.showErrorSnackBar(message: "Book name not be empty");
                return;
              }

              final newBook = NewBook(name: _bookNameController.text);
              // booksModel.refresh(context);
              _bookNameController.clear();

              newBook.create().then((book) {
                Navigator.pushNamed(context, "/book", arguments: BookArgs(book));
              }).catchError((ex) {
                log("Cound not create book", error: ex);
                context.showErrorSnackBar(message: "Could not create book");
              });
            } else {
              // The Dialog was closed with Cancel.
              _bookNameController.clear();
            }
          },
        );
      },
      label: const Text("Create Book"),
    );
  }
}

class NewBookDialog extends StatefulWidget {
  const NewBookDialog({
    super.key,
    required this.bookNameController,
  });

  final TextEditingController bookNameController;

  @override
  State<NewBookDialog> createState() => _NewBookDialogState();
}

class _NewBookDialogState extends State<NewBookDialog> {

  bool isBookNameEmpty = true;

  void _textUpdate() {
    log("Updating Text! ${widget.bookNameController.text.trim().isEmpty}");
    setState(() {
      isBookNameEmpty = widget.bookNameController.text.trim().isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    widget.bookNameController.addListener(_textUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Book ${isBookNameEmpty}"),
      content: TextField(
        decoration: const InputDecoration(label: Text("Book name")),
        controller: widget.bookNameController,
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
        TextButton(
          onPressed: isBookNameEmpty
              ? null
              : () {
                  if (widget.bookNameController.text.trim().isEmpty) {
                    context.showErrorSnackBar(message: "Book name should not be empty");
                    return;
                  }
                  Navigator.pop(context, true);
                },
          child: const Text("Ok"),
        ),
      ],
    );
  }
}
