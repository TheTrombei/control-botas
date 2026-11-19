import 'package:flutter_test/flutter_test.dart';
import 'package:control_botas/main.dart';
import 'package:control_botas/services/cloud_sync_service.dart';

void main() {
  tearDown(() {
    CloudSyncService.stopPolling();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BootControlApp());
    expect(find.text('Control de Corte de Botas'), findsOneWidget);
    CloudSyncService.stopPolling();
  });
}
