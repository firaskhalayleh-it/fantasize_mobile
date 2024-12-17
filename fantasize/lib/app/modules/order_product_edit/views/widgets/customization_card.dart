// lib/app/modules/order_product_edit/views/widgets/customization_card.dart

import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/modules/order_history/controllers/order_product_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared_widgets.dart';

class CustomizationCard extends StatelessWidget {
  final OrderProductEditController controller;

  const CustomizationCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Customizations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                InfoButton(
                  onTap: () => _showCustomizationInfo(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.orderedCustomizations.isEmpty) {
                return const ErrorState(
                  message: 'No customization options available',
                  icon: Icons.brush_outlined,
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.orderedCustomizations.length,
                itemBuilder: (context, index) {
                  final customization = controller.orderedCustomizations[index];
                  return _CustomizationSection(
                    customization: customization,
                    controller: controller,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCustomizationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customization Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'Customize your order with various options like size, color, or special instructions. '
            'Each customization may affect the final price of your order.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _CustomizationSection extends StatelessWidget {
  final OrderedCustomization customization;
  final OrderProductEditController controller;

  const _CustomizationSection({
    Key? key,
    required this.customization,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: customization.selectedOptions.map((option) {
        switch (option.type.toLowerCase()) {
          case 'button':
          case 'color':
            return _SelectionOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          case 'attachmessage':
            return _MessageOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          case 'uploadpicture':
            return _ImageUploadOption(
              option: option,
              customizationId: customization.orderedCustomizationId,
              controller: controller,
            );
          default:
            return const SizedBox();
        }
      }).toList(),
    );
  }
}

class _SelectionOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _SelectionOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: option.optionValues.map((value) {
            return Obx(() => ChoiceChip(
              label: Text(value.value),
              selected: value.isSelected.value,
              onSelected: (selected) {
                controller.updateSelectedOption(
                  customizationId,
                  option.name,
                  value.value,
                );
              },
              selectedColor: Colors.redAccent.withOpacity(0.2),
            ));
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MessageOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _MessageOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = controller.getTextController(
      customizationId,
      option.name,
    );
    final isVisible = controller.getAttachMessageVisibility(
      customizationId,
      option.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(option.name),
          trailing: IconButton(
            icon: Obx(() => Icon(
              isVisible.value ? Icons.expand_less : Icons.expand_more,
            )),
            onPressed: () => controller.toggleAttachMessageVisibility(
              customizationId,
              option.name,
            ),
          ),
        ),
        Obx(() {
          if (!isVisible.value) return const SizedBox();
          return TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter your message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
            maxLines: 3,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ImageUploadOption extends StatelessWidget {
  final OrderedOption option;
  final int customizationId;
  final OrderProductEditController controller;

  const _ImageUploadOption({
    Key? key,
    required this.option,
    required this.customizationId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePath = controller.getUploadedImagePath(
      customizationId,
      option.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (imagePath.value.isEmpty) {
              return const ErrorState(
                message: 'No image uploaded',
                icon: Icons.image_outlined,
              );
            }
            return Column(
              children: [
                const Icon(Icons.image, size: 48, color: Colors.redAccent),
                const SizedBox(height: 8),
                Text(
                  imagePath.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}