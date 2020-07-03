import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'file:///C:/Users/danie/Documents/Projekte/finance-planner/lib/views/widgets/transaction_list/transaction_list.dart';

import '../../app_localizations.dart';
import '../add_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _offsetAnimation;
  ScrollController _scrollController = ScrollController();
  bool _fabIsVisible = true;

  @override
  void initState() {
    super.initState();

    this._animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    this._offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  MainScreenState() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_fabIsVisible == true && !_animationController.isAnimating) {
          _animationController.forward();
          _fabIsVisible = false;
        }
      } else {
        if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (_fabIsVisible == false && !_animationController.isAnimating) {
            _animationController.reverse();
            _fabIsVisible = true;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TransactionList(
          scrollController: _scrollController,
        ),
        floatingActionButton: SlideTransition(
          position: _offsetAnimation,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransactionScreen()),
              );
            },
            tooltip: AppLocalizations.of(context).translate('add-transaction'),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
