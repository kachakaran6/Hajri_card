import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

class MainNavigationShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          int currentIndex = widget.navigationShell.currentIndex;
          if (details.primaryVelocity! > 300) {
            // Swipe Right -> Go Left (Previous tab)
            if (currentIndex > 0) {
              widget.navigationShell.goBranch(currentIndex - 1);
            }
          } else if (details.primaryVelocity! < -300) {
            // Swipe Left -> Go Right (Next tab)
            if (currentIndex < 4) {
              widget.navigationShell.goBranch(currentIndex + 1);
            }
          }
        },
        child: widget.navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: AppLocalizations.of(
                context,
              )!.todaysLabour, // matches dashboard tab
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: AppLocalizations.of(context)!.allWorkers,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business_center_outlined),
              activeIcon: const Icon(Icons.business_center),
              label: AppLocalizations.of(context)!.projects,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics_outlined),
              activeIcon: const Icon(Icons.analytics),
              label: AppLocalizations.of(context)!.reports,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: AppLocalizations.of(
                context,
              )!.chooseLanguage.split(' ').last, // Simple locale tab label
            ),
          ],
        ),
      ),
    );
  }
}
