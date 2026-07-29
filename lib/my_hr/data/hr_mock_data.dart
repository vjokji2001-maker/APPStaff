import '../models/hr_models.dart';

/// All mock/dummy data for the MY HR module
class HRMockData {
  HRMockData._();

  // ── Employee Profile ──────────────────────────────────────────────────────
  static const HREmployee employee = HREmployee(
    id: 'emp_001',
    name: 'Dr. Priya Sharma',
    designation: 'Senior Nurse',
    department: 'Cardiology',
    employeeCode: 'EMP-2023-0047',
    email: 'priya.sharma@cityhospital.com',
    phone: '+91 98765 43210',
    dob: '15 Mar 1990',
    gender: 'Female',
    bloodGroup: 'B+',
    maritalStatus: 'Married',
    joiningDate: '15 Jan 2023',
    employmentType: 'Full-Time Permanent',
    workLocation: 'City Hospital - Main Campus',
    reportingManager: 'Dr. Rajesh Kumar',
    shift: 'Morning (8:00 AM – 4:00 PM)',
    grade: 'Grade 7 – Senior Staff',
    pfNumber: 'PF-MH-34567890',
    uanNumber: '100987654321',
    esiNumber: 'ESI-1234567890',
    panNumber: 'ABCDE1234F',
    aadhaarLast4: '7890',
    address: '42, Green Valley Apartments, Andheri West, Mumbai – 400058',
    emergencyContact: 'Rahul Sharma',
    emergencyRelation: 'Spouse',
    emergencyPhone: '+91 91234 56789',
    avatarInitials: 'PS',
  );

  // ── Family Members ─────────────────────────────────────────────────────────
  static const List<FamilyMember> familyMembers = [
    FamilyMember(name: 'Rahul Sharma', relation: 'Spouse', dob: '10 Jun 1988', occupation: 'Software Engineer', isDependent: false),
    FamilyMember(name: 'Aarav Sharma', relation: 'Son', dob: '05 Feb 2018', occupation: 'Student', isDependent: true),
    FamilyMember(name: 'Sita Devi', relation: 'Mother', dob: '20 Nov 1960', occupation: 'Retired', isDependent: true),
  ];

  // ── Education ─────────────────────────────────────────────────────────────
  static const List<Education> education = [
    Education(degree: 'B.Sc. Nursing', institution: 'Mumbai University', year: '2012', grade: 'First Class', field: 'Nursing Science'),
    Education(degree: 'M.Sc. Clinical Nursing', institution: 'AIIMS Mumbai', year: '2015', grade: 'Distinction', field: 'Clinical Nursing'),
    Education(degree: 'Post Graduate Diploma – Critical Care', institution: 'Apollo Institute', year: '2017', grade: 'A+', field: 'Critical Care'),
  ];

  // ── Work Experience ───────────────────────────────────────────────────────
  static const List<WorkExperience> experience = [
    WorkExperience(company: 'City Hospital', role: 'Senior Nurse', from: 'Jan 2023', to: 'Present', duration: '1 yr 6 mo', isCurrent: true),
    WorkExperience(company: 'Apollo Hospitals', role: 'Staff Nurse', from: 'Jun 2017', to: 'Dec 2022', duration: '5 yr 6 mo', isCurrent: false),
    WorkExperience(company: 'Lilavati Hospital', role: 'Junior Nurse', from: 'Aug 2015', to: 'May 2017', duration: '1 yr 9 mo', isCurrent: false),
  ];

