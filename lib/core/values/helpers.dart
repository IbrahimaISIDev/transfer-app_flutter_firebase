import 'package:intl/intl.dart';

class AppHelpers {
  // Formater une date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Formater un montant
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA').format(amount);
  }

  // Générer un numéro de transaction unique
  static String generateTransactionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Masquer partiellement un numéro de téléphone
  static String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 4) return phoneNumber;
    return phoneNumber.replaceRange(
      3, 
      phoneNumber.length - 2, 
      '*' * (phoneNumber.length - 5)
    );
  }

  // Valider un numéro de téléphone
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^(\+33|0)[1-9](\d{2}){4}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  // Vérifier la force d'un mot de passe
  static bool isStrongPassword(String password) {
    final strongRegex = 
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return strongRegex.hasMatch(password);
  }
}