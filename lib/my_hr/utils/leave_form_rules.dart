class LeaveFormRules {
  static DateTime dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  static double totalDays(
    DateTime from,
    DateTime to,
    String fromDuration,
    String toDuration,
  ) {
    final days = dateOnly(to).difference(dateOnly(from)).inDays + 1;
    if (days <= 0) return 0;
    if (days == 1) {
      if (fromDuration != toDuration) return 0;
      return fromDuration == 'FULL_DAY' ? 1 : 0.5;
    }
    return days -
        (fromDuration == 'FULL_DAY' ? 0 : 0.5) -
        (toDuration == 'FULL_DAY' ? 0 : 0.5);
  }

  static int? cycleId(Map cycle) => int.tryParse(
    (cycle['id'] ?? cycle['yearId'] ?? cycle['cycleId'] ?? '').toString(),
  );

  static ({DateTime start, DateTime end})? cycleBounds(Map cycle) {
    final start = DateTime.tryParse(
      (cycle['fromDate'] ?? cycle['startDate'] ?? '').toString(),
    );
    final end = DateTime.tryParse(
      (cycle['toDate'] ?? cycle['endDate'] ?? '').toString(),
    );
    if (start != null && end != null) {
      return (start: dateOnly(start), end: dateOnly(end));
    }
    final name = (cycle['name'] ?? '').toString();
    // FY labels represent the Indian April–March financial year.
    final match = RegExp(
      r'^(?:FY|Financial\s+Year)\s*(\d{4})\s*[-–/]\s*(\d{2}|\d{4})$',
      caseSensitive: false,
    ).firstMatch(name.trim());
    if (match == null) return null;
    final first = int.parse(match.group(1)!);
    final lastText = match.group(2)!;
    final last = lastText.length == 2
        ? (first ~/ 100) * 100 + int.parse(lastText)
        : int.parse(lastText);
    if (last != first + 1) return null;
    return (start: DateTime.utc(first, 4, 1), end: DateTime.utc(last, 3, 31));
  }

  static bool covers(Map cycle, DateTime from, DateTime to) {
    final bounds = cycleBounds(cycle);
    return bounds != null &&
        !dateOnly(from).isBefore(bounds.start) &&
        !dateOnly(to).isAfter(bounds.end);
  }

  static int? currentCycleId(List<dynamic> cycles, DateTime date) {
    final matches = cycles
        .whereType<Map>()
        .where((cycle) => cycleId(cycle) != null && covers(cycle, date, date))
        .toList();
    if (matches.length == 1) return cycleId(matches.single);
    final active = cycles
        .whereType<Map>()
        .where(
          (cycle) =>
              cycleId(cycle) != null &&
              cycleBounds(cycle) == null &&
              cycle['status']?.toString().toUpperCase() == 'ACTIVE',
        )
        .toList();
    return matches.isEmpty && active.length == 1
        ? cycleId(active.single)
        : null;
  }

  static Map<String, dynamic> checkedResponse(dynamic response) {
    if (response is! Map || response.isEmpty) {
      throw Exception(
        'The server returned no leave confirmation. Refresh requests before retrying.',
      );
    }
    final result = Map<String, dynamic>.from(response);
    final status = result['status']?.toString().toUpperCase();
    final code = int.tryParse(
      (result['statusCode'] ?? result['code'] ?? '').toString(),
    );
    final error = result['error'];
    final hasError =
        error != null &&
        error != false &&
        (error is String
            ? error.trim().isNotEmpty
            : error is Map
            ? error.isNotEmpty
            : error is List
            ? error.isNotEmpty
            : true);
    if (result['success'] == false ||
        result['success'] == 'false' ||
        hasError ||
        ['ERROR', 'FAILED', 'FAILURE', 'FALSE'].contains(status) ||
        code != null && code >= 400) {
      throw Exception(
        result['message'] ?? result['error'] ?? 'Leave request was rejected.',
      );
    }
    return result;
  }
}
