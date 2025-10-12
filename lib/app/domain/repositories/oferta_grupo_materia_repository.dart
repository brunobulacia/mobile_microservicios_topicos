import '../models/oferta_grupo_materia.dart';

abstract class OfertaGrupoMateriaRepository {
  Future<List<OfertaGrupoMateria>> getOfertasGruposMaterias(
    String maestroDeOfertaId,
  );
}
