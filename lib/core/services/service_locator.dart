import 'package:get_it/get_it.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/core/services/token_storage_service.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/garaje/presentation/data/datasources/vehicle_remote_data_source.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';
import 'package:proyecto/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/history/data/models/datasources/maintenance_remote_data_source.dart';
import 'package:proyecto/features/history/data/repositories/maintenance_repository.dart';
import 'package:proyecto/features/appointments/data/datasources/reminder_remote_data_source.dart';
import 'package:proyecto/features/appointments/data/repositories/reminder_repository.dart';
import 'package:proyecto/features/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:proyecto/features/appointments/data/repositories/appointment_repository.dart';
import 'package:proyecto/features/workshop_admin/data/datasources/workshop_admin_remote_data_source.dart';
import 'package:proyecto/features/workshop_admin/data/repositories/workshop_admin_repository.dart';
import 'package:proyecto/features/diagnosis/data/datasources/diagnosis_remote_data_source.dart';
import 'package:proyecto/features/diagnosis/data/repositories/diagnosis_repository.dart';

final sl = GetIt.instance;

void setupLocator() {
  // --- CORE ---
  sl.registerLazySingleton(() => TokenStorageService());

  // --- API CLIENTS ---
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'https://auth-service-autogiad.onrender.com', 
      tokenStorage: sl()
    ),
    instanceName: 'AuthApiClient',
  );
  
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'https://vehicle-service-autodiag.onrender.com/api', 
      tokenStorage: sl()
    ),
    instanceName: 'VehicleApiClient',
  );
  
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'https://workshop-service-autodiag.onrender.com/api/workshops/workshops', 
      tokenStorage: sl()
    ),
    instanceName: 'WorkshopApiClient',
  );
  
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'https://ai-diagnosis-service-autodiag.onrender.com',
      tokenStorage: sl()
    ),
    instanceName: 'DiagnosisApiClient',
  );

  // Appointment Service API Client
  // TODO: Actualizar esta URL cuando despliegues el servicio en Render
  // Para pruebas locales usa: 'http://localhost:3000/api'
  // Para producción usa: 'https://appointment-service-autodiag.onrender.com/api'
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'https://appointment-service-autodiag.onrender.com/api',
      tokenStorage: sl()
    ),
    instanceName: 'AppointmentApiClient',
  );

  // --- DATA SOURCES ---
  sl.registerLazySingleton(() => AuthRemoteDataSource(apiClient: sl(instanceName: 'AuthApiClient')));
  sl.registerLazySingleton(() => VehicleRemoteDataSource(apiClient: sl(instanceName: 'VehicleApiClient')));
  sl.registerLazySingleton(() => WorkshopRemoteDataSource(apiClient: sl(instanceName: 'WorkshopApiClient')));
  sl.registerLazySingleton(() => WorkshopAdminRemoteDataSource(apiClient: sl(instanceName: 'WorkshopApiClient')));
  sl.registerLazySingleton(() => MaintenanceRemoteDataSource(apiClient: sl(instanceName: 'VehicleApiClient')));
  sl.registerLazySingleton(() => ReminderRemoteDataSource(apiClient: sl(instanceName: 'VehicleApiClient')));
  sl.registerLazySingleton(() => AppointmentRemoteDataSource(apiClient: sl(instanceName: 'AppointmentApiClient')));
  sl.registerLazySingleton(() => DiagnosisRemoteDataSource(dio: sl<ApiClient>(instanceName: 'DiagnosisApiClient').dio));

  // --- REPOSITORIES ---
  sl.registerLazySingleton(() => AuthRepository(remoteDataSource: sl(), tokenStorage: sl()));
  sl.registerLazySingleton(() => GarageRepository(remoteDataSource: sl()));
  sl.registerLazySingleton(() => WorkshopRepository(remoteDataSource: sl()));
  sl.registerLazySingleton(() => WorkshopAdminRepository(remoteDataSource: sl()));
  sl.registerLazySingleton(() => MaintenanceRepository(dataSource: sl(), garageRepository: sl()));
  sl.registerLazySingleton(() => ReminderRepository(dataSource: sl(), garageRepository: sl()));
  sl.registerLazySingleton(() => AppointmentRepository(remoteDataSource: sl()));
  sl.registerLazySingleton(() => DiagnosisRepository(dataSource: sl()));
}