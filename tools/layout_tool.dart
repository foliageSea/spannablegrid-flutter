#!/usr/bin/env dart
// 一个简单的命令行工具来演示 SpannableGrid 的 JSON 导入导出功能

import 'dart:convert';
import 'dart:io';

// 模拟 SpannableGrid 相关类（用于演示）
class SpannableGridCellData {
  SpannableGridCellData({
    required this.id,
    required this.column,
    required this.row,
    this.columnSpan = 1,
    this.rowSpan = 1,
  });

  final String id;
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;

  Map<String, dynamic> toJson() => {
        'id': id,
        'column': column,
        'row': row,
        'columnSpan': columnSpan,
        'rowSpan': rowSpan,
      };

  static SpannableGridCellData fromJson(Map<String, dynamic> json) =>
      SpannableGridCellData(
        id: json['id'],
        column: json['column'],
        row: json['row'],
        columnSpan: json['columnSpan'] ?? 1,
        rowSpan: json['rowSpan'] ?? 1,
      );
}

class SpannableGridLayout {
  SpannableGridLayout({
    required this.columns,
    required this.rows,
    required this.cells,
    this.metadata,
  });

  final int columns;
  final int rows;
  final List<SpannableGridCellData> cells;
  final Map<String, dynamic>? metadata;

  String toJson() {
    final data = {
      'columns': columns,
      'rows': rows,
      'cells': cells.map((cell) => cell.toJson()).toList(),
      'version': '1.0',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (metadata != null) 'metadata': metadata,
    };
    return JsonEncoder.withIndent('  ').convert(data);
  }

  static SpannableGridLayout fromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final cells = (data['cells'] as List)
        .map((cellJson) => SpannableGridCellData.fromJson(cellJson))
        .toList();

    return SpannableGridLayout(
      columns: data['columns'],
      rows: data['rows'],
      cells: cells,
      metadata: data['metadata'],
    );
  }

  void printGrid() {
    // 创建网格矩阵来可视化布局
    final grid = List.generate(
      rows,
      (row) => List.generate(columns, (col) => '  ·  '),
    );

    // 填充单元格
    for (final cell in cells) {
      final symbol = cell.id.length > 3
          ? cell.id.substring(0, 3).toUpperCase()
          : cell.id.toUpperCase().padRight(3);

      for (int r = cell.row - 1; r < cell.row + cell.rowSpan - 1; r++) {
        for (int c = cell.column - 1;
            c < cell.column + cell.columnSpan - 1;
            c++) {
          if (r < rows && c < columns) {
            grid[r][c] = ' $symbol ';
          }
        }
      }
    }

    // 打印网格
    print('\n网格布局 (${columns}x$rows):');
    print('┌${'─────┬' * (columns - 1)}─────┐');

    for (int r = 0; r < rows; r++) {
      print('│${grid[r].join('│')}│');
      if (r < rows - 1) {
        print('├${'─────┼' * (columns - 1)}─────┤');
      }
    }

    print('└${'─────┴' * (columns - 1)}─────┘');

    // 打印单元格信息
    print('\n单元格详情:');
    for (final cell in cells) {
      print(
          '  ${cell.id}: (${cell.column},${cell.row}) 跨度=${cell.columnSpan}x${cell.rowSpan}');
    }

    if (metadata != null && metadata!.isNotEmpty) {
      print('\n元数据:');
      metadata!.forEach((key, value) {
        print('  $key: $value');
      });
    }
  }
}

void main(List<String> args) {
  if (args.isEmpty) {
    showUsage();
    return;
  }

  switch (args[0]) {
    case 'create':
      createSampleLayout();
      break;
    case 'view':
      if (args.length < 2) {
        print('错误: 请提供 JSON 文件路径');
        print('用法: dart layout_tool.dart view <json_file>');
        return;
      }
      viewLayout(args[1]);
      break;
    case 'validate':
      if (args.length < 2) {
        print('错误: 请提供 JSON 文件路径');
        print('用法: dart layout_tool.dart validate <json_file>');
        return;
      }
      validateLayout(args[1]);
      break;
    case 'convert':
      if (args.length < 3) {
        print('错误: 请提供输入和输出文件路径');
        print('用法: dart layout_tool.dart convert <input_file> <output_file>');
        return;
      }
      convertLayout(args[1], args[2]);
      break;
    default:
      print('错误: 未知命令 "${args[0]}"');
      showUsage();
  }
}

void showUsage() {
  print('SpannableGrid 布局工具');
  print('');
  print('用法:');
  print('  dart layout_tool.dart <command> [arguments]');
  print('');
  print('命令:');
  print('  create              创建示例布局文件');
  print('  view <json_file>    查看布局文件内容');
  print('  validate <json_file> 验证布局文件');
  print('  convert <input> <output> 转换布局文件格式');
  print('');
  print('示例:');
  print('  dart layout_tool.dart create');
  print('  dart layout_tool.dart view sample_layout.json');
  print('  dart layout_tool.dart validate my_layout.json');
}

