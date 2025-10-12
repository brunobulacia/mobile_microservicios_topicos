import '../../domain/models/oferta_grupo_materia.dart';
import '../../domain/repositories/oferta_grupo_materia_repository.dart';
import '../services/remote/oferta_grupo_materia_api.dart';

class OfertaGrupoMateriaRepositoryImpl implements OfertaGrupoMateriaRepository {
  OfertaGrupoMateriaRepositoryImpl(this._ofertaGrupoMateriaApi);
  final OfertaGrupoMateriaApi _ofertaGrupoMateriaApi;

  @override
  Future<List<OfertaGrupoMateria>> getOfertasGruposMaterias(
    String maestroDeOfertaId,
  ) async {
    final response = await _ofertaGrupoMateriaApi.getOfertasGruposMaterias(
      maestroDeOfertaId,
    );
    // The API already returns List<OfertaGrupoMateria>, so return it directly.
    return response.toList(growable: false);
  }
}
