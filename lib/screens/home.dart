import 'package:appguide/screens/carte.dart';
import 'package:appguide/screens/favoris.dart';
import 'package:appguide/screens/user_profil.dart';
import 'package:appguide/services/favoris_service.dart';
import 'package:appguide/services/home_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<Widget> page;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  int _selectedIndex = 0;
  final HomeService _homeService = HomeService();
  final FavorisService _favorisService = FavorisService();
  late Future<List<DocumentSnapshot>> recommendedSites;
  late Future<List<QueryDocumentSnapshot>> popularSites;
  late Future<List<QueryDocumentSnapshot>> naturalSites;
  late List<String> favoriteSites;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    recommendedSites = _homeService.getRecommendedSites();
    popularSites = _homeService.getPopularSites();
    naturalSites = _homeService.getNaturalSites();

    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      throw Exception('User ID must not be empty');
    }

    favoriteSites = [];
    _loadFavoriteSites();

    page = [
      const HomePage(),
      FavorisPage(userId: currentUserId),
      UserProfilePage(userId: currentUserId),
      CartePage(),
    ];
  }

  void _loadFavoriteSites() async {
    // Récupérer les sites favoris de Firestore
    List<String> favorites = (await _favorisService.getFavorites(currentUserId))
        .map((doc) => doc.id)
        .toList();
    setState(() {
      favoriteSites = favorites;
    });
  }

  void _updateFavoriteStatus(String siteId, bool isFavorite) async {
    if (isFavorite) {
      await _favorisService.addFavorite(currentUserId, siteId);
    } else {
      await _favorisService.removeFavorite(currentUserId, siteId);
    }
    _loadFavoriteSites(); // Recharger les favoris après modification
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 200,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/back.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bienvenue !",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              Text("Découvrez les destinations incroyables",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle("Recommandations"),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: recommendedSites,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Aucun site recommandé.'));
                    }
                    return _buildSiteList(snapshot.data!);
                  },
                ),
                const SizedBox(height: 10),
                _buildSectionTitle("Les plus populaires"),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: popularSites,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucun site populaire.'));
                    }
                    return _buildSiteList(snapshot.data!);
                  },
                ),
                const SizedBox(height: 10),
                _buildSectionTitle("Sites Naturels"),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: naturalSites,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucun site naturel.'));
                    }
                    return _buildSiteList(snapshot.data!);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Switch between pages
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page[index]),
          );
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher une destination...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSiteList(List<dynamic> sites) {
    return SizedBox(
      height: 250, // Hauteur fixe pour scroller horizontalement
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sites.length,
        itemBuilder: (context, index) {
          final site = sites[index];
          final String siteId = site.id;
          bool isFavorite = favoriteSites.contains(siteId);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SiteDetailPage(site: site),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            site['image'],
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    isFavorite = !isFavorite;
                                    if (isFavorite) {
                                      favoriteSites.add(siteId);
                                    } else {
                                      favoriteSites.remove(siteId);
                                    }
                                  },
                                );
                              }),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        site['name'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        site['location'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Tarif: ${site['price']} ',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SiteDetailPage extends StatelessWidget {
  final dynamic site;

  const SiteDetailPage({Key? key, required this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(site['name'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                site['image'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              site['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Description: ${site['description']}'),
            const SizedBox(height: 5),
            Text('Tarif: ${site['price']} '),
            Text('Lieu: ${site['location']}'),
          ],
        ),
      ),
    );
  }
}
