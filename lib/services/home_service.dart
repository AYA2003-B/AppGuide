import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  Future<List<DocumentSnapshot>> getRecommendedSites() async {
    // Récupérer les données depuis la collection UserRecommendations
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('UserRecommendations')
        .get();

    List<DocumentSnapshot> recommendedSites = [];

    // Parcourir chaque document dans UserRecommendations
    for (var doc in snapshot.docs) {
      // Récupérer le tableau des références recommandées
      List<DocumentReference> siteRefs = List.from(doc['recommendedSites']);

      // Récupérer chaque site par sa référence
      for (var siteRef in siteRefs) {
        DocumentSnapshot siteSnapshot = await siteRef.get();

        // Si le site existe, l'ajouter à la liste des sites recommandés
        if (siteSnapshot.exists) {
          recommendedSites
              .add(siteSnapshot); // Ajoute DocumentSnapshot directement
        }
      }
    }

    // Retourner la liste des sites recommandés
    return recommendedSites;
  }

  // Récupérer les sites populaires triés par popularité
  // Récupérer les sites populaires dont la popularité est supérieure à 50, triés par popularité
  Future<List<QueryDocumentSnapshot>> getPopularSites() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(
              'HistoricalSites') // Assurez-vous que votre collection est correctement nommée
          .where('popularity',
              isGreaterThan: 50) // Filtrer les sites avec popularité > 50
          .orderBy('popularity',
              descending: true) // Trier par popularité décroissante
          .get();

      return snapshot.docs;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des sites populaires: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> getNaturalSites() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('HistoricalSites').get();
    return snapshot.docs;
  }
}
