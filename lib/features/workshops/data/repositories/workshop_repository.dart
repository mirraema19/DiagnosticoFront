import 'package:proyecto/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';

class WorkshopRepository {
  final WorkshopRemoteDataSource _remoteDataSource;

  WorkshopRepository({required WorkshopRemoteDataSource remoteDataSource}) 
    : _remoteDataSource = remoteDataSource;

  // Este método ahora llamará a getWorkshops del data source, que a su vez llama a /nearby
  Future<List<Workshop>> fetchWorkshops() async {
    return await _remoteDataSource.getWorkshops();
  }
  
  // Este método filtra los resultados que ya obtuvimos del backend
  Future<List<Workshop>> fetchWorkshopsBySpecialty(String specialty) async {
    final allWorkshops = await _remoteDataSource.getWorkshops();
    return allWorkshops
        .where((w) => w.specialties.any((s) => s.toLowerCase() == specialty.toLowerCase()))
        .toList();
  }
}