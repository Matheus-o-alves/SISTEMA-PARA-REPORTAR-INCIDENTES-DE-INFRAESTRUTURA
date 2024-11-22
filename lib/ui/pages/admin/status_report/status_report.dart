import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusReportPage extends StatelessWidget {
  final String status;

  StatusReportPage({required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatórios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF962038),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(status)  // A coleção agora é `resolved`, `partial`, ou `not_resolved`
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

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF962038),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(data['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Latitude: ${data['latitude']}',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Longitude: ${data['longitude']}',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Observação: ${data['observation']}',
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${_getStatusLabel(data['status'])}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(data['status']),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Data: ${_formatTimestamp(data['timestamp'])}',
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'resolved':
        return 'Resolvidos';
      case 'partial':
        return 'Parcialmente Resolvidos';
      case 'not_resolved':
        return 'Não Resolvidos';
      default:
        return 'Relatórios';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'resolved':
        return 'Resolvido';
      case 'partial':
        return 'Parcialmente Resolvido';
      case 'not_resolved':
        return 'Não Resolvido';
      default:
        return 'Desconhecido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'not_resolved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
