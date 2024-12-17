// lib/app/modules/order_product_edit/views/order_product_edit_view.dart

import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/product_card.dart';
import 'widgets/quantity_card.dart';
import 'widgets/customization_card.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/shared_widgets.dart';

class OrderProductEditView extends StatelessWidget {
  OrderProductEditView({Key? key}) : super(key: key);

  final OrderProductEditController controller =
      Get.put(OrderProductEditController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDiscardDialog(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingOverlay();
          }

          if (controller.orderProduct == null) {
            return const ErrorState(
              message: 'Failed to load order details',
              icon: Icons.error_outline,
            );
          }

          return Theme(
            data: Theme.of(context).copyWith(
              shadowColor: Colors.black.withOpacity(0.05),
              cardTheme: CardTheme(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildSection(
                  child: ProductCard(controller: controller),
                ),
                _buildSection(
                  child: QuantityCard(controller: controller),
                ),
                _buildSection(
                  child: CustomizationCard(controller: controller),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        }),
        bottomNavigationBar: BottomBar(controller: controller),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Edit Order Product',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black87),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () async {
          if (await showDiscardDialog(context) ?? false) {
            Get.back();
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () => showHelpSheet(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }
}

// Enhanced Product Card
class ProductCard extends StatelessWidget {
  final OrderProductEditController controller;

  const ProductCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = controller.orderProduct?.product;
    if (product == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Product Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusChip(
                        label: 'Order #${controller.orderId}',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            ImageHandler.getImageUrl(product.resources!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )),
                    )),
              ],
            ),
            if (product.description != null) ...[
              const SizedBox(height: 16),
              Text(
                product.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Enhanced Bottom Bar
class BottomBar extends StatelessWidget {
  final OrderProductEditController controller;

  const BottomBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: controller.saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
