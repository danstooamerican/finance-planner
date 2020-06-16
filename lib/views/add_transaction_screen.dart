import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

class AddTransactionScreen extends StatefulWidget {
  final Store<AppState> store;

  AddTransactionScreen({Key key, this.store}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddTransactionState();
  }
}

class AddTransactionState extends State<AddTransactionScreen> {
  DateTime selectedDate = DateTime.now();

  final String moneyRegex = r'\-?([0-9]{1,3}\.([0-9]{3}\.)*[0-9]{3}|[0-9]+)(\,[0-9][0-9])?';

  TextEditingController descriptionController = new TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController categoryController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  AddTransactionState() {
    _setDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Transaction"),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Amount is required';
                    }

                    RegExp regex = RegExp(moneyRegex);
                    Match match = regex.firstMatch(text);
                    if (match.end != text.length) {
                      return "Invalid amount";
                    }

                    return null;
                  },
                ),
                padding: const EdgeInsets.all(8),
              ),
              Padding(
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                padding: const EdgeInsets.all(8),
              ),
              Padding(
                child: TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Category',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                padding: const EdgeInsets.all(8),
              ),
              Padding(
                child: TextFormField(
                  controller: dateController,
                  onTap: () => _selectDate(context),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Date',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Date is required';
                    }
                    return null;
                  },
                ),
                padding: const EdgeInsets.all(8),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StoreConnector<AppState, VoidCallback>(
                    converter: (store) {
                      return () {
                        if (_formKey.currentState.validate()) {
                          NumberFormat f = NumberFormat.currency(locale: "de_DE");

                          store.dispatch(AddTransactionAction(
                            amount: f.parse(amountController.text),
                            date: selectedDate,
                            description: descriptionController.text,
                            category: categoryController.text,
                          ));

                          Navigator.pop(context);
                        }
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
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2200));

    if (picked != null && picked != selectedDate) {
      setState(() {
        _setDate(picked);
      });
    }
  }

  void _setDate(DateTime date) {
    selectedDate = date;

    DateFormat f = new DateFormat('dd.MM.yyyy');
    dateController.text = f.format(date);
  }
}
