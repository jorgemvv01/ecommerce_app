import 'package:collection/collection.dart';
import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);

    final cartState = ref.watch(cartViewModelProvider);
    final cartViewModel = ref.read(cartViewModelProvider.notifier);

    final cartItem = cartState.items.firstWhereOrNull(
      (item) => item.product.id == product.id
    );
    return VillaActionCard(
      elevation: 4,
      actionText: 'Detail',
      onActionPressed: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      title: Text(
        product.title,
        style: typography.h3,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      description: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CustomLoading());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      product.description,
                      style: typography.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: typography.body,
                    ),
                    cartItem == null
                    ? VillaTextButton(
                        text: 'Add to cart',
                        onPressed: () => cartViewModel.addProduct(product),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VillaIconButton(
                            icon: Icons.remove_circle_outline,
                            onPressed: () => cartViewModel.updateQuantity(product.id, cartItem.quantity - 1),
                          ),
                          Expanded(
                            child: Text(
                              '${cartItem.quantity}',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          VillaIconButton(
                            icon: Icons.add_circle_outline,
                            onPressed: () => cartViewModel.updateQuantity(product.id, cartItem.quantity + 1),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}