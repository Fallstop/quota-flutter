
import 'package:flutter/material.dart';
import 'package:quota/supabase.dart';

class QuoteRemoveWidget extends StatelessWidget {
  const QuoteRemoveWidget({
    super.key,
    required this.quote,
  });

  final Quote quote;

  Future<void> Function() _showConfirmDeleteDialogue(Quote quote, BuildContext context) {
    return () async {
      await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm delete'),
              content: Text('Are you sure you wanna delete the quote\n"${quote.quote}"\nby ${quote.person}'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('NOPE!'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Go ahead!'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          }).then((res) async {
        if (res ?? false) {
          await quote.delete(context);
          // await _getQuotes();
        }
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.more_vert,
      size: 16.0,
    );
  }
}
