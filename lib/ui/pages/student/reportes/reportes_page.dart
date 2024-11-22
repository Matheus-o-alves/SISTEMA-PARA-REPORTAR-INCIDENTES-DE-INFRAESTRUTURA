import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/material.dart';

class UserReportsPage extends StatelessWidget {
  final String userEmail;

  UserReportsPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Reportes'),
        backgroundColor: Color(0xFF962038),
      ),
      body: FutureBuilder(
        future: _getUserReportsFromStorage(userEmail),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum reporte encontrado.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var data = snapshot.data![index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10.0),
                  title: Text(data['name']),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      data['url'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${data['status']}'),
                      Text('Observação: ${data['observation']}'),
                      Text('Latitude: ${data['latitude']}'),
                      Text('Longitude: ${data['longitude']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
Future<List<Map<String, dynamic>>> _getUserReportsFromStorage(String userEmail) async {
  try {
    final storageRef = FirebaseStorage.instance.ref().child('uploads/');
    ListResult result = await storageRef.listAll();

    List<Map<String, dynamic>> userFiles = [];

    for (var item in result.items) {
      // Obter os metadados da imagem
      final fullMetadata = await item.getMetadata();

      // Verificar se o e-mail nos metadados corresponde ao e-mail do usuário
      if (fullMetadata.customMetadata?['email'] == userEmail) {
        final url = await item.getDownloadURL();

        // Verificar o status da imagem no Firestore
        final resolvedSnapshot = await FirebaseFirestore.instance
            .collection('resolvidos')
            .where('name', isEqualTo: item.name)
            .get();

        final partialSnapshot = await FirebaseFirestore.instance
            .collection('parcial')
            .where('name', isEqualTo: item.name)
            .get();

        final notResolvedSnapshot = await FirebaseFirestore.instance
            .collection('nao_resolvido')
            .where('name', isEqualTo: item.name)
            .get();

        String status = 'sem status';
        if (resolvedSnapshot.docs.isNotEmpty) {
          status = 'resolvido';
        } else if (partialSnapshot.docs.isNotEmpty) {
          status = 'parcial';
        } else if (notResolvedSnapshot.docs.isNotEmpty) {
          status = 'não resolvido';
        }

        // Adicionar o arquivo à lista se for do usuário
        userFiles.add({
          'name': item.name,
          'url': url,
          'status': status,
          'latitude': fullMetadata.customMetadata?['latitude'] ?? 'N/A',
          'longitude': fullMetadata.customMetadata?['longitude'] ?? 'N/A',
          'observation': fullMetadata.customMetadata?['observation'] ?? 'N/A',
        });
      }
    }

    return userFiles;
  } catch (e) {
    print('Erro ao buscar reportes do usuário: $e');
    return [];
  }
}