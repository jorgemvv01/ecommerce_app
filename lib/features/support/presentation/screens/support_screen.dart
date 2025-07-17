import 'package:flutter/material.dart';
import 'package:villa_design/villa_design.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);

    return VillaPageTemplate(
      appBar: const VillaHeader(
        title: 'Support & contact',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Get in touch',
            style: typography.h2,
          ),
          const SizedBox(height: 8),
          Text(
            'We are here to help you with any questions or issues you may have. Please feel free to reach out to us through any of the following methods.',
            style: typography.bodyLarge,
          ),
          const SizedBox(height: 24),
          VillaActionCard(
            title: Text('Email support', style: typography.h3),
            description: Text('support@ecommerceapp.com', style: typography.bodyLarge),
            actionText: 'Send us an email',
            onActionPressed: () {},
          ),
          const SizedBox(height: 16),
          VillaActionCard(
            title: Text('Phone support', style: typography.h3),
            description: Text('+1 (800) 555-0199', style: typography.bodyLarge),
            actionText: 'Call us at',
            onActionPressed: (){},
          ),
          const SizedBox(height: 16),
          VillaActionCard(
            title: Text('Live chat', style: typography.h3),
            description: Text('Available 24/7 on our website', style: typography.bodyLarge,),
            actionText: 'Write to us at',
            onActionPressed: () {},
          ),
        ],
      ),
    );
  }
}