// order package edit binding
import 'package:get/get.dart';

import '../../order_history/controllers/order_package_edit_controller.dart';

class OrderPackageEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderPackageEditController>(
      () => OrderPackageEditController(),
    );
  }
}
