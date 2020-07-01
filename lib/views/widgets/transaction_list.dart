import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/views/widgets/logout_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../app_localizations.dart';
import '../detail_transaction_screen.dart';

class TransactionList extends StatelessWidget {
  final Store<AppState> store;
  final List<Transaction> transactions;
  final VoidCallback onRefresh;
  final ScrollController scrollController;

  TransactionList({
    @required this.store,
    @required this.transactions,
    this.onRefresh,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    double balance = _getBalance(transactions);

    return RefreshIndicator(
      child: CustomScrollView(
        controller: scrollController,
        semanticChildCount: transactions.length,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
                title: Transform.translate(
                  offset: const Offset(-40, 0),
                  child: Text(AppLocalizations.of(context).translate('overview')),
                ),
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            AppLocalizations.of(context).translate('balance'),
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
                    Positioned(
                      child: LogoutButton(store),
                      right: 8,
                      top: 8,
                    ),
                  ],
                )),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _TransactionListItem(index, transactions, store);
              },
              childCount: transactions.length,
            ),
          ),
        ],
      ),
      onRefresh: onRefresh,
    );
  }

  double _getBalance(List<Transaction> transaction) {
    return transaction.fold(0, (previousValue, Transaction element) => previousValue + element.amount);
  }
}

class _TransactionListItem extends StatelessWidget {
  final int index;
  final List<Transaction> transactions;
  final Store<AppState> store;

  _TransactionListItem(this.index, this.transactions, this.store);

  @override
  Widget build(BuildContext context) {
    int current = index;
    int previous = index - 1;

    Transaction transaction = transactions[current];
    if (_isOnDifferentDayToPredecessor(transactions, current, previous)) {
      return _DividerTransactionItem(transaction, store);
    } else {
      return new _TransactionItem(transaction, store);
    }
  }

  bool _isOnDifferentDayToPredecessor(List<Transaction> transactions, int currentIndex, int previousIndex) {
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
}

class _DividerTransactionItem extends StatelessWidget {
  final Store<AppState> store;
  final Transaction transaction;

  _DividerTransactionItem(this.transaction, this.store);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            child: Text(
              _getDate(context, transaction.date),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
          ),
          const Divider(
            color: Colors.grey,
            height: 12,
            thickness: 1,
            indent: 4,
            endIndent: 16,
          ),
          Padding(
            child: _TransactionItem(transaction, store),
            padding: const EdgeInsets.only(top: 8),
          )
        ],
      ),
    );
  }

  String _getDate(BuildContext context, DateTime date) {
    DateTime now = DateTime.now();
    if (date.isAtSameMomentAs(new DateTime(now.year, now.month, now.day))) {
      return AppLocalizations.of(context).translate('today');
    }

    return date.toDateFormat();
  }
}

class _TransactionItem extends StatelessWidget {
  final Store<AppState> store;
  final Transaction transaction;

  _TransactionItem(this.transaction, this.store);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        transaction.category.icon,
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
        style: TextStyle(fontWeight: FontWeight.bold, color: transaction.amount.toMoneyColor()),
        textAlign: TextAlign.right,
        minFontSize: 8,
        maxLines: 1,
      ),
      onTap: () {
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
