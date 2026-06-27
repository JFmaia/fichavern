import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/domain.dart';
import 'dto/sheet_dto.dart';

/// Adaptador Supabase para `FichaRepository`.
/// O domínio nunca importa este arquivo — ele é injetado em runtime.
final class SupabaseFichaRepository implements FichaRepository {
  final SupabaseClient _client;

  const SupabaseFichaRepository(this._client);

  @override
  Future<void> save(Sheet sheet) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Usuário não autenticado');

    await _client.from('sheets').upsert(SheetDto.toRow(sheet, userId));
  }

  @override
  Future<Sheet?> findById(String id) async {
    final row = await _client
        .from('sheets')
        .select()
        .eq('id', id)
        .maybeSingle();

    return row == null ? null : SheetDto.fromRow(row);
  }

  @override
  Future<List<SheetSummary>> listByUser(String userId) async {
    final rows = await _client
        .from('sheets')
        .select('id, system_id, level, character')
        .eq('user_id', userId)
        .order('created_at');

    return rows.map(SheetDto.summaryFromRow).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('sheets').delete().eq('id', id);
  }
}
