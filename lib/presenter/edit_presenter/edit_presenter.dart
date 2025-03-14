import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EditImageController extends GetxController {
  final String imageUrl;
  final String? latitude;
  final String? longitude;
  final String? name;
  final RxString? status = RxString(null);
  final RxString observation = ''.obs;
  
  EditImageController({
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.name,
    String? initialObservation,
  }) {
    if (initialObservation != null) {
      observation.value = initialObservation;
    }
  }

  Future<void> openMap() async {
    if (latitude != null && longitude != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Não foi possível abrir o mapa';
      }
    } else {
      Get.snackbar('Erro', 'Localização não disponível', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saveReport() async {
    if (status?.value == null) {
      Get.back();
      return;
    }

    try {
      String collectionPath;
      switch (status?.value) {
        case 'resolved':
          collectionPath = 'resolvidos';
          break;
        case 'partial':
          collectionPath = 'parcial';
          break;
        case 'not_resolved':
          collectionPath = 'nao_resolvido';
          break;
        default:
          throw Exception('Status desconhecido');
      }

      await FirebaseFirestore.instance.collection(collectionPath).add({
        'imageUrl': imageUrl,
        'status': status!.value,
        'observation': observation.value,
        'latitude': latitude ?? 'N/A',
        'longitude': longitude ?? 'N/A',
        'name': name ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Sucesso', 'Relatório salvo com sucesso.', snackPosition: SnackPosition.BOTTOM);
      Get.back();
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao salvar relatório: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
