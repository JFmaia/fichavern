import 'package:fichavern/domain/domain.dart';

/// Salva uma ficha recém-criada pelo wizard no repositório.
/// O motor já foi usado na camada de UI (via provider); aqui só persiste.
final class CreateSheetUseCase {
  final FichaRepository _repository;

  const CreateSheetUseCase(this._repository);

  Future<void> execute(Sheet sheet) => _repository.save(sheet);
}
