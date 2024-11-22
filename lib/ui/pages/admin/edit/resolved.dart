import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResolvedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resolvidos por Outros'),
        backgroundColor: Color(0xFFAA1F37),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('resolvidos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(child: Text("Nenhum reporte resolvido por outros", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              return ListTile(
                contentPadding: EdgeInsets.all(10.0),
                title: Text(data['name'] ?? 'Sem nome'),
                leading: Image.network(
                  data['imageUrl'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, color: Colors.red);
                  },
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitude: ${data['latitude']}'),
                    Text('Longitude: ${data['longitude']}'),
                    Text('Observação: ${data['observation']}'),
                    Text('Status: ${data['status']}'),
                    Text('Timestamp: ${data['timestamp'].toDate()}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
