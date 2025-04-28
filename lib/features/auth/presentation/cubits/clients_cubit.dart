import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_clients.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final GetClients getClients;

  ClientsCubit({required this.getClients}) : super(ClientsInitial());

  Future<void> loadClients() async {
    emit(ClientsLoading());

    final result = await getClients();

    result.fold(
      (failure) => emit(ClientsError(message: failure.message)),
      (clients) => emit(ClientsLoaded(clients: clients)),
    );
  }
}