  // ── Attendance Records ────────────────────────────────────────────────────
  static final List<AttendanceRecord> attendanceRecords = [
    const AttendanceRecord(date: '24 Jul 2026', punchIn: '08:02 AM', punchOut: '04:15 PM', status: 'Present', workHours: '8h 13m', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '23 Jul 2026', punchIn: '08:18 AM', punchOut: '04:00 PM', status: 'Late', workHours: '7h 42m', isLate: true, isEarlyExit: false),
    const AttendanceRecord(date: '22 Jul 2026', punchIn: '07:55 AM', punchOut: '04:10 PM', status: 'Present', workHours: '8h 15m', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '21 Jul 2026', punchIn: '08:00 AM', punchOut: '12:30 PM', status: 'Half Day', workHours: '4h 30m', isLate: false, isEarlyExit: true),
    const AttendanceRecord(date: '20 Jul 2026', punchIn: '–', punchOut: '–', status: 'Sunday', workHours: '–', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '19 Jul 2026', punchIn: '–', punchOut: '–', status: 'Saturday', workHours: '–', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '18 Jul 2026', punchIn: '08:05 AM', punchOut: '04:30 PM', status: 'Present', workHours: '8h 25m', isLate: false, isEarlyExit: false, overtimeHours: '0h 30m'),
    const AttendanceRecord(date: '17 Jul 2026', punchIn: '08:00 AM', punchOut: '04:00 PM', status: 'Present', workHours: '8h 00m', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '16 Jul 2026', punchIn: '–', punchOut: '–', status: 'Leave', workHours: '–', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '15 Jul 2026', punchIn: '–', punchOut: '–', status: 'Holiday', workHours: '–', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '14 Jul 2026', punchIn: '08:00 AM', punchOut: '04:05 PM', status: 'Present', workHours: '8h 05m', isLate: false, isEarlyExit: false),
    const AttendanceRecord(date: '13 Jul 2026', punchIn: '08:25 AM', punchOut: '04:00 PM', status: 'Late', workHours: '7h 35m', isLate: true, isEarlyExit: false),
  ];

  static const AttendanceSummary attendanceSummary = AttendanceSummary(
    totalWorkingDays: 23, present: 19, absent: 1, late: 3,
    earlyExit: 1, halfDay: 1, holidays: 2, leavesTaken: 2,
    attendancePercentage: 91.3,
  );

  // Monthly attendance data for bar chart [Mon–Sun values as hours worked]
  static const List<double> weeklyHours = [8.0, 7.7, 8.2, 4.5, 0, 0, 8.1];
  static const List<double> monthlyPresence = [20, 21, 22, 19, 23, 20, 21, 22, 18, 22, 21, 20]; // each month

  // ── Leave Balances ────────────────────────────────────────────────────────
  static const List<LeaveBalance> leaveBalances = [
    LeaveBalance(leaveType: 'Annual Leave', total: 24, used: 6, pending: 2, available: 16, colorHex: '#1565C0'),
    LeaveBalance(leaveType: 'Sick Leave', total: 12, used: 3, pending: 0, available: 9, colorHex: '#C62828'),
    LeaveBalance(leaveType: 'Casual Leave', total: 10, used: 2, pending: 1, available: 7, colorHex: '#2E7D32'),
    LeaveBalance(leaveType: 'Compensatory Off', total: 5, used: 1, pending: 0, available: 4, colorHex: '#6A1B9A'),
    LeaveBalance(leaveType: 'Emergency Leave', total: 3, used: 0, pending: 0, available: 3, colorHex: '#E65100'),
  ];

  // ── Leave Applications ─────────────────────────────────────────────────────
  static const List<LeaveApplication> leaveApplications = [
    LeaveApplication(id: 'LV001', leaveType: 'Annual Leave', fromDate: '10 Aug 2026', toDate: '12 Aug 2026', days: 3, reason: 'Family function', status: 'Pending', appliedOn: '22 Jul 2026'),
    LeaveApplication(id: 'LV002', leaveType: 'Sick Leave', fromDate: '16 Jul 2026', toDate: '16 Jul 2026', days: 1, reason: 'Fever and cold', status: 'Approved', appliedOn: '16 Jul 2026', approvedBy: 'Dr. Rajesh Kumar', remarks: 'Approved. Get well soon.'),
    LeaveApplication(id: 'LV003', leaveType: 'Casual Leave', fromDate: '05 Jun 2026', toDate: '05 Jun 2026', days: 1, reason: 'Personal work', status: 'Approved', appliedOn: '03 Jun 2026', approvedBy: 'Dr. Rajesh Kumar'),
    LeaveApplication(id: 'LV004', leaveType: 'Annual Leave', fromDate: '20 May 2026', toDate: '25 May 2026', days: 6, reason: 'Vacation', status: 'Rejected', appliedOn: '12 May 2026', approvedBy: 'Dr. Rajesh Kumar', remarks: 'Critical period – shortage of staff.'),
    LeaveApplication(id: 'LV005', leaveType: 'Sick Leave', fromDate: '10 Apr 2026', toDate: '11 Apr 2026', days: 2, reason: 'Surgery follow-up', status: 'Approved', appliedOn: '09 Apr 2026', approvedBy: 'Dr. Rajesh Kumar'),
  ];

