import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _locationController;
  late TextEditingController _quoteController;
  late TextEditingController _hobbiesController;
  late TextEditingController _ageController;
  late TextEditingController _imageUrlController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('Users').doc(widget.userId).get();
      if (documentSnapshot.exists) {
        var userProfile = documentSnapshot.data() as Map<String, dynamic>;
        _firstNameController =
            TextEditingController(text: userProfile['first_name']);
        _lastNameController =
            TextEditingController(text: userProfile['last_name']);
        _locationController =
            TextEditingController(text: userProfile['location']);
        _quoteController = TextEditingController(text: userProfile['quote']);
        _hobbiesController = TextEditingController(text: userProfile['hobies']);
        _ageController =
            TextEditingController(text: userProfile['age'].toString());
        _imageUrlController = TextEditingController(text: userProfile['image']);
        setState(() {});
      } else {
        throw Exception("Utilisateur non trouvé");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _imageUrlController.text = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('Users').doc(widget.userId).update({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'location': _locationController.text,
          'quote': _quoteController.text,
          'hobies': _hobbiesController.text,
          'age': int.parse(_ageController.text),
          'image': _imageUrlController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profil mis à jour avec succès")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la mise à jour : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firstNameController == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Modifier le Profil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le Profil'),
        backgroundColor: Colors.blue, // Couleur bleue
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : NetworkImage(_imageUrlController.text) as ImageProvider,
                  backgroundColor: Colors.blueGrey[100],
                  child: _image == null
                      ? Icon(Icons.camera_alt, color: Colors.blue)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL de l\'image'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une URL d\'image';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Localisation'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une localisation';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quoteController,
                decoration: InputDecoration(labelText: 'Citation personnelle'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une citation';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hobbiesController,
                decoration: InputDecoration(
                    labelText: 'Hobbies (séparés par des virgules)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer vos hobbies';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Âge'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre âge';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Couleur bleue pour le bouton
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
