import 'package:get/get.dart';

import '../../../../data/services/employee_service.dart';
import '../../../../presentation/recognition/controllers/recognition.controller.dart';

class RecognitionControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EmployeeService>(EmployeeService(), permanent: true);
    Get.lazyPut<RecognitionController>(
      // Ensure EmployeeService is available
      () => RecognitionController(),
    );
  }
}
