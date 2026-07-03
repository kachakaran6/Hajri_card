import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../models/project.dart';
import '../repositories/projects_repository.dart';
import 'package:hajriapp/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';

class ProjectsScreen extends HookConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsStreamProvider);
    final activeProject = ref.watch(activeProjectProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void showAddProjectSheet([Project? project]) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddProjectSheet(project: project),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.projects),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showAddProjectSheet(),
            ),
          ],
        ),
        body: projects.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_center_outlined,
                        size: 64,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noProjects,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: projects.length,
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final isActive = activeProject?.id == project.id;

                  return Slidable(
                    key: ValueKey(project.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => showAddProjectSheet(project),
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: AppLocalizations.of(context)!.edit,
                        ),
                        SlidableAction(
                          onPressed: (context) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.delete,
                                ),
                                content: Text(
                                  AppLocalizations.of(context)!.confirmDelete,
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      AppLocalizations.of(context)!.delete,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (isActive) {
                                ref.read(activeProjectProvider.notifier).state =
                                    null;
                              }
                              await ref
                                  .read(projectsRepositoryProvider)
                                  .deleteProject(project.id);
                              ref.invalidate(projectsStreamProvider);
                            }
                          },
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: AppLocalizations.of(context)!.delete,
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isActive
                              ? AppColors.primary
                              : isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business_center,
                            color: isActive ? Colors.white : AppColors.primary,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 16),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.active.toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            project.location ?? 'No location added',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        onTap: () {
                          ref.read(activeProjectProvider.notifier).state =
                              project;
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AddProjectSheet extends HookConsumerWidget {
  final Project? project;

  const AddProjectSheet({super.key, this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: project?.name);
    final locationController = useTextEditingController(
      text: project?.location,
    );
    final notesController = useTextEditingController(text: project?.notes);

    void handleSave() async {
      if (nameController.text.isEmpty) return;

      final updatedProject = Project(
        id: project?.id ?? const Uuid().v4(),
        contractorId: project?.contractorId ?? '',
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        notes: notesController.text.trim(),
        status: project?.status ?? 'Active',
      );

      final navigator = Navigator.of(context);
      await ref.read(projectsRepositoryProvider).saveProject(updatedProject);
      ref.invalidate(projectsStreamProvider);
      navigator.pop();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            project == null
                ? AppLocalizations.of(context)!.addProject
                : AppLocalizations.of(context)!.edit,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.projectName,
              prefixIcon: const Icon(Icons.business_center_outlined),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.location,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.notes,
              prefixIcon: const Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.save,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