  // ── Holidays ──────────────────────────────────────────────────────────────
  static const List<HRHoliday> holidays = [
    HRHoliday(name: 'Independence Day', date: '15 Aug 2026', day: 'Saturday', type: 'National', isOptional: false),
    HRHoliday(name: 'Ganesh Chaturthi', date: '25 Aug 2026', day: 'Tuesday', type: 'Regional', isOptional: false),
    HRHoliday(name: 'Gandhi Jayanti', date: '02 Oct 2026', day: 'Friday', type: 'National', isOptional: false),
    HRHoliday(name: 'Dussehra', date: '12 Oct 2026', day: 'Monday', type: 'National', isOptional: false),
    HRHoliday(name: 'Diwali', date: '01 Nov 2026', day: 'Sunday', type: 'National', isOptional: false),
    HRHoliday(name: 'Christmas Day', date: '25 Dec 2026', day: 'Friday', type: 'National', isOptional: false),
  ];

  // ── Salary Slips ──────────────────────────────────────────────────────────
  static const List<SalarySlip> salarySlips = [
    SalarySlip(month: 'July', year: '2026', payPeriod: '01 Jul – 31 Jul 2026',
      basicSalary: 32000, hra: 12800, conveyanceAllowance: 1600, medicalAllowance: 1250,
      specialAllowance: 5350, nightAllowance: 1500, doctorIncentive: 0, bonus: 0,
      grossEarnings: 54500, pfDeduction: 3840, esicDeduction: 409, professionalTax: 200,
      tds: 2800, loanDeduction: 3000, totalDeductions: 10249, netSalary: 44251,
      status: 'Paid', creditDate: '28 Jul 2026', workingDays: 27, presentDays: 24),
    SalarySlip(month: 'June', year: '2026', payPeriod: '01 Jun – 30 Jun 2026',
      basicSalary: 32000, hra: 12800, conveyanceAllowance: 1600, medicalAllowance: 1250,
      specialAllowance: 5350, nightAllowance: 0, doctorIncentive: 0, bonus: 0,
      grossEarnings: 53000, pfDeduction: 3840, esicDeduction: 398, professionalTax: 200,
      tds: 2800, loanDeduction: 3000, totalDeductions: 10238, netSalary: 42762,
      status: 'Paid', creditDate: '28 Jun 2026', workingDays: 26, presentDays: 25),
    SalarySlip(month: 'May', year: '2026', payPeriod: '01 May – 31 May 2026',
      basicSalary: 32000, hra: 12800, conveyanceAllowance: 1600, medicalAllowance: 1250,
      specialAllowance: 5350, nightAllowance: 2000, doctorIncentive: 0, bonus: 5000,
      grossEarnings: 60000, pfDeduction: 3840, esicDeduction: 450, professionalTax: 200,
      tds: 3200, loanDeduction: 3000, totalDeductions: 10690, netSalary: 49310,
      status: 'Paid', creditDate: '28 May 2026', workingDays: 27, presentDays: 26),
    SalarySlip(month: 'April', year: '2026', payPeriod: '01 Apr – 30 Apr 2026',
      basicSalary: 32000, hra: 12800, conveyanceAllowance: 1600, medicalAllowance: 1250,
      specialAllowance: 5350, nightAllowance: 0, doctorIncentive: 0, bonus: 0,
      grossEarnings: 53000, pfDeduction: 3840, esicDeduction: 398, professionalTax: 200,
      tds: 2800, loanDeduction: 3000, totalDeductions: 10238, netSalary: 42762,
      status: 'Paid', creditDate: '28 Apr 2026', workingDays: 26, presentDays: 24),
  ];

  // ── Shift Schedules ───────────────────────────────────────────────────────
  static const List<ShiftSchedule> shiftSchedule = [
    ShiftSchedule(date: '21 Jul', day: 'Mon', shiftName: 'Morning', startTime: '08:00 AM', endTime: '04:00 PM', ward: 'Cardiology – Ward 3', type: 'Regular', isToday: false),
    ShiftSchedule(date: '22 Jul', day: 'Tue', shiftName: 'Morning', startTime: '08:00 AM', endTime: '04:00 PM', ward: 'Cardiology – Ward 3', type: 'Regular', isToday: false),
    ShiftSchedule(date: '23 Jul', day: 'Wed', shiftName: 'Morning', startTime: '08:00 AM', endTime: '04:00 PM', ward: 'Cardiology – Ward 3', type: 'Regular', isToday: false),
    ShiftSchedule(date: '24 Jul', day: 'Thu', shiftName: 'Morning', startTime: '08:00 AM', endTime: '04:00 PM', ward: 'Cardiology – Ward 3', type: 'Regular', isToday: true),
    ShiftSchedule(date: '25 Jul', day: 'Fri', shiftName: 'Afternoon', startTime: '02:00 PM', endTime: '10:00 PM', ward: 'ICU – Level 2', type: 'Regular', isToday: false),
    ShiftSchedule(date: '26 Jul', day: 'Sat', shiftName: 'Off', startTime: '–', endTime: '–', ward: '–', type: 'Weekly Off', isToday: false),
    ShiftSchedule(date: '27 Jul', day: 'Sun', shiftName: 'Off', startTime: '–', endTime: '–', ward: '–', type: 'Weekly Off', isToday: false),
  ];

