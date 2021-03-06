import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_localizations.dart';
import 'edit_transaction_screen.dart';

class DetailTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  DetailTransactionScreen({Key key, this.transaction}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('details')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(transaction.category.icon),
                ),
                Expanded(
                    child: Padding(
                  child: AutoSizeText(
                    transaction.category.name,
                    minFontSize: 14,
                    maxLines: 2,
                    wrapWords: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  padding: const EdgeInsets.only(right: 64),
                )),
                Text(
                  transaction.date.toDateFormat(),
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.right,
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
                      style: TextStyle(color: transaction.amount.toMoneyColor()),
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
                  AppLocalizations.of(context).translate('description'),
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
                Flexible(
                  child: Text(
                    transaction.description,
                    style: TextStyle(fontSize: 16),
                  ),
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
                transaction: transaction,
              ),
            ),
          );

          if (editedTransaction != null) {
            setState(() {
              transaction = editedTransaction;
            });
          }
        },
        tooltip: AppLocalizations.of(context).translate('edit-transaction'),
        child: Icon(Icons.edit),
      )),
    );
  }
}
