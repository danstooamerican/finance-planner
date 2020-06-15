import 'dart:ffi';

import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class AddTransactionScreen extends StatefulWidget {
  final Store<AppState> store;

  AddTransactionScreen({Key key, this.store}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddTransactionState();
  }
}

class AddTransactionState extends State<AddTransactionScreen> {
  TextEditingController descriptionController = new TextEditingController();
  MoneyMaskedTextController amountController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  TextEditingController dateController = new TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController categoryController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add transaction"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Description",
                ),
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Amount",
                ),
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextField(
                onTap: () => _selectDate(context),
                keyboardType: TextInputType.datetime,
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Date",
                ),
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Category",
                ),
              ),
              padding: const EdgeInsets.all(8),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StoreConnector<AppState, VoidCallback>(
                  converter: (store) {
                    return () {
                      store.dispatch(AddTransactionAction(
                        amount: amountController.numberValue,
                        date: selectedDate,
                        description: descriptionController.text,
                        category: categoryController.text,
                      ));
                      Navigator.pop(context);
                    };
                  },
                  builder: (context, callback) {
                    return Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: new RaisedButton(
                              onPressed: callback,
                              child: Text("Add"),
                            )));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    DateFormat f = new DateFormat('dd.MM.yyyy');
    dateController.text = f.format(selectedDate);
  }
}
