import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final Rx<UserType> selectedUserType = UserType.client.obs;

  UserModel? get user => _user.value;

  Future<void> _loadUserData(String userId) async {
    try {
      _user.value = await _firebaseService.getUserDetails(userId);
      _redirectBasedOnUserType();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données utilisateur');
    }
  }

  void _redirectBasedOnUserType() {
    if (_user.value != null) {
      Get.offAllNamed(_user.value!.userType == UserType.client
          ? '/client/home'
          : '/distributor/home');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _firebaseService.login(email, password, isLoading);

      final userId = _firebaseService.getCurrentUserId();
      _user.value = await _firebaseService.getUserDetails(userId);

      isLoading.value = false;
      _redirectBasedOnUserType();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur de connexion', e.toString());
    }
  }

  Future<void> registerClient(UserModel userData, String password) async {
    try {
      isLoading.value = true;
      await _firebaseService.registerClient(
        email: userData.email,
        password: password,
        phoneNumber: userData.phoneNumber,
        fullName: userData.fullName ?? 'Default Name', // Default value if null
        isLoading: isLoading,
      );
      Get.snackbar('Succès', 'Inscription réussie');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Erreur d\'inscription', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerDistributor(String email, String password,
      String phoneNumber, String agentCode) async {
    try {
      isLoading.value = true;
      await _firebaseService.registerDistributor(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        agentCode: agentCode,
        isLoading: isLoading,
      );
      Get.snackbar('Succès', 'Inscription réussie');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Erreur d\'inscription', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true; // Ajouter un indicateur de chargement

      // Déconnexion de Firebase
      await _firebaseService.logout();

      // Réinitialiser toutes les données locales
      _user.value = null;

      // Supprimer toutes les routes précédentes et rediriger vers login
      await Get.offAllNamed('/login', predicate: (_) => false);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de se déconnecter: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter une méthode pour vérifier l'état de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mettre à jour onInit pour écouter les changements d'authentification
  @override
  void onInit() {
    super.onInit();
    ever(_user, (user) {
      if (user == null) {
        Get.offAllNamed('/login');
      }
    });

    _auth.authStateChanges().listen((User? user) {
      if (user == null && Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final userCredential = await _firebaseService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        // Charger les données utilisateur
        final userId = userCredential.user!.uid;
        _user.value = await _firebaseService.getUserDetails(userId);
        _redirectBasedOnUserType();
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      // Implémentez la logique de connexion Facebook
    } catch (e) {
      // Gérez les erreurs
    }
  }

  Future<void> signInWithGithub() async {
    try {
      // Implémentez la logique de connexion GitHub
    } catch (e) {
      // Gérez les erreurs
    }
  }

  final RxString verificationId = ''.obs;

  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _firebaseService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (String vId, int? resendToken) {
          verificationId.value = vId;
          Get.toNamed('/verify-otp');
        },
        onError: (String message) {
          Get.snackbar('Erreur', message);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String smsCode) async {
    if (verificationId.value.isEmpty) {
      Get.snackbar('Erreur', 'Session de vérification expirée');
      return;
    }

    try {
      await _firebaseService.verifyOTP(
        verificationId: verificationId.value,
        smsCode: smsCode,
        isLoading: isLoading,
      );

      final userId = _firebaseService.getCurrentUserId();
      _user.value = await _firebaseService.getUserDetails(userId);
      _redirectBasedOnUserType();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }
}
