import 'package:proyecto/features/appointments/data/models/appointment_model.dart';

class AppointmentRepository {
  final List<Appointment> _appointments = [
    Appointment(
      id: 'a1',
      date: DateTime.now().add(const Duration(days: 5)),
      workshopName: 'Taller Mecánico Central',
      serviceType: 'Cambio de aceite y filtros',
      status: AppointmentStatus.confirmed,
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
    return _appointments;
  }
}