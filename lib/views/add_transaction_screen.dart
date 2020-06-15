import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class AddTransactionScreen extends StatelessWidget {
  final Store<AppState> store;

  AddTransactionScreen({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Add transaction"),
          ),
          body: Text("Hello world")),
    );
  }
}
