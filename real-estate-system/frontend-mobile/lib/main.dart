import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(const HoroazhonApp());
}

class HoroazhonApp extends StatelessWidget {
  const HoroazhonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: MaterialApp(
        title: 'Horoazhon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const AppShell(),
      ),
    );
  }
}
