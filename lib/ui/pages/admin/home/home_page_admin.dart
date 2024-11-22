import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../edit/check_report_page.dart';
import '../status_report/status_report.dart';

class HomePageAdmin extends StatefulWidget {
  HomePageAdmin();

  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _activeFiles = [];
  String? _userName;
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadFilesWithoutStatus();
  }

  Future<void> _loadUserName() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      setState(() {
        _userName = userDoc['nome'];
      });
    } catch (e) {
      print('Erro ao buscar o nome do usuário: $e');
    }
  }

  Future<void> _loadFilesWithoutStatus() async {
    try {
      final activeRef = FirebaseStorage.instance.ref().child('uploads/');
      ListResult activeResult = await activeRef.listAll();
      List<Map<String, dynamic>> activeFiles = [];

      for (var item in activeResult.items) {
        final url = await item.getDownloadURL();

        // Verifica se o arquivo não está nas coleções de resolvidos, parcial, ou não resolvidos
        final resolvedSnapshot = await _firestore
            .collection('resolvidos')
            .where('name', isEqualTo: item.name)
            .get();
        final partialSnapshot = await _firestore
            .collection('parcial')
            .where('name', isEqualTo: item.name)
            .get();
        final notResolvedSnapshot = await _firestore
            .collection('nao_resolvido')
            .where('name', isEqualTo: item.name)
            .get();

        if (resolvedSnapshot.docs.isEmpty &&
            partialSnapshot.docs.isEmpty &&
            notResolvedSnapshot.docs.isEmpty) {
          // Se o arquivo não tem status, obtém os metadados
          final fullMetadata = await item.getMetadata();

          activeFiles.add({
            'name': item.name,
            'url': url,
            'latitude': fullMetadata.customMetadata?['latitude'] ?? 'N/A',
            'longitude': fullMetadata.customMetadata?['longitude'] ?? 'N/A',
            'observation': fullMetadata.customMetadata?['observation'] ?? '', // Capturando a observação
          });
        }
      }

      setState(() {
        _activeFiles = activeFiles;
        _hasData = activeFiles.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao listar arquivos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToEditPage(String imageUrl, String latitude, String longitude, String name, String observation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImagePage(
          imageUrl: imageUrl,
          latitude: latitude,
          longitude: longitude,
          name: name,
          observation: observation, // Passando a observação
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Central de Reportes'),
        backgroundColor: Color(0xFF962038),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF962038),
              ),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Resolvidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatusReportPage(status: 'resolvidos')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.timelapse),
              title: Text('Parcialmente Resolvidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatusReportPage(status: 'parcial')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Não Resolvidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatusReportPage(status: 'nao_resolvido')),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasData
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo, ${_userName ?? ''}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF962038),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Reportes Ativos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF962038),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _activeFiles.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemBuilder: (context, index) {
                            return Card(
                              color: Color(0xFF222222),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.network(
                                          _activeFiles[index]['url'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _activeFiles[index]['name'],
                                      style: TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        _navigateToEditPage(
                                          _activeFiles[index]['url'],
                                          _activeFiles[index]['latitude'],
                                          _activeFiles[index]['longitude'],
                                          _activeFiles[index]['name'],
                                          _activeFiles[index]['observation'], // Passando a observação
                                        );
                                      },
                                      child: Text('Resolver'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xFF962038),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : Center(child: Text("Nenhum reporte ativo", style: TextStyle(color: Colors.grey))),
    );
  }
}
