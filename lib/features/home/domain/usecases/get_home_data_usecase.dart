import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<Either<Failure, List<HomeEntity>>> call(NoParams params) async {
    return await repository.getHomeData();
  }
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
