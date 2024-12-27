import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavorisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter un site aux favoris
  Future<void> addFavorite(String userId, String placeId) async {
    try {
      DocumentReference placeRef =
          _firestore.collection('HistoricalSites').doc(placeId);
      await _firestore.collection('UserFavoris').doc(userId).set({
        'isFavoris': true,
        'place_name': placeRef,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout au favoris: $e');
    }
  }

  Future<void> updateFavoriteSites(
      String userId, List<String> favoriteSites) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': favoriteSites,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des favoris: $e');
    }
  }

  // Retirer un site des favoris
  Future<void> removeFavorite(String userId, String placeName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('UserFavoris')
          .where('place_name',
              isEqualTo:
                  _firestore.collection('HistoricalSites').doc(placeName))
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete(); // Supprimer le document du favoris
      }
    } catch (e) {
      print('Erreur lors de la suppression du favoris: $e');
    }
  }

  // Récupérer les sites favoris d'un utilisateur
  Future<List<QueryDocumentSnapshot>> getFavorites(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('UserFavoris')
          .where('isFavoris', isEqualTo: true)
          .where('user_id', isEqualTo: userId)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }
}
