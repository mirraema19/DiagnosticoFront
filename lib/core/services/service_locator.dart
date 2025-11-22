import 'package:get_it/get_it.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/core/services/token_storage_service.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/garaje/presentation/data/datasources/vehicle_remote_data_source.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';
import 'package:proyecto/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
// Imports de Maintenance y Reminder
import 'package:proyecto/features/history/data/models/datasources/maintenance_remote_data_source.dart';
import 'package:proyecto/features/history/data/repositories/maintenance_repository.dart';
import 'package:proyecto/features/appointments/data/datasources/reminder_remote_data_source.dart';
import 'package:proyecto/features/appointments/data/repositories/reminder_repository.dart';

final sl = GetIt.instance;

void setupLocator() {
  // --- CORE ---
  sl.registerLazySingleton(() => TokenStorageService());

  // --- API CLIENTS ---
  // Auth Service (Mantiene /v1 según tu info anterior de Auth)
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: 'https://auth-service-autogiad.onrender.com', tokenStorage: sl()),
    instanceName: 'AuthApiClient',
  );
  
  // Vehicle Service (CORREGIDO: Se quita el /v1 según tus links de Postman)
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: 'https://vehicle-service-autodiag.onrender.com/api', tokenStorage: sl()),
    instanceName: 'VehicleApiClient',
  );
  
  // Workshop Service
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: 'https://workshop-service-autodiag.onrender.com/api/v1/workshops', tokenStorage: sl()),
    instanceName: 'WorkshopApiClient',
  );
  
  // --- DATA SOURCES ---
  sl.registerLazySingleton(() => AuthRemoteDataSource(apiClient: sl(instanceName: 'AuthApiClient')));
  sl.registerLazySingleton(() => VehicleRemoteDataSource(apiClient: sl(instanceName: 'VehicleApiClient')));
  sl.registerLazySingleton(() => WorkshopRemoteDataSource(apiClient: sl(instanceName: 'WorkshopApiClient')));
  
  // Nuevos Data Sources con el cliente de Vehículos
  sl.registerLazySingleton(() => MaintenanceRemoteDataSource(apiClient: sl(instanceName: 'VehicleApiClient')));
  sl.registerLazySingleton(() => ReminderRemoteDataSource(apiClient: sl(instanceName: 'VehicleApiClient')));
  
  // --- REPOSITORIES ---
  sl.registerFactory(() => AuthRepository(remoteDataSource: sl(), tokenStorage: sl()));
  sl.registerFactory(() => GarageRepository(remoteDataSource: sl()));
  sl.registerFactory(() => WorkshopRepository(remoteDataSource: sl()));
  
  // Nuevos Repositorios
  // NOTA: Inyectamos también GarageRepository en estos para poder buscar el ID del vehículo si hace falta
  sl.registerFactory(() => MaintenanceRepository(dataSource: sl(), garageRepository: sl()));
  sl.registerFactory(() => ReminderRepository(dataSource: sl(), garageRepository: sl()));
}