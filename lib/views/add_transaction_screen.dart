import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
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

  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _categoryController = new TextEditingController();

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  final _prefixMoneyRegex = new RegExp(r'^-?([1-9][0-9]*(\,|\.)?)?([0-9]{1,2})?$');
  String previousAmountText;
  TextSelection previousAmountSelection;

  AddTransactionState() {
    _amountController.addListener(() {
      final String currentValue = _amountController.text;

      if (currentValue.length > 0 && _prefixMoneyRegex.matchAsPrefix(currentValue) == null) {
        _amountController.value = TextEditingValue(text: previousAmountText, selection: previousAmountSelection);
      } else {
        previousAmountText = currentValue;
        previousAmountSelection = _amountController.selection;
      }
    });

    previousAmountText = _amountController.text;
    previousAmountSelection = _amountController.selection;

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
                  controller: _dateController,
                  focusNode: _dateFocus,
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
              Padding(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  focusNode: _amountFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _amountFocus, _descriptionFocus);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Amount is required';
                    }

                    if (!text.isMoney()) {
                      return "Invalid amount";
                    }

                    return null;
                  },
                ),
                padding: const EdgeInsets.all(8),
              ),
              Padding(
                child: TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.next,
                  focusNode: _descriptionFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _descriptionFocus, _categoryFocus);
                  },
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
                  controller: _categoryController,
                  textInputAction: TextInputAction.done,
                  focusNode: _categoryFocus,
                  onFieldSubmitted: (term) {
                    submitAction();
                  },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StoreConnector<AppState, VoidCallback>(
                    converter: (store) {
                      return () {
                        submitAction();
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

  void submitAction() {
    if (_formKey.currentState.validate()) {
      widget.store.dispatch(createTransaction(
        amount: _amountController.text.parseMoney(),
        date: selectedDate,
        description: _descriptionController.text,
        category: _categoryController.text,
      ));

      Navigator.pop(context);
    }
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2200));

    if (picked != null && picked != selectedDate) {
      setState(() {
        _setDate(picked);
      });
    }

    _fieldFocusChange(context, _dateFocus, _amountFocus);
  }

  void _setDate(DateTime date) {
    selectedDate = date;
    _dateController.text = date.toDateFormat();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
