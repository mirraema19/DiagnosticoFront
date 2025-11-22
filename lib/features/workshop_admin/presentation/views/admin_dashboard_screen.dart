import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Lista de las pantallas/pestañas del dashboard
  static const List<Widget> _widgetOptions = <Widget>[
    AppointmentsTab(), // Pestaña de Citas
    StatsTab(),        // Pestaña de Estadísticas
    Text('Pestaña de Diagnósticos (Próximamente)'),
    Text('Pestaña de Reseñas (Próximamente)'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Taller'),
        // No mostramos la flecha de regreso
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Citas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle), label: 'Diagnósticos'),
          BottomNavigationBarItem(icon: Icon(Icons.reviews), label: 'Reseñas'),
        ],
        currentIndex: _selectedIndex,
        // Hacemos que los colores sean fijos y usen el tema
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- PESTAÑA DE CITAS (SIMULADA) ---
class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // En una implementación real, esto vendría de un BLoC
    final appointments = [
      {'client': 'Carlos Pérez', 'service': 'Cambio de aceite', 'status': 'Pendiente'},
      {'client': 'Ana Gómez', 'service': 'Revisión de frenos', 'status': 'En Diagnóstico'},
      {'client': 'Luis Fernandez', 'service': 'Alineación y balanceo', 'status': 'Listo'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(appointment['service']!),
            subtitle: Text('Cliente: ${appointment['client']}'),
            trailing: Chip(
              label: Text(appointment['status']!),
              // Lógica de color simple para el estado
              backgroundColor: appointment['status'] == 'Pendiente' 
                  ? Colors.orange.shade100
                  : appointment['status'] == 'Listo'
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
            ),
          ),
        );
      },
    );
  }
}

// --- PESTAÑA DE ESTADÍSTICAS (SIMULADA) ---
class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          StatCard(title: 'Ingresos del Mes', value: '\$2,500', icon: Icons.attach_money),
          StatCard(title: 'Clientes Atendidos', value: '35', icon: Icons.person),
          StatCard(title: 'Calificación Promedio', value: '4.8 ★', icon: Icons.star),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}