import '../../../../core/network/api_client.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeModel>> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<HomeModel>> getHomeData() async {
    // In a real app, you would fetch from an actual API endpoint
    // For demo purposes, we're returning mock data
    final mockData = [
      {
        'title': 'Welcome',
        'description': 'Welcome to our clean architecture app',
      },
      {
        'title': 'Features',
        'description': 'Explore the features of clean architecture',
      },
    ];

    return mockData.map((json) => HomeModel.fromJson(json)).toList();
  }
}
