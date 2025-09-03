# SpannableGrid JSON 导入导出功能

SpannableGrid 现在支持将网格布局导出为 JSON 格式，并从 JSON 数据导入布局配置。这个功能让您可以：

- 保存和恢复网格布局
- 在不同应用之间共享布局配置
- 动态加载预设的布局模板
- 进行布局的版本管理

## 功能特性

### 🚀 核心功能

1. **JSON 导出**: 将当前网格布局导出为结构化的 JSON 数据
2. **JSON 导入**: 从 JSON 数据恢复网格布局
3. **布局验证**: 自动验证导入的布局是否有效
4. **布局合并**: 合并多个布局文件
5. **元数据支持**: 支持自定义元数据信息

### 📊 支持的数据

- 网格尺寸（行数和列数）
- 单元格位置和跨度信息
- 布局版本信息
- 时间戳
- 自定义元数据

> **注意**: 由于 Flutter Widget 无法序列化，JSON 中只包含布局信息，不包含实际的 Widget 内容。导入时需要重新设置 Widget。

## 快速开始

### 1. 基础用法

```dart
import 'package:spannable_grid/spannable_grid.dart';

// 创建网格
final grid = SpannableGrid(
  columns: 4,
  rows: 3,
  cells: [
    SpannableGridCellData(
      id: 'header',
      column: 1,
      row: 1,
      columnSpan: 4,
      rowSpan: 1,
      child: Container(color: Colors.blue),
    ),
    // ... 其他单元格
  ],
);

// 导出布局
String jsonString = grid.exportToJson();
print(jsonString);

// 导入布局
Map<String, dynamic> layoutData = SpannableGrid.importFromJson(jsonString);
```

### 2. 使用工具类

```dart
import 'package:spannable_grid/spannable_grid.dart';

// 创建布局对象
final layout = SpannableGridLayout(
  columns: 3,
  rows: 3,
  cells: cells,
  metadata: {
    'name': '我的布局',
    'description': '这是一个示例布局',
  },
);

// 导出为 JSON
String jsonString = layout.toJson();

// 从 JSON 导入
SpannableGridLayout importedLayout = SpannableGridLayout.fromJson(jsonString);

// 验证布局
ValidationResult result = importedLayout.validate();
if (result.isValid) {
  print('布局有效！占用率：${(result.occupancyRate * 100).toStringAsFixed(1)}%');
} else {
  print('布局无效：${result.errors.join(', ')}');
}
```

### 3. 高级功能

```dart
// 合并两个布局
SpannableGridLayout mergedLayout = SpannableGridLayoutUtils.mergeLayouts(
  baseLayout,
  otherLayout,
  columnOffset: 2,
  rowOffset: 1,
  idPrefix: 'merged',
);

// 使用工具类导出
String jsonString = SpannableGridLayoutUtils.exportLayout(
  columns: 4,
  rows: 3,
  cells: cells,
  metadata: {
    'template': 'dashboard',
    'version': '2.0',
  },
);
```

## JSON 数据格式

### 基本结构

```json
{
  "columns": 4,
  "rows": 3,
  "cells": [
    {
      "id": "header",
      "column": 1,
      "row": 1,
      "columnSpan": 4,
      "rowSpan": 1
    },
    {
      "id": "sidebar",
      "column": 1,
      "row": 2,
      "columnSpan": 1,
      "rowSpan": 2
    }
  ],
  "version": "1.0",
  "timestamp": 1699123456789,
  "metadata": {
    "name": "示例布局",
    "description": "包含标题和侧边栏的布局",
    "author": "开发者",
    "tags": ["dashboard", "responsive"]
  }
}
```

### 字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `columns` | number | ✅ | 网格列数 |
| `rows` | number | ✅ | 网格行数 |
| `cells` | array | ✅ | 单元格数据数组 |
| `version` | string | ❌ | 格式版本号 |
| `timestamp` | number | ❌ | 创建时间戳 |
| `metadata` | object | ❌ | 自定义元数据 |

### 单元格数据格式

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | ✅ | 唯一标识符 |
| `column` | number | ✅ | 起始列（从1开始） |
| `row` | number | ✅ | 起始行（从1开始） |
| `columnSpan` | number | ❌ | 跨列数（默认1） |
| `rowSpan` | number | ❌ | 跨行数（默认1） |

## API 参考

### SpannableGrid 新增方法

#### `exportToJson()` 
导出当前网格布局为 JSON 字符串。

```dart
String exportToJson()
```

#### `importFromJson(String jsonString)`
从 JSON 字符串导入布局数据。

```dart
static Map<String, dynamic> importFromJson(String jsonString)
```

返回包含以下键的 Map：
- `columns`: 列数
- `rows`: 行数  
- `cells`: `List<SpannableGridCellData>`
- `version`: 版本信息
- `timestamp`: 时间戳

### SpannableGridCellData 新增方法

#### `toJson()`
将单元格数据转换为 JSON Map。

```dart
Map<String, dynamic> toJson()
```

#### `fromJson(Map<String, dynamic> json)`
从 JSON Map 创建单元格数据。

