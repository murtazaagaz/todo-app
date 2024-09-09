import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_bloc.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_event.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_state.dart';
import 'package:to_do_app/bloc/todo_bloc/todo_bloc.dart';
import 'package:to_do_app/main.dart' as app;
import 'package:to_do_app/models/todo.dart';
import 'package:to_do_app/repo/auth_repository.dart';
import 'package:to_do_app/repo/firestore_repository.dart';
import 'package:to_do_app/ui/todo/add_todo.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add ToDo', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add integration test logic
  });
  group('ToDo Model', () {
    test('should create ToDo object correctly', () {
      final todo = ToDo(
        id: '1',
        title: 'Test ToDo',
      );

      expect(todo.title, 'Test ToDo');
    });
  });

  testWidgets('Add ToDo Screen shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FutureBuilder(
            future: Hive.openBox<ToDo>(
                'todoBox'), // Open Hive box for local storage
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final Box<ToDo> todoBox = Hive.box<ToDo>('todoBox');

                builder:
                (context) {
                  return MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider(create: (context) => AuthRepository()),
                      RepositoryProvider(
                          create: (context) => FirestoreRepository()),
                    ],
                    child: BlocProvider(
                      create: (_) => ToDoBloc(
                        todoBox: todoBox,
                        firestoreRepository:
                            RepositoryProvider.of<FirestoreRepository>(context),
                        authRepository:
                            RepositoryProvider.of<AuthRepository>(context),
                      ),
                      child: AddToDoScreen(),
                    ),
                  );
                };
              }
              return Container();
            }),
      ),
    );

    expect(find.text('Add ToDo'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(1));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow works', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Find and enter email and password
    await tester.enterText(
        find.byKey(ValueKey('emailField')), 'test@example.com');
    await tester.enterText(
        find.byKey(ValueKey('passwordField')), 'password123');

    // Tap login button
    await tester.tap(find.byKey(ValueKey('loginButton')));
    await tester.pumpAndSettle();

    // Expect to navigate to ToDo screen after login
    expect(find.text('ToDo Screen'), findsOneWidget);
  });

  group('LocaleBloc', () {
    late LocaleBloc localeBloc;

    setUp(() {
      localeBloc = LocaleBloc();
    });

    test('should have default locale as English', () {
      expect(localeBloc.state, LocaleLoaded(Locale('en')));
    });

    test('should switch to Arabic when ChangeLocaleEvent is added', () {
      localeBloc.add(ChangeLocaleEvent(Locale('ar')));

      expectLater(
        localeBloc.stream,
        emitsInOrder([LocaleLoaded(Locale('ar'))]),
      );
    });
  });

  test('should save login status in shared preferences', () async {
    SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences

    final prefs = await SharedPreferences.getInstance();

    // Set login status
    await prefs.setBool('isLoggedIn', true);

    // Check login status
    final isLoggedIn = prefs.getBool('isLoggedIn');
    expect(isLoggedIn, true);
  });
}
