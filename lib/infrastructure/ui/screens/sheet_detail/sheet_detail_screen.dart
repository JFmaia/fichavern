import 'package:fichavern/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

/// Provider autoDispose parametrizado por ID — cada ficha tem seu próprio cache.
final _sheetProvider =
    FutureProvider.autoDispose.family<Sheet?, String>((ref, id) async {
  return ref.watch(fichaRepositoryProvider).findById(id);
});

class SheetDetailScreen extends ConsumerWidget {
  const SheetDetailScreen({super.key, required this.sheetId});

  final String sheetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetAsync = ref.watch(_sheetProvider(sheetId));

    return Scaffold(
      appBar: AppBar(title: const Text('Ficha')),
      body: sheetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (sheet) => sheet == null
            ? const Center(child: Text('Ficha não encontrada.'))
            : _SheetDetail(sheet: sheet),
      ),
    );
  }
}

class _SheetDetail extends ConsumerWidget {
  const _SheetDetail({required this.sheet});
  final Sheet sheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.read(engineProvider);
    final derived = engine.derive(sheet);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sheet.character.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '${sheet.systemId.toUpperCase()} · Nível ${sheet.level}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 32),

          // Estatísticas principais
          _SectionTitle('Estatísticas'),
          _StatRow('Pontos de Vida', '${derived.hitPoints}'),
          _StatRow('Classe de Armadura', '${derived.armorClass}'),
          _StatRow('Deslocamento', '${derived.speed} ft'),
          const SizedBox(height: 24),

          // Atributos
          _SectionTitle('Atributos'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: derived.abilities.entries.map((e) {
              final mod = derived.modifiers[e.key] ?? 0;
              final sign = mod >= 0 ? '+' : '';
              return _AbilityCard(
                label: _shortAbility(e.key),
                value: e.value,
                modifier: '$sign$mod',
              );
            }).toList(),
          ),

          // Perícias treinadas
          if (derived.skills.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle('Perícias'),
            const SizedBox(height: 4),
            ...derived.skills.entries.map((e) {
              final sign = e.value >= 0 ? '+' : '';
              return _StatRow(_shortRef(e.key), '$sign${e.value}');
            }),
          ],

          // Proficiências
          if (derived.proficiencies.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle('Proficiências'),
            const SizedBox(height: 4),
            Text(derived.proficiencies.map(_shortRef).join(', ')),
          ],

          // Traços
          if (derived.grantedTraits.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle('Traços'),
            const SizedBox(height: 4),
            Text(derived.grantedTraits.map(_shortRef).join(', ')),
          ],
        ],
      ),
    );
  }

  String _shortAbility(String key) => switch (key) {
        'strength' => 'FOR',
        'dexterity' => 'DES',
        'constitution' => 'CON',
        'intelligence' => 'INT',
        'wisdom' => 'SAB',
        'charisma' => 'CAR',
        _ => key.substring(0, 3).toUpperCase(),
      };

  String _shortRef(String ref) {
    final parts = ref.split('.');
    return parts.last.replaceAll('_', ' ');
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      );
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({
    required this.label,
    required this.value,
    required this.modifier,
  });
  final String label;
  final int value;
  final String modifier;

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
            Text('$value',
                style: Theme.of(context).textTheme.titleLarge),
            Text(modifier,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}