  static const List<ShiftSwapRequest> swapRequests = [
    ShiftSwapRequest(id: 'SW001', requestTo: 'Anita Patel', myDate: '25 Jul 2026', theirDate: '28 Jul 2026', reason: 'Family commitment', status: 'Pending', requestedOn: '22 Jul 2026'),
    ShiftSwapRequest(id: 'SW002', requestTo: 'Suresh Nair', myDate: '10 Jun 2026', theirDate: '12 Jun 2026', reason: 'Medical appointment', status: 'Approved', requestedOn: '08 Jun 2026'),
  ];

  // ── Documents ─────────────────────────────────────────────────────────────
  static const List<HRDocument> documents = [
    HRDocument(id: 'D001', name: 'Aadhaar Card', type: 'PDF', uploadedOn: '15 Jan 2023', expiryDate: 'N/A', status: 'Verified', fileSize: '245 KB', category: 'ID Proof', isExpiringSoon: false),
    HRDocument(id: 'D002', name: 'PAN Card', type: 'PDF', uploadedOn: '15 Jan 2023', expiryDate: 'N/A', status: 'Verified', fileSize: '187 KB', category: 'ID Proof', isExpiringSoon: false),
    HRDocument(id: 'D003', name: 'Nursing Registration Certificate', type: 'PDF', uploadedOn: '15 Jan 2023', expiryDate: '31 Dec 2026', status: 'Verified', fileSize: '512 KB', category: 'License', isExpiringSoon: true),
    HRDocument(id: 'D004', name: 'B.Sc. Nursing Degree', type: 'PDF', uploadedOn: '15 Jan 2023', expiryDate: 'N/A', status: 'Verified', fileSize: '1.2 MB', category: 'Education', isExpiringSoon: false),
    HRDocument(id: 'D005', name: 'COVID-19 Vaccination Certificate', type: 'PDF', uploadedOn: '20 Mar 2023', expiryDate: 'Lifetime', status: 'Verified', fileSize: '320 KB', category: 'Medical', isExpiringSoon: false),
    HRDocument(id: 'D006', name: 'Passport', type: 'PDF', uploadedOn: '01 Feb 2024', expiryDate: '15 Sep 2028', status: 'Verified', fileSize: '680 KB', category: 'ID Proof', isExpiringSoon: false),
    HRDocument(id: 'D007', name: 'Experience Letter – Apollo Hospitals', type: 'PDF', uploadedOn: '10 Jan 2023', expiryDate: 'N/A', status: 'Verified', fileSize: '298 KB', category: 'Experience', isExpiringSoon: false),
    HRDocument(id: 'D008', name: 'Critical Care Diploma', type: 'PDF', uploadedOn: '15 Jan 2023', expiryDate: 'N/A', status: 'Pending', fileSize: '870 KB', category: 'Certificate', isExpiringSoon: false),
  ];

  // ── Performance ───────────────────────────────────────────────────────────
  static const List<PerformanceGoal> goals = [
    PerformanceGoal(id: 'G001', title: 'Patient Satisfaction Score', description: 'Achieve patient satisfaction score ≥ 4.5/5.0', targetValue: 100, achievedValue: 87, deadline: '31 Dec 2026', status: 'In Progress', category: 'KPI'),
    PerformanceGoal(id: 'G002', title: 'Zero Medication Errors', description: 'Maintain zero critical medication errors per quarter', targetValue: 100, achievedValue: 100, deadline: '30 Sep 2026', status: 'Achieved', category: 'KPI'),
    PerformanceGoal(id: 'G003', title: 'Training Completion', description: 'Complete all mandatory training modules', targetValue: 8, achievedValue: 6, deadline: '30 Nov 2026', status: 'In Progress', category: 'KRA'),
    PerformanceGoal(id: 'G004', title: 'Documentation Accuracy', description: 'Patient record documentation accuracy ≥ 98%', targetValue: 100, achievedValue: 96, deadline: '31 Dec 2026', status: 'In Progress', category: 'KRA'),
    PerformanceGoal(id: 'G005', title: 'Infection Control Compliance', description: 'Follow infection control protocols 100% of the time', targetValue: 100, achievedValue: 100, deadline: '31 Dec 2026', status: 'Achieved', category: 'KPI'),
  ];

