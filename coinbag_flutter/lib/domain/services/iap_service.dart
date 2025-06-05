class IapService {
  bool _hasPremium = false;

  bool get hasPremium => _hasPremium;

  /// Simulates purchasing the premium upgrade.
  Future<void> buyPremium() async {
    // In a real app this would trigger the platform purchase flow.
    _hasPremium = true;
  }
}
