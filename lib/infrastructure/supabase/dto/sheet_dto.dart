import '../../../domain/domain.dart';

/// Serialização `Sheet` ↔ `Map<String, dynamic>` para persistência no Supabase.
/// Responsabilidade exclusiva da infraestrutura — o domínio nunca importa este arquivo.
final class SheetDto {
  SheetDto._();

  static Map<String, dynamic> toRow(Sheet sheet, String userId) => {
        'id': sheet.id,
        'user_id': userId,
        'system_id': sheet.systemId,
        'level': sheet.level,
        'base_abilities': sheet.baseAbilities,
        'tree': sheet.choices.map(_choiceToJson).toList(),
        'character': _characterToJson(sheet.character),
      };

  static Sheet fromRow(Map<String, dynamic> row) => Sheet(
        id: row['id'] as String,
        systemId: row['system_id'] as String,
        level: row['level'] as int,
        baseAbilities: Map<String, int>.from(row['base_abilities'] as Map),
        choices: (row['tree'] as List).map(_choiceFromJson).toList(),
        character: _characterFromJson(
          Map<String, dynamic>.from(row['character'] as Map),
        ),
      );

  static SheetSummary summaryFromRow(Map<String, dynamic> row) => SheetSummary(
        id: row['id'] as String,
        systemId: row['system_id'] as String,
        level: row['level'] as int,
        characterName: (Map<String, dynamic>.from(row['character'] as Map))['name'] as String,
      );

  // --- Choice (recursivo) ---

  static Map<String, dynamic> _choiceToJson(Choice c) => {
        'step': c.step,
        'option_id': c.optionId,
        'children': c.children.map(_choiceToJson).toList(),
      };

  static Choice _choiceFromJson(dynamic json) {
    final m = Map<String, dynamic>.from(json as Map);
    return Choice(
      step: m['step'] as StepId,
      optionId: m['option_id'] as String,
      children: (m['children'] as List? ?? []).map(_choiceFromJson).toList(),
    );
  }

  // --- Character ---

  static Map<String, dynamic> _characterToJson(Character c) => {
        'name': c.name,
        'story': c.story,
        'characteristics': c.characteristics,
        'traits': c.traits,
      };

  static Character _characterFromJson(Map<String, dynamic> m) => Character(
        name: m['name'] as String,
        story: m['story'] as String,
        characteristics: m['characteristics'] as String,
        traits: List<String>.from(m['traits'] as List),
      );
}
