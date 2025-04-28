part of 'clients_cubit.dart';

abstract class ClientsState extends Equatable {
  const ClientsState();

  @override
  List<Object> get props => [];
}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<User> clients;

  const ClientsLoaded({required this.clients});

  @override
  List<Object> get props => [clients];
}

class ClientsError extends ClientsState {
  final String message;

  const ClientsError({required this.message});

  @override
  List<Object> get props => [message];
}
