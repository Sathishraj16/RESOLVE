import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // App Logo/Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 60,
                  color: AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Resolve',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Logistics Layer for Governance',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Spacer(),
              // Role Cards
              _RoleCard(
                icon: Icons.person,
                title: 'I''m a Citizen',
                subtitle: 'Report civic issues in your area',
                color: AppTheme.primaryOrange,
                onTap: () => context.push('/login', extra: 'citizen'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.engineering,
                title: 'I''m an Official',
                subtitle: 'Resolve complaints and manage tasks',
                color: AppTheme.primaryColor,
                onTap: () => context.push('/login', extra: 'official'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.admin_panel_settings,
                title: 'I''m an Administrator',
                subtitle: 'Monitor performance and analytics',
                color: AppTheme.mediumPriority,
                onTap: () => context.push('/login', extra: 'admin'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
