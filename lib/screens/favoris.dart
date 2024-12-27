import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appguide/services/favoris_service.dart';
import 'package:appguide/screens/home.dart';
import 'package:appguide/screens/user_profil.dart';
import 'package:appguide/screens/carte.dart';

class FavorisPage extends StatefulWidget {
  final String userId;

  FavorisPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FavorisPageState createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  final FavorisService _favorisService = FavorisService();
  late Future<List<QueryDocumentSnapshot>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    // Charger les favoris au démarrage de la page
    _favoritesFuture = _favorisService.getFavorites(widget.userId);
  }

  // Fonction pour afficher les détails du site
  Future<Map<String, dynamic>> _getPlaceDetails(
      DocumentReference placeRef) async {
    DocumentSnapshot snapshot = await placeRef.get();
    return snapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun site favori.'));
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index].data() as Map<String, dynamic>;
              final placeRef = favorite['place_name'] as DocumentReference;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getPlaceDetails(placeRef),
                builder: (context, placeSnapshot) {
                  if (placeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (placeSnapshot.hasError) {
                    return Center(
                        child: Text('Erreur : ${placeSnapshot.error}'));
                  }

                  final placeDetails = placeSnapshot.data ?? {};
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.red),
                      title:
                          Text(placeDetails['name'] ?? 'Nom du site inconnu'),
                      subtitle: Text(
                          placeDetails['description'] ?? 'Pas de description'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () async {
                          // Supprimer du favoris
                          await _favorisService.removeFavorite(
                            widget.userId,
                            placeDetails['name'] ?? '',
                          );
                          // Rafraîchit la liste des favoris après la suppression
                          setState(() {
                            _favoritesFuture =
                                _favorisService.getFavorites(widget.userId);
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Sélectionner l'index des favoris
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
              break;
            case 1:
              break; // Cette page est déjà les favoris
            case 2:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UserProfilePage(userId: widget.userId)));
              break;
            case 3:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => CartePage()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
        ],
      ),
    );
  }
}
