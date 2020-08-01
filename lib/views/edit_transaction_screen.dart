import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_localizations.dart';
import 'main_view/main_screen.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  EditTransactionScreen({Key key, this.transaction}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new EditTransactionState();
  }
}

class EditTransactionState extends State<EditTransactionScreen> {
  final TransactionService _transactionService = locator<TransactionService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('edit-transaction')),
      ),
      body: Padding(
        child: TransactionForm(
          transaction: widget.transaction,
          primaryAction: editTransactionAction,
          primaryActionText: AppLocalizations.of(context).translate('edit'),
          secondaryAction: deleteTransactionAction,
          secondaryActionText: AppLocalizations.of(context).translate('delete'),
        ),
        padding: const EdgeInsets.only(top: 16),
      ),
    );
  }

  void editTransactionAction(Transaction transaction) {
    _transactionService.editTransaction(transaction);

    Navigator.pop(context, transaction);
  }

  void deleteTransactionAction(Transaction transaction) {
    _transactionService.deleteTransaction(transaction.id);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
