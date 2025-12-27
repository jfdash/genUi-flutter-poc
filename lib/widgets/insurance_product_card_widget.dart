import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InsuranceProduct {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const InsuranceProduct({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });
}

class InsuranceProductCard extends StatelessWidget {
  final InsuranceProduct product;
  final VoidCallback? onTap;

  const InsuranceProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: product.iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(product.icon, color: product.iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (product.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.subtitle,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}

class InsuranceProductsSection extends StatelessWidget {
  final List<InsuranceProduct> products;
  final String title;
  final VoidCallback? onViewAll;

  const InsuranceProductsSection({
    super.key,
    required this.products,
    this.title = 'Acquista o Richiedi',
    this.onViewAll,
  });

  static List<InsuranceProduct> get defaultProducts => [
    InsuranceProduct(
      title: 'Assicurazione Auto',
      subtitle: 'Per privati',
      icon: Icons.directions_car_rounded,
      iconBackground: AppColors.motorIconBg,
      iconColor: const Color(0xFF059669),
    ),
    InsuranceProduct(
      title: 'Assicurazione Salute',
      subtitle: 'Per aziende',
      icon: Icons.health_and_safety_rounded,
      iconBackground: AppColors.healthIconBg,
      iconColor: const Color(0xFF4F46E5),
    ),
    InsuranceProduct(
      title: 'Assicurazione Viaggio',
      subtitle: '',
      icon: Icons.flight_takeoff_rounded,
      iconBackground: AppColors.travelIconBg,
      iconColor: const Color(0xFFD97706),
    ),
    InsuranceProduct(
      title: 'Assicurazione Medica',
      subtitle: '',
      icon: Icons.local_hospital_rounded,
      iconBackground: AppColors.medicalIconBg,
      iconColor: const Color(0xFFDC2626),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'Vedi Tutti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return InsuranceProductCard(product: products[index], onTap: () {});
          },
        ),
      ],
    );
  }
}
