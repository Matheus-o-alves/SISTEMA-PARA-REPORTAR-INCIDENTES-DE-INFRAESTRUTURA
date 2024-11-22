import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reporta_ufop/ui/pages/admin/home/home_page_admin.dart';

import 'firebase_options.dart';
import 'ui/pages/admin/auth/login_page_admin.dart';
import 'ui/pages/student/auth/login_page_student.dart';

void main()async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Login',
      initialRoute: kIsWeb ? '/login-admin' : '/login-student',
      getPages: kIsWeb ? _getAdminPages() : _getStudentPages(),
    );
 
  }
}
  List<GetPage> _getStudentPages() {
    return [
      GetPage(name: '/login-student', page: () => LoginPageStudent()),
      // Adicione outras rotas de estudante aqui
    ];
  }

  List<GetPage> _getAdminPages() {
    return [
      GetPage(name: '/login-admin', page: () => LoginPageAdmin()),
      // Adicione outras rotas de admin aqui
    ];
  }

