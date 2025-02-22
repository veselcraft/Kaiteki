import 'package:flutter/foundation.dart';
import 'package:kaiteki/fediverse/adapter.dart';
import 'package:kaiteki/fediverse/model/user.dart';
import 'package:kaiteki/logger.dart';
import 'package:kaiteki/model/account_key.dart';
import 'package:kaiteki/model/auth/account_compound.dart';
import 'package:kaiteki/model/auth/account_secret.dart';
import 'package:kaiteki/model/auth/client_secret.dart';
import 'package:kaiteki/repositories/repository.dart';
import 'package:kaiteki/utils/extensions.dart';
import 'package:tuple/tuple.dart';

class AccountManager extends ChangeNotifier {
  static final _logger = getLogger('AccountContainer');

  Account? _currentAccount;
  Account get currentAccount => _currentAccount!;
  set currentAccount(Account account) {
    assert(_accounts.contains(account));
    _currentAccount = account;
    notifyListeners();
  }

  String get instance => currentAccount.key.host;
  FediverseAdapter get adapter => currentAccount.adapter;
  bool get loggedIn => _currentAccount != null;

  final Repository<AccountSecret, AccountKey> _accountSecrets;
  final Repository<ClientSecret, AccountKey> _clientSecrets;

  final Set<Account> _accounts = {};
  Iterable<Account> get accounts => List.unmodifiable(_accounts);

  AccountManager(this._accountSecrets, this._clientSecrets);

  Future<void> remove(Account account) async {
    assert(
      _accounts.contains(account),
      "The specified account doesn't exist",
    );

    await _accountSecrets.delete(account.key);

    if (account.clientSecret != null) {
      await _clientSecrets.delete(account.key);
    }

    _accounts.remove(account);
    if (_currentAccount == account) {
      _currentAccount = _accounts.isEmpty //
          ? null
          : _accounts.first;
    }

    notifyListeners();
  }

  Future<void> add(Account account) async {
    assert(
      !_accounts.contains(account),
      "An account with the same username and instance already exists",
    );

    await _accountSecrets.create(account.key, account.accountSecret);
    if (account.clientSecret != null) {
      await _clientSecrets.create(account.key, account.clientSecret!);
    }

    _accounts.add(account);
    _currentAccount ??= account;

    notifyListeners();
  }

  Future<void> loadAllAccounts() async {
    final accountSecrets = await _accountSecrets.read();
    final clientSecrets = await _clientSecrets.read();

    final secretPairs = accountSecrets.entries.map((kv) {
      final clientSecret = clientSecrets[kv.key];
      return Tuple3(kv.key, kv.value, clientSecret);
    });

    await Future.forEach(secretPairs, _restoreSession);

    if (_accounts.isNotEmpty) {
      // TODO(Craftplacer): Store which account the user last used
      currentAccount = _accounts.first;
    }
  }

  /// Retrieves the client secret for a given instance.
  Future<ClientSecret?> getClientSecret(
    String instance, [
    String? username,
  ]) async {
    final secrets = await _clientSecrets.read();
    final key = secrets.keys.firstOrDefault((key) {
      return key.host == instance && key.username == username;
    });
    return secrets[key];
  }

  Future<void> _restoreSession(
    Tuple3<AccountKey, AccountSecret, ClientSecret?> credentials,
  ) async {
    final key = credentials.item1;
    final accountSecret = credentials.item2;
    final clientSecret = credentials.item3;

    _logger.v('Trying to recover a ${key.type!.displayName} account');

    final adapter = key.type!.createAdapter(key.host);
    if (clientSecret != null) {
      await adapter.client.setClientAuthentication(clientSecret);
    }
    await adapter.client.setAccountAuthentication(accountSecret);

    User user;

    try {
      user = await adapter.getMyself();
    } catch (ex) {
      _logger.e('Failed to verify credentials', ex);
      return;
    }

    final account = Account(
      key: key,
      adapter: adapter,
      user: user,
      clientSecret: clientSecret,
      accountSecret: accountSecret,
    );

    _logger.v(
      'Recovered ${account.user.displayName} @ ${key.host}',
    );

    await add(account);
  }
}