```dart
static SpannableGridCellData fromJson(Map<String, dynamic> json)
```

#### `copyWith({...})`
创建单元格数据的副本。

```dart
SpannableGridCellData copyWith({
  Object? id,
  Widget? child,
  int? column,
  int? row,
  int? columnSpan,
  int? rowSpan,
})
```

### SpannableGridLayoutUtils 工具类

#### `exportLayout({...})`
导出网格布局为 JSON 字符串。

```dart
static String exportLayout({
  required int columns,
  required int rows,
  required List<SpannableGridCellData> cells,
  Map<String, dynamic>? metadata,
})
```

#### `importLayout(String jsonString)`
从 JSON 字符串导入布局。

```dart
static SpannableGridLayout importLayout(String jsonString)
```

#### `validateLayout(SpannableGridLayout layout)`
验证布局的有效性。

```dart
static ValidationResult validateLayout(SpannableGridLayout layout)
```

#### `mergeLayouts(SpannableGridLayout base, SpannableGridLayout other, {...})`
合并两个布局。

```dart
static SpannableGridLayout mergeLayouts(
  SpannableGridLayout base,
  SpannableGridLayout other, {
  int columnOffset = 0,
  int rowOffset = 0,
  String? idPrefix,
})
```

### SpannableGridLayout 数据类

表示完整的网格布局信息。

```dart
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
}
```

### ValidationResult 验证结果

```dart
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
}
```

## 实际应用示例

### 1. 保存用户布局

```dart
class LayoutManager {
  static Future<void> saveLayout(String name, SpannableGrid grid) async {
    final jsonString = grid.exportToJson();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('layout_$name', jsonString);
  }

  static Future<SpannableGridLayout?> loadLayout(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('layout_$name');
    if (jsonString != null) {
      return SpannableGridLayout.fromJson(jsonString);
    }
    return null;
  }
}
```

### 2. 网络加载布局模板

```dart
class TemplateLoader {
  static Future<SpannableGridLayout> loadFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return SpannableGridLayout.fromJson(response.body);
    }
    throw Exception('Failed to load template');
  }
}
```

### 3. 布局编辑器

```dart
class LayoutEditor extends StatefulWidget {
  @override
  _LayoutEditorState createState() => _LayoutEditorState();
}

class _LayoutEditorState extends State<LayoutEditor> {
  List<SpannableGridCellData> cells = [];
  
  void exportLayout() {
    final grid = SpannableGrid(columns: 4, rows: 4, cells: cells);
    final jsonString = grid.exportToJson();
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('布局已复制到剪贴板')),
    );
  }
  
  void importLayout(String jsonString) {
    try {
      final layout = SpannableGridLayout.fromJson(jsonString);
      final result = layout.validate();
      
      if (result.isValid) {
        setState(() {
          cells = layout.cells.map((cellData) {
            return cellData.copyWith(
              child: _createDefaultWidget(cellData.id.toString()),
            );
          }).toList();
        });
      } else {
        _showError('布局验证失败：${result.errors.join(', ')}');
      }
    } catch (e) {
      _showError('导入失败：$e');
    }
  }
  
  Widget _createDefaultWidget(String id) {
    return Container(
      color: Colors.primaries[id.hashCode % Colors.primaries.length],
      child: Center(child: Text(id)),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

## 错误处理

### 常见错误和解决方案

1. **FormatException**: JSON 格式无效
   ```dart
   try {
     final layout = SpannableGridLayout.fromJson(jsonString);
   } catch (e) {
     print('JSON 解析错误：$e');
   }
   ```

2. **ValidationError**: 布局验证失败
   ```dart
   final result = layout.validate();
   if (!result.isValid) {
     for (final error in result.errors) {
       print('验证错误：$error');
     }
   }
   ```

3. **边界检查**: 单元格超出网格范围
   ```dart
   // 布局验证会自动检查这些问题：
   // - 单元格位置不能小于 1
   // - 单元格不能超出网格边界
   // - 单元格不能重叠
   // - 跨度必须大于 0
   ```

## 性能考虑

1. **大型布局**: 对于包含大量单元格的布局，JSON 解析可能需要一些时间
2. **内存使用**: 导入后的 `SpannableGridCellData` 对象不包含 Widget，需要单独设置
3. **验证成本**: 布局验证会遍历所有单元格，对于大型布局可能有性能影响

## 最佳实践

1. **版本控制**: 在 metadata 中记录布局版本，便于后续兼容性处理
2. **错误处理**: 始终包装 JSON 操作在 try-catch 中
3. **布局验证**: 导入布局后立即进行验证
4. **Widget 重建**: 导入后需要根据业务逻辑重新创建 Widget
5. **元数据利用**: 使用 metadata 存储布局相关的额外信息

## 示例项目

查看 `example/lib/json_example.dart` 文件获取完整的示例应用，展示了：

- ✅ 交互式布局编辑
- ✅ JSON 导出和导入
- ✅ 布局验证和错误处理  
- ✅ 示例 JSON 数据
- ✅ 剪贴板集成

运行示例：
```bash
cd example
flutter run lib/json_example.dart
```