import 'package:proyecto/features/appointments/data/models/appointment_model.dart';

class AppointmentRepository {
  // Simulación de base de datos en memoria
  final List<Appointment> _appointments = [
    Appointment(
      id: 'a1',
      date: DateTime.now().add(const Duration(days: 5, hours: 2)),
      workshopName: 'Taller Mecánico Central',
      serviceType: 'Cambio de aceite y filtros',
      status: AppointmentStatus.received,
    ),
     Appointment(
      id: 'a2',
      date: DateTime.now().subtract(const Duration(days: 10)),
      workshopName: 'AutoExpert Pro',
      serviceType: 'Revisión de frenos',
      status: AppointmentStatus.completed,
    ),
  ];

  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _appointments.sort((a, b) => b.date.compareTo(a.date)); // Ordenar por fecha
    return _appointments;
  }

  // MÉTODO NUEVO PARA AÑADIR CITAS
  Future<void> addAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _appointments.add(appointment);
  }
}