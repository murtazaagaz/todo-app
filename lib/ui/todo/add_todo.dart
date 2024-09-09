import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/bloc/todo_bloc/todo_bloc.dart';
import 'package:to_do_app/bloc/todo_bloc/todo_event.dart';
import 'package:to_do_app/generated/l10n.dart';

class AddToDoScreen extends StatefulWidget {
  const AddToDoScreen({super.key});

  @override
  AddToDoScreenState createState() => AddToDoScreenState();
}

class AddToDoScreenState extends State<AddToDoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller for fading
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create a fade animation that starts from 0 (invisible) and moves to 1 (visible)
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start the fade animation as soon as the screen is loaded
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Dispose of the controller to prevent memory leaks
    super.dispose();
  }

  // Save ToDo logic
  void _saveToDo() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save the ToDo item here

      context.read<ToDoBloc>().add(AddToDo(_title));
      // Show confirmation using a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).todo_added),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ToDoBloc>(context),
      child: FadeTransition(
        opacity: _fadeAnimation, // Adding fade-in effect
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                // Title field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: S.of(context).title,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),

                const SizedBox(height: 16.0),

                // Save button with animation
                ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveToDo,
                    child: Text(S.of(context).saveTodo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
