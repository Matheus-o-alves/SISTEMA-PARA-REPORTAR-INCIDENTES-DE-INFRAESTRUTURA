import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reporta_ufop/ui/pages/admin/home/home_page_admin.dart';
import 'package:url_launcher/url_launcher.dart';

class EditImagePage extends StatefulWidget {
  final String imageUrl;
  final String? latitude;
  final String? longitude;
  final String? name;
  final String? observation;

  EditImagePage({
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.name,
    this.observation, // Recebendo a observação
  });

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  String? _status;
  final TextEditingController _observationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializa a observação se houver
    if (widget.observation != null) {
      _observationController.text = widget.observation!;
    }
  }

  void _openMap() async {
    if (widget.latitude != null && widget.longitude != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      print('Localização não disponível.');
    }
  }

  Future<void> _saveReport() async {
    if (_status == null) {
      Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageAdmin(),
      ));
      return;
    }

    try {
      String collectionPath;
      if (_status == 'resolved') {
        collectionPath = 'resolvidos';
      } else if (_status == 'partial') {
        collectionPath = 'parcial';
      } else if (_status == 'not_resolved') {
        collectionPath = 'nao_resolvido';
      } else {
        throw Exception('Status desconhecido');
      }

      await FirebaseFirestore.instance.collection(collectionPath).add({
        'imageUrl': widget.imageUrl,
        'status': _status!,
        'observation': _observationController.text,
        'latitude': widget.latitude ?? 'N/A',
        'longitude': widget.longitude ?? 'N/A',
        'name': widget.name ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Relatório salvo com sucesso.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Erro ao salvar relatório: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar relatório. Detalhes: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Gerenciar Reporte'),
        backgroundColor: Color(0xFF962038),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do lado esquerdo
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.imageUrl,
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 100,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.observation ?? 'Sem observações',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Campos do lado direito
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'resolved', child: Text('Resolvido')),
                      DropdownMenuItem(value: 'partial', child: Text('Parcialmente Resolvido')),
                      DropdownMenuItem(value: 'not_resolved', child: Text('Não Resolvido')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _observationController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Observações Internas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveReport,
                    icon: Icon(Icons.save),
                    label: Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF962038),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _openMap,
                    icon: Icon(Icons.map),
                    label: Text('Visualizar Local'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
