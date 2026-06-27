import 'package:fichavern/infrastructure/ui/providers/app_providers.dart';
import 'package:fichavern/infrastructure/ui/screens/login_screen.dart';
import 'package:fichavern/infrastructure/ui/screens/sheet_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_KEY');

Future<void> main() async {
  assert(_supabaseUrl.isNotEmpty,
      'SUPABASE_URL não definido — rode com --dart-define-from-file=config/dev.json');
  assert(_supabaseAnonKey.isNotEmpty,
      'SUPABASE_KEY não definido — rode com --dart-define-from-file=config/dev.json');

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );

  runApp(const ProviderScope(child: FichavApp()));
}

class FichavApp extends StatelessWidget {
  const FichavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fichavern',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

/// Escuta o stream de auth e decide qual tela exibir.
/// Enquanto carrega, mostra um splash de loading.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro de autenticação: $e')),
      ),
      data: (user) =>
          user != null ? const SheetListScreen() : const LoginScreen(),
    );
  }
}
