import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Creamos el BLoC aquí para que esté disponible en esta pantalla y las sub-pantallas
      create: (context) => GarageBloc()..add(LoadGarageData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Garaje'),
        ),
        body: BlocBuilder<GarageBloc, GarageState>(
          builder: (context, state) {
            if (state is GarageLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GarageLoaded) {
              if (state.vehicles.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Aún no tienes vehículos. ¡Añade el primero!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  // Permite al usuario "deslizar para recargar" la lista
                  context.read<GarageBloc>().add(LoadGarageData());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = state.vehicles[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          context.push('/garage/details', extra: vehicle);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              // --- CORRECCIÓN IMPLEMENTADA ---
                              // Intenta cargar desde una URL. Si falla, usa una imagen local.
                              child: Image.network(
                                vehicle.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/civic.jpg', // Imagen local de respaldo
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                '${vehicle.make} ${vehicle.model}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${vehicle.mileage} km'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            if (state is GarageError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Algo salió mal.'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                // Navega a la pantalla de añadir, que ahora necesita el GarageBloc.
                // GoRouter se encargará de que el BlocProvider.value funcione.
                context.push('/garage/add');
              },
              label: const Text('Añadir Vehículo'),
              icon: const Icon(Icons.add),
            );
          }
        ),
      ),
    );
  }
}