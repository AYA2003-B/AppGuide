// lib/carte.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CartePage extends StatefulWidget {
  @override
  _CartePageState createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {}; // Pour ajouter des marqueurs sur la carte

  // Coordonnées initiales de la carte
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(34.020882, -6.841650), // Exemple : coordonnées de Rabat
    zoom: 14.0,
  );

  // Vérifier si le contrôleur de la carte est créé
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      // Logique pour gérer l'état de la carte après sa création
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte Graphique - Google Maps'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        myLocationEnabled: true, // Active la localisation de l'utilisateur
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Ajouter un marqueur à la carte
            _markers.add(
              const Marker(
                markerId: MarkerId('1'),
                position: LatLng(34.020882, -6.841650),
                infoWindow: InfoWindow(
                  title: 'Marqueur Exemple',
                  snippet: 'Ceci est un marqueur exemple.',
                ),
              ),
            );
          });
        },
        child: Icon(Icons.add_location),
      ),
    );
  }
}
