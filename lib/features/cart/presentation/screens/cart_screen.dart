import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';

import '../providers/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartViewModelProvider);
    final cartViewModel = ref.read(cartViewModelProvider.notifier);
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);

    return VillaPageTemplate(
      appBar: VillaHeader(
        title: 'My cart',
        actions: [
          if (cartState.items.isNotEmpty)
            VillaIconButton(
              icon: Icons.delete_outline, 
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text(
                        'Confirm elimination',
                        style: typography.h3,
                      ),
                      content: Text(
                        'Are you sure you want to empty the cart?',
                        style: typography.body,
                      ),
                      actions: <Widget>[
                        VillaTextButton(
                          text: 'Cancel',
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); 
                          },
                        ),
                        VillaTextButton(
                          text: 'Delete',
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            cartViewModel.clearCart();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            )
        ],
      ),
      body: cartState.items.isEmpty
          ? Center(
              child: Text(
              'Your cart is empty',
              style: typography.h3,
              )
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return ListTile(
                        leading: Image.network(item.product.image, width: 50, height: 50),
                        title: Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VillaIconButton(
                              icon: Icons.remove_circle_outline,
                              onPressed: () => cartViewModel.updateQuantity(item.product.id, item.quantity - 1),
                            ),
                            Text('${item.quantity}', style: typography.bodyLarge),
                            VillaIconButton(
                              icon: Icons.add_circle_outline,
                              onPressed: () => cartViewModel.updateQuantity(item.product.id, item.quantity + 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}