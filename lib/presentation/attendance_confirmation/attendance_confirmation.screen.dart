import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/attendance_confirmation.controller.dart';

class AttendanceConfirmationScreen
    extends GetView<AttendanceConfirmationController> {
  const AttendanceConfirmationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AttendanceConfirmationScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AttendanceConfirmationScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
