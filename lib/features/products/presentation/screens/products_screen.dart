import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/widgets/cart_icon_badge.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_providers.dart';
import 'package:ecommerce_app/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_card.dart';
import 'package:ecommerce_app/features/support/presentation/screens/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(productsViewModelProvider);
      if (currentState.allProducts.isEmpty) {
        ref.read(productsViewModelProvider.notifier).loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsViewModelProvider);
    final viewModel = ref.read(productsViewModelProvider.notifier);
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);

    return VillaPageTemplate(
      appBar: VillaHeader(
        title: 'Product catalog',
        actions: [
          const CartIconBadge(),
          VillaIconButton(
            icon: Icons.refresh,
            color: colors.textPrimary,
            onPressed: state.isLoading
            ? null
            : () {
              viewModel.filterByCategory(null);
              viewModel.loadProducts();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  ref.read(authViewModelProvider.notifier).logout();
                  break;
                case 'support':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'support',
                child: Text('Support'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                VillaSearchBar(
                  controller: _searchController,
                  hintText: 'Search products...',
                  onChanged: (value){
                    ref.read(productsViewModelProvider.notifier).search(value);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: Text('All', style: typography.body.copyWith(color: colors.textPrimary)),
                        selectedColor: colors.secondary,
                        selected: state.selectedCategory == null,
                        onSelected: (_) => viewModel.filterByCategory(null),
                      ),
                      const SizedBox(width: 8),
                      ...state.categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category, style: typography.body.copyWith(color: colors.textPrimary)),
                          selectedColor: colors.secondary,
                          selected: state.selectedCategory == category,
                          onSelected: (_) => viewModel.filterByCategory(category),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductsState state) {
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);
    if (state.isLoading) {
      return const Center(child: CustomLoading());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            VillaElevatedButton(
              onPressed: () {
                ref.read(productsViewModelProvider.notifier).loadProducts();
              },
              text: 'Retry',
            )
          ],
        ),
      );
    }

    if (state.filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'No products were found',
          style: typography.bodyLarge,
        )
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(productsViewModelProvider.notifier).loadProducts(),
      backgroundColor: colors.background,
      color: colors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 430,
        ),
        itemCount: state.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = state.filteredProducts[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}