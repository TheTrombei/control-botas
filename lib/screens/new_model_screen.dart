import 'package:flutter/material.dart';
import '../models/boot_model.dart';
import '../services/storage_service.dart';
import 'table_screen.dart';

class NewModelScreen extends StatefulWidget {
  const NewModelScreen({super.key});

  @override
  State<NewModelScreen> createState() => _NewModelScreenState();
}

class _NewModelScreenState extends State<NewModelScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _gender = 'Hombre'; // 'Hombre' or 'Mujer'

  // Available sizes
  late List<double> _womenSizes;
  late List<double> _menSizes;

  // Selected sizes and their quantities: size -> quantity
  final Map<double, int> _selectedSizes = {};

  // Filter for men's sizes
  String _menFilter = 'adulto'; // 'adulto' (25-30), '5-12', 'todos'

  int _defaultQuantity = 6;

  @override
  void initState() {
    super.initState();
    // Mujer: 2 al 7 con medios puntos
    _womenSizes = [];
    for (double s = 2.0; s <= 7.05; s += 0.5) {
      _womenSizes.add(double.parse(s.toStringAsFixed(1)));
    }

    // Hombre: 5 al 30 con medios puntos
    _menSizes = [];
    for (double s = 5.0; s <= 30.05; s += 0.5) {
      _menSizes.add(double.parse(s.toStringAsFixed(1)));
    }

    // Default select standard adult sizes for men (25 al 30) with 6 pares
    _selectPresetAdultMen();
  }

  void _selectPresetAdultMen() {
    _selectedSizes.clear();
    for (double s = 25.0; s <= 30.05; s += 0.5) {
      _selectedSizes[double.parse(s.toStringAsFixed(1))] = 6;
    }
  }

  void _selectPresetWomen() {
    _selectedSizes.clear();
    for (var s in _womenSizes) {
      _selectedSizes[s] = 6;
    }
  }

  String _formatSize(double s) {
    if (s % 1 == 0) {
      return s.toInt().toString();
    } else {
      return '${s.toInt()} ½';
    }
  }

  List<double> get _currentAvailableSizes {
    if (_gender == 'Mujer') {
      return _womenSizes;
    } else {
      if (_menFilter == 'adulto') {
        return _menSizes.where((s) => s >= 24.5 && s <= 30.0).toList();
      } else if (_menFilter == '5-12') {
        return _menSizes.where((s) => s >= 5.0 && s <= 12.0).toList();
      } else {
        return _menSizes;
      }
    }
  }

  void _toggleSize(double s) {
    setState(() {
      if (_selectedSizes.containsKey(s)) {
        _selectedSizes.remove(s);
      } else {
        _selectedSizes[s] = _defaultQuantity > 0 ? _defaultQuantity : 6;
      }
    });
  }

  void _applyDefaultToAll() {
    setState(() {
      for (var key in _selectedSizes.keys) {
        _selectedSizes[key] = _defaultQuantity;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Se asignaron $_defaultQuantity pares a todos los puntos seleccionados'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _selectAllCurrent() {
    setState(() {
      for (var s in _currentAvailableSizes) {
        _selectedSizes[s] = _defaultQuantity;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedSizes.clear();
    });
  }

  void _saveAndStart() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe el nombre o número del modelo'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un punto para el corte'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Sort sizes ascending
    final sortedSizes = _selectedSizes.keys.toList()..sort();
    final rows = sortedSizes.map((s) {
      return BootSizeRow(
        size: s,
        quantity: _selectedSizes[s] ?? 1,
      );
    }).toList();

    final newModel = BootModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      gender: _gender,
      createdAt: DateTime.now(),
      rows: rows,
    );

    await StorageService.saveSingleModel(newModel);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TableScreen(model: newModel),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedSelected = _selectedSizes.keys.toList()..sort();
    int totalPares = 0;
    for (var q in _selectedSizes.values) {
      totalPares += q;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Modelo de Botas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Model Name Input
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Nombre o Código del Modelo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Ej: Bota Rodeo 501, Caiman Mod. 20...',
                        prefixIcon: const Icon(Icons.style, color: Colors.brown),
                        filled: true,
                        fillColor: Colors.brown.shade50.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.brown.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.brown.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.brown, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Gender Selector
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. ¿Para quién es el corte?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_gender != 'Hombre') {
                                setState(() {
                                  _gender = 'Hombre';
                                  _selectPresetAdultMen();
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _gender == 'Hombre'
                                    ? const Color(0xFF1976D2)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _gender == 'Hombre'
                                      ? const Color(0xFF0D47A1)
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.male,
                                    color: _gender == 'Hombre' ? Colors.white : Colors.grey.shade700,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'HOMBRE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _gender == 'Hombre' ? Colors.white : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_gender != 'Mujer') {
                                setState(() {
                                  _gender = 'Mujer';
                                  _selectPresetWomen();
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _gender == 'Mujer'
                                    ? const Color(0xFFC2185B)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _gender == 'Mujer'
                                      ? const Color(0xFF880E4F)
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.female,
                                    color: _gender == 'Mujer' ? Colors.white : Colors.grey.shade700,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MUJER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _gender == 'Mujer' ? Colors.white : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _gender == 'Hombre'
                          ? 'Puntos disponibles: 5 al 30 con medios puntos'
                          : 'Puntos disponibles: 2 al 7 con medios puntos',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Sizes Picker
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '3. Toca los Puntos a cortar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        Text(
                          '${_selectedSizes.length} seleccionados',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Filter tabs if Hombre
                    if (_gender == 'Hombre') ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Comunes (25 al 30)'),
                              selected: _menFilter == 'adulto',
                              onSelected: (val) {
                                if (val) setState(() => _menFilter = 'adulto');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Tallas 5 al 12'),
                              selected: _menFilter == '5-12',
                              onSelected: (val) {
                                if (val) setState(() => _menFilter = '5-12');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Todos (5 al 30)'),
                              selected: _menFilter == 'todos',
                              onSelected: (val) {
                                if (val) setState(() => _menFilter = 'todos');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Quick action buttons
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _selectAllCurrent,
                          icon: const Icon(Icons.select_all, size: 18),
                          label: const Text('Seleccionar Todos'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _clearSelection,
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Deseleccionar'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Size chips grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentAvailableSizes.map((s) {
                        final isSelected = _selectedSizes.containsKey(s);
                        final label = _formatSize(s);

                        return FilterChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.brown.shade900,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4E342E),
                          backgroundColor: Colors.brown.shade50,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF3E2723) : Colors.brown.shade200,
                            ),
                          ),
                          onSelected: (_) => _toggleSize(s),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Quantities table for selected sizes
            if (_selectedSizes.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '4. Cantidad de Pares por Punto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Total: $totalPares pares',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Set default to all row
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Poner a todos: ',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: _defaultQuantity > 1
                                  ? () => setState(() => _defaultQuantity--)
                                  : null,
                            ),
                            Text(
                              '$_defaultQuantity',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => setState(() => _defaultQuantity++),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D4037),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: _applyDefaultToAll,
                              child: const Text('Aplicar a Todos'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // List of sizes with individual adjusters
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedSelected.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final s = sortedSelected[idx];
                          final qty = _selectedSizes[s] ?? 1;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 65,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4E342E),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _formatSize(s),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  'Cantidad:',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Color(0xFF8D6E63)),
                                  onPressed: qty > 1
                                      ? () => setState(() => _selectedSizes[s] = qty - 1)
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E1C0C),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Color(0xFF4E342E)),
                                  onPressed: () => setState(() => _selectedSizes[s] = qty + 1),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                                  onPressed: () => _toggleSize(s),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Start Cutting Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saveAndStart,
              icon: const Icon(Icons.check_circle_outline, size: 26),
              label: Text(
                'CREAR HOJA DE CORTE (${_selectedSizes.length} puntos)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
