import 'dart:convert';

import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:redux/redux.dart';
import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:http/http.dart' as http;

class TransactionForm extends StatefulWidget {
  final Transaction transaction;
  final Store<AppState> store;

  final String primaryActionText;
  final String secondaryActionText;

  final Function(Transaction) primaryAction;

  //// No form checks are performed before this action is called.
  final Function(Transaction) secondaryAction;

  factory TransactionForm.empty(
      {Key key,
      Store store,
      Function(Transaction) onSuccess,
      String submitText = "Save"}) {
    Transaction transaction = new Transaction(
      id: 0, // keep 0 as default id so the backend can recognize it as new
      category: null,
      description: null,
      amount: null,
      dateTime: DateTime.now(),
    );

    return TransactionForm.filled(
      key: key,
      store: store,
      transaction: transaction,
      primaryAction: onSuccess,
      primaryActionText: submitText,
    );
  }

  TransactionForm.filled({
    Key key,
    @required this.store,
    @required this.transaction,
    @required this.primaryAction,
    this.secondaryAction,
    this.primaryActionText = "Save",
    this.secondaryActionText = "Delete",
  }) : super(key: key) {
    store.dispatch(getCategories());
  }

  @override
  State<StatefulWidget> createState() {
    return new TransactionFormState(transaction);
  }
}

class TransactionFormState extends State<TransactionForm> {
  DateTime selectedDate = DateTime.now();

  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  Category _selectedCategory;
  List<Category> _categories = List();

  IconData _selectedIcon = Icons.category;

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();
  final Transaction transaction;

  final _formKey = GlobalKey<FormState>();

  final _prefixMoneyRegex =
      new RegExp(r'^-?(([1-9][0-9]*|0)(\,|\.)?)?([0-9]{1,2})?$');
  String previousAmountText;
  TextSelection previousAmountSelection;

  TransactionFormState(this.transaction) {
    _amountController.addListener(() {
      final String currentValue = _amountController.text;

      if (currentValue.length > 0 &&
          _prefixMoneyRegex.matchAsPrefix(currentValue) == null) {
        _amountController.value = TextEditingValue(
            text: previousAmountText, selection: previousAmountSelection);
      } else {
        previousAmountText = currentValue;
        previousAmountSelection = _amountController.selection;
      }
    });

    previousAmountText = _amountController.text;
    previousAmountSelection = _amountController.selection;

    _setDate(transaction.date);
    _amountController.text = transaction.amount?.formatMoneyToEdit();
    _descriptionController.text = transaction.description;

    getCategories().then((value) => setState(() {
          if (transaction.category != null) {
            _selectedCategory = transaction.category;
          } else {
            _selectedCategory = _categories.first;
          }
        }));
  }

  Future<void> getCategories() async {
    await http.get(
      'http://zwerschke.net:2000/categories',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((value) {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));
      _categories = list.map((model) => Category.fromJson(model)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
                  if (text == null || text.trim().isEmpty) {
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
                maxLength: 9,
                focusNode: _amountFocus,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _amountFocus, _descriptionFocus);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount',
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
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
                maxLength: 255,
                minLines: 1,
                maxLines: 5,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _descriptionFocus, _categoryFocus);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: Row(
                children: [
                  Transform.translate(
                    offset: Offset(0, -10),
                    child: IconButton(
                      icon: Icon(_selectedIcon),
                      padding: const EdgeInsets.only(right: 8),
                      iconSize: 48,
                      color: Colors.white,
                      onPressed: _pickIcon,
                    ),
                  ),
                  Expanded(
                      child: DropdownButton<Category>(
                    value: _selectedCategory,
                    onChanged: (Category newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<Category>>((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                  )),
                ],
              ),
              padding: const EdgeInsets.all(8),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: new RaisedButton(
                      onPressed: submitPrimaryAction,
                      child: Text(widget.primaryActionText),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.secondaryAction != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: new RaisedButton(
                        color: Colors.red,
                        onPressed: submitSecondaryAction,
                        child: Text(widget.secondaryActionText),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void submitPrimaryAction() {
    if (_formKey.currentState.validate()) {
      final Transaction transaction = Transaction(
        id: widget.transaction.id,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        amount: _amountController.text.parseMoney(),
        dateTime: selectedDate,
      );

      widget.primaryAction(transaction);
    }
  }

  void submitSecondaryAction() {
    widget.secondaryAction(transaction);
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2200));

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

  void _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.material);

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
