import '../model/sheet.dart';
import '../model/sheet_summary.dart';

/// Porta domínio↔backend. O domínio declara o contrato;
/// quem o cumpre (Supabase hoje, outro backend amanhã) é um adaptador da infraestrutura.
abstract interface class FichaRepository {
  Future<void> save(Sheet sheet);
  Future<Sheet?> findById(String id);
  Future<List<SheetSummary>> listByUser(String userId);
  Future<void> delete(String id);
}
