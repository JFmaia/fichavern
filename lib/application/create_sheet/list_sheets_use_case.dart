import 'package:fichavern/domain/domain.dart';

/// Lista resumos das fichas salvas pelo usuário.
final class ListSheetsUseCase {
  final FichaRepository _repository;

  const ListSheetsUseCase(this._repository);

  Future<List<SheetSummary>> execute(String userId) =>
      _repository.listByUser(userId);
}
