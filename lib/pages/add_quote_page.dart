import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quota/contants.dart';
import 'package:quota/state/quotes_model.dart';

import '../state/supabase.dart';

class AddQuotePage extends StatefulWidget {
  final String bookId;
  const AddQuotePage({super.key, required this.bookId});

  @override
  State<AddQuotePage> createState() => _AddQuotePageState();
}

final RegExp dateTimeRegex = RegExp(r'^(\d{1,2})\/(\d{1,2})\/((\d{2}){1,2})$');

class _AddQuotePageState extends State<AddQuotePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime date = DateTime.now();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quoteController = TextEditingController();

  bool formValid = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Add Quote")),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
              key: _formKey,
              onChanged: () {
                setState(() {
                  formValid = _formKey.currentState!.validate();
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _quoteController,
                    decoration: const InputDecoration(labelText: "Quote"),
                    validator: (value) =>
                        (value == null || value.trim() == "") ? "Quote must not be an empty string" : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Person"),
                    validator: (value) =>
                        (value == null || value.trim() == "") ? "Name must not be an empty string" : null,
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FormField(
                        builder: (context) => OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            date = await showDatePicker(
                                context: context.context,
                                initialDate: this.date,
                                firstDate: DateTime(2010),
                                lastDate: DateTime.now()) ?? date;
                          },
                          label: Text("${date.day}/${date.month}/${date.year}"),
                        ),
                      ),
                      FilledButton.icon(
                        label: const Text("Submit"),
                        onPressed: !formValid
                            ? null
                            : () {
                                print("adding quote");
                                NewQuote(
                                        book: widget.bookId,
                                        date: date,
                                        person: _nameController.text,
                                        quote: _quoteController.text)
                                    .add()
                                    .then((_) {
                                  print("Success");
                                  Provider.of<QuotesModel>(context, listen: false).refresh(context, widget.bookId);

                                  Navigator.of(context).pop(true);
                                }).catchError((ex) {
                                  print("Quote add failed");
                                  print(ex);
                                  context.showErrorSnackBar(message: "Could not add quote");
                                  Navigator.of(context).pop(false);
                                });
                              },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              )),
        ));
  }
}
