import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/add_transaction_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'detail_transaction_screen.dart';

class MainScreen extends StatelessWidget {
  final Store<AppState> store;

  MainScreen({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StoreProvider<AppState>(
        store: store,
        child: Scaffold(
          body: StoreConnector<AppState, List<Transaction>>(
            converter: (Store<AppState> store) {
              List<Transaction> sorted = store.state.transactions;
              sorted.sort((t1, t2) {
                int dateCompare = t2.dateTime.compareTo(t1.dateTime);

                if (dateCompare == 0) {
                  return t2.id.compareTo(t1.id);
                }

                return dateCompare;
              });

              return sorted;
            },
            builder: (BuildContext context, List<Transaction> transactions) {
              double balance = _getBalance(transactions);

              return RefreshIndicator(
                child: CustomScrollView(
                  semanticChildCount: transactions.length,
                  slivers: <Widget>[
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 220.0,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Transform.translate(
                          offset: const Offset(-40, 0),
                          child: Text('Overview'),
                        ),
                        background: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "Balance",
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.left,
                                minFontSize: 30,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AutoSizeText(
                                balance.toMoneyFormatWithSign(),
                                style: TextStyle(color: balance.toMoneyColor()),
                                textAlign: TextAlign.left,
                                minFontSize: 50,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return _buildTransactionListItem(transactions, index);
                        },
                        childCount: transactions.length,
                      ),
                    ),
                  ],
                ),
                onRefresh: updateTransactionList,
              );
            },
          ),
          floatingActionButton: (FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(store: store)),
              );
            },
            tooltip: 'Add Transaction',
            child: Icon(Icons.add),
          )),
        ),
      ),
    );
  }

  Widget _buildTransactionListItem(List<Transaction> transactions, int index) {
    int current = index;
    int previous = index - 1;

    Transaction transaction = transactions[current];
    if (_isOnDifferentDayToPredecessor(transactions, current, previous)) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              child: Text(
                _getDate(transaction.date),
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
            ),
            const Divider(
              color: Colors.grey,
              height: 12,
              thickness: 1,
              endIndent: 8,
            ),
            Padding(
              child: TransactionItem(transaction, store),
              padding: const EdgeInsets.only(top: 8),
            )
          ],
        ),
      );
    } else {
      return new TransactionItem(transaction, store);
    }
  }

  Future<Null> updateTransactionList() async {
    store.dispatch(fetchTransactions());

    return null;
  }

  bool _isOnDifferentDayToPredecessor(
      List<Transaction> transactions, int currentIndex, int previousIndex) {
    if (currentIndex == 0) {
      return true;
    }

    if (currentIndex < 0 ||
        currentIndex >= transactions.length ||
        previousIndex < 0 ||
        previousIndex >= transactions.length) {
      return false;
    }

    Transaction current = transactions[currentIndex];
    Transaction previous = transactions[previousIndex];

    return current.date.isOnDifferentDay(previous.date);
  }

  String _getDate(DateTime date) {
    DateTime now = DateTime.now();
    if (date.isAtSameMomentAs(new DateTime(now.year, now.month, now.day))) {
      return "Today";
    }

    return date.toDateFormat();
  }

  double _getBalance(List<Transaction> transaction) {
    return transaction.fold(0,
        (previousValue, Transaction element) => previousValue + element.amount);
  }
}

class TransactionItem extends StatelessWidget {
  final Store<AppState> store;
  final Transaction transaction;

  TransactionItem(this.transaction, this.store);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.card_giftcard,
        color: Colors.white,
        size: 30.0,
      ),
      title: AutoSizeText(
        transaction.description,
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.left,
        minFontSize: 14,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AutoSizeText(
        transaction.amount.toMoneyFormatWithSign(),
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.amount.toMoneyColor()),
        textAlign: TextAlign.right,
        minFontSize: 8,
        maxLines: 1,
      ),
      onTap: () {
        print(transaction);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTransactionScreen(
              store: store,
              transaction: transaction,
            ),
          ),
        );
      },
    );
  }
}
