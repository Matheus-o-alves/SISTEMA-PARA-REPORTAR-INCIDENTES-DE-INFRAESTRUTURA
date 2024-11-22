import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reportes/reportes_page.dart';
import 'camera_app.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({Key? key}) : super(key: key);

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      // Obtendo o UID do usuário logado
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Buscando o documento do usuário no Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      setState(() {
        _userName = userDoc['nome']; // Armazenando o nome do usuário no estado
      });
    } catch (e) {
      print('Erro ao buscar o nome do usuário: $e');
    }
  }

  void _navigateToReports() async {
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserReportsPage(userEmail: userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF962038),
      appBar: AppBar(
        title: Text("Bem-vindo, ${_userName ?? ''}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
                onPressed: () async {
                  await availableCameras().then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CameraPage(cameras: value),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Color(0xFF962038)),
                label: const Text(
                  "Adicionar Reporte",
                  style: TextStyle(color: Color(0xFF962038)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _navigateToReports,
                icon: Icon(Icons.report, color: Color(0xFF962038)),
                label: const Text(
                  "Ver Meus Reportes",
                  style: TextStyle(color: Color(0xFF962038)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
