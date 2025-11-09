import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';

class WorkshopRepository {
  final List<Workshop> _workshops = [
    Workshop(
      id: '1',
      name: 'Taller Mecánico Central',
      address: 'Av. Principal 1234',
      phone: '+1 555-0101',
      operatingHours: 'L-V 8am - 6pm',
      description: 'Con más de 20 años de experiencia, ofrecemos un servicio de confianza para todo tipo de vehículos. Nos especializamos en diagnóstico y reparación de motores.',
      rating: 4.8,
      reviewCount: 120,
      distance: 1.2,
      imageUrl: 'assets/images/workshop_placeholder.png',
      tags: ['Precios Justos', 'Servicio Rápido'],
      specialties: ['Frenos', 'Motor', 'Transmisión'],
      reviews: [
        Review(authorName: 'Ana Gómez', rating: 5, comment: 'Excelente servicio, muy profesionales y honestos. Resolvieron mi problema rápidamente.', date: DateTime(2023, 10, 25)),
        Review(authorName: 'Juan Pérez', rating: 4, comment: 'Buen trabajo, aunque tardaron un poco más de lo esperado. Los precios son justos.', date: DateTime(2023, 9, 15)),
      ],
    ),
    Workshop(
      id: '2',
      name: 'AutoExpert Pro',
      address: 'Calle Secundaria 567',
      phone: '+1 555-0102',
      operatingHours: 'L-S 9am - 7pm',
      description: 'Somos un taller moderno enfocado en la tecnología. Utilizamos equipo de última generación para diagnósticos precisos en sistemas eléctricos y de suspensión.',
      rating: 4.6,
      reviewCount: 95,
      distance: 2.5,
      imageUrl: 'assets/images/workshop_placeholder.png',
      tags: ['Buena Comunicación', 'Especialistas'],
      specialties: ['Electricidad', 'Motor', 'Suspensión'],
      reviews: [
        Review(authorName: 'Carlos Rodriguez', rating: 5, comment: 'Me explicaron todo el proceso con mucha paciencia. Muy recomendados.', date: DateTime(2023, 11, 2)),
        Review(authorName: 'Laura Martinez', rating: 4, comment: 'El diagnóstico fue acertado. El lugar está muy limpio y ordenado.', date: DateTime(2023, 10, 5)),
      ],
    ),
    const Workshop(
      id: '3',
      name: 'Servicio Premium Motors',
      address: 'Zona Industrial 890',
      phone: '+1 555-0103',
      operatingHours: 'L-V 7am - 5pm',
      description: 'Ofrecemos un servicio de alta gama con garantía extendida en todas nuestras reparaciones. Especialistas en llantas y sistemas de aire acondicionado.',
      rating: 4.9,
      reviewCount: 210,
      distance: 3.8,
      imageUrl: 'assets/images/workshop_placeholder.png',
      tags: ['Servicio Premium', 'Garantía'],
      specialties: ['Frenos', 'Llantas', 'Aire Acondicionado'],
      reviews: [], // Taller sin reseñas para ver cómo se maneja el caso
    ),
  ];

  Future<List<Workshop>> fetchWorkshops() async {
    await Future.delayed(const Duration(seconds: 1));
    return _workshops;
  }
  
  Future<List<Workshop>> fetchWorkshopsBySpecialty(String specialty) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _workshops
        .where((w) => w.specialties.any((s) => s.toLowerCase() == specialty.toLowerCase()))
        .toList();
  }
}