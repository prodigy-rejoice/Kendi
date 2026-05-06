class PayazaBank {
  final String code;
  final String name;
  const PayazaBank({required this.code, required this.name});
}

class NigerianBanks {
  static const List<PayazaBank> all = [
    PayazaBank(code: '000014', name: 'ACCESS BANK'),
    PayazaBank(code: '000005', name: 'ACCESS(DIAMOND) BANK'),
    PayazaBank(code: '000009', name: 'CITI BANK'),
    PayazaBank(code: '000010', name: 'ECOBANK'),
    PayazaBank(code: '000007', name: 'FIDELITY BANK'),
    PayazaBank(code: '000016', name: 'FIRST BANK OF NIGERIA'),
    PayazaBank(code: '000003', name: 'FIRST CITY MONUMENT BANK (FCMB)'),
    PayazaBank(code: '000027', name: 'GLOBUS BANK'),
    PayazaBank(code: '000013', name: 'GTBANK PLC'),
    PayazaBank(code: '000020', name: 'HERITAGE BANK'),
    PayazaBank(code: '000006', name: 'JAIZ BANK'),
    PayazaBank(code: '000002', name: 'KEYSTONE BANK'),
    PayazaBank(code: '000029', name: 'LOTUS BANK'),
    PayazaBank(code: '090267', name: 'KUDA MICROFINANCE BANK'),
    PayazaBank(code: '090405', name: 'MONIEPOINT MICROFINANCE BANK'),
    PayazaBank(code: '100004', name: 'OPAY'),
    PayazaBank(code: '100002', name: 'PAGA'),
    PayazaBank(code: '100033', name: 'PALMPAY'),
    PayazaBank(code: '000008', name: 'POLARIS BANK'),
    PayazaBank(code: '000031', name: 'PREMIUM TRUST BANK'),
    PayazaBank(code: '000023', name: 'PROVIDUS BANK'),
    PayazaBank(code: '000034', name: 'SIGNATURE BANK'),
    PayazaBank(code: '000012', name: 'STANBIC IBTC BANK'),
    PayazaBank(code: '000021', name: 'STANDARD CHARTERED BANK'),
    PayazaBank(code: '000001', name: 'STERLING BANK'),
    PayazaBank(code: '000022', name: 'SUNTRUST BANK'),
    PayazaBank(code: '000026', name: 'TAJ BANK'),
    PayazaBank(code: '000025', name: 'TITAN TRUST BANK'),
    PayazaBank(code: '000018', name: 'UNION BANK'),
    PayazaBank(code: '000004', name: 'UNITED BANK FOR AFRICA'),
    PayazaBank(code: '000011', name: 'UNITY BANK'),
    PayazaBank(code: '000017', name: 'WEMA BANK'),
    PayazaBank(code: '000015', name: 'ZENITH BANK'),
    PayazaBank(code: '090328', name: 'EYOWO'),
    PayazaBank(code: '090551', name: 'FAIRMONEY'),
    PayazaBank(code: '090325', name: 'SPARKLE'),
    PayazaBank(code: '090426', name: 'TANGERINE MONEY'),
    PayazaBank(code: '090110', name: 'VFD MFB'),
    PayazaBank(code: '090175', name: 'RUBIES MICROFINANCE BANK'),
  ];

  static PayazaBank? findByCode(String code) {
    try {
      return all.firstWhere((b) => b.code == code);
    } catch (_) {
      return null;
    }
  }

  static List<PayazaBank> search(String query) {
    final q = query.toLowerCase();
    return all.where((b) => b.name.toLowerCase().contains(q)).toList();
  }
}
