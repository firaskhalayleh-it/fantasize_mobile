// lib/app/modules/home/views/search_view.dart

import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as custom;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final custom.SearchController searchController = Get.put(custom.SearchController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController optionNameController = TextEditingController();
  final TextEditingController offerDiscountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Product Search',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Clear all fields
              nameController.clear();
              categoryController.clear();
              subCategoryController.clear();
              materialController.clear();
              brandController.clear();
              minPriceController.clear();
              maxPriceController.clear();
              optionNameController.clear();
              offerDiscountController.clear();
              searchController.resetSearch();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.redAccent.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchHeader(),
              SizedBox(height: 24),
              _buildSearchForm(),
              SizedBox(height: 24),
              _buildSearchButton(),
              SizedBox(height: 24),
              _buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your Perfect Product',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Use the filters below to narrow down your search',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(
              title: 'Basic Information',
              children: [
                _buildSearchField(
                  controller: nameController,
                  label: 'Product Name',
                  icon: Icons.shopping_bag,
                  onChanged: (value) => searchController.name.value = value,
                ),
                SizedBox(height: 16),
                _buildSearchField(
                  controller: brandController,
                  label: 'Brand',
                  icon: Icons.branding_watermark,
                  onChanged: (value) => searchController.brand.value = value,
                ),
              ],
            ),
            _buildDivider(),
            _buildSearchSection(
              title: 'Categories',
              children: [
                _buildSearchField(
                  controller: categoryController,
                  label: 'Category',
                  icon: Icons.category,
                  onChanged: (value) => searchController.categoryName.value = value,
                ),
                SizedBox(height: 16),
                _buildSearchField(
                  controller: subCategoryController,
                  label: 'Subcategory',
                  icon: Icons.subdirectory_arrow_right,
                  onChanged: (value) => searchController.subCategoryName.value = value,
                ),
              ],
            ),
            _buildDivider(),
            _buildSearchSection(
              title: 'Product Details',
              children: [
                _buildSearchField(
                  controller: materialController,
                  label: 'Material',
                  icon: Icons.texture,
                  onChanged: (value) => searchController.materialName.value = value,
                ),
                SizedBox(height: 16),
                _buildSearchField(
                  controller: optionNameController,
                  label: 'Option Name',
                  icon: Icons.list_alt,
                  onChanged: (value) => searchController.optionName.value = value,
                ),
              ],
            ),
            _buildDivider(),
            _buildSearchSection(
              title: 'Price Range',
              children: [
                _buildPriceFields(),
              ],
            ),
            _buildDivider(),
            _buildSearchSection(
              title: 'Offers',
              children: [
                _buildOfferFields(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.redAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: minPriceController,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                searchController.minPrice.value = int.tryParse(value) ?? 0,
            decoration: InputDecoration(
              labelText: 'Min Price',
              prefixIcon: Icon(Icons.attach_money, color: Colors.redAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: maxPriceController,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                searchController.maxPrice.value = int.tryParse(value) ?? 0,
            decoration: InputDecoration(
              labelText: 'Max Price',
              prefixIcon: Icon(Icons.attach_money, color: Colors.redAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferFields() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() {
                return Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: searchController.offerAvailable.value,
                    onChanged: (value) {
                      searchController.offerAvailable.value = value ?? false;
                      if (!value!) {
                        searchController.offerDiscount.value = 0;
                        offerDiscountController.clear();
                      }
                    },
                    activeColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
              SizedBox(width: 8),
              Text(
                'Offer Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            return AnimatedOpacity(
              opacity: searchController.offerAvailable.value ? 1.0 : 0.5,
              duration: Duration(milliseconds: 200),
              child: TextFormField(
                enabled: searchController.offerAvailable.value,
                controller: offerDiscountController,
                keyboardType: TextInputType.number,
                onChanged: (value) => searchController.offerDiscount.value =
                    int.tryParse(value) ?? 0,
                decoration: InputDecoration(
                  labelText: 'Minimum Discount (%)',
                  prefixIcon: Icon(Icons.percent, color: Colors.redAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: Colors.grey[300]),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          searchController.resetSearch();
          searchController.name.value = nameController.text.trim();
          searchController.categoryName.value = categoryController.text.trim();
          searchController.subCategoryName.value = subCategoryController.text.trim();
          searchController.materialName.value = materialController.text.trim();
          searchController.brand.value = brandController.text.trim();
          searchController.optionName.value = optionNameController.text.trim();
          searchController.offerDiscount.value =
              searchController.offerAvailable.value
                  ? int.tryParse(offerDiscountController.text.trim()) ?? 0
                  : 0;
          searchController.performSearch();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 24),
            SizedBox(width: 8),
            Text(
              'Search Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Builds the search results section
  Widget _buildSearchResults() {
    return Obx(() {
      if (searchController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      } else if (searchController.searchResults.isEmpty) {
        return Center(child: Text('No results found.'));
      } else {
        // Calculate grid items height
        int itemCount = searchController.searchResults.length;
        int rowCount = (itemCount / 2).ceil(); // 2 is the crossAxisCount
        double itemHeight =
            (Get.width / 2) * (1 / 0.75); // Based on childAspectRatio
        double gridHeight = rowCount * itemHeight;

        return Column(
          children: [
            Container(
              height: gridHeight,
              child: GridView.builder(
                padding: EdgeInsets.all(2.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.52,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 1.0,
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: searchController.searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchController.searchResults[index];
                  if (item is Product) {
                    return _buildProductItem(item);
                  } else if (item is Package) {
                    return _buildPackageItem(item);
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
            // Pagination Button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                searchController.loadMore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Load More', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      }
    });
  }


Widget _buildProductItem(Product product) {
  return Container(
    margin: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () {
          // Navigate to product details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Offer Badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Hero(
                    tag: 'product-${product.productId}',
                    child: Image.network(
                      ImageHandler.getImageUrl(product.resources),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (product.offer != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${product.offer!.discount}% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content Section with Gradient Overlay
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (product.discountPrice != null) ...[
                        Text(
                          '\$${product.discountPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '\$${double.parse(product.price).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ] else
                        Text(
                          '\$${double.parse(product.price).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        product.avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${product.reviews.length})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.quantity > 0
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.quantity > 0 ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                product.quantity > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPackageItem(Package package) {
  return Container(
    margin: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () {
          // Navigate to package details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Package Badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Hero(
                    tag: 'package-${package.packageId}',
                    child: Image.network(
                      ImageHandler.getImageUrl(package.resources),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
               
                  
                 
                if (package.offer != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SAVE ${package.offer!.discount}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content Section
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${package.packageProducts.length} Products Inside',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${package.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            package.avgRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: package.quantity > 0
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      package.quantity > 0 ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        color: package.quantity > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
