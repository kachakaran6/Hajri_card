import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

import '../../workers/repositories/workers_repository.dart';
import '../../projects/repositories/projects_repository.dart';
import '../../attendance/repositories/attendance_repository.dart';
import '../../auth/providers/auth_providers.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(authControllerProvider).valueOrNull;

    final workers = ref.watch(workersStreamProvider);
    final activeProject = ref.watch(activeProjectProvider);
    final projects = ref.watch(projectsStreamProvider);
    final attendance = ref.watch(attendanceStreamProvider(activeProject?.id));

    final presentCount = attendance
        .where(
          (a) =>
              a.status == 'Present' ||
              a.status == 'Half Day' ||
              a.status == 'Overtime',
        )
        .length;

    final lastBackPressTime = useState<DateTime?>(null);

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome header
                Text(
                  '${AppLocalizations.of(context)!.goodMorning},',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.fullName ?? 'Contractor',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Highlight metrics
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: "Today's Attendance",
                        value: '$presentCount / ${workers.length}',
                        icon: Icons.how_to_reg,
                        color: AppColors.primary,
                        isDark: isDark,
                        onTap: () => context.push('/attendance'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Active Projects',
                        value: '${projects.length}',
                        icon: Icons.business_center,
                        color: AppColors.warning,
                        isDark: isDark,
                        onTap: () => context.go('/projects'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Total Enrolled',
                        value: '${workers.length} Workers',
                        icon: Icons.people,
                        color: AppColors.success,
                        isDark: isDark,
                        onTap: () => context.go('/workers'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Generate Reports',
                        value: 'View Ledger',
                        icon: Icons.analytics,
                        color: AppColors.info,
                        isDark: isDark,
                        onTap: () => context.go('/reports'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Active Project context
                if (activeProject != null) ...[
                  Text(
                    'Current Active Project',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.domain,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        activeProject.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        activeProject.location ?? 'No location specified',
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go('/projects'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );}

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
