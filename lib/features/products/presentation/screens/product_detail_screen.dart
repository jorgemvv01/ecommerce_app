import 'package:collection/collection.dart';
import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);
  
    final cartState = ref.watch(cartViewModelProvider);
    final cartViewModel = ref.read(cartViewModelProvider.notifier);
  
    final cartItem = cartState.items.firstWhereOrNull(
      (item) => item.product.id == product.id
    );

    return VillaPageTemplate(
      appBar: VillaHeader(
        title: product.title,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colors.surface,
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CustomLoading());
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                product.title,
                style: typography.h3,
              ),
              const SizedBox(height: 8),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    Icon(
                      i < product.rating.rate.round() ? Icons.star : Icons.star_border,
                      color: colors.secondary,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.rating.rate} (${product.rating.count} reviews)',
                    style: typography.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Description', style: typography.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: typography.bodyLarge.copyWith(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: cartItem == null
                    ? VillaElevatedButton(
                        text: 'Add to cart',
                        onPressed: () {
                          cartViewModel.addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: colors.primary,
                              content: Text(
                                '${product.title} added.',
                                style: typography.bodyLarge.copyWith(color: colors.background),
                              ),
                              duration: const Duration(seconds: 1)),
                          );
                        },
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VillaIconButton(
                            icon: Icons.remove,
                            onPressed: () => cartViewModel.updateQuantity(product.id, cartItem.quantity - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              '${cartItem.quantity}',
                              style: typography.h3,
                            ),
                          ),
                          VillaIconButton(
                            icon: Icons.add,
                            onPressed: () => cartViewModel.updateQuantity(product.id, cartItem.quantity + 1),
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
