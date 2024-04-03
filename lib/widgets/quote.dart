import 'package:flutter/material.dart';
import 'package:quota/widgets/quote-remove.dart';
import 'package:quota/state/supabase.dart';

class QuoteWidget extends StatelessWidget {
  const QuoteWidget({
    super.key,
    required this.quote,
    required this.isOwner,
  });

  final Quote quote;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    quote.quote,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: quote.person, style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " - ${quote.date.day}/${quote.date.month}/${quote.date.year}")
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isOwner) QuoteRemoveWidget(quote: quote),
          ],
        ),
      ),
    );
  }
}
