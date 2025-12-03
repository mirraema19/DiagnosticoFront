import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';

// EVENTOS
abstract class AdminWorkshopEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadMyWorkshops extends AdminWorkshopEvent {}
class CreateWorkshopEvent extends AdminWorkshopEvent {
  final Map<String, dynamic> data;
  CreateWorkshopEvent(this.data);
}
class UpdateWorkshopEvent extends AdminWorkshopEvent {
  final String id;
  final Map<String, dynamic> data;
  UpdateWorkshopEvent(this.id, this.data);
}
class DeleteWorkshopEvent extends AdminWorkshopEvent {
  final String id;
  DeleteWorkshopEvent(this.id);
}
// Eventos para detalles (Schedule/Specialties)
class UpdateScheduleEvent extends AdminWorkshopEvent {
  final String workshopId;
  final List<Map<String, dynamic>> schedule;
  UpdateScheduleEvent(this.workshopId, this.schedule);
}
class AddSpecialtyEvent extends AdminWorkshopEvent {
  final String workshopId;
  final Map<String, dynamic> data;
  AddSpecialtyEvent(this.workshopId, this.data);
}
class DeleteSpecialtyEvent extends AdminWorkshopEvent {
  final String workshopId;
  final String specialtyId;
  DeleteSpecialtyEvent(this.workshopId, this.specialtyId);
}

// ESTADOS
abstract class AdminWorkshopState extends Equatable {
  @override List<Object?> get props => [];
}
class AdminLoading extends AdminWorkshopState {}
class AdminLoaded extends AdminWorkshopState {
  final List<Workshop> workshops;
  AdminLoaded(this.workshops);
  @override List<Object?> get props => [workshops];
}
class AdminOperationSuccess extends AdminWorkshopState {
  final String message;
  AdminOperationSuccess(this.message);
}
class AdminError extends AdminWorkshopState {
  final String message;
  AdminError(this.message);
  @override List<Object?> get props => [message];
}

// BLOC
class AdminWorkshopBloc extends Bloc<AdminWorkshopEvent, AdminWorkshopState> {
  final WorkshopRepository _repository = sl<WorkshopRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();

  AdminWorkshopBloc() : super(AdminLoading()) {
    on<LoadMyWorkshops>(_onLoadMyWorkshops);
    on<CreateWorkshopEvent>(_onCreateWorkshop);
    on<UpdateWorkshopEvent>(_onUpdateWorkshop);
    on<DeleteWorkshopEvent>(_onDeleteWorkshop);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<AddSpecialtyEvent>(_onAddSpecialty);
    on<DeleteSpecialtyEvent>(_onDeleteSpecialty);
  }

  Future<void> _onLoadMyWorkshops(LoadMyWorkshops event, Emitter<AdminWorkshopState> emit) async {
    emit(AdminLoading());
    try {
      // 1. Obtener usuario actual
      final currentUser = await _authRepository.currentUser;
      if (currentUser == null) {
        emit(AdminError("No hay sesión activa"));
        return;
      }

      // 2. Llamar al repositorio pasando el ID
      final workshops = await _repository.getMyWorkshops(currentUser.id);
      
      emit(AdminLoaded(workshops));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onCreateWorkshop(CreateWorkshopEvent event, Emitter<AdminWorkshopState> emit) async {
    try {
      await _repository.createWorkshop(event.data);
      emit(AdminOperationSuccess("Taller creado exitosamente"));
      add(LoadMyWorkshops());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateWorkshop(UpdateWorkshopEvent event, Emitter<AdminWorkshopState> emit) async {
    try {
      await _repository.updateWorkshop(event.id, event.data);
      emit(AdminOperationSuccess("Taller actualizado"));
      add(LoadMyWorkshops());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteWorkshop(DeleteWorkshopEvent event, Emitter<AdminWorkshopState> emit) async {
    try {
      await _repository.deleteWorkshop(event.id);
      emit(AdminOperationSuccess("Taller eliminado"));
      add(LoadMyWorkshops());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateSchedule(UpdateScheduleEvent event, Emitter<AdminWorkshopState> emit) async {
    try {
      await _repository.setSchedule(event.workshopId, event.schedule);
      emit(AdminOperationSuccess("Horario actualizado"));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAddSpecialty(AddSpecialtyEvent event, Emitter<AdminWorkshopState> emit) async {
    try {
      await _repository.addSpecialty(event.workshopId, event.data);
      emit(AdminOperationSuccess("Especialidad agregada"));
    } catch (e) {
      // Detectar error 409 (duplicado)
      if (e.toString().contains('409')) {
        emit(AdminError("Esta especialidad ya existe en el taller"));
      } else {
        emit(AdminError("Error al agregar especialidad: ${e.toString()}"));
      }
    }
  }

  Future<void> _onDeleteSpecialty(DeleteSpecialtyEvent event, Emitter<AdminWorkshopState> emit) async {
    try {
      await _repository.deleteSpecialty(event.workshopId, event.specialtyId);
      emit(AdminOperationSuccess("Especialidad eliminada"));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}