import 'package:get/get.dart';

import '../../../../presentation/confirmation/controllers/confirmation.controller.dart';

class ConfirmationControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmationController>(() => ConfirmationController());
  }
}
