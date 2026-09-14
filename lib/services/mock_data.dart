import '../models/models.dart';
import 'seed_data.dart';

class MockData {
  static List<ServiceCategory> get categories => SeedData.categories;
  static List<ServiceItem> get services => SeedData.services;
  static Technician get defaultTechnician => SeedData.technicians.first;
}
