import 'package:fichavern/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import 'create_sheet/create_sheet_screen.dart';
import 'sheet_detail/sheet_detail_screen.dart';

class SheetListScreen extends ConsumerWidget {
  const SheetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetsAsync = ref.watch(sheetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Fichas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: sheetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (sheets) => sheets.isEmpty
            ? const Center(child: Text('Nenhuma ficha salva ainda.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sheets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _SheetTile(summary: sheets[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateSheetScreen()),
          );
          // Recarrega a lista ao voltar da criação.
          ref.invalidate(sheetListProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova ficha'),
      ),
    );
  }
}

class _SheetTile extends ConsumerWidget {
  const _SheetTile({required this.summary});

  final SheetSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(summary.characterName),
        subtitle: Text('${summary.systemId.toUpperCase()} · Nível ${summary.level}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SheetDetailScreen(sheetId: summary.id),
          ),
        ),
      ),
    );
  }
}