  static const List<PerformanceReview> reviews = [
    PerformanceReview(period: 'Q2 2026 (Apr–Jun)', reviewDate: '10 Jul 2026', rating: 'Exceeds Expectations', ratingScore: 4.3, reviewedBy: 'Dr. Rajesh Kumar', feedback: 'Priya consistently demonstrates exceptional clinical skills and leadership qualities. She handled critical cases with great composure.', status: 'Completed'),
    PerformanceReview(period: 'Annual 2025', reviewDate: '15 Jan 2026', rating: 'Exceeds Expectations', ratingScore: 4.1, reviewedBy: 'Dr. Rajesh Kumar', feedback: 'Strong performer with high patient satisfaction. Excellent teamwork and communication skills.', status: 'Completed'),
  ];

  static const List<Award> awards = [
    Award(title: 'Best Nurse of the Quarter', date: 'Apr 2026', givenBy: 'Hospital Management', description: 'Awarded for exceptional patient care and zero errors in Q1 2026.', category: 'Excellence'),
    Award(title: 'Covid Warrior Certificate', date: 'Jun 2021', givenBy: 'Government of Maharashtra', description: 'Recognized for frontline service during the COVID-19 pandemic.', category: 'Service'),
    Award(title: 'Team Player Award', date: 'Dec 2024', givenBy: 'HR Department', description: 'Outstanding contribution to team building and mentoring new nurses.', category: 'Teamwork'),
  ];

  // ── Training ──────────────────────────────────────────────────────────────
  static const List<TrainingCourse> trainings = [
    TrainingCourse(id: 'T001', title: 'Advanced Cardiac Life Support (ACLS)', category: 'Clinical Skills', instructor: 'Dr. Meera Pillai', startDate: '01 Aug 2026', endDate: '03 Aug 2026', duration: '3 days', mode: 'Classroom', status: 'Upcoming', progress: 0, hasCertificate: false),
    TrainingCourse(id: 'T002', title: 'Infection Control & Prevention', category: 'Safety & Compliance', instructor: 'Dr. Sanjay Gupta', startDate: '10 Jun 2026', endDate: '10 Jun 2026', duration: '1 day', mode: 'Online', status: 'Completed', progress: 1.0, hasCertificate: true, certificateDate: '10 Jun 2026'),
    TrainingCourse(id: 'T003', title: 'Patient Communication & Empathy', category: 'Soft Skills', instructor: 'Ms. Kavitha Nair', startDate: '15 Jul 2026', endDate: '17 Jul 2026', duration: '3 days', mode: 'Blended', status: 'Ongoing', progress: 0.6, hasCertificate: false),
    TrainingCourse(id: 'T004', title: 'EMR System – Advanced Module', category: 'IT & Systems', instructor: 'Mr. Ravi Chandran', startDate: '01 Mar 2026', endDate: '02 Mar 2026', duration: '2 days', mode: 'Online', status: 'Completed', progress: 1.0, hasCertificate: true, certificateDate: '02 Mar 2026'),
    TrainingCourse(id: 'T005', title: 'Fire Safety & Emergency Evacuation', category: 'Safety & Compliance', instructor: 'Mr. Arvind Singh', startDate: '05 Sep 2026', endDate: '05 Sep 2026', duration: '1 day', mode: 'Classroom', status: 'Upcoming', progress: 0, hasCertificate: false),
  ];

