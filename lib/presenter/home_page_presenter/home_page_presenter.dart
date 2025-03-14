import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../edit/check_report_page.dart';
import '../status_report/status_report.dart';

class HomePageAdminPresenter extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<Map<String, dynamic>> activeFiles = <Map<String, dynamic>>[].obs;
  RxString userName = ''.obs;
  RxBool isLoading = true.obs;
  RxBool hasData = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
    loadFilesWithoutStatus();
  }

  Future<void> loadUserName() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      userName.value = userDoc['nome'];
    } catch (e) {
      print('Erro ao buscar o nome do usuário: $e');
    }
  }

  Future<void> loadFilesWithoutStatus() async {
    try {
      final activeRef = _storage.ref().child('uploads/');
      ListResult activeResult = await activeRef.listAll();
      List<Map<String, dynamic>> activeFilesTemp = [];

      for (var item in activeResult.items) {
        final url = await item.getDownloadURL();
        final fullMetadata = await item.getMetadata();

        final resolvedSnapshot = await _firestore.collection('resolvidos').where('name', isEqualTo: item.name).get();
        final partialSnapshot = await _firestore.collection('parcial').where('name', isEqualTo: item.name).get();
        final notResolvedSnapshot = await _firestore.collection('nao_resolvido').where('name', isEqualTo: item.name).get();

        if (resolvedSnapshot.docs.isEmpty && partialSnapshot.docs.isEmpty && notResolvedSnapshot.docs.isEmpty) {
          activeFilesTemp.add({
            'name': item.name,
            'url': url,
            'latitude': fullMetadata.customMetadata?['latitude'] ?? 'N/A',
            'longitude': fullMetadata.customMetadata?['longitude'] ?? 'N/A',
            'observation': fullMetadata.customMetadata?['observation'] ?? '',
          });
        }
      }

      activeFiles.assignAll(activeFilesTemp);
      hasData.value = activeFilesTemp.isNotEmpty;
      isLoading.value = false;
    } catch (e) {
      print('Erro ao listar arquivos: $e');
      isLoading.value = false;
    }
  }

  void navigateToEditPage(String imageUrl, String latitude, String longitude, String name, String observation) {
    Get.to(() => EditImagePage(
          imageUrl: imageUrl,
          latitude: latitude,
          longitude: longitude,
          name: name,
          observation: observation,
        ));
  }
}
