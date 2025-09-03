import 'dart:convert';
import 'dart:math' as math;
import 'spannable_grid_cell_data.dart';

/// 网格布局导入导出工具类
/// 提供便捷的方法来处理网格布局的序列化和反序列化
class SpannableGridLayoutUtils {
  /// 将网格布局数据导出为 JSON 字符串
  ///
  /// [columns] 网格列数
  /// [rows] 网格行数
  /// [cells] 单元格数据列表
  /// [metadata] 可选的额外元数据
  static String exportLayout({
    required int columns,
    required int rows,
    required List<SpannableGridCellData> cells,
    Map<String, dynamic>? metadata,
  }) {
    final layoutData = {
      'columns': columns,
      'rows': rows,
      'cells': cells.map((cell) => cell.toJson()).toList(),
      'version': '1.0',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (metadata != null) 'metadata': metadata,
    };
    return jsonEncode(layoutData);
  }

  /// 从 JSON 字符串导入网格布局数据
  ///
  /// 返回包含布局信息的 SpannableGridLayout 对象
  /// 如果 JSON 格式无效将抛出 FormatException
  static SpannableGridLayout importLayout(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!jsonData.containsKey('columns') ||
          !jsonData.containsKey('rows') ||
          !jsonData.containsKey('cells')) {
        throw FormatException('无效的 JSON 格式：缺少必要的字段');
      }

      final columns = jsonData['columns'] as int;
      final rows = jsonData['rows'] as int;
      final cellsData = jsonData['cells'] as List<dynamic>;

      final cells = cellsData
          .map((cellJson) =>
              SpannableGridCellData.fromJson(cellJson as Map<String, dynamic>))
          .toList();

      return SpannableGridLayout(
        columns: columns,
        rows: rows,
        cells: cells,
        version: jsonData['version'] as String?,
        timestamp: jsonData['timestamp'] as int?,
        metadata: jsonData['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw FormatException('解析 JSON 时出错：$e');
    }
  }

  /// 验证网格布局是否有效
  ///
  /// 检查单元格是否超出网格边界、是否重叠等
  static ValidationResult validateLayout(SpannableGridLayout layout) {
    final errors = <String>[];
    final warnings = <String>[];

    // 检查网格尺寸
    if (layout.columns <= 0 || layout.rows <= 0) {
      errors.add('网格尺寸必须大于 0');
    }

    // 创建占用矩阵来检查重叠
    final occupied = List.generate(
        layout.rows, (row) => List.generate(layout.columns, (col) => false));

    for (final cell in layout.cells) {
      // 检查边界
      if (cell.column < 1 || cell.row < 1) {
        errors.add('单元格 ${cell.id} 的位置不能小于 1');
        continue;
      }

      if (cell.column + cell.columnSpan - 1 > layout.columns ||
          cell.row + cell.rowSpan - 1 > layout.rows) {
        errors.add('单元格 ${cell.id} 超出网格边界');
        continue;
      }

      // 检查跨度
      if (cell.columnSpan < 1 || cell.rowSpan < 1) {
        errors.add('单元格 ${cell.id} 的跨度必须大于 0');
        continue;
      }

      // 检查重叠
      for (int r = cell.row - 1; r < cell.row + cell.rowSpan - 1; r++) {
        for (int c = cell.column - 1;
            c < cell.column + cell.columnSpan - 1;
            c++) {
          if (occupied[r][c]) {
            errors.add('单元格 ${cell.id} 与其他单元格重叠在位置 (${c + 1}, ${r + 1})');
          } else {
            occupied[r][c] = true;
          }
        }
      }
    }

    // 检查空置率
    final totalCells = layout.columns * layout.rows;
    final occupiedCells = occupied.fold<int>(
        0, (sum, row) => sum + row.where((cell) => cell).length);
    final occupancyRate = occupiedCells / totalCells;

    if (occupancyRate < 0.3) {
      warnings.add('网格占用率较低 (${(occupancyRate * 100).toStringAsFixed(1)}%)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      occupancyRate: occupancyRate,
    );
  }

  /// 合并两个网格布局
  ///
  /// 将 [other] 布局合并到 [base] 布局中
  /// 可以指定偏移量来避免重叠
  static SpannableGridLayout mergeLayouts(
    SpannableGridLayout base,
    SpannableGridLayout other, {
    int columnOffset = 0,
    int rowOffset = 0,
    String? idPrefix,
  }) {
    final mergedCells = List<SpannableGridCellData>.from(base.cells);

    for (final cell in other.cells) {
      final newCell = cell.copyWith(
        id: idPrefix != null ? '${idPrefix}_${cell.id}' : cell.id,
        column: cell.column + columnOffset,
        row: cell.row + rowOffset,
      );
      mergedCells.add(newCell);
    }

    final newColumns = math.max(base.columns, other.columns + columnOffset);
    final newRows = math.max(base.rows, other.rows + rowOffset);

    return SpannableGridLayout(
      columns: newColumns,
      rows: newRows,
      cells: mergedCells,
      version: base.version,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      metadata: {
        ...?base.metadata,
        'merged_from': [
          base.metadata?['source'] ?? 'base',
          other.metadata?['source'] ?? 'other'
        ],
      },
    );
  }
}

/// 网格布局数据类
/// 包含完整的网格布局信息
class SpannableGridLayout {
  const SpannableGridLayout({
    required this.columns,
    required this.rows,
    required this.cells,
    this.version,
    this.timestamp,
    this.metadata,
  });

  final int columns;
  final int rows;
  final List<SpannableGridCellData> cells;
  final String? version;
  final int? timestamp;
  final Map<String, dynamic>? metadata;

  /// 转换为 JSON 字符串
  String toJson() => SpannableGridLayoutUtils.exportLayout(
        columns: columns,
        rows: rows,
        cells: cells,
        metadata: metadata,
      );

  /// 从 JSON 字符串创建布局
  static SpannableGridLayout fromJson(String jsonString) =>
      SpannableGridLayoutUtils.importLayout(jsonString);

  /// 验证布局有效性
  ValidationResult validate() => SpannableGridLayoutUtils.validateLayout(this);

  /// 创建布局副本
  SpannableGridLayout copyWith({
    int? columns,
    int? rows,
    List<SpannableGridCellData>? cells,
    String? version,
    int? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return SpannableGridLayout(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      cells: cells ?? this.cells,
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 验证结果类
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.occupancyRate,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final double occupancyRate;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('布局验证结果:');
    buffer.writeln('有效性: ${isValid ? "有效" : "无效"}');
    buffer.writeln('占用率: ${(occupancyRate * 100).toStringAsFixed(1)}%');

    if (errors.isNotEmpty) {
      buffer.writeln('错误:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('警告:');
      for (final warning in warnings) {
        buffer.writeln('  - $warning');
      }
    }

    return buffer.toString();
  }
}
