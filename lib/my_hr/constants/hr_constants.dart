/// HR Module Constants - strings, enums, route names
class HRConstants {
  HRConstants._();

  // ── Route names ───────────────────────────────────────────────────────────
  static const String hrDashboard    = '/hr/dashboard';
  static const String hrProfile      = '/hr/profile';
  static const String hrAttendance   = '/hr/attendance';
  static const String hrLeave        = '/hr/leave';
  static const String hrPayroll      = '/hr/payroll';
  static const String hrShift        = '/hr/shift';
  static const String hrDocuments    = '/hr/documents';
  static const String hrPerformance  = '/hr/performance';
  static const String hrTraining     = '/hr/training';
  static const String hrAssets       = '/hr/assets';
  static const String hrLoan         = '/hr/loan';
  static const String hrExpenses     = '/hr/expenses';
  static const String hrRequests     = '/hr/requests';
  static const String hrApprovals    = '/hr/approvals';
  static const String hrNotifications= '/hr/notifications';
  static const String hrCalendar     = '/hr/calendar';
  static const String hrPolicies     = '/hr/policies';
  static const String hrSettings     = '/hr/settings';

  // ── Leave Types ───────────────────────────────────────────────────────────
  static const List<String> leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Casual Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Emergency Leave',
    'Compensatory Off',
    'Study Leave',
    'On Duty',
    'Loss of Pay',
  ];

  // ── Department list ───────────────────────────────────────────────────────
  static const List<String> departments = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Oncology',
    'Pediatrics',
    'Gynecology',
    'Emergency',
    'ICU',
    'Surgery',
    'Radiology',
    'Pathology',
    'Pharmacy',
    'Administration',
    'Nursing',
    'HR & Admin',
  ];

  // ── Blood Groups ──────────────────────────────────────────────────────────
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  // ── Shift Types ───────────────────────────────────────────────────────────
  static const List<String> shiftTypes = [
    'Morning (6:00 AM – 2:00 PM)',
    'Day (9:00 AM – 5:00 PM)',
    'Afternoon (2:00 PM – 10:00 PM)',
    'Night (10:00 PM – 6:00 AM)',
    'General (8:00 AM – 4:00 PM)',
    'Rotational',
  ];

  // ── Expense types ─────────────────────────────────────────────────────────
  static const List<String> expenseTypes = [
    'Travel',
    'Medical',
    'Food',
    'Accommodation',
    'Communication',
    'Training',
    'Other',
  ];

  // ── Asset types ───────────────────────────────────────────────────────────
  static const List<String> assetTypes = [
    'Laptop',
    'Mobile',
    'ID Card',
    'Uniform',
    'Stethoscope',
    'Medical Kit',
    'Safety Equipment',
    'Other',
  ];

  // ── Policy types ──────────────────────────────────────────────────────────
  static const List<String> policyTypes = [
    'Attendance Policy',
    'Leave Policy',
    'Payroll Policy',
    'HR Policy',
    'Hospital SOP',
    'Code of Conduct',
    'IT Security Policy',
    'Patient Safety Policy',
  ];

  // ── Training categories ───────────────────────────────────────────────────
  static const List<String> trainingCategories = [
    'Clinical Skills',
    'Soft Skills',
    'Safety & Compliance',
    'Leadership',
    'IT & Systems',
    'Patient Care',
    'Emergency Protocols',
    'Infection Control',
  ];

  // ── Performance ratings ───────────────────────────────────────────────────
  static const List<String> performanceRatings = [
    'Outstanding',
    'Exceeds Expectations',
    'Meets Expectations',
    'Below Expectations',
    'Unsatisfactory',
  ];

  // ── Request types ─────────────────────────────────────────────────────────
  static const List<String> requestTypes = [
    'Attendance Correction',
    'Leave Request',
    'Shift Change',
    'Transfer Request',
    'Resignation',
    'Asset Request',
    'Loan Request',
    'Expense Claim',
  ];

  // ── Months ────────────────────────────────────────────────────────────────
  static const List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