  // ── Assets ────────────────────────────────────────────────────────────────
  static const List<HRAsset> assets = [
    HRAsset(id: 'A001', name: 'Laptop – Dell Inspiron', type: 'Laptop', assetCode: 'IT-LT-0042', assignedDate: '15 Jan 2023', condition: 'Good', status: 'Active', serialNumber: 'DELL9824KL', model: 'Inspiron 15', brand: 'Dell'),
    HRAsset(id: 'A002', name: 'Staff ID Card', type: 'ID Card', assetCode: 'HR-ID-0047', assignedDate: '15 Jan 2023', condition: 'Good', status: 'Active'),
    HRAsset(id: 'A003', name: 'Nurse Uniform – Set of 3', type: 'Uniform', assetCode: 'HR-UN-0047', assignedDate: '15 Jan 2023', condition: 'Good', status: 'Active'),
    HRAsset(id: 'A004', name: 'Stethoscope – Littmann', type: 'Medical Equipment', assetCode: 'MED-ST-0023', assignedDate: '15 Jan 2023', condition: 'Excellent', status: 'Active', brand: 'Littmann', model: 'Classic III'),
    HRAsset(id: 'A005', name: 'Mobile Phone – Samsung', type: 'Mobile', assetCode: 'IT-MB-0018', assignedDate: '01 Jun 2024', condition: 'Good', status: 'Active', serialNumber: 'SAM2024XL', brand: 'Samsung'),
  ];

