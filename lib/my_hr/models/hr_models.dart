// ignore_for_file: non_constant_identifier_names

// All data models for the MY HR module
// Pure Dart classes – no database, no serialization dependencies

// ─────────────────────────────────────────────────────────────────────────────
// Employee / Profile
// ─────────────────────────────────────────────────────────────────────────────

class HREmployee {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String employeeCode;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String maritalStatus;
  final String joiningDate;
  final String employmentType;
  final String workLocation;
  final String reportingManager;
  final String shift;
  final String grade;
  final String pfNumber;
  final String uanNumber;
  final String esiNumber;
  final String panNumber;
  final String aadhaarLast4;
  final String address;
  final String emergencyContact;
  final String emergencyRelation;
  final String emergencyPhone;
  final String avatarInitials;

  const HREmployee({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.employeeCode,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.maritalStatus,
    required this.joiningDate,
    required this.employmentType,
    required this.workLocation,
    required this.reportingManager,
    required this.shift,
    required this.grade,
    required this.pfNumber,
    required this.uanNumber,
    required this.esiNumber,
    required this.panNumber,
    required this.aadhaarLast4,
    required this.address,
    required this.emergencyContact,
    required this.emergencyRelation,
    required this.emergencyPhone,
    required this.avatarInitials,
  });

