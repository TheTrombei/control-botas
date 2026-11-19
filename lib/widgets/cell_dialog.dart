import 'package:flutter/material.dart';

class CellDialog extends StatefulWidget {
  final String componentName;
  final String sizeLabel;
  final int totalQuantity;
  final int currentCompleted;

  const CellDialog({
    super.key,
    required this.componentName,
    required this.sizeLabel,
    required this.totalQuantity,
    required this.currentCompleted,
  });

  static Future<int?> show(
    BuildContext context, {
    required String componentName,
    required String sizeLabel,
    required int totalQuantity,
    required int currentCompleted,
  }) {
    final isWide = MediaQuery.of(context).size.width > 600;
    if (isWide) {
      return showDialog<int>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: CellDialog(
              componentName: componentName,
              sizeLabel: sizeLabel,
              totalQuantity: totalQuantity,
              currentCompleted: currentCompleted,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: CellDialog(
            componentName: componentName,
            sizeLabel: sizeLabel,
            totalQuantity: totalQuantity,
            currentCompleted: currentCompleted,
          ),
        ),
      );
    }
  }

  @override
  State<CellDialog> createState() => _CellDialogState();
}

class _CellDialogState extends State<CellDialog> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.currentCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalQuantity;
    final isComplete = _count == total && total > 0;
    final isPartial = _count > 0 && _count < total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.content_cut, color: Colors.brown, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.componentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2013),
                      ),
                    ),
                    Text(
                      'Punto: ${widget.sizeLabel}  •  Meta: $total pares',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFFE8F5E9)
                  : isPartial
                      ? const Color(0xFFFFF3E0)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isComplete
                    ? const Color(0xFF4CAF50)
                    : isPartial
                        ? const Color(0xFFFF9800)
                        : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isComplete) ...[
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '¡COMPLETO ($total de $total)!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ] else if (isPartial) ...[
                  const Text(
                    '— ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  Text(
                    'Medio completo: $_count de $total pares',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Pendiente (0 de $total)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Shortcut: Paloma Completo
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.of(context).pop(total);
            },
            icon: const Icon(Icons.check, size: 24),
            label: Text(
              'Paloma: Marcar Completo ($total)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          // Section for Medio Completo / Ajuste de Cantidad
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Raya: Cantidad Parcial',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                    Text(
                      '$_count / $total pares',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Stepper Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundIconButton(
                      icon: Icons.remove,
                      onPressed: _count > 0 ? () => setState(() => _count--) : null,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.brown.shade200, width: 2),
                      ),
                      child: Text(
                        '$_count',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.add,
                      onPressed: _count < total ? () => setState(() => _count++) : null,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Quick buttons: 1, Mitad, Casi todo
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (total > 2)
                      ActionChip(
                        label: Text('Mitad (${(total / 2).round()})'),
                        onPressed: () {
                          setState(() {
                            _count = (total / 2).round();
                          });
                        },
                      ),
                    if (total >= 4)
                      ActionChip(
                        label: Text('${total - 1} pares'),
                        onPressed: () {
                          setState(() {
                            _count = total - 1;
                          });
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Slider
                Slider(
                  value: _count.toDouble(),
                  min: 0,
                  max: total.toDouble(),
                  divisions: total > 0 ? total : 1,
                  activeColor: const Color(0xFFE65100),
                  onChanged: (val) {
                    setState(() {
                      _count = val.round();
                    });
                  },
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3E0),
                    foregroundColor: const Color(0xFFE65100),
                    side: const BorderSide(color: Color(0xFFFFB74D)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(_count);
                  },
                  icon: const Icon(Icons.remove, size: 20),
                  label: Text(
                    'Guardar Raya con $_count pares',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Reset to 0
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop(0);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Poner en 0 (Pendiente)'),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? Colors.brown.shade600 : Colors.grey.shade300,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
