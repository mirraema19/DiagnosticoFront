import 'package:proyecto/features/workshops/data/models/workshop_model.dart';

class WorkshopRepository {
  
  Future<List<Workshop>> fetchWorkshops() async {
    await Future.delayed(const Duration(seconds: 2));

    // --- DATOS SIMULADOS ACTUALIZADOS ---
    return [
      const Workshop(
        id: '1',
        name: 'Taller Mecánico Central',
        address: 'Av. Principal 1234',
        rating: 4.8,
        reviewCount: 120,
        distance: 1.2,
        imageUrl: 'assets/images/workshop_placeholder.png',
        tags: ['Precios Justos', 'Servicio Rápido'],
      ),
      const Workshop(
        id: '2',
        name: 'AutoExpert Pro',
        address: 'Calle Secundaria 567',
        rating: 4.6,
        reviewCount: 95,
        distance: 2.5,
        imageUrl: 'assets/images/workshop_placeholder.png',
        tags: ['Buena Comunicación', 'Especialistas'],
      ),
      const Workshop(
        id: '3',
        name: 'Servicio Premium Motors',
        address: 'Zona Industrial 890',
        rating: 4.9,
        reviewCount: 210,
        distance: 3.8,
        imageUrl: 'assets/images/workshop_placeholder.png',
        tags: ['Servicio Premium', 'Garantía'],
      ),
    ];
  }
}