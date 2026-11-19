import 'package:flutter/material.dart';
import '../models/boot_model.dart';
import '../services/storage_service.dart';
import '../widgets/progress_header.dart';
import '../widgets/cell_dialog.dart';

class TableScreen extends StatefulWidget {
  final BootModel model;

  const TableScreen({super.key, required this.model});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  late BootModel _model;
  bool _quickMode = true;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();

  static const double colWidthSize = 75;
  static const double colWidthCant = 65;
  static const double colWidthComponent = 96;
  static const double rowHeight = 48;
  static const double headerHeight = 52;

  @override
  void initState() {
    super.initState();
    _model = widget.model;

    _horizontalController.addListener(() {
      if (_headerScrollController.hasClients && _horizontalController.hasClients) {
        if (_headerScrollController.offset != _horizontalController.offset) {
          _headerScrollController.jumpTo(_horizontalController.offset);
        }
      }
    });

    _headerScrollController.addListener(() {
      if (_horizontalController.hasClients && _headerScrollController.hasClients) {
        if (_horizontalController.offset != _headerScrollController.offset) {
          _horizontalController.jumpTo(_headerScrollController.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await StorageService.saveSingleModel(_model);
    setState(() {});
  }

  void _onCellTapped(BootSizeRow row, String component) async {
    final current = row.getCompleted(component);

    if (_quickMode) {
      // One-touch toggle: 0 -> Complete (✓) -> 0
      if (current == 0) {
        row.markComponentAll(component);
      } else {
        row.markComponentZero(component);
      }
      await _save();
    } else {
      _openCellDialog(row, component);
    }
  }

  void _onCellLongPressed(BootSizeRow row, String component) {
    _openCellDialog(row, component);
  }

  Future<void> _openCellDialog(BootSizeRow row, String component) async {
    final result = await CellDialog.show(
      context,
      componentName: component,
      sizeLabel: row.formattedSizeWithHalf,
      totalQuantity: row.quantity,
      currentCompleted: row.getCompleted(component),
    );

    if (result != null) {
      row.setCompleted(component, result);
      await _save();
    }
  }

  void _showColumnMenu(String component) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.view_column, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  'Columna: $component',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Avance: ${_model.getColumnCompletedPieces(component)} de ${_model.getColumnTotalPieces(component)} piezas cortadas',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.done_all),
              label: Text('Marcar TODO "$component" Completo (✓)'),
              onPressed: () {
                _model.markColumnComplete(component);
                _save();
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.clear_all),
              label: const Text('Reiniciar esta columna a 0'),
              onPressed: () {
                _model.resetColumn(component);
                _save();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRowMenu(BootSizeRow row) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.straighten, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  'Punto: ${row.formattedSizeWithHalf} (${row.quantity} pares)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Avance: ${row.rowCompletedPieces} de ${row.rowTotalPieces} piezas listas',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.done_all),
              label: Text('Marcar TODA la Talla ${row.formattedSizeWithHalf} Completa (✓)'),
              onPressed: () {
                row.markAllComponentsComplete();
                _save();
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.clear_all),
              label: const Text('Reiniciar esta talla a 0'),
              onPressed: () {
                row.resetAllComponents();
                _save();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    final is100 = _model.isFullyCompleted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              is100 ? Icons.check_circle : Icons.warning_amber_rounded,
              color: is100 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(is100 ? '¿Borrar Modelo Completado?' : '¿Borrar Modelo?'),
          ],
        ),
        content: Text(
          is100
              ? 'Has completado el 100% del modelo "${_model.name}". Al borrarlo se eliminará de la memoria del dispositivo.'
              : 'El modelo "${_model.name}" va al ${_model.progressPercentInt}%. El usuario configuró borrarlo al terminar al 100%, pero puedes borrarlo ahora si deseas cancelar este corte.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Borrar'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await StorageService.deleteModel(_model.id);
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Control: ${_model.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _quickMode ? 'Modo Rápido (1 toque = ✓)' : 'Modo Parcial (1 toque = Ventana)',
            icon: Icon(
              _quickMode ? Icons.bolt : Icons.tune,
              color: _quickMode ? Colors.amberAccent : Colors.white70,
            ),
            onPressed: () {
              setState(() => _quickMode = !_quickMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 1400),
                  content: Text(
                    _quickMode
                        ? 'Modo Rápido Activo: 1 toque marca ✓ Paloma completa'
                        : 'Modo Parcial Activo: 1 toque abre ventana para poner — Raya con cantidad',
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Borrar Modelo',
            icon: Icon(
              Icons.delete_outline,
              color: _model.isFullyCompleted ? Colors.redAccent : Colors.white70,
            ),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary / Progress Bar
            ProgressHeader(
              model: _model,
              quickMode: _quickMode,
              onQuickModeChanged: (val) => setState(() => _quickMode = val),
              onDeleteRequested: _confirmDelete,
            ),

            // Subtle Hint bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFFEFEBE9),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, size: 16, color: Color(0xFF5D4037)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _quickMode
                          ? 'Toca cualquier casilla para palomear ✓. Mantén presionado para raya — con cantidad.'
                          : 'Toca una casilla para registrar cantidad parcial (—) o completado (✓).',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4E342E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Header Row
            Container(
              height: headerHeight,
              decoration: const BoxDecoration(
                color: Color(0xFF4E342E),
                boxShadow: [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3),
                ],
              ),
              child: Row(
                children: [
                  // Pinned Header: Talla & Cant.
                  Container(
                    width: colWidthSize,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Color(0xFF3E2723), width: 1.5)),
                    ),
                    child: const Center(
                      child: Text(
                        'Talla',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: colWidthCant,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Color(0xFF2E1C0C), width: 2.5)),
                    ),
                    child: const Center(
                      child: Text(
                        'Cant.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Scrollable Header: Components
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _headerScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: kBootComponents.map((component) {
                          return InkWell(
                            onTap: () => _showColumnMenu(component),
                            child: Container(
                              width: colWidthComponent,
                              height: headerHeight,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Color(0xFF6D4C41)),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    component,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_model.getColumnCompletedPieces(component)}/${_model.getColumnTotalPieces(component)}',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body (Vertical scroll contains both left sticky & right horizontal)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Left Columns Body
                    SizedBox(
                      width: colWidthSize + colWidthCant,
                      child: Column(
                        children: List.generate(_model.rows.length, (rowIndex) {
                          final row = _model.rows[rowIndex];
                          final isRowDone = row.isRowFullyCompleted;
                          final isEven = rowIndex % 2 == 0;

                          return InkWell(
                            onTap: () => _showRowMenu(row),
                            child: Container(
                              height: rowHeight,
                              decoration: BoxDecoration(
                                color: isRowDone
                                    ? const Color(0xFFE8F5E9)
                                    : (isEven ? Colors.white : const Color(0xFFF9F6F0)),
                                border: const Border(
                                  bottom: BorderSide(color: Color(0xFFE0E0E0)),
                                  right: BorderSide(color: Color(0xFF2E1C0C), width: 2.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Talla
                                  SizedBox(
                                    width: colWidthSize,
                                    child: Center(
                                      child: Text(
                                        row.formattedSizeWithHalf,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: isRowDone
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFF2E1C0C),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Cantidad
                                  SizedBox(
                                    width: colWidthCant,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.brown.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.brown.shade200),
                                        ),
                                        child: Text(
                                          '${row.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF3E2723),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Horizontally Scrollable Components Body
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: kBootComponents.length * colWidthComponent,
                          child: Column(
                            children: List.generate(_model.rows.length, (rowIndex) {
                              final row = _model.rows[rowIndex];
                              final isEven = rowIndex % 2 == 0;

                              return Container(
                                height: rowHeight,
                                decoration: BoxDecoration(
                                  color: isEven ? Colors.white : const Color(0xFFF9F6F0),
                                  border: const Border(
                                    bottom: BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                ),
                                child: Row(
                                  children: kBootComponents.map((component) {
                                    final count = row.getCompleted(component);
                                    final isComplete = row.isComplete(component);
                                    final isPartial = row.isPartial(component);

                                    Widget cellWidget;
                                    Color cellBg = Colors.transparent;

                                    if (isComplete) {
                                      cellBg = const Color(0xFFE8F5E9);
                                      cellWidget = Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: Color(0xFF2E7D32),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$count',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else if (isPartial) {
                                      cellBg = const Color(0xFFFFF3E0);
                                      cellWidget = Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '—',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 19,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$count',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Empty / 0
                                      cellWidget = Text(
                                        '·',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 18,
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      width: colWidthComponent,
                                      child: InkWell(
                                        onTap: () => _onCellTapped(row, component),
                                        onLongPress: () => _onCellLongPressed(row, component),
                                        child: Container(
                                          height: rowHeight,
                                          decoration: BoxDecoration(
                                            color: cellBg,
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 0.8,
                                              ),
                                            ),
                                          ),
                                          child: Center(child: cellWidget),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
