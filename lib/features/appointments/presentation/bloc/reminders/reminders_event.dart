part of 'reminders_bloc.dart';

abstract class RemindersEvent extends Equatable {
  const RemindersEvent();
  @override
  List<Object> get props => [];
}

class LoadReminders extends RemindersEvent {}

class AddReminder extends RemindersEvent {
  final Reminder reminder;
  const AddReminder(this.reminder);
  @override
  List<Object> get props => [reminder];
}