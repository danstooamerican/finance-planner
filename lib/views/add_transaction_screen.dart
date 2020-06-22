import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/widgets/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  final Store<AppState> store;

  AddTransactionScreen({Key key, this.store}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddTransactionState();
  }
}

class AddTransactionState extends State<AddTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: Scaffold(
          appBar: AppBar(
            title:
                Text(AppLocalizations.of(context).translate('add-transaction')),
          ),
          body: Padding(
              child: TransactionForm.empty(
                primaryAction: submitAction,
                primaryText: AppLocalizations.of(context).translate('save'),
                store: widget.store,
              ),
              padding: const EdgeInsets.only(top: 16))),
    );
  }

  void submitAction(Transaction transaction) {
    widget.store.dispatch(createTransaction(transaction: transaction));

    Navigator.pop(context);
  }
}
