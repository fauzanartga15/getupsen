import 'package:get/get.dart';

import '../../../../presentation/attendance_confirmation/controllers/attendance_confirmation.controller.dart';

class AttendanceConfirmationControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceConfirmationController>(
      () => AttendanceConfirmationController(),
    );
  }
}