void createSampleLayout() {
  // 创建示例布局
  final layout = SpannableGridLayout(
    columns: 4,
    rows: 3,
    cells: [
      SpannableGridCellData(
        id: 'header',
        column: 1,
        row: 1,
        columnSpan: 4,
        rowSpan: 1,
      ),
      SpannableGridCellData(
        id: 'sidebar',
        column: 1,
        row: 2,
        columnSpan: 1,
        rowSpan: 2,
      ),
      SpannableGridCellData(
        id: 'content',
        column: 2,
        row: 2,
        columnSpan: 3,
        rowSpan: 1,
      ),
      SpannableGridCellData(
        id: 'footer',
        column: 2,
        row: 3,
        columnSpan: 3,
        rowSpan: 1,
      ),
    ],
    metadata: {
      'name': '经典布局',
      'description': '包含标题、侧边栏、内容区和底部的经典网页布局',
      'author': 'SpannableGrid示例',
      'created': DateTime.now().toIso8601String(),
    },
  );

  final filename = 'sample_layout.json';
  final file = File(filename);
  file.writeAsStringSync(layout.toJson());

  print('✅ 示例布局已创建: $filename');
  layout.printGrid();
}

void viewLayout(String filename) {
  try {
    final file = File(filename);
    if (!file.existsSync()) {
      print('❌ 错误: 文件不存在: $filename');
      return;
    }

    final jsonString = file.readAsStringSync();
    final layout = SpannableGridLayout.fromJson(jsonString);

    print('📄 布局文件: $filename');
    layout.printGrid();
  } catch (e) {
    print('❌ 读取文件失败: $e');
  }
}

void validateLayout(String filename) {
  try {
    final file = File(filename);
    if (!file.existsSync()) {
      print('❌ 错误: 文件不存在: $filename');
      return;
    }

    final jsonString = file.readAsStringSync();
    final layout = SpannableGridLayout.fromJson(jsonString);

    print('🔍 验证布局: $filename');

    // 简单验证
    final errors = <String>[];
    final warnings = <String>[];

    // 检查网格尺寸
    if (layout.columns <= 0 || layout.rows <= 0) {
      errors.add('网格尺寸必须大于 0');
    }

    // 检查单元格边界和重叠
    final occupied = List.generate(
        layout.rows, (row) => List.generate(layout.columns, (col) => false));

    for (final cell in layout.cells) {
      // 边界检查
      if (cell.column < 1 || cell.row < 1) {
        errors.add('单元格 ${cell.id} 的位置不能小于 1');
        continue;
      }

      if (cell.column + cell.columnSpan - 1 > layout.columns ||
          cell.row + cell.rowSpan - 1 > layout.rows) {
        errors.add('单元格 ${cell.id} 超出网格边界');
        continue;
      }

      // 重叠检查
      for (int r = cell.row - 1; r < cell.row + cell.rowSpan - 1; r++) {
        for (int c = cell.column - 1;
            c < cell.column + cell.columnSpan - 1;
            c++) {
          if (occupied[r][c]) {
            errors.add('单元格 ${cell.id} 与其他单元格重叠');
          } else {
            occupied[r][c] = true;
          }
        }
      }
    }

    // 计算占用率
    final totalCells = layout.columns * layout.rows;
    final occupiedCells = occupied.fold<int>(
        0, (sum, row) => sum + row.where((cell) => cell).length);
    final occupancyRate = occupiedCells / totalCells;

    if (occupancyRate < 0.3) {
      warnings.add('网格占用率较低 (${(occupancyRate * 100).toStringAsFixed(1)}%)');
    }

    // 输出结果
    if (errors.isEmpty) {
      print('✅ 布局验证通过');
      print('📊 占用率: ${(occupancyRate * 100).toStringAsFixed(1)}%');
      print('📦 单元格数量: ${layout.cells.length}');
    } else {
      print('❌ 布局验证失败');
      for (final error in errors) {
        print('  • $error');
      }
    }

    if (warnings.isNotEmpty) {
      print('⚠️  警告:');
      for (final warning in warnings) {
        print('  • $warning');
      }
    }
  } catch (e) {
    print('❌ 验证失败: $e');
  }
}

void convertLayout(String inputFile, String outputFile) {
  try {
    final input = File(inputFile);
    if (!input.existsSync()) {
      print('❌ 错误: 输入文件不存在: $inputFile');
      return;
    }

    final jsonString = input.readAsStringSync();
    final layout = SpannableGridLayout.fromJson(jsonString);

    // 重新格式化 JSON
    final output = File(outputFile);
    output.writeAsStringSync(layout.toJson());

    print('✅ 布局文件已转换: $inputFile → $outputFile');
  } catch (e) {
    print('❌ 转换失败: $e');
  }
}
