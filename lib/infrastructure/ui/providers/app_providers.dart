import 'package:fichavern/application/auth/auth_port.dart';
import 'package:fichavern/application/create_sheet/create_sheet_use_case.dart';
import 'package:fichavern/application/create_sheet/list_sheets_use_case.dart';
import 'package:fichavern/domain/domain.dart';
import 'package:fichavern/domain/systems/dnd5e/dnd5e_plugin.dart';
import 'package:fichavern/infrastructure/supabase/supabase_auth_service.dart';
import 'package:fichavern/infrastructure/supabase/supabase_ficha_repository.dart';
import 'package:fichavern/infrastructure/ui/screens/create_sheet/sheet_creation_notifier.dart';
import 'package:fichavern/infrastructure/ui/screens/create_sheet/sheet_creation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Infraestrutura
// ---------------------------------------------------------------------------

final authServiceProvider = Provider<AuthPort>(
  (ref) => SupabaseAuthService(Supabase.instance.client),
);

final fichaRepositoryProvider = Provider<FichaRepository>(
  (ref) => SupabaseFichaRepository(Supabase.instance.client),
);

// ---------------------------------------------------------------------------
// Domínio
// ---------------------------------------------------------------------------

final systemProvider = Provider<SistemaDeRPG>(
  (ref) => const Dnd5ePlugin(),
);

final engineProvider = Provider<CharacterCreationEngine>(
  (ref) => CharacterCreationEngine(ref.watch(systemProvider)),
);

// ---------------------------------------------------------------------------
// Auth state — stream do Supabase
// ---------------------------------------------------------------------------

final authStateProvider = StreamProvider<User?>(
  (ref) => Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user),
);

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------

final createSheetUseCaseProvider = Provider<CreateSheetUseCase>(
  (ref) => CreateSheetUseCase(ref.watch(fichaRepositoryProvider)),
);

final listSheetsUseCaseProvider = Provider<ListSheetsUseCase>(
  (ref) => ListSheetsUseCase(ref.watch(fichaRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Listagem de fichas (recarregada ao chamar ref.invalidate)
// ---------------------------------------------------------------------------

final sheetListProvider =
    FutureProvider.autoDispose<List<SheetSummary>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  return ref.watch(listSheetsUseCaseProvider).execute(userId);
});

// ---------------------------------------------------------------------------
// Wizard de criação
// ---------------------------------------------------------------------------

final sheetCreationProvider = StateNotifierProvider.autoDispose<
    SheetCreationNotifier, SheetCreationState>(
  (ref) => SheetCreationNotifier(ref.watch(engineProvider)),
);
