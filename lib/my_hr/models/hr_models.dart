// ignore_for_file: non_constant_identifier_names
library hr_models;

/// All data models for the MY HR module
/// Pure Dart classes – no database, no serialization dependencies

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
  final String punchIn;
  final String punchOut;
  final String status;   // Present, Absent, Late, Half Day, Holiday, Leave
  final String workHours;
  final bool isLate;
  final bool isEarlyExit;
  final String? overtimeHours;

  const AttendanceRecord({
    required this.date,
    required this.punchIn,
    required this.punchOut,
    required this.status,
    required this.workHours,
    required this.isLate,
    required this.isEarlyExit,
    this.overtimeHours,
  });
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

  const LeaveBalance({
    required this.leaveType,
    required this.total,
    required this.used,
    required this.pending,
    required this.available,
    required this.colorHex,
  });
}

class LeaveApplication {
  final String id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int days;
  final String reason;
  final String status;  // Pending, Approved, Rejected
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
}

class HRHoliday {
  final String name;
  final String date;
  final String day;
  final String type;   // National, Regional, Optional
  final bool isOptional;

  const HRHoliday({
    required this.name,
    required this.date,
    required this.day,
    required this.type,
    required this.isOptional,
  });
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
  final String status;     // Paid, Pending
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Shift
// ─────────────────────────────────────────────────────────────────────────────

class ShiftSchedule {
  final String date;
  final String day;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String ward;
  final String type;    // Regular, Emergency, On-Call
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
  final String status;     // Verified, Pending, Expired
  final String fileSize;
  final String category;   // ID Proof, License, Certificate, etc.
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
  final String category;   // KPI, KRA, Objective

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
  final String mode;     // Online, Classroom, Blended
  final String status;   // Upcoming, Ongoing, Completed
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
  final String status;      // Active, Returned, Lost
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
  final String loanType;     // Personal Loan, Salary Advance
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
  final String status;    // Paid, Upcoming, Overdue
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
  final String type;    // Announcement, Circular, Reminder, Alert
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
  final String priority;  // High, Medium, Low

  const DashboardAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.postedBy,
    required this.priority,
  });
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
