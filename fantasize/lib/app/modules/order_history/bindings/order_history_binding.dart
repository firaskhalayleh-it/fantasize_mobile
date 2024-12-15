import 'package:get/get.dart';

import 'package:fantasize/app/modules/order_history/controllers/order_edit_controller.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_package_edit_controller.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';

import '../controllers/order_history_controller.dart';

class OrderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderPackageEditController>(
      () => OrderPackageEditController(),
    );
    Get.lazyPut<OrderProductEditController>(
      () => OrderProductEditController(),
    );
    Get.lazyPut<OrderEditController>(
      () => OrderEditController(),
    );
    Get.lazyPut<OrderHistoryController>(
      () => OrderHistoryController(),
    );
  }
}
