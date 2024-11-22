import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reporta_ufop/ui/pages/student/home/home_page_student.dart';

class PreviewPage extends StatefulWidget {
  final XFile picture;

  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final TextEditingController _observationController = TextEditingController();

  Future<void> _saveImage() async {
    try {
      File file = File(widget.picture.path);

      // Obtendo a localização atual
      Position position = await _getCurrentLocation();

      // Obtendo o email do usuário autenticado
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? 'email_desconhecido';

      // Criando os metadados com a latitude, longitude, observação e email do usuário
      final metadata = SettableMetadata(
        customMetadata: {
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
          'observation': _observationController.text,
          'email': userEmail,
        },
      );

      // Criando a referência de armazenamento no Firebase
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.png');

      // Enviando a imagem com os metadados
      await storageRef.putFile(file, metadata);

      print('Imagem enviada com sucesso com os metadados de localização.');

      // Redirecionando de volta para a HomePageStudent após salvar a imagem
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageStudent(),
        ),
      );
    } catch (e) {
      print('Erro ao enviar a imagem: $e');
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('O serviço de localização está desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização foi negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permissões de localização foram negadas permanentemente, não podemos solicitar permissões.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF962038),
      appBar: AppBar(
        title: const Text('Detalhes do Reporte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Image.file(
                File(widget.picture.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _observationController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observações',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Tirar Outra Foto'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveImage,
                  icon: Icon(Icons.save),
                  label: Text('Salvar Foto'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
