import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String title;
  final String description;

  const HomeEntity({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}
