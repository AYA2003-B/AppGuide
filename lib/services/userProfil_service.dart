import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère le profil utilisateur par `userId`
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID must not be empty');
    }
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('User not found in the database');
      }
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Crée un profil utilisateur avec des données initiales
  Future<void> createUserProfile(
      String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty || data.isEmpty) {
      throw Exception('User ID and data must not be empty');
    }
    try {
      await _firestore.collection('Users').doc(userId).set(data);
    } on FirebaseException catch (e) {
      throw Exception('Error creating user profile: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Met à jour le profil utilisateur
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty || data.isEmpty) {
      throw Exception('User ID and data must not be empty');
    }
    try {
      await _firestore.collection('Users').doc(userId).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Error updating user profile: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Supprime un profil utilisateur
  Future<void> deleteUserProfile(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID must not be empty');
    }
    try {
      await _firestore.collection('Users').doc(userId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Error deleting user profile: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Vérifie si un utilisateur existe
  Future<bool> userExists(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID must not be empty');
    }
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      return documentSnapshot.exists;
    } catch (e) {
      throw Exception('Error checking user existence: $e');
    }
  }

  /// Récupère le nom complet de l'utilisateur
  String getFullName(Map<String, dynamic> userProfile) {
    String firstName = userProfile['first_name'] ?? 'Unknown';
    String lastName = userProfile['last_name'] ?? 'User';
    return '$firstName $lastName';
  }

  /// Récupère la liste des hobbies de l'utilisateur
  List<String> getHobbies(Map<String, dynamic> userProfile) {
    String hobbies = userProfile['hobies'] ?? '';
    return hobbies.isNotEmpty ? hobbies.split(', ') : [];
  }

  /// Récupère l'image de profil de l'utilisateur
  String getProfileImage(Map<String, dynamic> userProfile) {
    return userProfile['image'] ?? 'default_image_url';
  }

  /// Récupère les préférences de l'utilisateur
  Map<String, dynamic> getPreferences(Map<String, dynamic> userProfile) {
    return userProfile['preferences'] ?? {};
  }

  /// Récupère les sites historiques favoris de l'utilisateur
  Map<String, dynamic> getHistoricalSites(Map<String, dynamic> userProfile) {
    return userProfile['historicalSites'] ?? {};
  }
}
