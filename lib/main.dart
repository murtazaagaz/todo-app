import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_bloc.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_state.dart';
import 'package:to_do_app/generated/l10n.dart';
import 'package:to_do_app/models/todo.dart';
import 'package:to_do_app/repo/auth_repository.dart';
import 'package:to_do_app/repo/firestore_repository.dart';
import 'package:to_do_app/repo/localisation.dart';
import 'package:to_do_app/services/sync_service.dart';
import 'package:to_do_app/ui/todo/add_todo.dart';
import 'package:to_do_app/ui/auth/auth_screen.dart';
import 'package:to_do_app/ui/todo/todo_page.dart';
import 'package:workmanager/workmanager.dart';

void backgroundSync() {
  // Sync ToDos with Firebase Firestore
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(
      ToDoAdapter()); // Register the adapter after generating it

  // Register background fetch task
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 360, // Every 6 hours (360 minutes)
      stopOnTerminate: false,
      enableHeadless: true,
    ),
    (String taskId) async {
      // Handle the background fetch task
      await syncToFirestoreInBackground();
      BackgroundFetch.finish(taskId);
    },
  );
  await S.load(const Locale.fromSubtags(languageCode: 'en'));
  await S.load(const Locale.fromSubtags(languageCode: 'ar'));
  runApp(const MyApp());
}

Future<void> syncToFirestoreInBackground() async {
  final todoBox = await Hive.openBox<ToDo>('todoBox');
  final firestoreRepository = FirestoreRepository();
  final authRepository = AuthRepository();
  final syncService = SyncService(
    todoBox: todoBox,
    firestoreRepository: firestoreRepository,
    authRepository: authRepository,
  );
  await syncService
      .syncToFirestore(); // Sync local data to Firestore in the background
}

getApplicationDocumentsDirectory() {}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    backgroundSync();
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<LocaleBloc>(
          create: (context) => LocaleBloc(),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, state) {
          Locale locale = const Locale('en'); // default locale
          if (state is LocaleLoaded) {
            locale = state.locale;
          }

          return MaterialApp(
              locale: locale,
              title: 'Todo App',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate,
              ],
              supportedLocales: [
                ...S.delegate.supportedLocales,
                // const Locale('en', ''), // English
                // const Locale('ar', ''), // Arabic
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              routes: {
                '/auth': (context) => const AuthScreen(),
                '/todo': (context) => const TodoPage(),
                '/addTodo': (context)=> const AddToDoScreen(),
              },
              home: const AuthScreen());
        },
      ),
    );
  }
}

class AuthPage {
}
