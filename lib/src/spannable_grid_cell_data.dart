import 'package:flutter/widgets.dart';
import 'dart:convert';

/// A metadata that defines an item (cell) of [SpannableGrid].
///
/// The item [id] is required and must be unique within the grid widget.
/// Item is positioned to [column] and [row] withing the grid and span
/// [columnSpan] and [rowSpan] cells. By default, the grid item occupies
/// a single cell.
/// The content of the cell is determined by the [child] widget.
///
/// ```dart
/// List<SpannableGridCellData> cells = List();
/// cells.add(SpannableGridCellData(
///   column: 1,
///   row: 1,
///   columnSpan: 2,
///   rowSpan: 2,
///   id: "Test Cell 1",
///   child: Container(
///     color: Colors.lime,
///     child: Center(
///       child: Text("Tile 2x2",
///         style: Theme.of(context).textTheme.title,
///       ),
///      ),
///   ),
/// ));
/// cells.add(SpannableGridCellData(
///   column: 4,
///   row: 1,
///   id: "Test Cell 2",
///   child: Container(
///     color: Colors.lime,
///     child: Center(
///       child: Text("Tile 1x1",
///         style: Theme.of(context).textTheme.title,
///       ),
///     ),
///   ),
/// ));
/// ```
class SpannableGridCellData {
  SpannableGridCellData(
      {required this.id,
      this.child,
      required this.column,
      required this.row,
      this.columnSpan = 1,
      this.rowSpan = 1});

  Object id;
  Widget? child;
  int column;
  int row;
  int columnSpan;
  int rowSpan;

  /// 将单元格数据转换为 JSON Map
  /// 注意：由于 Widget 无法序列化，只导出布局信息，不包含 child
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'column': column,
      'row': row,
      'columnSpan': columnSpan,
      'rowSpan': rowSpan,
    };
  }

  /// 从 JSON Map 创建单元格数据
  /// 注意：child 需要在创建后单独设置
  static SpannableGridCellData fromJson(Map<String, dynamic> json) {
    return SpannableGridCellData(
      id: json['id'],
      column: json['column'],
      row: json['row'],
      columnSpan: json['columnSpan'] ?? 1,
      rowSpan: json['rowSpan'] ?? 1,
    );
  }

  /// 创建单元格数据的副本
  SpannableGridCellData copyWith({
    Object? id,
    Widget? child,
    int? column,
    int? row,
    int? columnSpan,
    int? rowSpan,
  }) {
    return SpannableGridCellData(
      id: id ?? this.id,
      child: child ?? this.child,
      column: column ?? this.column,
      row: row ?? this.row,
      columnSpan: columnSpan ?? this.columnSpan,
      rowSpan: rowSpan ?? this.rowSpan,
    );
  }
}
