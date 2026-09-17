import 'package:flutter/material.dart';

class EntityTableColumn<T> {
  final String label;
  final Widget Function(T item) build;
  final bool numeric;
  final double? width;

  const EntityTableColumn({
    required this.label,
    required this.build,
    this.numeric = false,
    this.width,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<EntityTableColumn<T>> columns;
  final List<T> items;

  const EntityTable({super.key, required this.columns, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: DataTable(
              columns: columns
                  .map(
                    (c) => DataColumn(label: Text(c.label), numeric: c.numeric),
                  )
                  .toList(),
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: columns
                          .map((c) => DataCell(c.build(item)))
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
