import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hajriapp/core/widgets/main_navigation_shell.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

void main() {
  testWidgets('Navigation back button behavior test', (WidgetTester tester) async {
    // 1. Setup mock router
    final router = GoRouter(
      initialLocation: '/workers',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const Scaffold(body: Text('Home Screen')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/workers',
                  builder: (context, state) => const Scaffold(body: Text('Workers List')),
                  routes: [
                    GoRoute(
                      path: 'details',
                      builder: (context, state) => const Scaffold(body: Text('Worker Details')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify we are on workers list
    expect(find.text('Workers List'), findsOneWidget);

    // Push details
    router.go('/workers/details');
    await tester.pumpAndSettle();
    expect(find.text('Worker Details'), findsOneWidget);

    // Press back from details -> should go back to workers list
    // A back press is triggered via binding.handlePopRoute()
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Workers List'), findsOneWidget);
    expect(find.text('Worker Details'), findsNothing);

    // Press back from workers list root -> should go to Home tab
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);

    // Press back from Home tab root -> should show Toast and not exit
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    
    // It should still be on Home Screen, and show a snackbar (Toast)
    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
