import 'package:stacked/stacked.dart';

import '../../../utils/bank_codes.dart';

class BankAccountPickerSheetModel extends BaseViewModel {
  List<PayazaBank> _results = NigerianBanks.all;

  List<PayazaBank> get results => _results;

  void onSearchChanged(String query) {
    _results = query.isEmpty ? NigerianBanks.all : NigerianBanks.search(query);
    notifyListeners();
  }
}
