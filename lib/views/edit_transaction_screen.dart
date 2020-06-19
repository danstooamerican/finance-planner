import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/main_screen.dart';
import 'package:financeplanner/views/widgets/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class EditTransactionScreen extends StatefulWidget {
  final Store<AppState> store;
  final Transaction transaction;

  EditTransactionScreen({Key key, this.store, this.transaction}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new EditTransactionState();
  }
}

class EditTransactionState extends State<EditTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Transaction"),
        ),
        body: TransactionForm.filled(
          transaction: widget.transaction,
          primaryAction: editTransactionAction,
          primaryActionText: "Edit",
          secondaryAction: deleteTransactionAction,
          secondaryActionText: "Delete",
        ),
      ),
    );
  }

  void editTransactionAction(Transaction transaction) {
    widget.store.dispatch(editTransaction(transaction));

    Navigator.pop(context, transaction);
  }

  void deleteTransactionAction(Transaction transaction) {
    widget.store.dispatch(deleteTransaction(transaction.id));

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(store: widget.store)),
        (Route<dynamic> route) => false);
  }
}
