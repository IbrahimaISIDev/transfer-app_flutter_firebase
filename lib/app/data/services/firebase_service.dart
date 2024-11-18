import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  Future<void> register(UserModel user, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: user.email, 
      password: password
    );

    await _firestore.collection('users').doc(credential.user!.uid).set(
      user.toJson()
    );
  }

  Future<UserModel> getUserDetails(String uid) async {
    var doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data()!);
  }

  Future<double> getUserBalance() async {
    var currentUser = _auth.currentUser;
    var doc = await _firestore.collection('users')
      .doc(currentUser!.uid).get();
    return doc.data()?['balance'] ?? 0.0;
  }

  Future<List<TransactionModel>> getUserTransactions() async {
    var currentUser = _auth.currentUser;
    var querySnapshot = await _firestore.collection('transactions')
      .where('senderId', isEqualTo: currentUser!.uid)
      .get();

    return querySnapshot.docs.map((doc) => 
      TransactionModel.fromJson(doc.data())
    ).toList();
  }

  Future<void> createTransfer(String receiverPhone, double amount) async {
    // Logique de transfert complexe
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}