import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ResolvedPage extends StatelessWidget {
  final String status;

  ResolvedPage({required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios - $status'),
        backgroundColor: Color(0xFF962038),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('relatorios')
            .where('status', isEqualTo: status)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum relatório encontrado.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];

              return ListTile(
                contentPadding: EdgeInsets.all(10.0),
                title: Text(data['name']),
                leading: Image.network(
                  data['imageUrl'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                subtitle: Text('Latitude: ${data['latitude']}, Longitude: ${data['longitude']}'),
              );
            },
          );
        },
      ),
    );
  }
}