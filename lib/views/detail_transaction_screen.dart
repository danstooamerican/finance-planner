import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:financeplanner/extensions/extensions.dart';

import 'edit_transaction_screen.dart';

class DetailTransactionScreen extends StatefulWidget {
  final Store<AppState> store;
  final Transaction transaction;

  DetailTransactionScreen({Key key, this.store, this.transaction})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new DetailTransactionState(transaction);
  }
}

class DetailTransactionState extends State<DetailTransactionScreen> {
  Transaction transaction;

  DetailTransactionState(this.transaction);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Details"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.category),
                  ),
                  Text(
                    transaction.category,
                    style: TextStyle(fontSize: 18),
                  ),
                  Spacer(),
                  Text(
                    transaction.date.toDateFormat(),
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xff3b3f42)),
                      child: AutoSizeText(
                        transaction.amount.toMoneyFormatWithSign(),
                        style:
                            TextStyle(color: transaction.amount.toMoneyColor()),
                        textAlign: TextAlign.center,
                        minFontSize: 30,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Description:",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    transaction.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: (FloatingActionButton(
          onPressed: () async {
            final Transaction editedTransaction = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTransactionScreen(
                  store: widget.store,
                  transaction: transaction,
                ),
              ),
            );
            setState(() {
              transaction = editedTransaction;
            });
          },
          tooltip: 'Edit Transaction',
          child: Icon(Icons.edit),
        )),
      ),
    );
  }
}
