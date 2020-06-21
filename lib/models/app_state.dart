import 'package:financeplanner/models/models.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final List<Transaction> transactions;

  AppState({
    @required this.transactions,
  });
}
