import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';
import '../providers/cart_providers.dart';
import '../screens/cart_screen.dart';

class CartIconBadge extends ConsumerWidget {
  const CartIconBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = ref.watch(cartViewModelProvider.select((state) => state.totalItems));
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: colors.textPrimary,
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
          if (totalItems > 0)
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10)
                ),
                constraints: const BoxConstraints(
                  minWidth: 16, minHeight: 16
                ),
                child: Text(
                  '$totalItems',
                  style: typography.caption.copyWith(color: colors.background),
                  textAlign: TextAlign.center
                ),
              ),
            ),
        ],
      ),
    );
  }
}