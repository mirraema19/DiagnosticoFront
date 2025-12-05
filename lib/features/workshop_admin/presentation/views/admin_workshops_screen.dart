import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';

class AdminWorkshopsScreen extends StatefulWidget {
  const AdminWorkshopsScreen({super.key});

  @override
  State<AdminWorkshopsScreen> createState() => _AdminWorkshopsScreenState();
}

class _AdminWorkshopsScreenState extends State<AdminWorkshopsScreen> {
  // Nota: La carga inicial (LoadMyWorkshops) ya se hace en el Dashboard padre,
  // pero no hace daño dejarla aquí para asegurar que se refresque si entras directo.
  @override
  void initState() {
    super.initState();
    context.read<AdminWorkshopBloc>().add(LoadMyWorkshops());
  }

  @override
  Widget build(BuildContext context) {
    // Ya no usamos Scaffold aquí porque esta vista es parte del 'body' del Dashboard
    return BlocBuilder<AdminWorkshopBloc, AdminWorkshopState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminLoaded) {
          if (state.workshops.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- CORRECCIÓN AQUÍ: Usamos un icono estándar ---
                  Icon(Icons.store, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No has registrado ningún taller.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.workshops.length,
            itemBuilder: (context, index) {
              final workshop = state.workshops[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.store, color: Colors.blue.shade800),
                  ),
                  title: Text(
                    workshop.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(workshop.address),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        workshop.isApproved ? Icons.check_circle : Icons.hourglass_empty,
                        color: workshop.isApproved ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workshop.isApproved ? 'Activo' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 10,
                          color: workshop.isApproved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    // Navegar a editar
                    context.push('/admin/edit-workshop', extra: workshop);
                  },
                ),
              );
            },
          );
        }
        if (state is AdminError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}