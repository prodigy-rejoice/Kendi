import 'dart:async';

import '../models/withdrawal_request.dart';

class WithdrawalStore {
  final List<WithdrawalRequest> _withdrawals = [];
  final _controller =
      StreamController<List<WithdrawalRequest>>.broadcast();

  Stream<List<WithdrawalRequest>> get stream => _controller.stream;
  List<WithdrawalRequest> get all => List.unmodifiable(_withdrawals);

  void add(WithdrawalRequest request) {
    _withdrawals.insert(0, request);
    _controller.add(_withdrawals);
  }

  void dispose() => _controller.close();
}
