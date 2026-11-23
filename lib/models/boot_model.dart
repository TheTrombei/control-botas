import 'dart:convert';

const List<String> kBootComponents = [
  'Chinela y talón',
  'Tubos',
  'Forro',
  'Etiqueta',
  'Ormas',
  'Cartón',
  'Planta',
  'Contra fuerte',
  'Rif',
  'Suela',
  'Tacón',
  'Espinazo',
];

class BootSizeRow {
  final double size; // e.g. 26.5 or 5.0
  final int quantity; // e.g. 10 pairs
  // Maps component name -> pieces completed (0 to quantity)
  final Map<String, int> progress;

  BootSizeRow({
    required this.size,
    required this.quantity,
    Map<String, int>? progress,
  }) : progress = progress != null
            ? ({for (var c in kBootComponents) c: progress[c] ?? 0})
            : {for (var c in kBootComponents) c: 0};

  String get formattedSize {
    if (size % 1 == 0) {
      return size.toInt().toString();
    } else {
      final whole = size.toInt();
      return '$whole.5'; // e.g. 26.5
    }
  }

  String get formattedSizeWithHalf {
    if (size % 1 == 0) {
      return size.toInt().toString();
    } else {
      final whole = size.toInt();
      return '$whole ½'; // e.g. 26 ½
    }
  }

  int getCompleted(String component) => progress[component] ?? 0;

  bool isComplete(String component) => getCompleted(component) >= quantity && quantity > 0;

  bool isPartial(String component) {
    final count = getCompleted(component);
    return count > 0 && count < quantity;
  }

  bool isZero(String component) => getCompleted(component) == 0;

  void setCompleted(String component, int count) {
    if (count < 0) count = 0;
    if (count > quantity) count = quantity;
    progress[component] = count;
  }

  void markComponentAll(String component) {
    progress[component] = quantity;
  }

  void markComponentZero(String component) {
    progress[component] = 0;
  }

  void markAllComponentsComplete() {
    for (var c in kBootComponents) {
      progress[c] = quantity;
    }
  }

  void resetAllComponents() {
    for (var c in kBootComponents) {
      progress[c] = 0;
    }
  }

  int get rowTotalPieces => quantity * kBootComponents.length;

  int get rowCompletedPieces {
    int total = 0;
    for (var c in kBootComponents) {
      total += getCompleted(c);
    }
    return total;
  }

  double get rowProgressPercentage {
    if (rowTotalPieces == 0) return 0.0;
    return (rowCompletedPieces / rowTotalPieces).clamp(0.0, 1.0);
  }

  bool get isRowFullyCompleted => rowCompletedPieces >= rowTotalPieces && rowTotalPieces > 0;

  Map<String, dynamic> toJson() => {
        'size': size,
        'quantity': quantity,
        'progress': progress,
      };

  factory BootSizeRow.fromJson(Map<String, dynamic> json) {
    final pMap = <String, int>{};
    if (json['progress'] != null) {
      final rawP = json['progress'] as Map<String, dynamic>;
      for (var entry in rawP.entries) {
        pMap[entry.key] = (entry.value as num).toInt();
      }
    }
    for (var c in kBootComponents) {
      pMap.putIfAbsent(c, () => 0);
    }
    return BootSizeRow(
      size: (json['size'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      progress: pMap,
    );
  }

  BootSizeRow copyWith({
    double? size,
    int? quantity,
    Map<String, int>? progress,
  }) {
    return BootSizeRow(
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      progress: progress != null ? Map<String, int>.from(progress) : Map<String, int>.from(this.progress),
    );
  }
}

class BootModel {
  final String id;
  String name;
  String gender; // 'Hombre' or 'Mujer'
  DateTime createdAt;
  List<BootSizeRow> rows;

  BootModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.createdAt,
    required this.rows,
  });

  int get totalPieces {
    int total = 0;
    for (var r in rows) {
      total += r.rowTotalPieces;
    }
    return total;
  }

  int get totalPairs {
    int pairs = 0;
    for (var r in rows) {
      pairs += r.quantity;
    }
    return pairs;
  }

  int get completedPieces {
    int comp = 0;
    for (var r in rows) {
      comp += r.rowCompletedPieces;
    }
    return comp;
  }

  double get progressPercentage {
    if (totalPieces == 0) return 0.0;
    return (completedPieces / totalPieces).clamp(0.0, 1.0);
  }

  int get progressPercentInt => (progressPercentage * 100).round();

  bool get isFullyCompleted => completedPieces >= totalPieces && totalPieces > 0;

  void markColumnComplete(String component) {
    for (var r in rows) {
      r.markComponentAll(component);
    }
  }

  void resetColumn(String component) {
    for (var r in rows) {
      r.markComponentZero(component);
    }
  }

  int getColumnCompletedPieces(String component) {
    int sum = 0;
    for (var r in rows) {
      sum += r.getCompleted(component);
    }
    return sum;
  }

  int getColumnTotalPieces(String component) {
    int sum = 0;
    for (var r in rows) {
      sum += r.quantity;
    }
    return sum;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'createdAt': createdAt.toIso8601String(),
        'rows': rows.map((r) => r.toJson()).toList(),
      };

  factory BootModel.fromJson(Map<String, dynamic> json) {
    return BootModel(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      rows: (json['rows'] as List<dynamic>)
          .map((r) => BootSizeRow.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  static String encodeList(List<BootModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());

  static List<BootModel> decodeList(String jsonString) {
    if (jsonString.trim().isEmpty) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((m) => BootModel.fromJson(m as Map<String, dynamic>)).toList();
  }
}
