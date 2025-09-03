import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spannable_grid/spannable_grid.dart';

void main() {
  runApp(const JsonExampleApp());
}

class JsonExampleApp extends StatelessWidget {
  const JsonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpannableGrid JSON 导入导出示例',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const JsonExamplePage(),
    );
  }
}

class JsonExamplePage extends StatefulWidget {
  const JsonExamplePage({super.key});

  @override
  State<JsonExamplePage> createState() => _JsonExamplePageState();
}

class _JsonExamplePageState extends State<JsonExamplePage> {
  List<SpannableGridCellData> cells = [];
  int columns = 4;
  int rows = 4;
  final TextEditingController _jsonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDefaultLayout();
  }

  void _initializeDefaultLayout() {
    cells = [
      SpannableGridCellData(
        column: 1,
        row: 1,
        columnSpan: 2,
        rowSpan: 1,
        id: "header",
        child: Container(
          color: Colors.blue[300],
          child: const Center(
            child: Text(
              "标题区域",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      SpannableGridCellData(
        column: 3,
        row: 1,
        columnSpan: 2,
        rowSpan: 2,
        id: "sidebar",
        child: Container(
          color: Colors.green[300],
          child: const Center(
            child: Text(
              "侧边栏",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      SpannableGridCellData(
        column: 1,
        row: 2,
        columnSpan: 1,
        rowSpan: 1,
        id: "content1",
        child: Container(
          color: Colors.orange[300],
          child: const Center(child: Text("内容1")),
        ),
      ),
      SpannableGridCellData(
        column: 2,
        row: 2,
        columnSpan: 1,
        rowSpan: 1,
        id: "content2",
        child: Container(
          color: Colors.purple[300],
          child: const Center(child: Text("内容2")),
        ),
      ),
      SpannableGridCellData(
        column: 1,
        row: 3,
        columnSpan: 4,
        rowSpan: 1,
        id: "footer",
        child: Container(
          color: Colors.grey[600],
          child: const Center(
            child: Text(
              "底部区域",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  void _exportLayout() {
    try {
      final layout = SpannableGridLayout(
        columns: columns,
        rows: rows,
        cells: cells,
        metadata: {
          'name': '示例布局',
          'description': '这是一个包含标题、侧边栏、内容和底部的示例布局',
          'created_by': 'SpannableGrid 示例应用',
        },
      );

      final jsonString = layout.toJson();
      _jsonController.text = jsonString;

      // 复制到剪贴板
      Clipboard.setData(ClipboardData(text: jsonString));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('布局已导出并复制到剪贴板'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$e'), backgroundColor: Colors.red),
      );
    }
  }

  void _importLayout() {
    try {
      final jsonString = _jsonController.text.trim();
      if (jsonString.isEmpty) {
        throw const FormatException('JSON 字符串不能为空');
      }

      final layout = SpannableGridLayout.fromJson(jsonString);

      // 验证布局
      final validationResult = layout.validate();
      if (!validationResult.isValid) {
        throw FormatException('布局验证失败：${validationResult.errors.join(', ')}');
      }

      setState(() {
        columns = layout.columns;
        rows = layout.rows;
        cells = layout.cells.map((cellData) {
          // 重新设置 widget，因为 JSON 中不包含 widget 信息
          return cellData.copyWith(
            child: _createCellWidget(cellData.id.toString()),
          );
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '布局导入成功！占用率：${(validationResult.occupancyRate * 100).toStringAsFixed(1)}%',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // 显示警告（如果有）
      if (validationResult.warnings.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('导入警告'),
            content: Text(validationResult.warnings.join('\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败：$e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _createCellWidget(String id) {
    final colors = [
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.purple[300]!,
      Colors.grey[600]!,
      Colors.red[300]!,
      Colors.teal[300]!,
      Colors.indigo[300]!,
    ];

    final color = colors[id.hashCode % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Text(
          id,
          style: TextStyle(
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _resetLayout() {
    setState(() {
      _initializeDefaultLayout();
      _jsonController.clear();
    });
  }

  void _showSampleJson() {
    const sampleJson = '''
{
  "columns": 3,
  "rows": 3,
  "cells": [
    {
      "id": "top_banner",
      "column": 1,
      "row": 1,
      "columnSpan": 3,
      "rowSpan": 1
    },
    {
      "id": "left_content",
      "column": 1,
      "row": 2,
      "columnSpan": 2,
      "rowSpan": 1
    },
    {
      "id": "right_sidebar", 
      "column": 3,
      "row": 2,
      "columnSpan": 1,
      "rowSpan": 2
    },
    {
      "id": "bottom_left",
      "column": 1,
      "row": 3,
      "columnSpan": 1,
      "rowSpan": 1
    },
    {
      "id": "bottom_right",
      "column": 2,
      "row": 3,
      "columnSpan": 1,
      "rowSpan": 1
    }
  ],
  "version": "1.0",
  "timestamp": 1699123456789,
  "metadata": {
    "name": "示例布局",
    "description": "3x3 网格示例布局"
  }
}''';

    _jsonController.text = sampleJson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpannableGrid JSON 导入导出'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 网格显示区域
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '当前布局：${columns}x$rows',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text('单元格数：${cells.length}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SpannableGrid(
                      columns: columns,
                      rows: rows,
                      cells: cells,
                      showGrid: true,
                      style: const SpannableGridStyle(
                        spacing: 2.0,
                        backgroundColor: Colors.black12,
                      ),
                      onCellChanged: (cell) {
                        print('Cell ${cell?.id} moved');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // JSON 输入输出区域
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'JSON 数据',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _jsonController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'JSON 数据将显示在这里...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 操作按钮区域
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _exportLayout,
                  icon: const Icon(Icons.upload),
                  label: const Text('导出布局'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _importLayout,
                  icon: const Icon(Icons.download),
                  label: const Text('导入布局'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showSampleJson,
                  icon: const Icon(Icons.code),
                  label: const Text('示例JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetLayout,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重置布局'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }
}
