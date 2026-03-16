import 'package:ready_pro/models/section.dart';

abstract class SectionRepository {
  Future<List<Section>> getSectionsByEvent(String eventId);
  Future<Section> getSectionById(String id);
  Future<void> createSection(Section section);
  Future<void> updateSection(Section section);
  Future<void> deleteSection(String id);
}
