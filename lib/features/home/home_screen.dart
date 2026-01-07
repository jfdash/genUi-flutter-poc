// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/di/di.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Benvenuto in',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Insurance GenUI',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Preventivi assicurativi personalizzati\ncon AI generativa',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Demo Cards
              _buildDemoCard(
                context,
                icon: Icons.directions_car_rounded,
                title: 'Assicurazione Auto',
                description: 'Preventivo personalizzato con AI',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                onTap: () {
                  navigatorRepository.pushToRoute('/quote_chat');
                }
              ),
              
              const SizedBox(height: 16),
              
              _buildDemoCard(
                context,
                icon: Icons.home_rounded,
                title: 'Assicurazione Casa',
                description: 'Coming soon',
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                enabled: false,
              ),
              
              const SizedBox(height: 16),
              
              _buildDemoCard(
                context,
                icon: Icons.favorite_rounded,
                title: 'Assicurazione Salute',
                description: 'Coming soon',
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                ),
                enabled: false,
              ),
              
              const Spacer(),
              
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF4F46E5),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'POC dimostrativa - Dati non reali',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
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

  Widget _buildDemoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: enabled ? 4 : 0,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled 
                  ? Colors.transparent 
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: enabled ? gradient : null,
                  color: enabled ? null : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: enabled ? Colors.white : const Color(0xFF9CA3AF),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: enabled 
                            ? const Color(0xFF111827) 
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled 
                            ? const Color(0xFF6B7280) 
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: enabled 
                    ? const Color(0xFF4F46E5) 
                    : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

 
}