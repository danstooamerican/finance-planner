import 'package:financeplanner/app_localizations.dart';
import 'package:financeplanner/views/add_transaction_screen.dart';
import 'package:financeplanner/views/widgets/transaction_list/transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
        if (_fabIsVisible && !_animationController.isAnimating) {
          _animationController.forward();
          _fabIsVisible = false;
        }
      } else {
        if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (!_fabIsVisible && !_animationController.isAnimating) {
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
            onPressed: _navigateToAddTransactionScreen,
            tooltip: AppLocalizations.of(context).translate('add-transaction'),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _navigateToAddTransactionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(),
      ),
    );
  }
}