  // ── Loan ──────────────────────────────────────────────────────────────────
  static final List<LoanDetail> loans = [
    LoanDetail(
      id: 'LN001', loanType: 'Personal Loan', principalAmount: 120000,
      interestRate: 8.5, tenureMonths: 24, emiAmount: 5450,
      outstandingBalance: 65400, totalRepaid: 54600,
      disbursedDate: '01 Aug 2024', status: 'Active',
      emiSchedule: List.generate(24, (i) => EMIPayment(
        installmentNo: i + 1,
        dueDate: '01 ${[
          'Sep 2024','Oct 2024','Nov 2024','Dec 2024','Jan 2025','Feb 2025',
          'Mar 2025','Apr 2025','May 2025','Jun 2025','Jul 2025','Aug 2025',
          'Sep 2025','Oct 2025','Nov 2025','Dec 2025','Jan 2026','Feb 2026',
          'Mar 2026','Apr 2026','May 2026','Jun 2026','Jul 2026','Aug 2026',
        ][i]}',
        amount: 5450,
        status: i < 10 ? 'Paid' : i == 10 ? 'Upcoming' : 'Upcoming',
        paidDate: i < 10 ? '28 ${['Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar','Apr','May'][i]} ${i < 4 ? 2024 : 2025}' : null,
      )),
    ),
  ];

  // ── Expenses ──────────────────────────────────────────────────────────────
  static const List<ExpenseClaim> expenses = [
    ExpenseClaim(id: 'EX001', type: 'Travel', description: 'Taxi to Regional Medical Conference, Pune', amount: 1850, date: '15 Jul 2026', status: 'Pending', submittedOn: '16 Jul 2026'),
    ExpenseClaim(id: 'EX002', type: 'Medical', description: 'Annual Health Check-up reimbursement', amount: 2500, date: '10 Jun 2026', status: 'Approved', submittedOn: '12 Jun 2026', approvedBy: 'Dr. Rajesh Kumar'),
    ExpenseClaim(id: 'EX003', type: 'Food', description: 'Team lunch during patient care workshop', amount: 680, date: '05 Jun 2026', status: 'Approved', submittedOn: '06 Jun 2026', approvedBy: 'Dr. Rajesh Kumar'),
    ExpenseClaim(id: 'EX004', type: 'Travel', description: 'Train ticket – Mumbai to Delhi (CME Programme)', amount: 2200, date: '20 Mar 2026', status: 'Approved', submittedOn: '25 Mar 2026', approvedBy: 'Dr. Rajesh Kumar'),
    ExpenseClaim(id: 'EX005', type: 'Accommodation', description: 'Hotel stay – Annual nursing conference', amount: 3500, date: '21 Mar 2026', status: 'Rejected', submittedOn: '25 Mar 2026', approvedBy: 'Dr. Rajesh Kumar'),
  ];

  // ── Requests ──────────────────────────────────────────────────────────────
  static const List<HRRequest> requests = [
    HRRequest(id: 'RQ001', type: 'Attendance Correction', subject: 'Missing punch-in on 18 Jul 2026', description: 'I was present but the biometric device did not capture my punch-in. Please correct the record.', submittedOn: '19 Jul 2026', status: 'Pending'),
    HRRequest(id: 'RQ002', type: 'Asset Request', subject: 'Request for BP Monitor', description: 'Requesting a digital BP monitor for daily ward rounds as the current one is malfunctioning.', submittedOn: '10 Jul 2026', status: 'Approved', remarks: 'Asset allocated. Collect from stores by 15 Jul.', resolvedOn: '12 Jul 2026'),
    HRRequest(id: 'RQ003', type: 'Shift Change', subject: 'Shift change request for 20 Jul 2026', description: 'Requesting shift change from morning to afternoon due to personal reasons.', submittedOn: '18 Jul 2026', status: 'Pending'),
    HRRequest(id: 'RQ004', type: 'Expense Claim', subject: 'Conference travel reimbursement', description: 'Requesting reimbursement for travel to Regional Nursing Conference on 15 Jul 2026.', submittedOn: '16 Jul 2026', status: 'Pending'),
    HRRequest(id: 'RQ005', type: 'Transfer Request', subject: 'Department transfer – Pediatrics', description: 'Requesting transfer to Pediatrics department due to personal interest and skill alignment.', submittedOn: '01 Jun 2026', status: 'Rejected', remarks: 'No vacancy currently in Pediatrics. Will be considered in next quarter.', resolvedOn: '10 Jun 2026'),
  ];

  // ── Approvals ─────────────────────────────────────────────────────────────
  static const List<ApprovalItem> approvals = [
    ApprovalItem(id: 'AP001', type: 'Leave Request', requestedBy: 'Anita Patel', requestedOn: '22 Jul 2026', description: 'Annual leave request: 01–03 Aug 2026 (3 days)', status: 'Pending'),
    ApprovalItem(id: 'AP002', type: 'Expense Claim', requestedBy: 'Suresh Nair', requestedOn: '20 Jul 2026', description: 'Travel expense claim: ₹1,200 for hospital visit', status: 'Pending'),
    ApprovalItem(id: 'AP003', type: 'Overtime', requestedBy: 'Meena Krishnan', requestedOn: '18 Jul 2026', description: 'OT request: 3 hours on 17 Jul 2026 – Emergency duty', status: 'Approved', remarks: 'Approved. OT credit added.', actionDate: '19 Jul 2026'),
    ApprovalItem(id: 'AP004', type: 'Shift Swap', requestedBy: 'Ravi Kumar', requestedOn: '15 Jul 2026', description: 'Shift swap: 20 Jul ↔ 22 Jul with Anita Patel', status: 'Approved', actionDate: '16 Jul 2026'),
    ApprovalItem(id: 'AP005', type: 'Asset Request', requestedBy: 'Pooja Mehta', requestedOn: '10 Jul 2026', description: 'Request for Pulse Oximeter for ICU ward', status: 'Rejected', remarks: 'Item not available. Submit request for procurement.', actionDate: '12 Jul 2026'),
  ];

  // ── Notifications ─────────────────────────────────────────────────────────
  static const List<HRNotification> notifications = [
    HRNotification(id: 'N001', title: 'Salary Credited', body: 'Your salary of ₹44,251 for July 2026 has been credited to your account.', type: 'Alert', time: '28 Jul, 9:05 AM', isRead: false),
    HRNotification(id: 'N002', title: 'Leave Application Update', body: 'Your leave request (LV001) for 10–12 Aug 2026 is pending approval.', type: 'Reminder', time: '22 Jul, 11:30 AM', isRead: false),
    HRNotification(id: 'N003', title: 'HR Circular: New Leave Policy', body: 'Please review the updated Leave Policy (v2.3) effective from 01 Aug 2026.', type: 'Circular', time: '20 Jul, 10:00 AM', isRead: true),
    HRNotification(id: 'N004', title: 'Training Reminder', body: 'ACLS Training is scheduled on 01 Aug 2026. Please confirm your attendance.', type: 'Reminder', time: '18 Jul, 9:00 AM', isRead: true),
    HRNotification(id: 'N005', title: 'Hospital Announcement', body: 'Hospital blood donation drive on 30 Jul 2026 in Conference Hall. All staff are encouraged to participate.', type: 'Announcement', time: '17 Jul, 3:00 PM', isRead: true),
    HRNotification(id: 'N006', title: 'Document Expiry Alert', body: 'Your Nursing Registration Certificate expires on 31 Dec 2026. Please renew it.', type: 'Alert', time: '15 Jul, 9:00 AM', isRead: true),
  ];

  // ── Dashboard data ────────────────────────────────────────────────────────
  static const List<DashboardAnnouncement> announcements = [
    DashboardAnnouncement(id: 'AN001', title: 'New HR Portal Launch', content: 'The upgraded HR Portal with self-service features is now live. Please explore the new modules.', date: '20 Jul 2026', postedBy: 'HR Department', priority: 'High'),
    DashboardAnnouncement(id: 'AN002', title: 'Annual Health Check-up Camp', content: 'A free health check-up camp for all staff will be conducted on 05 Aug 2026 in the hospital auditorium.', date: '18 Jul 2026', postedBy: 'Administration', priority: 'Medium'),
    DashboardAnnouncement(id: 'AN003', title: 'Updated Dress Code Policy', content: 'Kindly adhere to the updated uniform policy effective from 01 Aug 2026. Details in Company Policies.', date: '15 Jul 2026', postedBy: 'HR Department', priority: 'Low'),
  ];

  static const List<BirthdayItem> birthdays = [
    BirthdayItem(name: 'Dr. Sneha Kulkarni', designation: 'Cardiologist', date: 'Today', isToday: true, initials: 'SK'),
    BirthdayItem(name: 'Ravi Kumar', designation: 'Lab Technician', date: '26 Jul', isToday: false, initials: 'RK'),
    BirthdayItem(name: 'Pooja Mehta', designation: 'Pharmacist', date: '28 Jul', isToday: false, initials: 'PM'),
    BirthdayItem(name: 'Suresh Nair', designation: 'Senior Nurse', date: '30 Jul', isToday: false, initials: 'SN'),
  ];

  static const List<WorkAnniversaryItem> anniversaries = [
    WorkAnniversaryItem(name: 'Dr. Rajesh Kumar', designation: 'Head of Cardiology', years: 10, date: 'Today', isToday: true, initials: 'RK'),
    WorkAnniversaryItem(name: 'Anita Patel', designation: 'Senior Nurse', years: 5, date: '28 Jul', isToday: false, initials: 'AP'),
  ];

  // ── Policies ──────────────────────────────────────────────────────────────
  static const List<HRPolicy> policies = [
    HRPolicy(id: 'P001', title: 'Attendance & Punctuality Policy', category: 'Attendance', version: 'v3.1', effectiveDate: '01 Jan 2026', lastUpdated: '20 Dec 2025', description: 'Defines attendance expectations, late mark rules, biometric usage, and early exit norms.', pages: 12),
    HRPolicy(id: 'P002', title: 'Leave Management Policy', category: 'Leave', version: 'v2.3', effectiveDate: '01 Aug 2026', lastUpdated: '15 Jul 2026', description: 'Covers all leave types, accrual rules, approval workflow, and encashment norms.', pages: 18),
    HRPolicy(id: 'P003', title: 'Payroll & Compensation Policy', category: 'Payroll', version: 'v1.8', effectiveDate: '01 Apr 2026', lastUpdated: '25 Mar 2026', description: 'Salary structure, deductions, incentives, reimbursements, and payslip guidelines.', pages: 24),
    HRPolicy(id: 'P004', title: 'General HR Policy', category: 'HR', version: 'v4.0', effectiveDate: '01 Jan 2025', lastUpdated: '01 Dec 2024', description: 'Recruitment, induction, performance management, transfers, and grievance redressal.', pages: 46),
    HRPolicy(id: 'P005', title: 'Hospital Standard Operating Procedures', category: 'SOP', version: 'v6.2', effectiveDate: '01 Mar 2026', lastUpdated: '20 Feb 2026', description: 'Clinical and administrative SOPs for all hospital operations and patient care protocols.', pages: 112),
    HRPolicy(id: 'P006', title: 'Code of Conduct', category: 'HR', version: 'v2.1', effectiveDate: '01 Jan 2025', lastUpdated: '01 Dec 2024', description: 'Professional ethics, patient rights, confidentiality, and disciplinary procedures.', pages: 20),
    HRPolicy(id: 'P007', title: 'IT & Data Security Policy', category: 'IT', version: 'v1.5', effectiveDate: '01 Jun 2025', lastUpdated: '15 May 2025', description: 'Acceptable use of IT systems, data protection, password policies, and incident reporting.', pages: 16),
    HRPolicy(id: 'P008', title: 'Patient Safety & Infection Control Policy', category: 'Clinical', version: 'v3.0', effectiveDate: '01 Jan 2026', lastUpdated: '20 Dec 2025', description: 'Hand hygiene, PPE usage, waste management, and infection control standards.', pages: 30),
  ];
}
