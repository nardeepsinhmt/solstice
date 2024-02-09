import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solstice/features/terms_condition/bloc/terms_condition_cubit.dart';
import 'package:solstice/features/terms_condition/screens/terms_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TermsCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Solstice Assignment',
        theme: ThemeData(
          fontFamily: 'Satoshi',
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const TermsScreen(),
      ),
    );
  }
}
