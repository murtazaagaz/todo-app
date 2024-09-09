import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:to_do_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add ToDo', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add integration test logic
  });
}