  factory HREmployee.fromJson(Map<String, dynamic> json) {
    return HREmployee(
      id: json['id']?.toString() ?? '',
      name: json['firstName'] != null
          ? '${json['firstName']} ${json['lastName'] ?? ''}'.trim()
          : (json['name'] ?? ''),
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['mobileNo'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      maritalStatus: json['maritalStatus'] ?? '',
      joiningDate: json['joiningDate'] ?? '',
      employmentType: json['employmentType'] ?? '',
      workLocation: json['workLocation'] ?? '',
      reportingManager: json['reportingManager'] ?? '',
      shift: json['shift'] ?? '',
      grade: json['grade'] ?? '',
      pfNumber: json['pfNumber'] ?? '',
      uanNumber: json['uanNumber'] ?? '',
      esiNumber: json['esiNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      aadhaarLast4: json['aadhaarLast4'] ?? '',
      address: json['address'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      emergencyRelation: json['emergencyRelation'] ?? '',
      emergencyPhone: json['emergencyPhone'] ?? '',
      avatarInitials:
          json['firstName'] != null && json['firstName'].toString().isNotEmpty
          ? json['firstName'].toString()[0].toUpperCase()
          : 'U',
    );
  }

  factory HREmployee.empty() {
    return const HREmployee(
      id: '',
      name: 'Staff Member',
      designation: '',
      department: '',
      employeeCode: '',
      email: '',
      phone: '',
      dob: '',
      gender: '',
      bloodGroup: '',
      maritalStatus: '',
      joiningDate: '',
      employmentType: '',
      workLocation: '',
      reportingManager: '',
      shift: '',
      grade: '',
      pfNumber: '',
      uanNumber: '',
      esiNumber: '',
      panNumber: '',
      aadhaarLast4: '',
      address: '',
      emergencyContact: '',
      emergencyRelation: '',
      emergencyPhone: '',
      avatarInitials: '',
    );
  }
}

class FamilyMember {
  final String name;
  final String relation;
  final String dob;
  final String occupation;
  final bool isDependent;

  const FamilyMember({
    required this.name,
    required this.relation,
    required this.dob,
    required this.occupation,
    required this.isDependent,
  });
}

class Education {
  final String degree;
  final String institution;
  final String year;
  final String grade;
  final String field;

  const Education({
    required this.degree,
    required this.institution,
    required this.year,
    required this.grade,
    required this.field,
  });
}

class WorkExperience {
  final String company;
  final String role;
  final String from;
  final String to;
  final String duration;
  final bool isCurrent;

  const WorkExperience({
    required this.company,
    required this.role,
    required this.from,
    required this.to,
    required this.duration,
    required this.isCurrent,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendance
// ─────────────────────────────────────────────────────────────────────────────

class AttendanceRecord {
  final String date;
  final String shiftCode;
  final String shiftInTime;
  final String shiftOutTime;
  final String punchIn;
  final String punchOut;
  final String status;
  final String dayType;
  final String workHours;
  final bool isLate;
  final bool isEarlyExit;
  final String extraHours;

  const AttendanceRecord({
    required this.date,
    this.shiftCode = '',
    this.shiftInTime = '',
    this.shiftOutTime = '',
    this.punchIn = '–',
    this.punchOut = '–',
    this.status = 'Unknown',
    this.dayType = '',
    this.workHours = '–',
    this.isLate = false,
    this.isEarlyExit = false,
    this.extraHours = '00:00:00',
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    print('DEBUG: AttendanceRecord.fromJson called with: $json');
    final empIn = json['empInTime']?.toString() ?? '';
    final empOut = json['empOutTime']?.toString() ?? '';
    final shiftIn = json['shiftInTime']?.toString() ?? '';
    final shiftOut = json['shiftOutTime']?.toString() ?? '';
    final lateMark = (json['lateInMark'] ?? 0).toString();
    final earlyMark = (json['earlyOutMark'] ?? 0).toString();

    // Map dayType (e.g. ABS, PR, WO) to a readable status
    String rawDayType = (json['dayType'] ?? json['dayType1'] ?? '')
        .toString()
        .toUpperCase();
    String mappedStatus = json['status']?.toString() ?? 'Unknown';
    if (rawDayType == 'ABS')
      mappedStatus = 'Absent';
    else if (rawDayType == 'PR')
      mappedStatus = 'Present';
    else if (rawDayType == 'WO')
      mappedStatus = 'Holiday';
    else if (rawDayType == 'HD')
      mappedStatus = 'Half Day';
    else if (rawDayType == 'LV')
      mappedStatus = 'Leave';
    else if (rawDayType.isNotEmpty)
      mappedStatus = rawDayType;

    // Use empInTime if valid, do NOT fallback to shiftInTime because that implies they punched in when they didn't
    final finalPunchIn = (empIn.isNotEmpty && empIn != 'null') ? empIn : '–';
    final finalPunchOut = (empOut.isNotEmpty && empOut != 'null')
        ? empOut
        : '–';

    print(
      'DEBUG: Final mapped values -> punchIn: $finalPunchIn, punchOut: $finalPunchOut, status: $mappedStatus',
    );

    return AttendanceRecord(
      date: json['date'] ?? '',
      shiftCode: json['shiftCode'] ?? '',
      shiftInTime: json['shiftInTime']?.toString() ?? '00:00:00',
      shiftOutTime: json['shiftOutTime']?.toString() ?? '00:00:00',
      punchIn: finalPunchIn,
      punchOut: finalPunchOut,
      status: mappedStatus,
      dayType: rawDayType,
      workHours: json['totalHours'] ?? '–',
      isLate: double.tryParse(lateMark) != null && double.parse(lateMark) > 0,
      isEarlyExit:
          double.tryParse(earlyMark) != null && double.parse(earlyMark) > 0,
      extraHours: json['extraHours']?.toString() ?? '00:00:00',
    );
  }
}

class AttendanceSummary {
  final int totalWorkingDays;
  final int present;
  final int absent;
  final int late;
  final int earlyExit;
  final int halfDay;
  final int holidays;
  final int leavesTaken;
  final double attendancePercentage;

  const AttendanceSummary({
    required this.totalWorkingDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.earlyExit,
    required this.halfDay,
    required this.holidays,
    required this.leavesTaken,
    required this.attendancePercentage,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalWorkingDays: _parseInt(json['totalWorkingDays']),
      present: _parseInt(json['present']),
      absent: _parseInt(json['absent']),
      late: _parseInt(json['late']),
      earlyExit: _parseInt(json['earlyExit']),
      halfDay: _parseInt(json['halfDay']),
      holidays: _parseInt(json['holidays']),
      leavesTaken: _parseInt(json['leavesTaken']),
      attendancePercentage: _parseDouble(json['attendancePercentage']),
    );
  }

  factory AttendanceSummary.fromRecords(List<AttendanceRecord> records) {
    final total = records.length;
    final present = records
        .where((r) => r.status.toLowerCase() == 'present')
        .length;
    final absent = records
        .where((r) => r.status.toLowerCase() == 'absent')
        .length;
    final late = records.where((r) => r.isLate).length;
    final earlyExit = records.where((r) => r.isEarlyExit).length;
    final halfDay = records
        .where((r) => r.status.toLowerCase().contains('half'))
        .length;
    final holidays = records
        .where(
          (r) =>
              r.status.toLowerCase() == 'holiday' ||
              r.status.toLowerCase() == 'wo',
        )
        .length;
    final leaves = records
        .where((r) => r.status.toLowerCase() == 'leave')
        .length;

    // Only count days that are not holidays/weekends for total working days
    final workingDays = records
        .where(
          (r) =>
              r.status.toLowerCase() != 'holiday' &&
              r.status.toLowerCase() != 'wo',
        )
        .length;
    final attendancePercentage = workingDays == 0
        ? 0.0
        : (present / workingDays) * 100;

    return AttendanceSummary(
      totalWorkingDays: workingDays,
      present: present,
      absent: absent,
      late: late,
      earlyExit: earlyExit,
      halfDay: halfDay,
      holidays: holidays,
      leavesTaken: leaves,
      attendancePercentage: attendancePercentage,
    );
  }

  factory AttendanceSummary.empty() {
    return const AttendanceSummary(
      totalWorkingDays: 0,
      present: 0,
      absent: 0,
      late: 0,
      earlyExit: 0,
      halfDay: 0,
      holidays: 0,
      leavesTaken: 0,
      attendancePercentage: 0.0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leave
// ─────────────────────────────────────────────────────────────────────────────

class LeaveBalance {
  final String leaveType;
  final int total;
  final int used;
  final int pending;
  final int available;
  final String colorHex;
  final int? leaveNameId;

  const LeaveBalance({
    required this.leaveType,
    required this.total,
    required this.used,
    required this.pending,
    required this.available,
    required this.colorHex,
    this.leaveNameId,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leaveType:
          json['leaveType'] ?? json['leaveName'] ?? json['name'] ?? 'Unknown',
      total: (json['total'] ?? 0).toInt(),
      used: (json['used'] ?? 0).toInt(),
      pending: (json['pending'] ?? 0).toInt(),
      available: (json['available'] ?? json['balance'] ?? 0).toInt(),
      colorHex: json['colorHex'] ?? '#1565C0',
      leaveNameId: json['leaveNameId'] != null
          ? (json['leaveNameId'] as num).toInt()
          : null,
    );
  }
}

class LeaveApplication {
  final String id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int days;
  final String reason;
  final String status; // Pending, Approved, Rejected
  final String appliedOn;
  final String? approvedBy;
  final String? remarks;

  const LeaveApplication({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.approvedBy,
    this.remarks,
  });

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      id: json['id']?.toString() ?? json['requestId']?.toString() ?? '',
      leaveType: json['leaveType'] ?? json['leaveName'] ?? 'Leave',
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      days: (json['days'] ?? json['noOfDays'] ?? 0).toInt(),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      appliedOn: json['appliedOn'] ?? json['createdDate'] ?? '',
      approvedBy: json['approvedBy'],
      remarks: json['remarks'],
    );
  }
}

class HRHoliday {
  final String name;
  final String date;
  final String day;
  final String type; // National, Regional, Optional
  final bool isOptional;

  const HRHoliday({
    required this.name,
    required this.date,
    required this.day,
    required this.type,
    required this.isOptional,
  });

  factory HRHoliday.fromJson(Map<String, dynamic> json) {
    return HRHoliday(
      name: json['name'] ?? json['holidayName'] ?? 'Holiday',
      date: json['date'] ?? json['holidayDate'] ?? '',
      day: json['day'] ?? json['dayName'] ?? '',
      type: json['type'] ?? json['holidayType'] ?? 'National',
      isOptional: json['isOptional'] ?? (json['type'] == 'Optional'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payroll
// ─────────────────────────────────────────────────────────────────────────────

class SalarySlip {
  final String month;
  final String year;
  final String payPeriod;
  final double basicSalary;
  final double hra;
  final double conveyanceAllowance;
  final double medicalAllowance;
  final double specialAllowance;
  final double nightAllowance;
  final double doctorIncentive;
  final double bonus;
  final double grossEarnings;
  final double pfDeduction;
  final double esicDeduction;
  final double professionalTax;
  final double tds;
  final double loanDeduction;
  final double totalDeductions;
  final double netSalary;
  final String status; // Paid, Pending
  final String creditDate;
  final int workingDays;
  final int presentDays;

  const SalarySlip({
    required this.month,
    required this.year,
    required this.payPeriod,
    required this.basicSalary,
    required this.hra,
    required this.conveyanceAllowance,
    required this.medicalAllowance,
    required this.specialAllowance,
    required this.nightAllowance,
    required this.doctorIncentive,
    required this.bonus,
    required this.grossEarnings,
    required this.pfDeduction,
    required this.esicDeduction,
    required this.professionalTax,
    required this.tds,
    required this.loanDeduction,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
    required this.creditDate,
    required this.workingDays,
    required this.presentDays,
  });

  factory SalarySlip.fromJson(Map<String, dynamic> json) {
    return SalarySlip(
      month: json['month'] ?? '',
      year: json['year']?.toString() ?? '',
      payPeriod: json['payPeriod'] ?? '',
      basicSalary: (json['basicSalary'] ?? 0).toDouble(),
      hra: (json['hra'] ?? 0).toDouble(),
      conveyanceAllowance: (json['conveyanceAllowance'] ?? 0).toDouble(),
      medicalAllowance: (json['medicalAllowance'] ?? 0).toDouble(),
      specialAllowance: (json['specialAllowance'] ?? 0).toDouble(),
      nightAllowance: (json['nightAllowance'] ?? 0).toDouble(),
      doctorIncentive: (json['doctorIncentive'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      grossEarnings: (json['grossEarnings'] ?? 0).toDouble(),
      pfDeduction: (json['pfDeduction'] ?? json['pf'] ?? 0).toDouble(),
      esicDeduction: (json['esicDeduction'] ?? json['esic'] ?? 0).toDouble(),
      professionalTax: (json['professionalTax'] ?? json['pt'] ?? 0).toDouble(),
      tds: (json['tds'] ?? 0).toDouble(),
      loanDeduction: (json['loanDeduction'] ?? 0).toDouble(),
      totalDeductions: (json['totalDeductions'] ?? 0).toDouble(),
      netSalary: (json['netSalary'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      creditDate: json['creditDate'] ?? '',
      workingDays: (json['workingDays'] ?? 0).toInt(),
      presentDays: (json['presentDays'] ?? 0).toInt(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shift
// ─────────────────────────────────────────────────────────────────────────────

class ShiftRosterColumn {
  final String label;
  final String field;

  const ShiftRosterColumn({required this.label, required this.field});

  factory ShiftRosterColumn.fromJson(Map<String, dynamic> json) {
    return ShiftRosterColumn(
      label: json['label']?.toString() ?? json['labelName']?.toString() ?? '',
      field: json['field']?.toString() ?? json['columnName']?.toString() ?? '',
    );
  }
}

class ShiftRosterRow {
  final Map<String, dynamic> values;

  const ShiftRosterRow({required this.values});

  factory ShiftRosterRow.fromJson(Map<String, dynamic> json) {
    return ShiftRosterRow(
      values: json.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}

class ShiftRosterPagination {
  final int currentPage;
  final int pageSize;
  final int totalRecords;
  final int totalPages;

  const ShiftRosterPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory ShiftRosterPagination.fromJson(Map<String, dynamic> json) {
    final currentPage = _parseInt(
      json['currentPage'] ?? json['current_page'] ?? json['page'] ?? 1,
    );
    final pageSize = _parseInt(
      json['pageSize'] ?? json['page_size'] ?? json['size'] ?? 10,
    );
    final totalRecords = _parseInt(
      json['totalRecords'] ??
          json['total_records'] ??
          json['totalItems'] ??
          json['total'] ??
          0,
    );
    final totalPages = _parseInt(
      json['totalPages'] ??
          json['total_pages'] ??
          json['totalPage'] ??
          (pageSize > 0 ? ((totalRecords + pageSize - 1) ~/ pageSize) : 1),
    );
    return ShiftRosterPagination(
      currentPage: currentPage,
      pageSize: pageSize,
      totalRecords: totalRecords,
      totalPages: totalPages,
    );
  }
}

class ShiftTemplate {
  final String id;
  final String name;
  final String code;
  final String inTime;
  final String outTime;
  final String totalHours;
  final bool nightShift;
  final bool halfDay;
  final bool hourBased;
  final int? bufferTime;
  final int? cutOffTime;
  final double? fullRate;
  final double? halfRate;
  final List<Map<String, dynamic>> lateMarkRuleDTOList;

  const ShiftTemplate({
    required this.id,
    required this.name,
    required this.code,
    required this.inTime,
    required this.outTime,
    required this.totalHours,
    required this.nightShift,
    required this.halfDay,
    required this.hourBased,
    this.bufferTime,
    this.cutOffTime,
    this.fullRate,
    this.halfRate,
    this.lateMarkRuleDTOList = const [],
  });

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory ShiftTemplate.fromJson(Map<String, dynamic> json) {
    final rules = <Map<String, dynamic>>[];
    if (json['lateMarkRuleDTOList'] is List) {
      rules.addAll(
        (json['lateMarkRuleDTOList'] as List).cast<Map<String, dynamic>>(),
      );
    }
    return ShiftTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['shiftName']?.toString() ?? '',
      code: json['code']?.toString() ?? json['shiftCode']?.toString() ?? '',
      inTime: json['inTime']?.toString() ?? '',
      outTime: json['outTime']?.toString() ?? '',
      totalHours:
          json['totalWorkingHours']?.toString() ??
          json['totalHours']?.toString() ??
          '',
      nightShift: _parseBool(json['nightShift']),
      halfDay: _parseBool(json['halfDayApplicable'] ?? json['halfDay']),
      hourBased: _parseBool(json['hourBased']),
      bufferTime: json['bufferTime'] is int
          ? json['bufferTime'] as int
          : int.tryParse(json['bufferTime']?.toString() ?? ''),
      cutOffTime: json['cutOffTime'] is int
          ? json['cutOffTime'] as int
          : int.tryParse(json['cutOffTime']?.toString() ?? ''),
      fullRate: _parseDouble(json['fullRate'] ?? json['full_rate']),
      halfRate: _parseDouble(json['halfRate'] ?? json['half_rate']),
      lateMarkRuleDTOList: rules,
    );
  }
}

class ShiftSchedule {
  final String date;
  final String day;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String ward;
  final String type; // Regular, Emergency, On-Call
  final bool isToday;

  const ShiftSchedule({
    required this.date,
    required this.day,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.ward,
    required this.type,
    required this.isToday,
  });
}

class ShiftSwapRequest {
  final String id;
  final String requestTo;
  final String myDate;
  final String theirDate;
  final String reason;
  final String status;
  final String requestedOn;

  const ShiftSwapRequest({
    required this.id,
    required this.requestTo,
    required this.myDate,
    required this.theirDate,
    required this.reason,
    required this.status,
    required this.requestedOn,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Documents
// ─────────────────────────────────────────────────────────────────────────────

class HRDocument {
  final String id;
  final String name;
  final String type;
  final String uploadedOn;
  final String expiryDate;
  final String status; // Verified, Pending, Expired
  final String fileSize;
  final String category; // ID Proof, License, Certificate, etc.
  final bool isExpiringSoon;

  const HRDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadedOn,
    required this.expiryDate,
    required this.status,
    required this.fileSize,
    required this.category,
    required this.isExpiringSoon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance
// ─────────────────────────────────────────────────────────────────────────────

class PerformanceGoal {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  final double achievedValue;
  final String deadline;
  final String status;
  final String category; // KPI, KRA, Objective

  const PerformanceGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.achievedValue,
    required this.deadline,
    required this.status,
    required this.category,
  });

  double get progressPercent =>
      targetValue > 0 ? (achievedValue / targetValue).clamp(0.0, 1.0) : 0.0;
}

class PerformanceReview {
  final String period;
  final String reviewDate;
  final String rating;
  final double ratingScore;
  final String reviewedBy;
  final String feedback;
  final String status;

  const PerformanceReview({
    required this.period,
    required this.reviewDate,
    required this.rating,
    required this.ratingScore,
    required this.reviewedBy,
    required this.feedback,
    required this.status,
  });
}

class Award {
  final String title;
  final String date;
  final String givenBy;
  final String description;
  final String category;

  const Award({
    required this.title,
    required this.date,
    required this.givenBy,
    required this.description,
    required this.category,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Training
// ─────────────────────────────────────────────────────────────────────────────

class TrainingCourse {
  final String id;
  final String title;
  final String category;
  final String instructor;
  final String startDate;
  final String endDate;
  final String duration;
  final String mode; // Online, Classroom, Blended
  final String status; // Upcoming, Ongoing, Completed
  final double progress;
  final bool hasCertificate;
  final String? certificateDate;

  const TrainingCourse({
    required this.id,
    required this.title,
    required this.category,
    required this.instructor,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.mode,
    required this.status,
    required this.progress,
    required this.hasCertificate,
    this.certificateDate,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Assets
// ─────────────────────────────────────────────────────────────────────────────

class HRAsset {
  final String id;
  final String name;
  final String type;
  final String assetCode;
  final String assignedDate;
  final String condition;
  final String status; // Active, Returned, Lost
  final String? serialNumber;
  final String? model;
  final String? brand;
  final String? returnDate;

  const HRAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.assetCode,
    required this.assignedDate,
    required this.condition,
    required this.status,
    this.serialNumber,
    this.model,
    this.brand,
    this.returnDate,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Loan
// ─────────────────────────────────────────────────────────────────────────────

class LoanDetail {
  final String id;
  final String loanType; // Personal Loan, Salary Advance
  final double principalAmount;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final double outstandingBalance;
  final double totalRepaid;
  final String disbursedDate;
  final String status;
  final List<EMIPayment> emiSchedule;

  const LoanDetail({
    required this.id,
    required this.loanType,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.outstandingBalance,
    required this.totalRepaid,
    required this.disbursedDate,
    required this.status,
    required this.emiSchedule,
  });
}

class EMIPayment {
  final int installmentNo;
  final String dueDate;
  final double amount;
  final String status; // Paid, Upcoming, Overdue
  final String? paidDate;

  const EMIPayment({
    required this.installmentNo,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.paidDate,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Expenses
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseClaim {
  final String id;
  final String type;
  final String description;
  final double amount;
  final String date;
  final String status;
  final String submittedOn;
  final String? approvedBy;
  final String? receiptRef;

  const ExpenseClaim({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.submittedOn,
    this.approvedBy,
    this.receiptRef,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Requests
// ─────────────────────────────────────────────────────────────────────────────

class HRRequest {
  final String id;
  final String type;
  final String subject;
  final String description;
  final String submittedOn;
  final String status;
  final String? remarks;
  final String? resolvedOn;

  const HRRequest({
    required this.id,
    required this.type,
    required this.subject,
    required this.description,
    required this.submittedOn,
    required this.status,
    this.remarks,
    this.resolvedOn,
  });

  factory HRRequest.fromJson(Map<String, dynamic> json) {
    return HRRequest(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? json['requestType'] ?? 'General Request',
      subject: json['subject'] ?? json['title'] ?? 'Request',
      description: json['description'] ?? json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      submittedOn: json['submittedOn'] ?? json['createdDate'] ?? '',
      resolvedOn: json['resolvedOn'] ?? json['updatedDate'],
      remarks: json['remarks'],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Approvals
// ─────────────────────────────────────────────────────────────────────────────

class ApprovalItem {
  final String id;
  final String type;
  final String requestedBy;
  final String requestedOn;
  final String description;
  final String status;
  final String? remarks;
  final String? actionDate;

  const ApprovalItem({
    required this.id,
    required this.type,
    required this.requestedBy,
    required this.requestedOn,
    required this.description,
    required this.status,
    this.remarks,
    this.actionDate,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications
// ─────────────────────────────────────────────────────────────────────────────

class HRNotification {
  final String id;
  final String title;
  final String body;
  final String type; // Announcement, Circular, Reminder, Alert
  final String time;
  final bool isRead;
  final String? actionRoute;

  const HRNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.isRead,
    this.actionRoute,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Widgets Data
// ─────────────────────────────────────────────────────────────────────────────

class DashboardAnnouncement {
  final String id;
  final String title;
  final String content;
  final String date;
  final String postedBy;
  final String priority; // High, Medium, Low

  const DashboardAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.postedBy,
    required this.priority,
  });
}
// Placeholder classes for missing types

class HRAnnouncement {}

class RotaShift {}

class QuickTask {}

class PendingApproval {
  final String status;
  PendingApproval({this.status = 'Pending'});
}

class CheckInOutStatus {
  bool isCheckedIn = false;
  String punchTime = '';
}

class BirthdayItem {
  final String name;
  final String designation;
  final String date;
  final bool isToday;
  final String initials;

  const BirthdayItem({
    required this.name,
    required this.designation,
    required this.date,
    required this.isToday,
    required this.initials,
  });
}

class WorkAnniversaryItem {
  final String name;
  final String designation;
  final int years;
  final String date;
  final bool isToday;
  final String initials;

  const WorkAnniversaryItem({
    required this.name,
    required this.designation,
    required this.years,
    required this.date,
    required this.isToday,
    required this.initials,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Policy
// ─────────────────────────────────────────────────────────────────────────────

class HRPolicy {
  final String id;
  final String title;
  final String category;
  final String version;
  final String effectiveDate;
  final String lastUpdated;
  final String description;
  final int pages;

  const HRPolicy({
    required this.id,
    required this.title,
    required this.category,
    required this.version,
    required this.effectiveDate,
    required this.lastUpdated,
    required this.description,
    required this.pages,
  });
}
