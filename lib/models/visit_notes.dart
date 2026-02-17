import 'package:medigo_mobile/models/appointment_flag.dart';

/// Notes taken during an active appointment (manual, screenshots, AI).
class VisitNotes {
  static const _omitAiNotes = Object();

  final String manualNotes;
  final List<String> screenshotPaths;
  final String? aiNotes;
  final List<AppointmentFlag> flags;

  const VisitNotes({
    this.manualNotes = '',
    this.screenshotPaths = const [],
    this.aiNotes,
    this.flags = const [],
  });

  VisitNotes copyWith({
    String? manualNotes,
    List<String>? screenshotPaths,
    Object? aiNotes = _omitAiNotes,
    List<AppointmentFlag>? flags,
  }) {
    return VisitNotes(
      manualNotes: manualNotes ?? this.manualNotes,
      screenshotPaths: screenshotPaths ?? List.from(this.screenshotPaths),
      aiNotes: identical(aiNotes, _omitAiNotes) ? this.aiNotes : aiNotes as String?,
      flags: flags ?? List.from(this.flags),
    );
  }

  bool get hasContent =>
      manualNotes.isNotEmpty ||
      screenshotPaths.isNotEmpty ||
      (aiNotes != null && aiNotes!.isNotEmpty) ||
      flags.isNotEmpty;
}
