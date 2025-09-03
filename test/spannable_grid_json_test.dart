import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spannable_grid/spannable_grid.dart';

void main() {
  group('SpannableGrid JSON 导入导出测试', () {
    test('SpannableGridCellData JSON 序列化测试', () {
      // 创建测试数据
      final cellData = SpannableGridCellData(
        id: 'test_cell',
        column: 2,
        row: 3,
        columnSpan: 2,
        rowSpan: 1,
        child: Container(color: Colors.blue),
      );

      // 测试导出
      final json = cellData.toJson();
      expect(json['id'], equals('test_cell'));
      expect(json['column'], equals(2));
      expect(json['row'], equals(3));
      expect(json['columnSpan'], equals(2));
      expect(json['rowSpan'], equals(1));

      // 测试导入
      final importedCellData = SpannableGridCellData.fromJson(json);
      expect(importedCellData.id, equals('test_cell'));
      expect(importedCellData.column, equals(2));
      expect(importedCellData.row, equals(3));
      expect(importedCellData.columnSpan, equals(2));
      expect(importedCellData.rowSpan, equals(1));
      expect(importedCellData.child, isNull); // child 不会被序列化
    });

    test('SpannableGridLayout 创建和验证测试', () {
      // 创建测试布局
      final cells = [
        SpannableGridCellData(
          id: 'cell1',
          column: 1,
          row: 1,
          columnSpan: 2,
          rowSpan: 1,
        ),
        SpannableGridCellData(
          id: 'cell2',
          column: 1,
          row: 2,
          columnSpan: 1,
          rowSpan: 1,
        ),
      ];

      final layout = SpannableGridLayout(
        columns: 3,
        rows: 3,
        cells: cells,
        metadata: {'test': 'data'},
      );

      expect(layout.columns, equals(3));
      expect(layout.rows, equals(3));
      expect(layout.cells.length, equals(2));
      expect(layout.metadata?['test'], equals('data'));
    });

    test('SpannableGridLayoutUtils 导出测试', () {
      // 创建测试数据
      final cells = [
        SpannableGridCellData(
          id: 'header',
          column: 1,
          row: 1,
          columnSpan: 3,
          rowSpan: 1,
        ),
        SpannableGridCellData(
          id: 'content',
          column: 1,
          row: 2,
          columnSpan: 2,
          rowSpan: 1,
        ),
      ];

      // 测试导出
      final jsonString = SpannableGridLayoutUtils.exportLayout(
        columns: 3,
        rows: 2,
        cells: cells,
        metadata: {'name': 'test_layout'},
      );

      expect(jsonString, isA<String>());
      expect(jsonString.contains('"columns":3'), isTrue);
      expect(jsonString.contains('"rows":2'), isTrue);
      expect(jsonString.contains('header'), isTrue);
      expect(jsonString.contains('content'), isTrue);
    });

    test('SpannableGridLayoutUtils 导入测试', () {
      // 创建测试 JSON
      const jsonString = '''
      {
        "columns": 2,
        "rows": 2,
        "cells": [
          {
            "id": "test1",
            "column": 1,
            "row": 1,
            "columnSpan": 1,
            "rowSpan": 1
          },
          {
            "id": "test2",
            "column": 2,
            "row": 2,
            "columnSpan": 1,
            "rowSpan": 1
          }
        ],
        "version": "1.0",
        "metadata": {"test": true}
      }
      ''';

      // 测试导入
      final layout = SpannableGridLayoutUtils.importLayout(jsonString);

      expect(layout.columns, equals(2));
      expect(layout.rows, equals(2));
      expect(layout.cells.length, equals(2));
      expect(layout.version, equals('1.0'));
      expect(layout.metadata?['test'], equals(true));

      final firstCell = layout.cells.first;
      expect(firstCell.id, equals('test1'));
      expect(firstCell.column, equals(1));
      expect(firstCell.row, equals(1));
    });

    test('SpannableGridLayoutUtils 验证功能测试', () {
      // 测试有效布局
      final validLayout = SpannableGridLayout(
        columns: 3,
        rows: 3,
        cells: [
          SpannableGridCellData(
            id: 'cell1',
            column: 1,
            row: 1,
            columnSpan: 2,
            rowSpan: 1,
          ),
          SpannableGridCellData(
            id: 'cell2',
            column: 3,
            row: 1,
            columnSpan: 1,
            rowSpan: 2,
          ),
        ],
      );

      final validResult = SpannableGridLayoutUtils.validateLayout(validLayout);
      expect(validResult.isValid, isTrue);
      expect(validResult.errors, isEmpty);

      // 测试无效布局（重叠）
      final invalidLayout = SpannableGridLayout(
        columns: 2,
        rows: 2,
        cells: [
          SpannableGridCellData(
            id: 'cell1',
            column: 1,
            row: 1,
            columnSpan: 2,
            rowSpan: 1,
          ),
          SpannableGridCellData(
            id: 'cell2',
            column: 2,
            row: 1,
            columnSpan: 1,
            rowSpan: 1,
          ),
        ],
      );

      final invalidResult =
          SpannableGridLayoutUtils.validateLayout(invalidLayout);
      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.errors.isNotEmpty, isTrue);
    });

    test('SpannableGrid exportToJson 测试', () {
      // 创建测试网格
      final cells = [
        SpannableGridCellData(
          id: 'test',
          column: 1,
          row: 1,
          columnSpan: 1,
          rowSpan: 1,
          child: Container(),
        ),
      ];

      final grid = SpannableGrid(
        columns: 2,
        rows: 2,
        cells: cells,
      );

      // 测试导出
      final jsonString = grid.exportToJson();
      expect(jsonString, isA<String>());
      expect(jsonString.contains('"columns":2'), isTrue);
      expect(jsonString.contains('"rows":2'), isTrue);
      expect(jsonString.contains('test'), isTrue);
    });

    test('SpannableGrid importFromJson 测试', () {
      const jsonString = '''
      {
        "columns": 3,
        "rows": 2,
        "cells": [
          {
            "id": "imported_cell",
            "column": 2,
            "row": 1,
            "columnSpan": 2,
            "rowSpan": 1
          }
        ],
        "version": "1.0"
      }
      ''';

      // 测试导入
      final result = SpannableGrid.importFromJson(jsonString);

      expect(result['columns'], equals(3));
      expect(result['rows'], equals(2));
      expect(result['version'], equals('1.0'));

      final cells = result['cells'] as List<SpannableGridCellData>;
      expect(cells.length, equals(1));

      final cell = cells.first;
      expect(cell.id, equals('imported_cell'));
      expect(cell.column, equals(2));
      expect(cell.row, equals(1));
      expect(cell.columnSpan, equals(2));
      expect(cell.rowSpan, equals(1));
    });

    test('错误 JSON 格式处理测试', () {
      // 测试无效 JSON
      expect(
        () => SpannableGridLayoutUtils.importLayout('invalid json'),
        throwsA(isA<FormatException>()),
      );

      // 测试缺少必要字段的 JSON
      expect(
        () => SpannableGridLayoutUtils.importLayout('{"columns": 1}'),
        throwsA(isA<FormatException>()),
      );

      // 测试空字符串
      expect(
        () => SpannableGridLayoutUtils.importLayout(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('SpannableGridCellData copyWith 测试', () {
      final original = SpannableGridCellData(
        id: 'original',
        column: 1,
        row: 1,
        columnSpan: 2,
        rowSpan: 2,
        child: Container(),
      );

      final copied = original.copyWith(
        id: 'copied',
        column: 3,
      );

      expect(copied.id, equals('copied'));
      expect(copied.column, equals(3));
      expect(copied.row, equals(1)); // 保持不变
      expect(copied.columnSpan, equals(2)); // 保持不变
      expect(copied.rowSpan, equals(2)); // 保持不变
      expect(copied.child, equals(original.child)); // 保持不变
    });

    test('布局合并测试', () {
      final baseLayout = SpannableGridLayout(
        columns: 2,
        rows: 2,
        cells: [
          SpannableGridCellData(
            id: 'base1',
            column: 1,
            row: 1,
            columnSpan: 1,
            rowSpan: 1,
          ),
        ],
      );

      final otherLayout = SpannableGridLayout(
        columns: 2,
        rows: 2,
        cells: [
          SpannableGridCellData(
            id: 'other1',
            column: 1,
            row: 1,
            columnSpan: 1,
            rowSpan: 1,
          ),
        ],
      );

      final mergedLayout = SpannableGridLayoutUtils.mergeLayouts(
        baseLayout,
        otherLayout,
        columnOffset: 1,
        rowOffset: 0,
        idPrefix: 'merged',
      );

      expect(mergedLayout.cells.length, equals(2));
      expect(
          mergedLayout.columns, equals(3)); // base: 2, other: 2 + offset: 1 = 3

      final mergedCell = mergedLayout.cells.firstWhere(
        (cell) => cell.id == 'merged_other1',
      );
      expect(mergedCell.column, equals(2)); // 1 + offset: 1
      expect(mergedCell.row, equals(1));
    });
  });

  group('边界情况测试', () {
    test('最小网格尺寸测试', () {
      final layout = SpannableGridLayout(
        columns: 1,
        rows: 1,
        cells: [
          SpannableGridCellData(
            id: 'single',
            column: 1,
            row: 1,
            columnSpan: 1,
            rowSpan: 1,
          ),
        ],
      );

      final result = layout.validate();
      expect(result.isValid, isTrue);
      expect(result.occupancyRate, equals(1.0));
    });

    test('空网格测试', () {
      final layout = SpannableGridLayout(
        columns: 3,
        rows: 3,
        cells: [],
      );

      final result = layout.validate();
      expect(result.isValid, isTrue);
      expect(result.occupancyRate, equals(0.0));
      expect(result.warnings.isNotEmpty, isTrue); // 应该有低占用率警告
    });

    test('跨度为 0 的单元格测试', () {
      final layout = SpannableGridLayout(
        columns: 2,
        rows: 2,
        cells: [
          SpannableGridCellData(
            id: 'invalid',
            column: 1,
            row: 1,
            columnSpan: 0,
            rowSpan: 1,
          ),
        ],
      );

      final result = layout.validate();
      expect(result.isValid, isFalse);
      expect(result.errors.any((error) => error.contains('跨度必须大于 0')), isTrue);
    });

    test('超出边界的单元格测试', () {
      final layout = SpannableGridLayout(
        columns: 2,
        rows: 2,
        cells: [
          SpannableGridCellData(
            id: 'outbound',
            column: 2,
            row: 2,
            columnSpan: 2, // 会超出 2x2 网格的边界
            rowSpan: 1,
          ),
        ],
      );

      final result = layout.validate();
      expect(result.isValid, isFalse);
      expect(result.errors.any((error) => error.contains('超出网格边界')), isTrue);
    });
  });
}
