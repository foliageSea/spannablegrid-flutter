import 'package:flutter/material.dart';
import 'package:spannable_grid/spannable_grid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: Theme.of(context), home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cells = <SpannableGridCellData>[];

  @override
  void initState() {
    super.initState();
    cells.add(
      SpannableGridCellData(
        column: 1,
        row: 1,
        columnSpan: 2,
        rowSpan: 2,
        id: "Test Cell 1",
        child: Container(
          color: Colors.lightBlue,
          child: Center(child: Text("Tile 2x2")),
        ),
      ),
    );
    cells.add(
      SpannableGridCellData(
        column: 4,
        row: 1,
        columnSpan: 1,
        rowSpan: 1,
        id: "Test Cell 2",
        child: Container(
          color: Colors.lightBlue,
          child: Center(child: Text("Tile 1x1")),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 300,
        child: SpannableGrid(
          columns: 8,
          rows: 2,
          cells: cells,
          editingStrategy: const SpannableGridEditingStrategy(),
          onCellChanged: (cell) {
            print('Cell ${cell?.id} changed');
          },
          gridSize: SpannableGridSize.parentWidth,
          style: SpannableGridStyle(
            selectedCellDecoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                width: 4.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
