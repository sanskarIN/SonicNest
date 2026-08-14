import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';

class LibraryFilterButton extends StatelessWidget {
  const LibraryFilterButton({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final active = controller.hasAdvancedLibraryFilters;
    return FloatingActionButton.extended(
      heroTag: 'library-advanced-filters',
      onPressed: () => _showFilters(context),
      icon: Icon(active ? Icons.filter_alt : Icons.filter_alt_outlined),
      label: Text(active ? 'Filters active' : 'More filters'),
    );
  }

  Future<void> _showFilters(BuildContext context) async {
    var tag = controller.tagFilter;
    var from = controller.dateFromFilter;
    var to = controller.dateToFilter;

    final apply = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                6,
                20,
                20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Advanced library filters',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    if (controller.tags.isNotEmpty)
                      DropdownButtonFormField<String?>(
                        initialValue: tag,
                        decoration: const InputDecoration(labelText: 'Tag'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Any tag'),
                          ),
                          ...controller.tags.toList()..sort(),
                        ].map((item) {
                          if (item is DropdownMenuItem<String?>) {
                            return item;
                          }
                          final value = item as String;
                          return DropdownMenuItem<String?>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setSheetState(() => tag = value),
                      )
                    else
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.label_outline),
                        title: Text('No tags available yet'),
                        subtitle: Text(
                          'Add tags to recordings to filter by them here.',
                        ),
                      ),
                    const SizedBox(height: 12),
                    _DateFilterTile(
                      title: 'From date',
                      value: from,
                      onChanged: (value) => setSheetState(() => from = value),
                    ),
                    _DateFilterTile(
                      title: 'To date',
                      value: to,
                      onChanged: (value) => setSheetState(() => to = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setSheetState(() {
                              tag = null;
                              from = null;
                              to = null;
                            });
                          },
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          label: const Text('Clear'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext, false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => Navigator.pop(sheetContext, true),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (apply != true) {
      return;
    }
    controller.setTagFilter(tag);
    controller.setDateRangeFilter(from, to);
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Any date'
        : '${value!.year.toString().padLeft(4, '0')}-'
            '${value!.month.toString().padLeft(2, '0')}-'
            '${value!.day.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(title),
      subtitle: Text(text),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (value != null)
            IconButton(
              tooltip: 'Clear $title',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.close),
            ),
          IconButton(
            tooltip: 'Choose $title',
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 366)),
              );
              if (selected != null) {
                onChanged(selected);
              }
            },
            icon: const Icon(Icons.edit_calendar_outlined),
          ),
        ],
      ),
    );
  }
}
