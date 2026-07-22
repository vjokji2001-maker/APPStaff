import 'package:staff_mate/APIs/api_host.dart';

class ApiEndpoints {
  // ============ FROM ApiService (login) ============
  static String get login => '${ApiHost.securityBaseUrl}/auth/login';
  static String get refresh => '${ApiHost.securityBaseUrl}/auth/refresh';
  static String get sendOtp => '${ApiHost.securityBaseUrl}/auth/send-otp';
  static String get verifyOtp => '${ApiHost.securityBaseUrl}/auth/verify-otp';
  
  // ============ FROM IpdService ============
  static String get ipdPatients => '${ApiHost.ipdBaseUrl}/patient/all';
  static String get practitionerList => '${ApiHost.smartcareMainBaseUrl}/practitionerlist';
  static String get specializationList => '${ApiHost.smartcareMainBaseUrl}/clinic/specializationlist';
  static String wardList(String branchId) => '${ApiHost.smartcareMainBaseUrl}/clinic/branchwisewardlist/$branchId';
  static String availableBeds(String wardId) => '${ApiHost.smartcareMainBaseUrl}/clinic/availablebedinward/$wardId';
  static String get vitalsMaster => '${ApiHost.ipdBaseUrl}/common/get/vitals';
  static String vitalsByType(int vitalType) => '${ApiHost.ipdBaseUrl}/common/get/vitals/$vitalType';
  static String get saveVitals => '${ApiHost.ipdBaseUrl}/common/save/timewise/vitals';
  static String prescriptionNotification(String admissionId) => '${ApiHost.ipdBaseUrl}/patient/getNotification/priscription/$admissionId';
  static String investigationNotification(String admissionId) => '${ApiHost.ipdBaseUrl}/patient/getNotification/investigation/$admissionId';
  static String get dayToDayNotes => '${ApiHost.ipdBaseUrl}/patient/daytodaynotes/fetch';
  static String get saveDayToDayNotes => '${ApiHost.ipdBaseUrl}/patient/daytodaynotes/save';
  static String get shiftBed => '${ApiHost.ipdBaseUrl}/common/shiftbed';
  static String get addStdCharges => '${ApiHost.ipdBaseUrl}/patient/addstdcharges';
  static String get uploadDocument => '${ApiHost.smartcareMainBaseUrl}/patient/uploadDocuments';
  static String get prescriptionLocation => '${ApiHost.ipdBaseUrl}/prisc/location/get';
  
  // ============ FROM AddMedicineService ============
  static String get addMedicine => '${ApiHost.smartcareMainBaseUrl}/priscriptionmaster/medicinedetails/saveorupdate';
  
  // ============ FROM PackageService ============
  static String get packageExists => '${ApiHost.billingBaseUrl}/patientpackage/getPackageIfExists';
  static String get referenceList => '${ApiHost.smartcareMainBaseUrl}/refrencelist';
  static String get chargeTypeList => '${ApiHost.billingBaseUrl}/charges/chargetype/list';
  static String get masterDetailList => '${ApiHost.billingBaseUrl}/charges/master-detail-list';
  static String get createCharge => '${ApiHost.billingBaseUrl}/charges/createnew';
  
  // ============ FROM ClinicService ============
  static String clinicDetails(String clinicId) => '${ApiHost.smartcareMainBaseUrl}/clinic/details/clinicid/$clinicId';
  
  // ============ FROM FrequencyService ============
  static String get frequencyData => '${ApiHost.smartcareMainBaseUrl}/priscriptionmaster/datalist';
  
  // ============ FROM InvestigationService ============
  static String get packageList => '${ApiHost.masterBaseUrl}/package/packagelist';
  static String investigationTypes(int typeId) => '${ApiHost.smartcareMainBaseUrl}/investigation/master/testtypelist/$typeId/0';
  static String get investigationTemplate => '${ApiHost.smartcareMainBaseUrl}/investigation/investigtiontemplate';
  static String get saveInvestigation => '${ApiHost.smartcareMainBaseUrl}/investigation/savetestrequest';
  static String get parameterList => '${ApiHost.smartcareMainBaseUrl}/investigation/master/parameterlist';
  static String get getCharge => '${ApiHost.smartcareMainBaseUrl}/investigation/master/getcharge';
  static String get jobTitleList => '${ApiHost.smartcareMainBaseUrl}/clinic/jobtitle/list';
  static String patientInformation(String patientId) => '${ApiHost.smartcareMainBaseUrl}/patient/information/$patientId';
  static String patientIpdDetails(String patientId) => '${ApiHost.billingBaseUrl}/statement/patientinfoandlastipddetails/$patientId';
  
