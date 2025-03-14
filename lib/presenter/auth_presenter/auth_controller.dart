import 'package:flutter/material.dart';
import '../../../../data/repository/firebase_auth_repository.dart';
import '../home/home_page_admin.dart';
import 'package:get/get.dart';

class CreateAccountController extends GetxController {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;

  Future<void> registerUser(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Erro', 'As senhas não correspondem',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final message = await _authService.registration(
      email: emailController.text,
      password: passwordController.text,
      nome: nameController.text,
      cpf: cpfController.text,
    );
    isLoading.value = false;

    if (message!.contains('Success')) {
      Get.offAll(() => HomePageAdmin());
    }
    Get.snackbar('Status', message, snackPosition: SnackPosition.BOTTOM);
  }
}