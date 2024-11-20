import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Exemple : Vérifiez si l'utilisateur est authentifié
    bool isAuthenticated = false; // Remplacez par votre logique d'authentification

    if (!isAuthenticated) {
      // Redirigez vers la page de connexion si l'utilisateur n'est pas authentifié
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    return null; // Pas de redirection si l'utilisateur est authentifié
  }
}
