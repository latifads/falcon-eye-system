import 'package:flutter/material.dart';

import 'src/screens/app_shell.dart';
import 'src/theme/app_theme.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FalconEyeApp());
}

class FalconEyeApp extends StatelessWidget {
  const FalconEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FalconEye Rescue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppShell(),
    );
  }
}
