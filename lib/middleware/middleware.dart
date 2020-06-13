import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> accessDatabase(int counter) {
  return (Store<AppState> store) async {
    print(counter);

    // use tutorial at https://pub.dev/packages/postgresql

    store.dispatch(new IncrementAction());
  };
}
