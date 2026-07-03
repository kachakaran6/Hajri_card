import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

class MainNavigationShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final router = GoRouter.of(context);
        
        // Check if the current tab's nested stack can pop (i.e. has more than 1 route)
        if (router.canPop()) {
          router.pop();
          return;
        }

        // If we cannot pop the nested stack, check if we are on a non-Home tab
        if (widget.navigationShell.currentIndex != 0) {
          // Switch to Home tab
          widget.navigationShell.goBranch(0);
          return;
        }

        // If we are on the Home tab root, require double back press to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('બહાર નીકળવા માટે ફરીથી પાછળ દબાવો'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Second press within 2 seconds -> Exit app
        SystemNavigator.pop();
      },
      child: Scaffold(
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
                label: AppLocalizations.of(context)!.todaysLabour, // matches dashboard tab
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
                label: AppLocalizations.of(context)!.chooseLanguage.split(' ').last, // Simple locale tab label
              ),
            ],
          ),
        ),
      ),
    );
  }
}
