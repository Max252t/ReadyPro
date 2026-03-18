import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/section.dart';
import 'package:ready_pro/repositories/section_repository.dart';

class SupabaseSectionRepository implements SectionRepository {
  final SupabaseClient _client;

  SupabaseSectionRepository(this._client);

  @override
  Future<List<Section>> getSectionsByEvent(String eventId) async {
    final response = await _client
        .from('sections')
        .select()
        .eq('event_id', eventId)
        .order('name');
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Section.fromJson(json)).toList();
  }

  @override
  Future<Section> getSectionById(String id) async {
    final data = await _client
        .from('sections')
        .select()
        .eq('id', id)
        .single();
    return Section.fromJson(data);
  }

  @override
  Future<void> createSection(Section section) async {
    await _client.from('sections').insert({
      'event_id': section.eventId,
      'name': section.name,
      'description': section.description,
      'curator_id': section.curatorId,
      'progress': 0,
    });
  }

  @override
  Future<void> updateSection(Section section) async {
    await _client.from('sections').update({
      'name': section.name,
      'description': section.description,
      'curator_id': section.curatorId,
      'final_report': section.finalReport,
    }).eq('id', section.id);
  }

  @override
  Future<void> deleteSection(String id) async {
    await _client.from('sections').delete().eq('id', id);
  }
}
