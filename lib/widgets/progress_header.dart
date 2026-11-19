import 'package:flutter/material.dart';
import '../models/boot_model.dart';

class ProgressHeader extends StatelessWidget {
  final BootModel model;
  final bool quickMode;
  final ValueChanged<bool> onQuickModeChanged;
  final VoidCallback onDeleteRequested;

  const ProgressHeader({
    super.key,
    required this.model,
    required this.quickMode,
    required this.onQuickModeChanged,
    required this.onDeleteRequested,
  });

  @override
  Widget build(BuildContext context) {
    final percent = model.progressPercentInt;
    final progressVal = model.progressPercentage;
    final is100 = model.isFullyCompleted;

    Color progressColor;
    if (is100) {
      progressColor = const Color(0xFF2E7D32); // Deep Green
    } else if (percent > 60) {
      progressColor = const Color(0xFF388E3C);
    } else if (percent > 25) {
      progressColor = const Color(0xFFFB8C00); // Amber
    } else {
      progressColor = const Color(0xFFD84315); // Rust Orange
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: Title + Gender badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Modelo: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              model.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2E1C0C),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: model.gender == 'Hombre'
                                  ? const Color(0xFFE3F2FD)
                                  : const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: model.gender == 'Hombre'
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFFF06292),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  model.gender == 'Hombre' ? Icons.male : Icons.female,
                                  size: 16,
                                  color: model.gender == 'Hombre'
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFFC2185B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  model.gender,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: model.gender == 'Hombre'
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFFC2185B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${model.totalPairs} pares en ${model.rows.length} puntos',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Percent Circle or Big Number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: progressColor, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: progressColor,
                        ),
                      ),
                      Text(
                        'AVANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 14,
                child: LinearProgressIndicator(
                  value: progressVal,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Counters Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cortado: ${model.completedPieces} de ${model.totalPieces} piezas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                ),
                Text(
                  is100 ? '🎉 ¡TODO LISTO!' : 'Faltan ${model.totalPieces - model.completedPieces} piezas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: is100 ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // 100% Completion Celebration Banner & Delete Action
            if (is100) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: Color(0xFFFBC02D), size: 28),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '¡Corte Completado al 100%! Ya puedes borrar este registro',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onDeleteRequested,
                      icon: const Icon(Icons.delete_forever, size: 20),
                      label: const Text(
                        'Borrar este Modelo de la Memoria',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // Quick mode toggle & legend
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _LegendBadge(label: '✓ Paloma', color: const Color(0xFF2E7D32), bg: const Color(0xFFE8F5E9)),
                      const SizedBox(width: 6),
                      _LegendBadge(label: '— Raya', color: const Color(0xFFE65100), bg: const Color(0xFFFFF3E0)),
                      const SizedBox(width: 6),
                      _LegendBadge(label: 'Vacío', color: Colors.grey.shade600, bg: Colors.grey.shade100),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => onQuickModeChanged(!quickMode),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: quickMode ? Colors.brown.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: quickMode ? Colors.brown.shade700 : Colors.grey.shade400,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          quickMode ? Icons.bolt : Icons.tune,
                          size: 16,
                          color: quickMode ? Colors.brown.shade900 : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          quickMode ? 'Modo Rápido ON' : 'Modo Parcial',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: quickMode ? Colors.brown.shade900 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _LegendBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