  // ============ FROM MedicineService ============
  static String get medicineList => '${ApiHost.smartcareMainBaseUrl}/priscriptionmaster/medicinelist';
  static String get medicineDetails => '${ApiHost.smartcareMainBaseUrl}/priscriptionmaster/medicinedetails';
  
  // ============ FROM RepeatPrescriptionService ============
  static String get repeatPrescriptionList => '${ApiHost.smartcareMainBaseUrl}/priscription/repeatpriscriptionList';
  
  // ============ FROM SavePrescriptionService ============
  static String get savePrescription => '${ApiHost.smartcareMainBaseUrl}/priscription/save';
  
  // ============ FROM UnitService ============
  static String get unitStrength => '${ApiHost.smartcareMainBaseUrl}/priscriptionmaster/strengthlist';
  
  // ============ FROM UserInformationService ============
  static String get userInformation => '${ApiHost.smartcareMainBaseUrl}/userinformation';

  // ============ FROM DocumentService ============
  static String get documentTypes => '${ApiHost.smartcareMainBaseUrl}/patient/documenttypes';

  // ============ FROM DashboardService ============
  static String get dashboardData => '${ApiHost.smartcareMainBaseUrl}/dashboard/summary';

  // ============ FROM DischargeService ============
  static String get dischargeSummary => '${ApiHost.smartcareMainBaseUrl}/discharge/summary';

  // ============ FROM TransferService ============
  static String get transferPatient => '${ApiHost.smartcareMainBaseUrl}/patient/transfer';

  // ============ FROM LogoutService ============
  static String get logout => '${ApiHost.securityBaseUrl}/auth/logout';

  // ============ FROM ProfileService ============
  static String get profile => '${ApiHost.smartcareMainBaseUrl}/user/profile';

  // ============ FROM ChangePasswordService ============
  static String get changePassword => '${ApiHost.securityBaseUrl}/auth/changepassword';

  // ============ FROM NotificationService ============
  static String get notifications => '${ApiHost.smartcareMainBaseUrl}/notification/list';

  // ============ FROM SearchService ============
  static String searchPatients(String query) => '${ApiHost.smartcareMainBaseUrl}/patient/search?query=$query';

  // ============ FROM AdmissionService ============
  static String get admission => '${ApiHost.smartcareMainBaseUrl}/admission/save';

  // ============ FROM BedService ============
  static String get bedList => '${ApiHost.smartcareMainBaseUrl}/clinic/bedlist';

  // ============ FROM BranchService ============
  static String get branchList => '${ApiHost.smartcareMainBaseUrl}/clinic/branchlist';

  //=========== FROM MYTASKS SERVICE ============
  static String get myTasksCategory => '${ApiHost.appBaseUrl}/master/category/master/getAll';
  static String get saveTask => '${ApiHost.appBaseUrl}/master/task/master/save';
  static String get myTasksList => '${ApiHost.appBaseUrl}/master/task/master/fetch';
  static String get updateTaskStatus => '${ApiHost.appBaseUrl}/master/task/master/update';

  //=========== FROM Email/Password Services ============
  static String get verifyEmailBase => '${ApiHost.smartcareMainBaseUrl}/verifyemail';
  static String get passwordUpdateBase => '${ApiHost.smartcareMainBaseUrl}/passwordupdate';

  //=========== FROM Sclyte ============
  static String get treatmentRecords => '${ApiHost.sclyteBaseUrl}/patientTreatmentRecords';
  static String get sclyteLogin => '${ApiHost.sclyteBaseUrl}/login';

}
