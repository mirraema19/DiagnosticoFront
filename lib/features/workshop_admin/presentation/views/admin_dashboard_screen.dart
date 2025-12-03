import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';

// Vistas de las pestañas
import 'package:proyecto/features/workshop_admin/presentation/views/admin_workshops_screen.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/tabs/admin_reviews_tab.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/tabs/admin_stats_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<AdminWorkshopBloc>().add(LoadMyWorkshops());
  }

  // --- MÉTODO CORREGIDO: AHORA RECIBE EL ESTADO ---
  Widget? _buildFloatingActionButton(AdminWorkshopState state) {
    
    // Verificamos si hay talleres registrados
    bool hasWorkshops = false;
    if (state is AdminLoaded) {
      hasWorkshops = state.workshops.isNotEmpty;
    }

    if (_selectedIndex == 0) {
      // Pestaña MIS TALLERES: Siempre permite crear taller
      return FloatingActionButton.extended(
        onPressed: () {
          context.push('/admin/create-workshop');
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('Registrar Taller'),
      );
    } else if (_selectedIndex == 1) {
      // Pestaña AGENDA: Validamos si tiene talleres antes de permitir registrar servicio
      return FloatingActionButton.extended(
        onPressed: () {
          if (hasWorkshops) {
            // SI tiene talleres, puede registrar servicio
            context.push('/admin/add-service');
          } else {
            // NO tiene talleres, mostramos alerta y sugerimos ir a crear uno
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Debes registrar un taller primero para ofrecer servicios.'),
                action: SnackBarAction(
                  label: 'IR A CREAR',
                  onPressed: () => setState(() => _selectedIndex = 0), // Mueve a la pestaña 0
                ),
              ),
            );
          }
        },
        // Cambiamos el color a gris si está deshabilitado visualmente (opcional)
        backgroundColor: hasWorkshops ? Colors.indigo : Colors.grey,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.post_add),
        label: const Text('Nuevo Servicio'),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminWorkshopBloc, AdminWorkshopState>(
      builder: (context, state) {
        
        List<Workshop> myWorkshops = [];
        if (state is AdminLoaded) {
          myWorkshops = state.workshops;
        }

        final List<Widget> widgetOptions = <Widget>[
          const AdminWorkshopsScreen(),
          const AppointmentsTab(),
          AdminStatsTab(myWorkshops: myWorkshops),
          AdminReviewsTab(myWorkshops: myWorkshops),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Taller'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar Sesión',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  context.go('/login');
                },
              )
            ],
          ),
          
          body: widgetOptions.elementAt(_selectedIndex),

          // Pasamos el estado actual al método del botón
          floatingActionButton: _buildFloatingActionButton(state),

          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.store_mall_directory),
                label: 'Mis Talleres',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Agenda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Reportes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.reviews),
                label: 'Reseñas',
              ),
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}

// ... (AppointmentsTab y StatsTab quedan igual)
class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});
  @override
  Widget build(BuildContext context) {
     return const Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey),
           SizedBox(height: 16),
           Text("Agenda de Citas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
           SizedBox(height: 8),
           Padding(
             padding: EdgeInsets.symmetric(horizontal: 32.0),
             child: Text(
               "Aquí verás las solicitudes de citas.\nUsa 'Nuevo Servicio' para registrar en bitácora.",
               textAlign: TextAlign.center,
               style: TextStyle(color: Colors.grey),
             ),
           ),
         ],
       ),
     );
  }
}