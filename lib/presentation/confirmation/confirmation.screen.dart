import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:upsen_entrance/infrastructure/navigation/routes.dart';

import 'controllers/confirmation.controller.dart';

class ConfirmationScreen extends GetView<ConfirmationController> {
  const ConfirmationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConfirmationScreen'),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          children: [
            Text(
              'ConfirmationScreen is working',
              style: TextStyle(fontSize: 20),
            ),

            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(Routes.HOME);
              },
              child: Text("data"),
            ),
          ],
        ),
      ),
    );
  }
}
