import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
                return const Center(child: Text('Aún no tienes vehículos.'));
              }
              return ListView.builder(
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
                            child: Image.asset(
                              vehicle.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.directions_car)),
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
              );
            }
            if (state is GarageError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Algo salió mal.'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/garage/add');
          },
          label: const Text('Añadir Vehículo'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}