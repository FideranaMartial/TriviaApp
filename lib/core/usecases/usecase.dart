/// Contrat générique pour tous les Use Cases.
/// [Type] = type de retour, [Params] = paramètres d'entrée.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Utilisé quand un use case n'a pas besoin de paramètres.
class NoParams {
  const NoParams();
}