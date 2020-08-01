import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_localizations.dart';
import '../dependency_injection_config.dart';

class AddTransactionScreen extends StatefulWidget {
  AddTransactionScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddTransactionState();
  }
}

class AddTransactionState extends State<AddTransactionScreen> {
  final TransactionService _transactionService = locator<TransactionService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('add-transaction'),
        ),
      ),
      body: Padding(
        child: TransactionForm(
          primaryAction: submitAction,
          primaryActionText: AppLocalizations.of(context).translate('save'),
        ),
        padding: const EdgeInsets.only(top: 16),
      ),
    );
  }

  void submitAction(Transaction transaction) {
    _transactionService.createTransaction(transaction);

    Navigator.pop(context);
  }
}
