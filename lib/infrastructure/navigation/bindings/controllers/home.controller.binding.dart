import 'package:get/get.dart';

import '../../../../data/services/dashboard_service.dart';
import '../../../../presentation/home/controllers/home.controller.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardService>(() => DashboardService());
  }
}
