import 'dart:convert';

import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../app_localizations.dart';

class TransactionForm extends StatefulWidget {
  final Transaction transaction;

  final String primaryActionText;
  final String secondaryActionText;

  final Function(Transaction) primaryAction;

  //// No form checks are performed before this action is called.
  final Function(Transaction) secondaryAction;

  factory TransactionForm.empty(
      {Key key,
      @required Function(Transaction) primaryAction,
      Function(Transaction) secondaryAction,
      @required String primaryText,
      String secondaryText}) {
    Transaction transaction = new Transaction(
      id: 0, // keep 0 as default id so the backend can recognize it as new
      category: null,
      description: null,
      amount: null,
      dateTime: DateTime.now(),
    );

    return TransactionForm.filled(
      key: key,
      transaction: transaction,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      primaryActionText: primaryText,
      secondaryActionText: secondaryText,
    );
  }

  TransactionForm.filled({
    Key key,
    @required this.transaction,
    @required this.primaryAction,
    this.secondaryAction,
    @required this.primaryActionText,
    @required this.secondaryActionText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TransactionFormState(transaction);
  }
}

class TransactionFormState extends State<TransactionForm> {
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _categoryController = new TextEditingController();

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final _prefixMoneyRegex = new RegExp(r'^-?(([1-9][0-9]*|0)(\,|\.)?)?([0-9]{1,2})?$');
  String previousAmountText;
  TextSelection previousAmountSelection;

  TransactionFormState(this.transaction) {
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
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_selectedIcon),
                    padding: const EdgeInsets.only(right: 8),
                    iconSize: 48,
                    color: Colors.white,
                    onPressed: _pickIcon,
                  ),
                  Expanded(
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalizations.of(context).translate('category'),
                        ),
                      ),
                      itemBuilder: (context, suggestion) => ListTile(
                        title: Text(suggestion.name),
                        leading: Icon(suggestion.icon),
                      ),
                      suggestionsCallback: (pattern) {
                        List<Category> suggestions = List.from(_categories);
                        suggestions
                            .retainWhere((element) => element.name.toLowerCase().startsWith(pattern.toLowerCase()));

                        return suggestions;
                      },
                      onSuggestionSelected: (suggestion) {
                        setState(() {
                          _selectCategory(suggestion);
                        });
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      getImmediateSuggestions: true,
                      loadingBuilder: (context) => null,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return AppLocalizations.of(context).translate('category-required');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextFormField(
                controller: _dateController,
                focusNode: _dateFocus,
                onTap: () => _selectDate(context),
                keyboardType: TextInputType.number,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate('date'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('date-required');
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
                  labelText: AppLocalizations.of(context).translate('amount'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('amount-required');
                  }

                  if (!text.isMoney()) {
                    return AppLocalizations.of(context).translate('amount-invalid');
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
                  labelText: AppLocalizations.of(context).translate('description'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('description-required');
                  }
                  return null;
                },
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
                        onPressed: model.submitSecondaryAction,
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
      model.submitPrimaryAction();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: model.selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2200));

    model.selectedDate = picked;
    _dateController.text = date.toDateFormat();

    _fieldFocusChange(context, _dateFocus, _amountFocus);
  }

  void _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconPackMode: IconPack.material);

    model.selectedIcon = icon;
    _categoryController.text = model.categoryName;
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
