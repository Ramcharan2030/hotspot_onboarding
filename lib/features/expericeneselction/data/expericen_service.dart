import 'package:dio/dio.dart';

import 'package:hottspot_onboarding/features/expericeneselction/data/experince_model.dart';

class ExperienceService {
  final Dio _dio = Dio();

  Future<List<ExperienceModel>> fetchExperiences() async {
    try {
      final response = await _dio.get(
        'https://staging.chamberofsecrets.8club.co/v1/experiences?active=true',
      );

      final List data = response.data['data']['experiences'];
      return data.map((e) => ExperienceModel.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching experiences: $e");
      return [];
    }
  }
}
