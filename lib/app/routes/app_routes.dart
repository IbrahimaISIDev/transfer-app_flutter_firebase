abstract class AppRoutes {
  static const INITIAL = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';

  // Routes Client
  static const CLIENT_HOME = '/client/home';
  //static const CLIENT_TRANSFER = '/client/transfer';
  static const CLIENT_TRANSACTIONS = '/client/transactions';

  static const CLIENT_TRANSFER_SIMPLE = '/client-transfer-simple';
  static const CLIENT_TRANSFER_MULTIPLE = '/client-transfer-multiple';
  static const CLIENT_TRANSFER_SCHEDULED = '/client-transfer-scheduled';
  static const CLIENT_TRANSFER_HISTORY = '/client-transfer-history';

  // Routes Distributeur
  static const DISTRIBUTOR_HOME = '/distributor/home';
  static const DISTRIBUTOR_DEPOSIT = '/distributor/deposit';
  static const DISTRIBUTOR_WITHDRAWAL = '/distributor/withdrawal';
}

