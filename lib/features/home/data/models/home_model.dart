import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({required super.title, required super.description});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}
