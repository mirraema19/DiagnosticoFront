import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/appointments/presentation/bloc/reminders/reminders_bloc.dart';
import 'package:proyecto/features/appointments/data/models/reminder_model.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: BlocBuilder<RemindersBloc, RemindersState>(
        builder: (context, state) {
          if (state is RemindersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RemindersLoaded) {
            if (state.reminders.isEmpty) {
              return const Center(child: Text('No hay recordatorios activos.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reminders.length,
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];
                return _ReminderCard(reminder: reminder);
              },
            );
          }
          if (state is RemindersError) {
             return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reminders/add'),
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  const _ReminderCard({required this.reminder});

  String _formatDueValue() {
    if (reminder.dueType == 'MILEAGE') {
      return '${reminder.dueValue} km';
    } else {
      // Intentar parsear la fecha
      try {
        final date = DateTime.parse(reminder.dueValue);
        return DateFormat.yMMMd('es_ES').format(date);
      } catch (e) {
        return reminder.dueValue;
      }
    }
  }

  Color _getStatusColor() {
    switch (reminder.status) {
      case 'OVERDUE': return Colors.red;
      case 'COMPLETED': return Colors.green;
      case 'DISMISSED': return Colors.grey;
      default: return Colors.blue; // PENDING
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          reminder.dueType == 'MILEAGE' ? Icons.speed : Icons.event,
          color: Colors.amber[800],
        ),
        title: Text(reminder.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Vence: ${_formatDueValue()}'),
            if (reminder.description != null && reminder.description!.isNotEmpty)
              Text(reminder.description!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: Chip(
          label: Text(reminder.status),
          backgroundColor: _getStatusColor().withOpacity(0.1),
          labelStyle: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}