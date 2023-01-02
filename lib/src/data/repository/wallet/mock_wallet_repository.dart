import 'package:rxdart/rxdart.dart';

import '../../../wallet_constants.dart';
import '../../source/wallet_datasource.dart';
import 'wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  WalletDataSource dataSource;
  String? _pin;

  /// The amount of times the user incorrectly entered the pin, resets to 0 on a successful attempt.
  int _invalidPinAttempts = 0;
  final BehaviorSubject<bool> _locked = BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<bool> _isInitialized = BehaviorSubject<bool>.seeded(false);

  MockWalletRepository(this.dataSource);

  @override
  void lockWallet() => _locked.add(true);

  @override
  void unlockWallet(String pin) {
    if (!isInitialized) throw UnsupportedError('Wallet not yet initialized!');
    if (_pin != null && pin == _pin) {
      _locked.add(false);
      _invalidPinAttempts = 0;
    } else {
      _invalidPinAttempts++;
      if (_invalidPinAttempts >= kMaxUnlockAttempts) {
        destroyWallet();
      }
    }
  }

  @override
  Future<bool> confirmTransaction(String pin) async {
    if (!isInitialized) throw UnsupportedError('Wallet not yet initialized!');
    if (isLocked) throw UnsupportedError('Wallet is locked');
    if (_pin != null && pin == _pin) {
      _invalidPinAttempts = 0;
      return true;
    } else {
      _invalidPinAttempts++;
      if (_invalidPinAttempts >= kMaxUnlockAttempts) destroyWallet();
    }
    return false;
  }

  @override
  Future<bool> createWallet(String pin) async {
    if (pin.length != kPinDigits) throw UnsupportedError('Invalid pin. Length should be $kPinDigits');
    if (isInitialized) throw UnsupportedError('Wallet is already initialized');
    await Future.delayed(kDefaultMockDelay);
    _pin = pin;
    _isInitialized.add(true);
    _invalidPinAttempts = 0;
    return _isInitialized.value;
  }

  @override
  Future<void> destroyWallet() async {
    if (!isInitialized) throw UnsupportedError('Wallet not yet initialized!');
    dataSource.destroy();
    _pin = null;
    _isInitialized.add(false);
    _locked.add(true);
  }

  @override
  Stream<bool> get isInitializedStream => _isInitialized.stream.distinct();

  bool get isInitialized => _isInitialized.value;

  bool get isLocked => _locked.value;

  @override
  Stream<bool> get isLockedStream => _locked.stream.distinct();

  @override
  int get leftoverPinAttempts => _isInitialized.value ? kMaxUnlockAttempts - _invalidPinAttempts : -1;
}
