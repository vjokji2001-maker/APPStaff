import {
  ABDMHOST,
  apiHost,
  tallyHost,
  generateApiUrl,
  accountingHost,
  MISREPORTOST,
  videoMonitoringHost,
} from "./apiHost";
const smartcaremainBase = `smartcaremain/`;
const billingBase = `billing/`;
const apiBase = `accounting/`;
const ipdBase = `ipd/`;
const masterBase = `master/`;
const inventoryBase = `inventory/`;
const pharmacyBase = `pharmacy/`;
const misBase = `mis/`;
const tallyBase = `tally/`;
const settingBase = `settings/`;
const immunization = `master/immunization/`;
const supportBase = `support/`;
const crmBase = `crm/`;
const abdmBase = `abdm/` //abdm

// FOR ABDM API'S ONLY
// SWAGGER LINK - http://localhost:8081/smartcaremain/swagger-ui.html#!/
export const GENRATEABDMTOKEN = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api`,
);

export const VERIFYAADHAAROTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/enroll`,
);

export const ABHACARDDOWNLOAD = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/download/abhacard
`,
);

export const OPDALLREADYBOOK = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/opdcountbypatient`,
);

export const ABDMPROFILEDETAILS = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/profile/details
`,
);

export const ABDMPADDRESSROFILEDETAILS = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/abha/address/profile/details
`,
);

export const ALLREADYREGISTERAADHAROTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/verify/mobileotp/viadahar`,
);

export const ALLREADYREGVERIFYOTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/verification/via/adhar`,
);

export const GENRATEAADHAAROTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/genrateadharotp`,
);

export const GENRATEMOBILEOTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/genrate/mobileotp`,
);

export const VERIFYMOBILEOTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/verify/mobileotp`,
);

export const CHECKHEALTHIDEXIST = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/check/helthidallreadyexists`,
);
export const CREATEHEALTHID = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/create/healthid`,
);

export const SEARCHABHANUMBER = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/abha/search`,
);

export const ABDMCONSENTDASHBOARD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}m3/consent/dashboard`,
);

export const ABDMUPDATEPATIENTQUE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/update/patient/que
`,
);

export const ABDMPATIENTQUE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/abdm/patient/Que`,
);

export const SAVEABDMREGISTRATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/save/abdm/registration`,
);

export const REQUESTCONSENTS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}m3/request/init`,
);

export const PATIENTDISCOUNTGRPLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/discount/group/list`,
);

export const OPDFOLLOWUPLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}followup/getAll`,
);

export const FORGETPASSWORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}passwordupdate/sendEmailOTP`,
);
export const VERIFYOTP = generateApiUrl(
  apiHost,
  `${smartcaremainBase}passwordupdate/verifyOTP`,
);
export const UPDATEPASSWORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}passwordupdate/updatePassword`,
);

export const USERMASTERDASHBOARD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}userdashboardlist`,
);
export const EDITUSERDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}getUserDetails/`,
);
// COMMAON API'S USED IN INVESTIGATION, OPD, PATIENT PANEL, CLINICAL NOTES, INVESTIGATION MASTER, LOGIN, USER AND CLIENT DATA
// SWAGGER LINK - http://localhost:8081/smartcaremain/swagger-ui.html#!/

export const VERIFYLOGIN = generateApiUrl(
  apiHost,
  `${smartcaremainBase}verifylogincreds`,
);

export const DOWNLOADIMAGE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/downloadDocuments`,
);

// export const LOGIN = generateApiUrl(apiHost, PROTOCOL_SCECURITY ? `security/auth/login` : `${smartcaremainBase}c`);
export const LOGIN = generateApiUrl(apiHost, `security/auth/login`);

// export const LOGIN = generateApiUrl(apiHost, `${smartcaremainBase}login`);

export const REFRESHTOKEN = generateApiUrl(apiHost, `security/auth/refresh`);

export const USERINFO = generateApiUrl(
  apiHost,
  `${smartcaremainBase}userinformation`,
);

export const SECURITYLOGOUT = generateApiUrl(apiHost, `security/auth/logout`);

export const ABDMPATIENTDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/fetch/patient/details`,
);

export const USERACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}useraccess`,
);

export const DISCOUNTGROUP = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/save/discount/group`,
);

export const UPDATEPROFILE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}updatepassword`,
);

export const INVOICEGROUPDISCOUNT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/invoicediscountgroup/`,
);

export const USERUPDATEINFO = generateApiUrl(
  apiHost,
  `${smartcaremainBase}getuserupdatepassworddata`,
);
export const CLINICDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/details/clinicid/`,
);

export const FETCHCHIEFCOMPLAINS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/fetch/cheif/complains`,
);
export const REQUESTPRISCRIPTIONDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/template/medicine/`,
);
export const SAVEPRESCRIPTIONTEMPLATE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/template/medicine/save`,
);
export const SAVEPRESCRIPTIONINSTRUCTION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/saveinstruction`,
);
export const INVESTIGATIONJOBTITLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/jobtitle/list`,
);
export const SAVEINVESTIGATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/savertestrequest`,
); //Old request Investigation
export const NEWSAVEINVESTIGATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/savetestrequest`,
); //New request Investigation

export const INVESTIGATIONPACKAGE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}package/parentlist/2`,
);
export const SAVEPATIENTDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/register`,
);
export const COUNTRYSTATECITYLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/cityStateCountryList`,
);

export const CREATEACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/create`,
);

export const ASSIGNMODULE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/assign/module`,
);

export const USERADMINISTRATIONCLIENTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/all/active/clients
`,
);

export const HOSPITALCONFIGRATIONACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/update`,
);

export const GETALLCONFIGRATIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/getallconfiguration`,
);

export const GETKEYNAMEALLREADYEXIT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/check/keyname/exist/`,
);

export const EXTENDSUBSCRIPTON = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/extend/subscription/details`,
);

export const SUBSCRIPTIONLOGS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/subscription/logs/`,
);

export const CREATENEWACCOUNT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/request/new/client`,
);

export const MODULELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}configuration/module`,
);
export const PINCODE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/city/postalcode/`,
);
export const THIRDPARTYLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/thirdpartylist`,
);
export const PRACTITIONERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}practitionerlist`,
);
export const REFFERALDOCDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/refraldetails/`,
);
export const PATIENTINFO = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/information/`,
);
export const MAINPATIENTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/fetchlist`,
);
export const REFERRALLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}refrencelist`,
);
export const INITIALLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/initiallist`,
);
export const PHONECODE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/countryandphone`,
);
export const CLINICPATIENTDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/patientdata`,
);

export const CLINICNOTESTEMPLATEDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/othertemplate/`,
);
export const SENDCLINICALNOTESEMAIL = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/sendClinicalNotesMail`,
);
export const CLINICACCESSLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicaccess/getallaccess`,
);
export const PATIENTVITALS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/fetch/vitals/`,
);
export const SAVEPATIENTVITALS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/save/vitals`,
);
export const PRESCRIPTIONMASTERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/datalist`,
);
export const DOCUMENTTYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/documentList`,
);
export const OCCUPATIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/occupationList`,
);
export const CONDITIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/conditionList`,
);
export const DISCOUNTGRPLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/discountGrpList`,
);
export const MEDICINENAMELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/medicinelist`,
);
export const SAVEPRESCRIPTIONRECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/save`,
);
export const SAVEMEDICINEDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/medicinedetails/saveorupdate`,
);
export const ADDMEDICINEDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/medicinedetails`,
);
export const PRESCRIPTIONPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/print/`,
);
export const EDITPATIENTINFO = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/getPatientInfoForUpdate`,
);

export const ABHANUMBERALLREADYEXIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/check/abha/number
`,
);

export const INVESTIGATIONMASTERREPORT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/view/report
`,
);

export const UPDATEPATIENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/updatePatientInformation`,
);

export const IMMUNIZATIONDATA = generateApiUrl(
  apiHost,
  `${immunization}patient/`,
);

export const IMMUNIZATIONUPDATE = generateApiUrl(
  apiHost,
  `${immunization}update`,
);

export const VACCINATIONMASTERLIST = generateApiUrl(
  apiHost,
  `master/vaccinations/get`,
);


export const WARDLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/branchwisewardlist/`,
);
export const CHECKPATIENTBYMOBILE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/findbymobile/`,
);
export const CHECKBYAADHAAR = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/findbyadhar/`,
);
export const DISCOUNTTEAMLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/discountteams/list`,
);
export const DISCOUNTTEAMUSERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/discountteams/userlist/`,
);
export const CAMPDATALIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}package/campmasterlist`,
);
export const INVESTIGATIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/investigationDashboard`,
);
export const NEWSAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/collectsample/`,
);
export const NEWSAMPLECOLLECTAT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/updatecollectedBy`,
);
export const RECIEVEDSAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/recievedsample/`,
);
export const COLLECTEDSAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/testdetailswithparameter/`,
);
export const COMPLETEDSAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/completereport`,
);
export const APPROVEDSAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/approvereport`,
);
export const DELETEADDEDANTIBIOTICS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/antibiotics/delete/`,
);
export const OUTSOURCELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/outsourcelist`,
);
export const CANCELINVESTIGATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/canclereport`,
);
export const SENDOUTSOURCESAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/outsourcesample`,
);
export const INVESTIGATIONTYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/testtypelist/`,
);
export const NEWINVESTIGATIONTYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/testtypelistnew/`,
);
export const UPDATEINVESTIGATIONOUTSOURCE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/updateoutsourcedetails`,
);
export const INVESTIGATIONTEMPLATES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/fetchPreviousInvestigationlist`,
);
export const INVESTIGATIONTEMPLATEINFO = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/fetchPreviousInvestigationlist`,
);
export const INVESTIGATIONPARAMETERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/parameterlist/`,
);
export const CHECKIFEXISTVALIDATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}checkifexist`,
);
export const HEALTHICDCODES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}emr/health/issue/code/getAll/?searchText=`,
);
//OLD API GET METHOD
export const INVESTIGATIONNEWPARAMETERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/parameterlist`,
); //NEW API POST METHOD
export const INVESTIGATIONSIGNATURE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}practitioner/signaturepath/`,
);
export const INVESTIGATIONSECTIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/sectionlist`,
);
export const SECTIONWISETEMPLATELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/sectionwisetemplates/`,
);
export const SAVESECTIONWISETEMPLATELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/sectionwisetemplates`,
);
export const UPDATESTATUS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/setpaymentstatus`,
);
export const UPDATESIGNUNATUREONPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/updatesignatureonprint`,
);
export const UPDATEHIGHLIGHTNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/updatehighlightnotes`,
);
export const INVESTIGATIONQRCODE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/genrateqrcoddereport`,
);
export const ALLTESTDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/alltestdetails`,
);
export const COMPLETEALLTESTDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/complete/all/tests`,
);
export const COLLECTALLINVESTIGATIONS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/collectsample/multiple`,
);
export const APPROVEALLTESTDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/approve/all/tests`,
);
export const USERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}userlist/`,
);
export const PATHLABPRATITIONERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}pathlabpractitionerList`,
);
export const SECTIONWISEREPORTPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/sectionwise/print`,
);
export const FINDDISCGRPPERCENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/finddiscountgrouppercent/`,
);
export const PRINTINVESTIGATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/print`,
);
export const SPECIALIZATIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/specializationlist`,
);
export const AVAILABLEBED = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/branchwise/wardwise/availablebed`,
);
export const BEDINFOWARDWISE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/availablebedinward/`,
);
export const PRACTITIONERLISTWITHDIARY = generateApiUrl(
  apiHost,
  `${smartcaremainBase}practitioner/withdiary`,
);
export const DIARYSLOTS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/dashboardlist`,
);
export const BOOKOPDAPPOINMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/book`,
);
export const RECORDACTIVITYLOG = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/recordactivitylog`,
);
export const USERDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}userdetails/`,
);
export const APPOINMENTPREVIEW = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/preview`,
);
export const CHANGEPATIENTSTATUS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/changePatientStatus`,
);
export const UPDATEPATIENTAUTOCHARGE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/updateAutocharge`,
);
export const MONDAYLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/mondaylist/`,
);
export const SETPRACTIONERDIARY = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/savepractitionerdiary`,
);
export const PAYMENTINVOICEDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/fetchpaymentmasterdetails`,
);
export const COUNTBYPATIENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/countbypatient/`,
);
export const OPDMODIFYAPPOINMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/modify`,
);
export const VIDEOAPPOINMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/capture/video`,
);
export const INVESTIGATIONREPORTTYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/reporttypelist`,
);
export const INVESTIGATIONREPORTLINKDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/report/linked/data/`,
);
export const SAVEINVESTIGATIONREPORTLINKVALUE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/report/link/data/save`,
);
export const SAVEINVESTIGATIONGROUPVALUE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/report/link/save/masterData`,
);
export const SAVEINVESTIGATIONMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/save`,
);
export const TESTPARAMETERMASTERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/parameter/fetch/masterdata/`,
);
export const SAVETESTPARAMETERMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/saveUpdate/parameter/masterdata`,
);
export const SAVETESTRESULTMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/saveUpdate/parameter/resultmaster`,
);
export const CHECKINVESTIGATIONNAME = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/checkname`,
);
export const UPDATEMETHODNAME = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/parameter/methodname/linked/saveupdate`,
);

export const COMPLAINTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/speciality/complaints/`,
);
export const CLINICALNOTESMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/masterdata`,
);
export const DIAGNOSISLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/diagnosis`,
);
export const CLINICTEMPLATEDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/templateDetailsById/`,
);
export const EMRSAVETEMPLATE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/templateDetails`,
);
export const CLINICALNOTESPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/clinicalnotesprinthtml`,
);
export const DELETECLINICALNOTESPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/clinicalnotesprinthtml/delete/`,
);
export const COMPLAINTREMARKLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/remarkagainstcomplaintid/`,
);
export const SAVECOMPLAINTREMARK = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/complaints/save/remark`,
);
export const SAVECLINICALNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save`,
);
export const NEWCLINICALNOTESPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/clinical/notes/`,
);
export const REPEATPRESCRIPTIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/repeatpriscriptionList`,
);
export const REPEATPRESCRIPTIONDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/fetchrepeatpriscrition/`,
);
export const BOOKFOLLOWUPAPPOINTMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/bookfollowupForclinicalnotes`,
);
export const CLINICALNOTESLISTRECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/fetch/htmllist`,
);
export const BOOKDUMMYAPPOINTMENTS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/savedummyappointments`,
);
export const CLINICUSERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/userlist`,
);
export const DUMMYPATIENTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/fetchlistfordummyopd`,
);
export const DUMMYPATIENTLISTFORINV = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/listofdummyopd`,
);
export const SAVEDUMMYINVESTIGATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/createandsavedummytestrequest`,
);
export const FETCHRESULTMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/fetch/parameter/resultmasterbyparamid/`,
);
export const UPLOADPATIENTIMAGE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/uploadimage`,
);
export const DECLARATIONFORMDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/declarationform/datalist/`,
);
export const FETCHFINDINGSMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/parameter/finding/master/fetch/`,
);
export const SAVERESULTFINDINGS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/parameter/finding/master/save`,
);
export const SAVECOMPLAINTSTAG = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/saveupdate/complaints`,
);

export const SAVEADVICETAG = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/tag/advice`,
);
export const SAVEDIAGNOSISTAG = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/tag/diagnosis`,
);
export const SAVEPLANMANAGETAG = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/tag/planofmanagement`,
);
export const MEDICINEMASTERDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/tag/master/medicinedetails`,
);
export const CLINICALNOTESACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/clinicalnotesaccess/`,
);
export const AUTOSAVECLINICALNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/autosave`,
);

export const FETCHSAVECLINICALNOTESDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/fetch/autosaveData
`,
);

export const DOCUMENTINVESTIGATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/uploaddocuments`,
);
export const DOCUMENTUPLOADEMR = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/uploaddocument`,
);
export const UNLOCKCLINICALNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/unlockclinicalnotes`,
);
export const CHANGELETTERHEAD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/getletterhead/`,
);
export const VISITINGCONSULTANT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/visitingconsultantlist`,
);
export const PATIENTEVIDENCE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/uploadEvidenceimage`,
);
export const PATIENTEVIDENCELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/getevidencedataHistory/`,
);
export const PATIENTEVIDENCEDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/getevidencedata/`,
);
export const SAVENEWREFERENCE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/savereference`,
);

export const UPDATEREFFRAL = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/updateRefernce/`,
);
export const ALLUSERLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}alluserlist`,
);
export const BRANCHLOCATIONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/branchlocationlist`,
);
export const SAVENEWLOCATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/saveLocation`,
);
export const GETLOCATIONDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/getlocationData/`,
);
export const UPDATELOCATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/updateLocationInformation`,
);
export const DELETEPARAMETER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/deleteParameterMaster/`,
);
export const DELETEINVPRAMETER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/deleteParameter/`,
);
export const INVESTIGATIONREQUDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/patientWiseInvtReportPrint/`,
);
export const SURGEONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otsergionlist`,
);
export const ASSISTINGSTAFF = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otstafflist`,
);
export const PROCEDURELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}procedurelist/`,
);
export const ANESTHISIALIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}anesthisialist`,
);
export const OTCHARGETYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}chargetypelist/`,
);
export const OTTREATMENTEPISODELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}treatmentepisode/`,
);
export const SAVEOTREATMENTEPISODE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/savetreatmentepisode`,
);
export const USERLOGOUT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/logout/`,
);
export const LASTPRACTITIONERDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/patientLastPractionerData/`,
);
export const PATIENTVITALSLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/vitallist/`,
);
export const PATIENTVITALSHISTORY = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/vitaldatahistory`,
);
export const STRENGTHTYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/strengthlist`,
);
export const OTMONTHWISERECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/otdashboardlist/`,
);
export const ANESTHISIALOGIESTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/anesthesiaList`,
);
export const ASSISTINGSURGEONLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/assistingsurgeonList`,
);
export const SURGEONNAMELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/surgeonlist`,
);
export const DELETEPROCEDURE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/procedure/delete/`,
);
export const PROCEDURENAMELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/procedurelist/`,
);
export const DEPARTMENTNAMELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/departmentList`,
);
export const BOOKOTPATIENTRECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/otpatientwiselist`,
);
export const SAVEOTRECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/bookot`,
);
export const SAVEPROCEDURERECORDS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/fetchsaveotprocedurecharges`,
);
export const SAVEOTEQUIPMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/saveOtEquipmet`,
);
export const OTEQUIPMENTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/otEquimentList`,
);
export const PRINTOTEQUIPMENTLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/viewotequipmentlist/`,
);
export const OTAVAILABLESLOT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/otavailableslots`,
);
export const SAVEOTTEMPLATE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/saveotemplates`,
);
export const OTTEMPLATELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/ottemplatelist/`,
);
export const OTNOTESRECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/ottemplatenotes/`,
);
export const SAVEOTNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/saveotnotes`,
);
export const OTNOTESHISTORY = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/editotnotes/`,
);
export const OTPREOPERATIVENOTESHISTORY = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/editpreoperativenotes/`,
);
export const OTRECORDLOGS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/recordotlogs`,
);
export const SAVEOTEQUIPMENTNAME = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/saveotequimentmaster`,
);
export const OTSLOTDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/editOtBooking/`,
);
export const PROCEDURECHARGESRECORD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/fetchprocedurecharges`,
);
export const DELETEOTNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/deleteOtNote/`,
);
export const FETCHPROCEDURECHARGES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/createotcharges`,
);
export const OTNOTESLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/emrhistoricotdata/`,
);
export const OTPROCEDURECHARGEMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/saveotprocedurecharges`,
);
export const DELETEOTPROCEDURECHARGEMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/deleteproceduresubcharges/`,
);
export const CHECKOTSLOT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/checkotslot`,
);
export const UPDATEOTSLOTTIMING = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/updateottime`,
);
export const SAVECLINICALNOTESACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/saveclinicalnotesaccess`,
);
export const DELETESELECTEDOTSURGEONS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/deletepractitioner/`,
);
export const DELETESELECTEDOTDIAGNOSISOTNOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/otdiagnosis/delete/`,
);
export const OTREPORT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/otreport`,
);
export const SAVECLINCIUPIQR = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinic/saveqr`,
);
export const GENRATEREPORTPDF = generateApiUrl(
  apiHost,
  `${smartcaremainBase}pdfinvreport/generateinvestigationreportpdf`,
);
export const GETINVESTIGATIONCHARGES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/getcharge`,
);
export const SAVEWARDWISECHARGES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/save/wardwise/charges`,
);
export const WARDWISECHARGES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/master/getwardwise/charges`,
);
export const UPLOADPATIENTDOCUMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/uploadDocuments`,
);
export const FETCHDOCUMENT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/fetchDocuments`,
);
export const GETCLINICPROFILE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicprofile/get/`,
);
export const UPDATECLINICPROFILE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicprofile/save`,
);
export const UPDATEREGISTERDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicprofile/save/pharmacy/profile`,
);
export const MEDICINETYPELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscriptionmaster/medicnetypelist`,
);
export const UPDATEOTSURGEONANDPRACTITIONERES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/updateotpractitioner`,
);
export const UPDATEOTPROCEDUREDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/update`,
);
export const CUSTOMIZEPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}customize/fetch/`,
);
export const SAVEPRINTSETTING = generateApiUrl(
  apiHost,
  `${smartcaremainBase}customize/save`,
);
export const INVESTIGATIONANALYTICSDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}analytics/data`,
);
export const PATIENTINVESTIGATIONALAYTICALDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}analytics/patientdata`,
);
export const SAVEALLERGIES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}emr/allergy/save`,
);
export const SAVEALLERGIESMASTER = generateApiUrl(
  apiHost,
  `${smartcaremainBase}emr/allergyMaster/save`,
);
export const ALLERGIESLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}emr/allergyMaster/getAll`,
);
export const PATIENTALLERGIESLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}emr/allergy/getAll/`,
);
export const GETPATIENTDIAGNOSIS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}emr/diagnosis/getAll`,
);
export const CLINICALNOTESTEMPLATES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/othertemplate`,
);
export const BIOPSYFORMREQUEST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/saveotform`,
);
export const BIOPSYFORMPRINT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/editbiopsyform/`,
);
export const GETSLINICALNOTESTEMPLATE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/othertemplatelist/`,
);
export const FESTCHSANDSAVEINVESTIGATIONTEMPLATE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/investigtiontemplate`,
);
export const UPATEPATIENTPAYEE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/update/payee/type`,
);
export const PATIENTTREATMENTEPISODELIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}treatmentepisode/getList`,
);
export const TREATMENTEPISODELISTDASHBOARD = generateApiUrl(
  apiHost,
  `${smartcaremainBase}treatmentepisode/dashboard`,
);
export const DELETETREATMENTEPISODE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}treatmentepisode/delete/`,
);
export const FETCHTPCUSTOMIZATIONDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}customize/fetch/keyname/`,
);
export const SAVETPCUSTOMIZATIONDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}customize/save/thirdparty/setting`,
);
export const UPDATEPRESCRIPTIONSEQUENCE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/update`,
);
export const UPDATECLINICACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicaccess/updateaccessflag`,
);
export const DELETECLINCACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicaccess/deleteaccess/`,
);
export const CREATECLINICACCESS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicaccess/createaccess`,
);
export const ORDERSEQUENCE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/orderSequence`,
);
export const DOWNLOADINVESTIGATIONLOG = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigationlog/download/`,
);
export const FIELDIFEXIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}checkifexist`,
);
export const GETSAVEDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}saveuser`,
);
export const GETUSERDETAILS = generateApiUrl(
  apiHost,
  `${smartcaremainBase}getUserDetails/`,
);
export const UNCOLLECTEDSAMPLE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}investigation/uncollectsample/`,
);
export const RMOLISTDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}rmoList/`,
);
export const BIOPSYFORMLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}otbooking/biopsyFormList`,
);
export const GETDOCTORLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}getdoctorlist`,
);
export const GETLINKCARECONTEXT = generateApiUrl(
  apiHost,
  `${smartcaremainBase}m2/linkCareContext`,
);
export const GENERATELINKTOKEN = generateApiUrl(
  apiHost,
  `${smartcaremainBase}m2/generateLinkToken`,
);
export const FETCHMIMSCHECKDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}mims/check`,
);
export const DELETEASSIGNEDLOCATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}retailer/fetch`,
);

export const GETAPPOINTMENTOPDCHARGE = generateApiUrl(
  apiHost,
  `${smartcaremainBase}opd/appointment/opdcharge
`,
);
export const ABDMSENTOTPREQUEST = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/abha/mobile/request/otp
`,
);

export const ABHAADDRESSSUGGESTIONS = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/address/suggestions
`,
);

export const ABHAMULTIPLEACCOUNTS = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/abha/search/mobile
`,
);

export const ABHAPROFILEDETAILS = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/profile/details
`,
);

export const ENROLLABHAADDRESS = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/api/enroll/abha/address
`,
);

export const SENDMOBILEOTP = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/mobile/otp
`,
);

export const MOBILEOTPVERIFY = generateApiUrl(
  ABDMHOST,
  `${abdmBase}abdm/mobile/otp/verify
`,
);

export const GETBUNDAL = generateApiUrl(
  ABDMHOST,
  `${abdmBase}m3/bundle/view/
`,
);

export const MIMSDRUGINFO = generateApiUrl(
  apiHost,
  `${smartcaremainBase}mims/druginfo
`,
);

export const MIMSDRUGINTERACTION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}mims/check
`,
);
export const PRISCRIPTIONMASTERDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/masterdata
`,
);
export const MIMSACTIVECHECK = generateApiUrl(
  apiHost,
  `${smartcaremainBase}mims/active/check
`,
);
export const SAVECLINICALNOTESSEQ = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/save/clinical/notes/sequece`,
);

export const FETCHCLINICALNOTESSEQ = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/clinicalsequece/`,
);
export const CLINICALNOTESAI = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/clinical/notes/ai`,
);
export const CLINICALNOTESLIST = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/notes/list`,
);
export const NEWUPDATENOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/update/notes`,
);
export const DELETENEWUPDATENOTES = generateApiUrl(
  apiHost,
  `${smartcaremainBase}clinicalnotes/delete/`,
);
export const SEND_MOBILE_OTP = generateApiUrl(
  apiHost,
  `${smartcaremainBase}passwordupdate/sendMobOTP`,
);

export const VERIFY_MOBILE_OTP = generateApiUrl(
  apiHost,
  `${smartcaremainBase}passwordupdate/verifyMobOTP`,
);

export const LMHREGISTRATION = generateApiUrl(
  apiHost,
  `${smartcaremainBase}patient/lmh/registration/`,
);

export const POSTLMHPRESCRIPTIONDATA = generateApiUrl(
  apiHost,
  `${smartcaremainBase}priscription/lmh/priscription/`,
);

// API'S USED IN ACCOUNTS, BILLING
// SWAGGER LINK - http://localhost:8087/billing/swagger-ui.html#!/

export const RESETREVENUESHARE = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/reset`,
);

export const DISCOUNTREMOVAL = generateApiUrl(
  apiHost,
  `${billingBase}statement/discount/removal`,
);

export const TPAUPDATEFOLLOWER = generateApiUrl(
  apiHost,
  `${billingBase}tp/update/follower`,
);

export const ADDALLOCATION = generateApiUrl(
  apiHost,
  `${billingBase}tp/save/allocation
`,
);

export const VIEWALLOCATIONLIST = generateApiUrl(
  apiHost,
  `${billingBase}tp/allocation/list
`,
);

export const UPDATEALLOCATIONLIST = generateApiUrl(
  apiHost,
  `${billingBase}tp/update/allocation
`,
);

export const TPATHIRTPARTYFOLLOWERLIST = generateApiUrl(
  apiHost,
  `${billingBase}tp/thirdparty/follower/`,
);
export const ADDMEDICINECHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/addmedicineCharge/package`,
);
export const PRINTVENDER = generateApiUrl(
  apiHost,
  `${billingBase}statement/patientBillList/`,
);

export const INVOICEALLOCATIONLIST = generateApiUrl(
  apiHost,
  `${billingBase}tp/invoice/allocation/list
`,
);
export const SENDPAYMENTLINK = generateApiUrl(
  apiHost,
  `${billingBase}invoice/sendPaymentlink
`,
);
export const UPDATEINVOICEALLOCATION = generateApiUrl(
  apiHost,
  `${billingBase}tp/update
`,
);

export const DEBITALLOCATIONLOG = generateApiUrl(
  apiHost,
  `${billingBase}tp/allocation/debit/log/
`,
);

export const TPADASHBOARD = generateApiUrl(
  apiHost,
  `${billingBase}tp/dashboard
`,
);

export const CHANGEINVOICETYPE = generateApiUrl(
  apiHost,
  `${billingBase}statement/change/invoice/type`,
);
export const CHECKLIST = generateApiUrl(
  apiHost,
  `${billingBase}statement/patientAdmissionDetails/`,
);
export const PATIENTVIEWACCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}statement/newview`,
);

export const INVOICELIST = generateApiUrl(
  apiHost,
  `${billingBase}payment/record`,
);

export const FETCHPAYMENTDETAILS = generateApiUrl(
  apiHost,
  `${billingBase}payment/paymentlist`,
);

export const FETCHLASTPAYMENTDETAILS = generateApiUrl(
  apiHost,
  `${billingBase}payment/last/paymentdata
`,
);

export const PROCESSINGRECORDPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}payment/save`,
);
export const NEWPROCESSINGRECORDPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}payment/savenew`,
);
export const DEPARTMENTLOCATION = generateApiUrl(
  apiHost,
  `${billingBase}charges/location/list`,
);

export const CHARGEINVOICELIST = generateApiUrl(
  apiHost,
  `${billingBase}invoice/view`,
);
export const CREATEINVOICE = generateApiUrl(
  apiHost,
  `${billingBase}invoice/create`,
);

export const NEWCREATEINVOICE = generateApiUrl(
  apiHost,
  `${billingBase}invoice/createnew`,
);
export const INVOICETYPELIST = generateApiUrl(
  apiHost,
  `${billingBase}invoice/typelist`,
);
export const INVOICEPRINT = generateApiUrl(
  apiHost,
  `${billingBase}invoice/printdetails`,
);
export const REVENUESHARE = generateApiUrl(
  apiHost,
  `${billingBase}share/chargeswithuser`,
);
export const REFFRALSHARE = generateApiUrl(
  apiHost,
  `${billingBase}share/chargeswithreferral`,
);
export const SAVERECORDPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}payment/savedetailsforreport`,
);
export const REQUESTDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/request`,
);
export const DELETEAPPLIEDDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/deleteapplieddisount`,
);
export const DISCOUNTLIST = generateApiUrl(
  apiHost,
  `${billingBase}discount/dashboard`,
);
export const APPROVEDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/approve`,
);
export const APPROVEDALLISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/approveall`,
);
export const DISCOUNTDETAILS = generateApiUrl(
  apiHost,
  `${billingBase}discount/details/`,
);
export const APPLYDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/apply`,
);
export const DELETEDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/delete`,
);
export const UPDATEDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/update`,
);
export const DELETECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/deletebychargeinvoiceid`,
);
export const DELETESINGLECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/deletesinglecharge`,
);
export const CHARGEWISEREFRALSHARE = generateApiUrl(
  apiHost,
  `${billingBase}share/chargewiserefralcommision`,
);
export const CANCELINVOICE = generateApiUrl(
  apiHost,
  `${billingBase}invoice/cancel`,
);
export const CHECKNEWDISCOUNTREQ = generateApiUrl(
  apiHost,
  `${billingBase}refund/check-new-request`,
);
export const ADVREFTRANSCTIONSLIST = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/advance/refund/transactions/`,
);
export const GETPATIENTCREDITAMOUNT = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/advance/`,
);
export const ADVANCESAVE = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/advance/save`,
);
export const CREDITBILLPRINT = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/print`,
);
export const REFUNDDASHBOARD = generateApiUrl(
  apiHost,
  `${billingBase}refund/dashboard`,
);
export const NEWREFUNDDASHBOARD = generateApiUrl(
  apiHost,
  `${billingBase}refund/get-request-list`,
);
export const APPROVEREFUND = generateApiUrl(
  apiHost,
  `${billingBase}refund/approve`,
);
export const INVOICEPRACTITIONERID = generateApiUrl(
  apiHost,
  `${billingBase}invoice/fetch/practitonerid/`,
);
export const PAYREFUND = generateApiUrl(
  apiHost,
  `${billingBase}refund/pay/against/invoice`,
);
export const PAYREFUNDAGAINSTADV = generateApiUrl(
  apiHost,
  `${billingBase}refund/pay/against/advance`,
);
export const GETINVOICECHARGES = generateApiUrl(
  apiHost,
  `${billingBase}invoice/fetch/charges/`,
);
export const MODIFYINVOICE = generateApiUrl(
  apiHost,
  `${billingBase}invoice/modify`,
);
export const REQUESTREFUND = generateApiUrl(
  apiHost,
  `${billingBase}refund/request`,
);
export const CHECKEXISTINGREFUND = generateApiUrl(
  apiHost,
  `${billingBase}refund/checkincompleterequest/`,
);
export const CHECKINREFUNDBALANCE = generateApiUrl(
  apiHost,
  `${billingBase}refund/checkbalance`,
);
export const BILLSUMMARY = generateApiUrl(
  apiHost,
  `${billingBase}invoice/summary/`,
);
export const CHANGEINVOICEPAYMODE = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/update/paymentmode`,
);
export const PAYMENTTRANSACTIONS = generateApiUrl(
  apiHost,
  `${billingBase}payment/transactionlist/`,
);
export const UPDATEPAYMENTTRANSCTIONS = generateApiUrl(
  apiHost,
  `${billingBase}payment/mode/update`,
);
export const CHARGEDETAILS = generateApiUrl(
  apiHost,
  `${billingBase}statement/detailedstatement`,
);
export const UPDATECHARGEQTYANDUNITPRICE = generateApiUrl(
  apiHost,
  `${billingBase}charges/updateqtyandcharge`,
);
export const DISCOUNTSTATEMENT = generateApiUrl(
  apiHost,
  `${billingBase}charges/notinvoicedfordiscount/againstpatientid`,
);
export const REQUESTCHARGEDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/chargerequest`,
);
export const APPLYCHARGEWISEDISCOUNT = generateApiUrl(
  apiHost,
  `${billingBase}discount/applytocharge`,
);
export const CANCELREFUND = generateApiUrl(
  apiHost,
  `${billingBase}refund/request/cancle`,
);
export const CAMPVALIDATION = generateApiUrl(
  apiHost,
  `${billingBase}camp/iscampvalid/`,
);
export const CAMPDISCOUNTONCHARGE = generateApiUrl(
  apiHost,
  `${billingBase}camp/fetchcampdiscountoncharge`,
);
export const INVESTIGATIONADDCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/againstinvestigations`,
);
export const NEWCREATECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/createnew`,
);
export const CHARGETYPELIST = generateApiUrl(
  apiHost,
  `${billingBase}charges/chargetype/list`,
);
export const DETAILEDCHARGENAMELIST = generateApiUrl(
  apiHost,
  `${billingBase}charges/master-detail-list`,
);
export const PACKAGELIST = generateApiUrl(
  apiHost,
  `${billingBase}charges/package/list`,
);
export const PACKAGELISTIPD = generateApiUrl(
  apiHost,
  `${billingBase}packagemaster/parentlist/`,
);
export const FETCHPACKAGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/fetch/packages`,
);
export const PACKAGECHILDLIST = generateApiUrl(
  apiHost,
  `${billingBase}packagemaster/childlist/`,
);
export const APPLYPACKAGE = generateApiUrl(
  apiHost,
  `${billingBase}patientpackage/apply`,
);
export const PACKAGEEXIST = generateApiUrl(
  apiHost,
  `${billingBase}patientpackage/getPackageIfExists`,
);
export const CHECKIFCHARGETYPEIDEXIST = generateApiUrl(
  apiHost,
  `${billingBase}packagemaster/checkChargeTypeIdExistsOrNot`,
);
export const CHECKIDCHARGEIDEXIST = generateApiUrl(
  apiHost,
  `${billingBase}packagemaster/checkChargeidExistsOrNot`,
);
export const FINDCHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/findbyid/`,
);

export const OPDMODIFYCHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/modifyappointmentchargedetails`,
);
export const BOOKOPDAPPOINMENTWITHPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}payment/opdappointment`,
);
export const NEWBOOKOPDAPPOINMENTWITHPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}payment/againstopd`,
);
export const CHECKINVOICECREATED = generateApiUrl(
  apiHost,
  `${billingBase}invoice/checkbyidpid/`,
);
export const SELFTOTPVICEVERSA = generateApiUrl(
  apiHost,
  `${billingBase}charges/selftotpviceversa`,
);
export const IPDHISTORICDATA = generateApiUrl(
  apiHost,
  `${billingBase}statement/patientipdidwiseHistoricData/`,
);
export const PATIENTIPDDATA = generateApiUrl(
  apiHost,
  `${billingBase}statement/patientinfoandlastipddetails/`,
);

export const SAVEIPDPHARMACYCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/include/pharmacy/charges`,
);
export const LASTOPDDETAILS = generateApiUrl(
  apiHost,
  `${billingBase}statement/patientinfoandlastopddetails/`,
);
export const GENRATEINVVOICEPDF = generateApiUrl(
  apiHost,
  `${billingBase}pdfinvoice/emailinvoicepdf`,
);
export const INVOICELASTDATEIME = generateApiUrl(
  apiHost,
  `${billingBase}invoice/invoice/lastupdatedtime/`,
);
export const PATIENTDELETECHARGELOG = generateApiUrl(
  apiHost,
  `${billingBase}charges/deletedchargelog`,
);
export const LASTUPDATEDRECORDDATETIME = generateApiUrl(
  apiHost,
  `${billingBase}payment/getlastupdatedtime/`,
);
export const EXCLUDEPACKAGECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/excludePackageCharge`,
);
export const INCLUDEPACKAGECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/includePackageCharge`,
);
export const EXCLUDEMEDICINECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/MedicineCharge/update/`,
);
export const MULTIEXCLUDEMEDICINECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/medicineCharge/delete`,
);
export const INCLUDEMEDICINECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/MedicineCharge`,
);
export const PROCESSCHARGESLIST = generateApiUrl(
  apiHost,
  `${billingBase}charges/fetch/charges`,
);
export const FETCHCONVERTCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/fetch/updated/charges/List`,
);
export const CONVERTCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/update/charges`,
);
export const ADDNEWCONVERTCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/save/newcharges`,
);
export const DELETEPACKAGES = generateApiUrl(
  apiHost,
  `${billingBase}patientpackage/remove`,
);
export const PHARMCYACCOUNTCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}statement/pharmacyBillList`,
);
export const GATEPASSVALIDATION = generateApiUrl(
  apiHost,
  `${billingBase}invoice/getInvoice/`,
);
export const MULTICHARGEDELETE = generateApiUrl(
  apiHost,
  `${billingBase}charges/deleteMultiplecharge`,
);
export const CHARGESREPORT = generateApiUrl(
  apiHost,
  `${billingBase}ChargesReportDetailed/chargesreport`,
);
export const GETALLCHARGES = generateApiUrl(
  apiHost,
  `${billingBase}charges/getallcharges`,
);
export const REFUNDAPPROVEALL = generateApiUrl(
  apiHost,
  `${billingBase}refund/approveAll`,
);

//API's USED IN REVENUE
export const REVENUECHARGELIST = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/chargesList`,
);
export const REVENUEGROUPDATA = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/get/assign/charges/toGroup`,
);
export const ASSIGNGROUPTOCHARGE = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/assign/charges/toGroup`,
);
export const GETREVENUEGROUPLIST = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/get/group`,
);
export const CREATENEWGROUP = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/create/group`,
);
export const GETGRPLISTBYUSERID = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/get/assign/groupList`,
);
export const ASSIGNGRPTOUSER = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/assign/group/toUser`,
);
export const GETREVENUEDASHBOARD = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/dashboard`,
);
export const CALCULATEREVENUESHARE = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/calculate`,
);
export const REVENUESHAREPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/payment`,
);
export const UPDATECHARGEPAYEE = generateApiUrl(
  apiHost,
  `${billingBase}statement/updateChargePaidBy`,
);
export const GETCHARGELISTFORALREDYASSIGNGRP = generateApiUrl(
  apiHost,
  `${billingBase}revenueshare/master/assign/twoOrMoreGroup/validate`,
);
export const PATIENTINVOICERECORD = generateApiUrl(
  apiHost,
  `${billingBase}invoice/fetchinvoiceData`,
);
export const INVOICEEXELDATA = generateApiUrl(
  apiHost,
  `${billingBase}invoice/downLoad/invoiceExcel/`,
);
export const GETINVINVOICEDATA = generateApiUrl(
  apiHost,
  `${billingBase}statement/invoiceDetails/`,
);
export const EXCLUDEMEDICINEPACKAGECHARGE = generateApiUrl(
  apiHost,
  `${billingBase}charges/excludemedicineCharge/package`,
);
export const COLLECTIONSUMMARYREPORT = generateApiUrl(
  apiHost,
  `${billingBase}summaryreport/collectionreport`,
);
export const REVENUEREPORTSUMMARY = generateApiUrl(
  apiHost,
  `${billingBase}revenueReport/shareSummary`,
);
export const DATEWISESHARESUMMARY = generateApiUrl(
  apiHost,
  `${billingBase}revenueReport/dateWiseshareSummary`,
);
export const IPDSHAREREPORT = generateApiUrl(
  apiHost,
  `${billingBase}revenueReport/ipdShareReport`,
);
export const OPDSHAREREPORT = generateApiUrl(
  apiHost,
  `${billingBase}revenueReport/opdShareReport`,
);
export const REPORTDETAILS = generateApiUrl(
  apiHost,
  `${billingBase}report/chargedetails`,
);
export const INVOICEREPORT = generateApiUrl(
  apiHost,
  `${billingBase}report/invoice`,
);
export const USERWISECOLLECTION = generateApiUrl(
  apiHost,
  `${billingBase}report/userwisecollection`,
);
export const PAYMENTREPORTSUMMARY = generateApiUrl(
  apiHost,
  `${billingBase}report/paymentreport`,
);
export const SUMMARYREPORTDETAIL = generateApiUrl(
  apiHost,
  `${billingBase}summaryreport/details`,
);
export const PAYMENTRECIEPTREPORT = generateApiUrl(
  apiHost,
  `${billingBase}report/payment/receipt/report`,
);
export const CANCELREPORT = generateApiUrl(
  apiHost,
  `${billingBase}ChargesReportDetailed/cancelReport`,
);
export const FETCHTOTALADVANCEAMOUNT = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/advance/sum/`,
);

export const PUSHTRANSACTIONPAYMENT = generateApiUrl(
  apiHost,
  `${billingBase}payment/push/transaction`,
);

export const CHECKCALLBACKTRANSACTIONS = generateApiUrl(
  apiHost,
  `${billingBase}payment/check/callback/transactions`,
);

export const CHARGESMACHINELIST = generateApiUrl(
  apiHost,
  `${billingBase}charges/pos/machine/list`,
);

export const CHARGESINSERTDATA = generateApiUrl(
  apiHost,
  `${billingBase}charges/insert/data`,
);

export const CANCELADVANCEDATA = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/cancel/advance/`,
);

export const UPDATEADVANCEAMOUNT = generateApiUrl(
  apiHost,
  `${billingBase}creditaccount/update/advance/amount/`,
);

// API'S USED IN IPD
// SWAGGER LINK - http://localhost:8085/ipd/swagger-ui.html#!/
export const DECLARATIONFORM = generateApiUrl(
  accountingHost,
  `${ipdBase}common/declrationForm`,
);

export const SAVEDISCHARGEDATAFIELDMASTER = generateApiUrl(
  accountingHost,
  `${ipdBase}discharge/save/field/master`,
);

export const SUGGDISCHARGEDATAFIELDMASTER = generateApiUrl(
  accountingHost,
  `${ipdBase}discharge/fetch/field/master
`,
);

export const DISCHARGEFILDSAVEMASTER = generateApiUrl(
  accountingHost,
  `${ipdBase}discharge/field/master/save/type`,
);

export const DISCHARGEFILDFETCHMASTER = generateApiUrl(
  accountingHost,
  `${ipdBase}discharge/type/`,
);

export const DISCHARGEFORMSAVEREMARK = generateApiUrl(
  accountingHost,
  `${ipdBase}discharge/field/master/save/remark`,
);

export const DISCHARGEFORMFETCHEMARK = generateApiUrl(
  accountingHost,
  `${ipdBase}discharge/remarkagainstfield/`,
);

export const PHARMACYLOCATION = generateApiUrl(
  apiHost,
  `${ipdBase}prisc/location/get`,
);

export const FEEDBACKQUESTIONLIST = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/questionsList`,
);

export const SAVEFEEDBACKQUESTION = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/saveQuestions`,
);

export const DELETEFEEDBACKQUESTION = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/deleteQuestion/`,
);

export const FEEDBACKPATIENTLIST = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/patientListByType`,
);

export const SUBMITFEEDBACK = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/submitFeedback
`,
);
export const FEEDBACKSUMMARYREPORT = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/feedbackSummaryReport
`,
);
export const FEEDBACKRATINGREPORT = generateApiUrl(
  apiHost,
  `${ipdBase}feedback/feedbackRatingReport
`,
);

export const IPDWARDBED = generateApiUrl(apiHost, `${ipdBase}patient/all`);

export const SEARCHFINALDIAGNOSIS = generateApiUrl(
  apiHost,
  `${ipdBase}patient/diagonsis/find`,
);
export const SAVEDISCHARGEFORM = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/save`,
);
export const DISCHARGESTARTSTOP = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/startstop`,
);
export const MASTERDATA = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/masterdata`,
);

export const IPDPATIENTDATA = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/patientdata`,
);
export const DISCHARGETEMPLATE = generateApiUrl(
  apiHost,
  `${ipdBase}common/template/fetch/`,
);
export const SAVETEMPLATE = generateApiUrl(
  apiHost,
  `${ipdBase}common/template/save`,
);
export const GETVITALS = generateApiUrl(apiHost, `${ipdBase}common/get/vitals`);
export const GETINTAKE = generateApiUrl(
  apiHost,
  `${ipdBase}common/get/vitals/2`,
);

export const SAVEVITALS = generateApiUrl(
  apiHost,
  `${ipdBase}common/save/timewise/vitals`,
);
export const GETVITALSSTATICS = generateApiUrl(
  apiHost,
  `${ipdBase}common/get/vitals/statistics`,
);
export const INCLUDEINVESTIGATION = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/investigations/`,
);
export const IPDFORMACCESS = generateApiUrl(
  apiHost,
  `${ipdBase}common/fieldaccess/`,
);
export const IPDACCESSSETTING = generateApiUrl(
  apiHost,
  `${ipdBase}common/formfield/enabledisable`,
);
export const IPDFORMFIELDLIST = generateApiUrl(
  apiHost,
  `${ipdBase}common/ipdformFieldList`,
);
export const UPDATEIPDFORMFIELD = generateApiUrl(
  apiHost,
  `${ipdBase}common/updateipdformField`,
);
export const DISCHARGECARDPRINT = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/print/`,
);
export const UPDATECLINICALNOTESFIELDNAME = generateApiUrl(
  apiHost,
  `${ipdBase}common/updateclinicalNotesformField`,
);
export const CLINICALNOTESFIELDLIST = generateApiUrl(
  apiHost,
  `${ipdBase}common/clinicalNotesFieldList`,
);
export const SAVEDIAGNOSISICD = generateApiUrl(
  apiHost,
  `${ipdBase}common/diagnosis/save`,
);
export const SAVEADMISSIONFORM = generateApiUrl(
  apiHost,
  `${ipdBase}patient/admit`,
);
export const ADMITPATIENTTOIPD = generateApiUrl(
  apiHost,
  `${ipdBase}patient/admitToIpd`,
);
export const PROCEDURESLIST = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/procedures/`,
);
export const IPDPATIENTADMITCHECK = generateApiUrl(
  apiHost,
  `${ipdBase}patient/isallreadyadmited/`,
);
export const SHIFTIPDBED = generateApiUrl(apiHost, `${ipdBase}common/shiftbed`);
export const SHIFTIPDBEDCHARGES = generateApiUrl(
  apiHost,
  `${ipdBase}patient/addstdcharges`,
);
export const CANCELADDMISSION = generateApiUrl(
  apiHost,
  `${ipdBase}patient/cancleadmission`,
);
export const DISCHARGEPROCESSLIST = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/patientchecklist/`,
);
export const UPDATECHECKLIST = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/update/checklist`,
);
export const UPDATESTEPDISCHARGEPROCESS = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/update/step/process`,
);
export const DISCHARGEPATIENT = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/complete`,
);
export const ADMISSIONFORMUPDATE = generateApiUrl(
  apiHost,
  `${ipdBase}patient/updateAdmissionForm`,
);
export const DISCHARGEFORMTEMPLATE = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/previousDischargeData/`,
);

export const SAVEFINALDIAGNOSIS = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/save/diagnosis`,
);

export const NURSEDIAGNOSISLIST = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/diagnosislist`,
);
export const NURSEPLANNINGLIST = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/planlist/`,
);
export const NURSEINTERVATIONLIST = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/interventionlist/`,
);
export const SAVENURSEPLANDATA = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/save`,
);
export const FETCHNURSEDAYTODAYNOTES = generateApiUrl(
  apiHost,
  `${ipdBase}patient/daytodaynotes/fetch`,
);
export const SAVENURSEDAYTODAYNOTES = generateApiUrl(
  apiHost,
  `${ipdBase}patient/daytodaynotes/save`,
);
export const INHOUSEPATIENTLIST = generateApiUrl(
  apiHost,
  `${ipdBase}common/fetch/inhousepatient/list`,
);
export const RATEWARDLIST = generateApiUrl(
  apiHost,
  `${ipdBase}patient/update/ratecard/`,
);
export const AUTOCAREDIAGNOSISLIST = generateApiUrl(
  apiHost,
  `${ipdBase}autocare/diagnosisids/`,
);
export const DIAGNOSISPROBLEMLIST = generateApiUrl(
  apiHost,
  `${ipdBase}autocare/problemnamelist/bydiagnosisids/`,
);
export const PROBLEMDETAILS = generateApiUrl(
  apiHost,
  `${ipdBase}autocare/details/byproblemnameid/`,
);
export const AUTOCAREEMRINSERT = generateApiUrl(
  apiHost,
  `${ipdBase}autocare/details/save`,
);
export const NURSINGPLANCATEGOARY = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/categorylist`,
);
export const NURSINGPLANTASK = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/detailslist/`,
);
export const SAVENURSINGCAREPLAN = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/save/carerequest`,
);
export const FETCHNURSINGCARE = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/fetch/nursingrequest/bypatientid/`,
);
export const FETCHNURSINGCAREDATA = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/fetch/nursingrequest/childlist/`,
);
export const ACTIVEPATIENTLIST = generateApiUrl(
  apiHost,
  `${ipdBase}patient/currentipdpatientlist`,
);
export const VISITINGCONSULTANTDASHBOARDLIST = generateApiUrl(
  apiHost,
  `${ipdBase}visitingconsultant/fetchrequestedconsultantlist`,
);
export const REQUESTVISITINGCONSULTANT = generateApiUrl(
  apiHost,
  `${ipdBase}visitingconsultant/saverequest`,
);
export const UPDATECONSULTANTREQUEST = generateApiUrl(
  apiHost,
  `${ipdBase}visitingconsultant/update/status/visited/`,
);
export const UPDATECONSULTANTCANCELSTATUS = generateApiUrl(
  apiHost,
  `${ipdBase}visitingconsultant/cancle/`,
);
export const DISCHARGEDASHBOARD = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/dischargeDashboard`,
);
export const REFRESHAUTOCHARGE = generateApiUrl(
  apiHost,
  `${ipdBase}patient/save/standardcharges`,
);
export const DELETEDIAGNOSISDISCHARGEFORM = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/deletediagnosis`,
);
export const DELETEPROVISIONALDIAGNOSIS = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/deleteprovisionaldiagnosis`,
);
export const UPDATESTATUSDISCHARGEDASHBOARD = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/updateStatus`,
);
export const IPDREADDMISSION = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/readmit`,
);
export const DELETEMEDICINE = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/deletepriscFromDischarge`,
);
export const DELETEMULTIPLEPRESCFROMDIS = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/deleteMutliplepriscFromDischarge`,
);
export const INHOUSEREMARK = generateApiUrl(
  apiHost,
  `${ipdBase}common/inhousepatient/save/remark`,
);
export const IPDPHARMACYCHARGES = generateApiUrl(
  apiHost,
  `${ipdBase}patient/getAllIpdId/`,
);
export const GETIPDPATIENTNOTIFICATONDATA = generateApiUrl(
  apiHost,
  `${ipdBase}patient/getNotification/priscription/`,
);
export const UPDATEIPDPATIENTPRESCRIPTIONTIME = generateApiUrl(
  apiHost,
  `${ipdBase}patient/updateNotification/priscription`,
);
export const STOPPRESCRIPTION = generateApiUrl(
  apiHost,
  `${ipdBase}patient/stop/priscription`,
);
export const GETIPDPATIENTNURSINGDATA = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/getNotification/nursing/`,
);
export const UPDATEIPDPATIENTNURSINGFREQUENCYTIME = generateApiUrl(
  apiHost,
  `${ipdBase}nursingplan/updateNotification/nursing`,
);
export const GETIPDPATIENTINVESTIGATIONDATA = generateApiUrl(
  apiHost,
  `${ipdBase}patient/getNotification/investigation/`,
);
export const GETTREATMENTRECORD = generateApiUrl(
  apiHost,
  `${ipdBase}patient/get/treatmentGivenSheet`,
);
export const GETMRDLIST = generateApiUrl(apiHost, `${ipdBase}mrd/mrddashboard`);
export const CREATENEWMRD = generateApiUrl(apiHost, `${ipdBase}mrd/create`);
export const GETMRDDETAIL = generateApiUrl(apiHost, `${ipdBase}mrd/getdetails`);
export const GETMRDDETAILBYID = generateApiUrl(
  apiHost,
  `${ipdBase}mrd/getmrddetailsbyid/`,
);
export const UPDATEMRD = generateApiUrl(apiHost, `${ipdBase}mrd/update`);
export const DELETEMRD = generateApiUrl(apiHost, `${ipdBase}mrd/delete/`);
export const GETSHIFTMRDDATA = generateApiUrl(
  apiHost,
  `${ipdBase}mrd/getShiftedRecord/`,
);
export const SHIFTMRDRECORD = generateApiUrl(
  apiHost,
  `${ipdBase}mrd/saveShiftRecord`,
);
export const UNDERCLEANINGSTATUSUPDATE = generateApiUrl(
  apiHost,
  `${ipdBase}patient/updateBed/`,
);
export const RELEASEPATIENTIPD = generateApiUrl(
  apiHost,
  `${ipdBase}patient/release/daycare`,
);
export const RETURNMEDICINELIST = generateApiUrl(
  apiHost,
  `${ipdBase}common/returnmedicinelist/`,
);
export const RETURNMEDICINE = generateApiUrl(
  apiHost,
  `${ipdBase}common/returnmedicine`,
);
export const IPDASSESSMENTSLOG = generateApiUrl(
  apiHost,
  `${ipdBase}patient/treatmentlog`,
);

export const DISCHARGECOUNT = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/count`,
);

export const SAVEDISCHARGEFORMSEQ = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/save/dischare/form/sequence`,
);

export const FETCHDISCHARGESEQ = generateApiUrl(
  apiHost,
  `${ipdBase}discharge/fetch/discharge/sequence/`,
);

// API'S USED IN INVENTORY
// SWAGGER LINK - http://localhost:8083/inventory/swagger-ui.html#!/

export const MANAGEUSERGROUPASSIGNED = generateApiUrl(
  apiHost,
  `${inventoryBase}userAssigned/roleList/{clinicId}/{branchId}`,
);

export const MANAGEUSERSAVEGROUPACCESS = generateApiUrl(
  apiHost,
  `${inventoryBase}userAssigned/save`,
);

export const REMOVESASSIGNEDLOCATION = generateApiUrl(
  apiHost,
  `${inventoryBase}userAssigned/delete`,
);

export const SAVEHSNNOCATALOG = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/save/hsn/number
`,
);

export const GETHSNNOCATALOG = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/findall
`,
);

export const USERASSIGNED = generateApiUrl(
  apiHost,
  `${inventoryBase}userAssigned/create`,
);

export const DIRECTTRANSFER = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/direct/transfer`,
);

export const DELETETERMSANDCONDITIONS = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/delete/condidtion/`,
);

export const SAVEPERPRINTTERMSANDCONDITIONS = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/save/terms/condidtion`,
);

export const AUTOSAVEGRN = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/autosave`,
);

export const GETAUTOSAVEGRN = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/fetch/autosave/product`,
);

export const DELETEAUTOSAVEGRN = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/delete/autosave/`,
);

export const UPDATEAUTOSAVEGRN = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/update/autosave`,
);

export const DEPARTMENTTRANSFER = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/department/transfer`,
);

export const DEPARTMENTTRANSFERDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/department/transfer/dashboard`,
);

export const DELETEDEPARTMENTTRANSFER = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/delete/department/transfer/`,
);

export const UPDATEDEPARTMENTTRANSFERDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/update/department/transfer`,
);

export const CONSUMPTIONREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementreport/consumptionreport`,
);

export const DEPARTMENTTRANSFERREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/department/transfer/dashboard`,
);

export const ADJUSTMENTREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}adjustment/adjustmentReport`,
);

export const EDITPRODUCTMASTEPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/edit`,
);

export const ALLREADYUSERASSIGNED = generateApiUrl(
  apiHost,
  `${inventoryBase}userAssigned/getList/`,
);

export const UPLOADEXCELFILE = generateApiUrl(
  apiHost,
  `${inventoryBase}stockUpload/uploadStockExcel`,
);
export const DOWNLOADEXCELFILE = generateApiUrl(
  apiHost,
  `${inventoryBase}stockUpload/stockExcelDownload`,
);
export const UPLOADGRNEXCELFILE = generateApiUrl(
  apiHost,
  `${inventoryBase}stockUpload/upload/grn`,
);
export const DOWNLOADGRNEXCELFILE = generateApiUrl(
  apiHost,
  `${inventoryBase}stockUpload/download/grn/template`,
);
export const FETCHMINIMUMQTYLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/minimumqtylist`,
);
export const GENERATEBARCODE = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/generate/barcode`,
);
export const ADJUSTMENTEDITPRINT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/getprintDetails/`,
);
export const GETCATALOUGEDATA = generateApiUrl(
  apiHost,
  `${inventoryBase}grnwithoutpodashboard`,
);
export const SUBCATEGORYLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getSubcategoryList`,
);
export const SAVECATELOUGEPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}saveCatalogue`,
);
export const CATALOUGELIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getCatalogueList`,
);
export const ADDNEWPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}addNewProduct`,
);
export const PROCUREMENTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementList`,
);
export const SAVEGRNWITHOUTPO = generateApiUrl(
  apiHost,
  `${inventoryBase}saveGrnWithoutPo`,
);
export const INVENTORYLOCATION = generateApiUrl(
  apiHost,
  `${inventoryBase}locationList`,
);
export const SAVEWITHPODASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}grnwithpodashboard`,
);
export const WITHPODASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}addGrnWithPoProducts`,
);
export const INVENTORYCATALOUGELIST = generateApiUrl(
  apiHost,
  `${inventoryBase}listCatalogue`,
);
export const SAVECATALOUGEPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}saveCatalogueProducts`,
);
export const CATEGORYLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getCategoryList`,
);
export const MAINSUBCATEGORYLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getCatalogueSubcategoryList`,
);
export const SHELFLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getShelfList`,
);
export const MRPCRITERIALIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getmrpcriterialist`,
);
export const SAVESUPPLIER = generateApiUrl(
  apiHost,
  `${inventoryBase}supplier/save`,
);
export const FETCHSUPPLIERDATA = generateApiUrl(
  apiHost,
  `${inventoryBase}supplier/get/supplier/data/`,
);
export const SUPPLIERCITYSTATELIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getstateCitylist`,
);
export const SAVEGRNWITHPO = generateApiUrl(
  apiHost,
  `${inventoryBase}saveGrnRequest`,
);
export const CONFIRMPODETAILS = generateApiUrl(
  apiHost,
  `${inventoryBase}getPoDetailsTConfirm`,
);
export const WAREHOUSELIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getWarehouseList`,
);
export const GETPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getProductList`,
);
export const GETRETAILERPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/fetch/product`,
);

export const INVENTORYPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/fetch/product`,
);
export const CURRENTSTOCK = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/current/stock`,
);
export const PRODUCTINFOFORUPDATE = generateApiUrl(
  apiHost,
  `${inventoryBase}getproductinfoforupdate`,
);
export const UPDATECATELOUGE = generateApiUrl(
  apiHost,
  `${inventoryBase}updatecatalogue`,
);
export const MFGDETAILS = generateApiUrl(
  apiHost,
  `${inventoryBase}getmfgdetails`,
);
export const GENERICNAMEDETAILS = generateApiUrl(
  apiHost,
  `${inventoryBase}getgenericdetails`,
);
export const ADDMFG = generateApiUrl(apiHost, `${inventoryBase}savemfgdetails`);
export const ADDGENERICNAME = generateApiUrl(
  apiHost,
  `${inventoryBase}savegenericdetails`,
);
export const UPDATESTOCK = generateApiUrl(
  apiHost,
  `${inventoryBase}updatestockdetails`,
);
export const ADJUSTSTOCK = generateApiUrl(
  apiHost,
  `${inventoryBase}adjustproductstock`,
);
export const SAVEMRPCRITERIA = generateApiUrl(
  apiHost,
  `${inventoryBase}savemrpcriteria`,
);
export const EXPIRYPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getexpiredproductlist/`,
);
export const MINQTYPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getminimumproductqtylist/`,
);
export const CONFIRMGRNWITHPO = generateApiUrl(
  apiHost,
  `${inventoryBase}confirmGrnwithPo`,
);
export const CANCELPO = generateApiUrl(
  apiHost,
  `${inventoryBase}cancelGrnWithPo/`,
);
export const ADDTOPO = generateApiUrl(apiHost, `${inventoryBase}addtopo/`);
export const GRNPRINT = generateApiUrl(apiHost, `${inventoryBase}getgrnprint/`);
export const RETURNPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getproductreturnlog`,
);
export const RETURNPRODUCTDELETE = generateApiUrl(
  apiHost,
  `${inventoryBase}deletereturntosupplier`,
);

export const PROFITANDLOSSREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}profitlossreport/getReportDetails
`,
);
export const PRODUCTRETURNQUE = generateApiUrl(
  apiHost,
  `${inventoryBase}addToProductReturnQue`,
);
export const PRODUCTRETURNQUELIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productReturnList/`,
);
export const ADDPRODUCTTORETURNQUE = generateApiUrl(
  apiHost,
  `${inventoryBase}addtoProductReturnDashboard`,
);
export const RETURNREADYPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturndashboard/`,
);
export const SAVERETURNPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}saveproductreturn`,
);
export const SUPPLIERSACCOUNT = generateApiUrl(
  apiHost,
  `${inventoryBase}getSupplierAccountList/`,
);
export const SUPPLIERPAYMENTINFO = generateApiUrl(
  apiHost,
  `${inventoryBase}getpaymentinfo`,
);
export const SAVEPAYMENTINFO = generateApiUrl(
  apiHost,
  `${inventoryBase}savepaymentinfo`,
);
export const DELETMULTIPLEPRODUCTSPO = generateApiUrl(
  apiHost,
  `${inventoryBase}deletemultipleproducts`,
);
export const DELIVERMEMOLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}getdeliverymemolist`,
);
export const DELETEPRODUTCRETURNQUE = generateApiUrl(
  apiHost,
  `${inventoryBase}deleteproductreturnque/`,
);
export const POPRINT = generateApiUrl(apiHost, `${inventoryBase}getpoprint/`);
export const TRANSFERWITHOUTINDENT = generateApiUrl(
  apiHost,
  `${inventoryBase}transferwithoutindent`,
);
export const PAYRETURNEDAMOUNT = generateApiUrl(
  apiHost,
  `${inventoryBase}saveReturnamt`,
);
export const CREDITDEBITPRINT = generateApiUrl(
  apiHost,
  `${inventoryBase}printreturn/`,
);
export const PAYMENTRECIEPTRPRINT = generateApiUrl(
  apiHost,
  `${inventoryBase}paymentreciept/`,
);

export const CANCLEGRN = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/cancel/grn/`,
);

export const ADUSTEDITDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}adjustmentDashboard`,
);
export const ADJUSTMENTPRINT = generateApiUrl(
  apiHost,
  `${inventoryBase}adjustpaymentprint/`,
);
export const SAVECATALOUGE = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/save`,
);
export const FETCHCATALOUGE = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/getAll`,
);
export const PRODUCTALLREADYEXIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/checkIfNameExists`,
);
export const UPLOADPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}upload-download/upload/catalogue`,
);
export const DOWNLOADPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}upload-download/download/template`,
);
export const SUPPLIERLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}supplier/fetch`,
);
export const POQUELIST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/poquelist`,
);
export const POPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/getproductlist`,
);
export const PROCUREMENTREQUEST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/requestPo`,
);
export const INVENTORTDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/dashboard`,
);
export const MODIFYALL = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/modify/all`,
);

export const UPDATEGOODSRECIEPT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/updategrn`,
);

export const DMINVENTORYDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/dm/dashboard`,
);
export const PODATA = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/fetch`,
);
export const GRNDATA = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/grndetails`,
);
export const POSTATUS = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/modify`,
);
export const SAVEGOODSRECIEPT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/savegrn`,
);

export const INVOICEALLREADYEXIST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/invoice/exist`,
);

export const DMALLREADYEXIST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/dm/exist`,
);

export const CREATEGOODSDM = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/createdm`,
);
export const SAVEGOODSDM = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/savedm`,
);
export const STOCKSTATUSLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/stockdata`,
);
export const MULTIADJUSTMENTDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/adjusteditdashboard`,
);
export const MULTIADJUSTMENTREQUEST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/adjusteditrequest`,
);
export const APPROVEDMULTIADJUSTMENT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/adjusteditapprove`,
);
export const REQUESTPRODUCTS = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/manage`,
);
export const GRNPOPRINT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/fetch/`,
);
export const SAVEINVENTORYPHARMACYLOCATION = generateApiUrl(
  apiHost,
  `${inventoryBase}location/save`,
);
export const INVENTORYPHARMACYLOCATION = generateApiUrl(
  apiHost,
  `${inventoryBase}location/fetch`,
);
export const REQUESTPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/fetch/product`,
);
export const INDENTDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/fetch`,
);

export const INDENTDPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/product/list
`,
);

export const INDENTCHNAGERODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/product/change
`,
);

export const MODIFYINDENTREQUEST = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/modify`,
);
export const AVAILABLEPRODUCTSINDENT = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/available/product/list`,
);
export const AVAILABLEINDENTDELETE = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/delete/`,
);

export const ADDINDENTPRODUCTTOPOQUE = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/add/poque`,
);

export const DELIVERYPOPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/delivered`,
);
export const DELIVEREDPODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/fetch/delivered/`,
);
export const HANDOVERINDENT = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/handover`,
);
export const RECIEVEDINDENTPRODUCTS = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/recieved/`,
);
export const MULTIPLERECIVEDINDENTPODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/multiplerecieved`,
);

export const PHARMACYSALEPRODUCTS = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/fetch`,
);
export const OPENINGCLOSINGREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/transaction/report/openingclosing`,
);
export const ADJUCTMULTIEDIT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/adjustedit`,
);
export const PHARMACYINVENTORYLETTERHEAD = generateApiUrl(
  apiHost,
  `${inventoryBase}location/letterhead`,
);
export const BINCARDREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/transaction/report/bincard`,
);
export const FSNSTOCKREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/transaction/report/fsn`,
);
export const UPDATEPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/updateProduct`,
);

export const DELETESTOCKEDITADJST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/deleterequest/`,
);

export const GETSUPPLIERPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/getsupplierproductlist`,
);
export const GETRETURNPRODUCTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/getreturnproductlist`,
);
export const GETRETURNPRODUCT = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/returnproduct`,
);
export const PHARMACYADDTOCART = generateApiUrl(
  apiHost,
  `${inventoryBase}productcart/add`,
);
export const INVENTORYPODUCTRETURNDELETE = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/deletereturnrequest/`,
);

export const DELETEPRODUCTINCART = generateApiUrl(
  apiHost,
  `${inventoryBase}productcart/clear`,
);
export const CONSUMERPRODUCTINCART = generateApiUrl(
  apiHost,
  `${inventoryBase}productcart/getconsumercart`,
);

export const CONSUME = generateApiUrl(apiHost, `${inventoryBase}stock/consume`);

export const FETCHREPORTSTOCK = generateApiUrl(
  apiHost,
  `${inventoryBase}transaction/report/stock`,
);
export const GETPRODUTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productmaster/getproductlist`,
);
export const GETRETURNPRODUTLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/getreturnproductlist`,
);
export const APPROVEDPRODUCTRETURN = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/approvereturnproducts`,
);
export const PROCUREMENTGRNHISTORY = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/grnhistory`,
);
export const CHECKEDIT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/check/edit`,
);
export const FETCHACCOUNTDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}supplier/account/dashboard`,
);
export const EDITSUPPLIER = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/changesupplier`,
);
export const SUPPLIERACCOUNT = generateApiUrl(
  apiHost,
  `${inventoryBase}supplier/fetch/supplieraccount`,
);
export const RECORDPAYMENT = generateApiUrl(
  apiHost,
  `${inventoryBase}supplier/record/payment`,
);
export const STOCKREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/transaction/report/stock`,
);
export const PROCUREMENTGRN = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementreport/grn`,
);
export const ITEMWISEREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementreport/itemWise/purchase`,
);
export const CHECKBARCODEEXIST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/checkbarcodeexist`,
);
export const SUPPLIERRETURNPRINT = generateApiUrl(
  apiHost,
  `${inventoryBase}productreturn/getreturnprint`,
);
export const STOCKUPLOAD = generateApiUrl(
  apiHost,
  `${inventoryBase}stockUpload/uploadStockExcel`,
);
export const SENDEMAIL = generateApiUrl(
  apiHost,
  `${inventoryBase}purchaseorderpdf/popdf`,
);
export const USERWISELOCATION = generateApiUrl(
  apiHost,
  `${inventoryBase}location/userWise`,
);
export const POEMAILLOG = generateApiUrl(
  apiHost,
  `${inventoryBase}purchaseorderpdf/poemail/log`,
);
export const ADDTOPOQUEUE = generateApiUrl(
  apiHost,
  `${inventoryBase}indent/add/poque`,
);
export const DELETEPOQUEUE = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/deletepoque`,
);
export const DOWNLOADSTOCKDATA = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/downloadStockdata/Excel`,
);
export const PROCUREMENTGRNGST = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementreport/grnGst`,
);
export const EXPIRYPRODUCTREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/transaction/report/expiry`,
);
export const POREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementreport/poreport`,
);
export const INDENTREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurementreport/indentreport`,
);
export const DETAILGRNREPORT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/detailsGrnReport`,
);
export const PRODUTEXPIRYLIST = generateApiUrl(
  apiHost,
  `${inventoryBase}stock/expirylist`,
);
export const POCOUNT = generateApiUrl(
  apiHost,
  `${inventoryBase}procurement/fetch/po/count`,
);
export const DOWNLOADPRODUCTMASTER = generateApiUrl(
  apiHost,
  `${inventoryBase}upload-download/download/productmaster`,
);
export const ADDTORETURNCARTSAVE = generateApiUrl(
  apiHost,
  `${inventoryBase}return/request/cart/save`,
);
export const FETCHRETURNPRODUCTCART = generateApiUrl(
  apiHost,
  `${inventoryBase}return/request/cart/fetch/`,
);
export const DELETERETURNPRODUCTCART = generateApiUrl(
  apiHost,
  `${inventoryBase}return/request/cart/delete/`,
);
export const RETURNTOSTORESAVE = generateApiUrl(
  apiHost,
  `${inventoryBase}return/to/store/save`,
);
export const ASSETREGISTERDASHBOARD = generateApiUrl(
  apiHost,
  `${inventoryBase}asset/register/dashboard`,
);
export const ASSETREGISTERSAVE = generateApiUrl(
  apiHost,
  `${inventoryBase}asset/register/save`,
);
export const TRANSACTIONPRODUCTDETAILS = generateApiUrl(
  apiHost,
  `${inventoryBase}asset/regiseter/transaction/get/product/details/`,
);
export const REGISTERTRANSACTIONSAVE = generateApiUrl(
  apiHost,
  `${inventoryBase}asset/regiseter/transaction/save`,
);
export const VIEWTRANSACTIONFILE = generateApiUrl(
  apiHost,
  `${inventoryBase}asset/regiseter/transaction/viewFile/`,
);

// API'S USED IN PHARMACY   http://192.168.0.112:8083/inventory/
// SWAGGER LINK - http://localhost:8082/pharmacy/swagger-ui.html#!/

export const PHARMACYCOLLECTION = generateApiUrl(
  apiHost,
  `${pharmacyBase}consumer/pharmacy/collection`,
);

export const PRODUCTWISERETUENREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/returnReport`,
);

export const SALEREQUESTREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/saleReqReport`,
);

export const GETCURRENTMARGIN = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/getmarginalPercentage/`,
);

export const HSNWISEGETREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/hsWiseGst`,
);

export const PATIENTMEDICINEHISTORY = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/patient/medicine/history/`,
);

export const UPDATEPAYMENT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/paymentchange`,
);

export const CONSUMERLEDGER = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/consumerledger`,
);
export const PAYMENTCHANGELIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/paymentchangelist`,
);
export const ADDMARGINE = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/addmargin`,
);
export const SAVEBILL = generateApiUrl(apiHost, `${pharmacyBase}saveBill`);
export const SALEDASHBOARD = generateApiUrl(
  apiHost,
  `${pharmacyBase}saledashboard`,
);
export const CATELOUGELIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}getCatalogueList`,
);
export const SAVECLIENT = generateApiUrl(apiHost, `${pharmacyBase}saveClient`);
export const PATIENTLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}consumer/list`,
);
export const BATCHWISEPRODUCT = generateApiUrl(
  apiHost,
  `${pharmacyBase}getBatchwiseProduct`,
);
export const PATIENTDETAILS = generateApiUrl(
  apiHost,
  `${pharmacyBase}consumer/patientDetails`,
);
export const UPDATEREFRENCE = generateApiUrl(
  apiHost,
  `${pharmacyBase}saveReference`,
);
export const ADDPRODUCT = generateApiUrl(apiHost, `${pharmacyBase}addProducts`);
export const PHARMACYNOTIFICATION = generateApiUrl(
  apiHost,
  `${pharmacyBase}getonlinerequest`,
);
export const DELETETEMPPRODUCT = generateApiUrl(
  apiHost,
  `${pharmacyBase}deleteTemp`,
);
export const GSTBIFURCATION = generateApiUrl(
  apiHost,
  `${pharmacyBase}gstbifurcation/billno/`,
);
export const PHARMACYBARCODE = generateApiUrl(
  apiHost,
  `${pharmacyBase}getProductOfBarcode`,
);
export const ONLINEPRICS = generateApiUrl(
  apiHost,
  `${pharmacyBase}requestmedicines`,
);
export const CANCELBILL = generateApiUrl(
  apiHost,
  `${pharmacyBase}cancelPharmacyBill`,
);
export const PHARMACYREQUESTDISCOUNT = generateApiUrl(
  apiHost,
  `${pharmacyBase}requestDiscount`,
);
export const DELETEPENDINGSALECART = generateApiUrl(
  apiHost,
  `${pharmacyBase}deletePendingSaleCart`,
);
export const GETBILLS = generateApiUrl(apiHost, `${pharmacyBase}salehistory`);
export const RETURNDASHBOARD = generateApiUrl(
  apiHost,
  `${pharmacyBase}returndashboard`,
);
export const CLIENTBILLS = generateApiUrl(
  apiHost,
  `${pharmacyBase}clientaccount`,
);
export const PRINTINVOICE = generateApiUrl(
  apiHost,
  `${pharmacyBase}getBillPrint`,
);
export const CLEARBILL = generateApiUrl(apiHost, `${pharmacyBase}clearbalance`);
export const GETPATIENTLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}getPatientList`,
);
export const SAVEADVANCE = generateApiUrl(
  apiHost,
  `${pharmacyBase}saveAdvance`,
);
export const ADVANCELIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}getAdvanceList`,
);
export const ADVREFPRINT = generateApiUrl(
  apiHost,
  `${pharmacyBase}getBillPrintInfo`,
);
export const PAYPHARMACYREFUND = generateApiUrl(
  apiHost,
  `${pharmacyBase}payRefund`,
);
export const PARTTIMEPAYMENTRECIEPT = generateApiUrl(
  apiHost,
  `${pharmacyBase}getClearBillReceipt`,
);
export const CLEARBILLPRINT = generateApiUrl(
  apiHost,
  `${pharmacyBase}getClearBillPrint`,
);
export const DISCOUNTREQUESTCHECK = generateApiUrl(
  apiHost,
  `${pharmacyBase}getPharmacyDiscountData`,
);
export const PRODUCTEXPIRYLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}getExpiredProduct`,
);
export const CLIENTBILLSRECORD = generateApiUrl(
  apiHost,
  `${pharmacyBase}clientaccounthistory`,
);
export const PHARMACYSETTINGS = generateApiUrl(
  apiHost,
  `${pharmacyBase}getPharmacySettings`,
);
export const UPDATESETTINGPHARMACY = generateApiUrl(
  apiHost,
  `${pharmacyBase}updatePharmacySettings`,
);
export const RETURNPRODUCT = generateApiUrl(
  apiHost,
  `${pharmacyBase}returnProduct`,
);
export const SALERETURN = generateApiUrl(apiHost, `${pharmacyBase}salereturn`);
export const NURSERETURN = generateApiUrl(
  apiHost,
  `${pharmacyBase}nursereturnhistory`,
);
export const NURSERETURNDASH = generateApiUrl(
  apiHost,
  `${pharmacyBase}getNurseReturnDashboard`,
);
export const NURSERETURNPRINT = generateApiUrl(
  apiHost,
  `${pharmacyBase}nursereturnprint`,
);
export const PRISCRIPTIONPRINT = generateApiUrl(
  apiHost,
  `${pharmacyBase}getOnlinePriscPrint`,
);
export const PHARMACYREVENUEREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}getOpdRevenueReportData/`,
);
export const SAVEPHARMACY = generateApiUrl(apiHost, `${pharmacyBase}sale/save`);
export const UPDATESALEPHARMACY = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/update`,
);
export const SALEHISTORYDASHBOARD = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/fetch`,
);
export const CURRENTADVANCE = generateApiUrl(
  apiHost,
  `${pharmacyBase}credit/fetch/advance`,
);
export const PHARMACYRECIEPT = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/print/`,
);
export const PATIENTPHARMACYHISTORY = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/patienthistory`,
);
export const PHARMACYPATIENTADVANCE = generateApiUrl(
  apiHost,
  `${pharmacyBase}credit/advance`,
);

export const PHARMACYPATIENTREFUND = generateApiUrl(
  apiHost,
  `${pharmacyBase}credit/refund`,
);
export const PHARMACYPATIENTADVREFLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}credit/fetch/`,
);
export const PHARMACYADVANCERECIEPT = generateApiUrl(
  apiHost,
  `${pharmacyBase}credit/print/`,
);
export const PHARMACYSALEINVOICECANCEL = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/cancel`,
);
export const PHARMACYRECIEPTDATAFORRETURN = generateApiUrl(
  apiHost,
  `${pharmacyBase}return/fetch/`,
);
export const RETURNPHARMACYPRODUCT = generateApiUrl(
  apiHost,
  `${pharmacyBase}return/returnagainst`,
);
export const RETURNWITHOUTSALE = generateApiUrl(
  apiHost,
  `${pharmacyBase}return/returnwithoutsale`,
);
export const SALERETURNPRODUCT = generateApiUrl(
  apiHost,
  `${pharmacyBase}return/salereturn`,
);
export const CLEARPHARMACYBALANCE = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/clearbalance`,
);
export const CLEARPHARMACYBALANCEONCE = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/multiple/clear/pharmacy`,
);
export const CLEARBALANCEPRINT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/receipt/print/`,
);
export const CLEARBALANCERECIPT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/clear/balance/receipt`,
);
export const NEWCLIENTBILLSRECORD = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/printall`,
);
export const RETURNREQUESTLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}productreturnrequest/returnRequestList`,
);
export const NEWRETURNMEDICINELIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}productreturnrequest/getreturnproductlist`,
);
export const NEWRETURNMEDICINE = generateApiUrl(
  apiHost,
  `${pharmacyBase}productreturnrequest/save`,
);
export const DELETENURSERETURN = generateApiUrl(
  apiHost,
  `${pharmacyBase}productreturnrequest/modify`,
);
export const PHARMACYSALEREQUESTDISCOUNT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/requestdiscount`,
);
export const PHARMACYSALEDIRECTDISCOUNT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/directdiscount`,
);
export const PHARMACYDISCOUNTDASHBOARD = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/requestdiscountdasboard`,
);
export const PHARMACYOUTSTANDINGDASHBOARD = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/outstanding/details`,
);
export const PHARMACYADVANCEDASHBOARD = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/advance/report`,
);
export const MODIFYDISCOUNT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/modifydiscount`,
);
export const RETURNFETCHPRODUCTS = generateApiUrl(
  apiHost,
  `${pharmacyBase}return/fetchproducts`,
);
export const REQUESTLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/getList`,
);
export const PRODUCTSALE = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/getProductTosale/`,
);
export const PHARMACYDAILYSALEREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/dailysale`,
);
export const INHOUSECONSUMERLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}consumer/inhouseconsumerlist`,
);
export const SALEREPORTLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/salelist`,
);
export const PHARMACYGSTREPORTDATA = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/gst`,
);
export const UPDATEWALKINGCLIENT = generateApiUrl(
  apiHost,
  `${pharmacyBase}consumer/update/walkin`,
);
export const PAYMENTREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}payment/report/`,
);
export const REQUESTMODIFY = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/modify`,
);

export const UPDATESTATUSDELIVER = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/update/delevery
`,
);

export const SENDOTPNURSERETURN = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/send/otp
`,
);

export const VERIFYOTPNURSERETURN = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/verify/otp
`,
);

export const DELIVERYBOYMASTER = generateApiUrl(
  apiHost,
  `${pharmacyBase}request/deliveryboy/master
`,
);

export const USERWISEREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}payment/report/userWise`,
);
export const PHARMACYUSERLIST = generateApiUrl(
  apiHost,
  `${pharmacyBase}consumer/saleUser/`,
);
export const GETCREDITREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/getCreditReport`,
);
export const PAYMENTRECEIPTPRINT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/payment/print/`,
);
export const PRODUCTWISESALEREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/productwisesale`,
);
export const PAYMENTRECIEPT = generateApiUrl(
  apiHost,
  `${pharmacyBase}dashboard/payment/receipt/`,
);

export const PHARMACYVIEWCHECKBOX = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/modify`,
);

export const PHARMACYSAPC = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/update/sale/purchase/cost`,
);
export const PHARMACYSASC = generateApiUrl(
  apiHost,
  `${pharmacyBase}sale/update/sale/at/sale/price`,
);
export const PHARMACYADVANCEREPORT = generateApiUrl(
  apiHost,
  `${pharmacyBase}pharmacy/sale/pharmacy/advance/report`,
);
// API'S USED IN MASTER
// SWAGGER LINK - http://localhost:8089/master/swagger-ui.html#!/
// export const PATHLABPRATITIONERLIST = generateApiUrl(
//   apiHost,
//   `${masterBase}diagnosis/pathlabpractitionerList`,
// );
export const GETPRINTCUSTOMIZATION = generateApiUrl(
  apiHost,
  `${masterBase}clinical/notes/print/customization/get/all`,
);
export const SAVEPRINTCUSTOMIZATION = generateApiUrl(
  apiHost,
  `${masterBase}clinical/notes/print/customization/save`,
);
export const UPDATETPDETAILS = generateApiUrl(
  apiHost,
  `${masterBase}patientrelation/update/tp/details`,
);
export const GETIPDOPDDETAILS = generateApiUrl(
  apiHost,
  `${masterBase}patientrelation/get/ipd/opd/details/`,
);
export const UPDATEGLOBALACCESS = generateApiUrl(
  apiHost,
  `${masterBase}ipd/notes/update/globalaccess/`,
);
export const UPDATEACTIVESTATUS = generateApiUrl(
  apiHost,
  `${masterBase}ipd/notes/update/activestatus/`,
);
export const OTROOMLIST = generateApiUrl(apiHost, `${masterBase}otroom/list`);
export const OTROOMMASTERLIST = generateApiUrl(
  apiHost,
  `${masterBase}otroom/otroommasterlist`,
);

export const FETCHSHELF = generateApiUrl(apiHost, `${masterBase}shelf/fetch`);
export const SAVESHELF = generateApiUrl(apiHost, `${masterBase}shelf/save`);
export const UPDATESHELF = generateApiUrl(apiHost, `${masterBase}shelf/update`);
export const USERSENDMOBILEOTP = generateApiUrl(apiHost, `${masterBase}ipd/notes/sendMobOTP`);
export const USERVERIFYMOBOTP = generateApiUrl(apiHost, `${masterBase}ipd/notes/verifyMobOTP`);

export const USERSENDEMAILOTP = generateApiUrl(apiHost, `${masterBase}ipd/notes/sendEmailOTP`);
export const USERVERIFYEMAILOTP = generateApiUrl(apiHost, `${masterBase}ipd/notes/verifyEmailOTP`);

export const MAINTPATHIRTPARTYLIST = generateApiUrl(
  apiHost,
  `${masterBase}thirdparty/tp/follower/list`,
);

export const TPATHIRTPARTYLIST = generateApiUrl(
  apiHost,
  `${masterBase}thirdparty/mainThirdPartyList`,
);
export const SAVETERMSANDCONDITIONS = generateApiUrl(
  apiHost,
  `${masterBase}terms/save`,
);
export const GETTERMSANDCONDITIONS = generateApiUrl(
  apiHost,
  `${masterBase}terms/fetch`,
);

export const SAVEOTROOMMASRTER = generateApiUrl(
  apiHost,
  `${masterBase}otroom/save`,
);
export const EDITOTROOMMASTER = generateApiUrl(
  apiHost,
  `${masterBase}otroom/editotroommaster/`,
);
export const MASTERCPACKAGECATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}package/category/get`,
);
export const CREATEMASTERCPACKAGECATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}package/category/save`,
);
export const UPDATEPACKAGESTATUS = generateApiUrl(
  apiHost,
  `${masterBase}package/update/status`,
);
export const SAVEPACKAGE = generateApiUrl(apiHost, `${masterBase}package/save`);
export const GETPACKAGE = generateApiUrl(apiHost, `${masterBase}package/get`);
export const EDITPACKAGE = generateApiUrl(
  apiHost,
  `${masterBase}package/edit/`,
);
export const DELETEPACKAGECHARGE = generateApiUrl(
  apiHost,
  `${masterBase}package/delete/chargePackage/`,
);
export const GETINVESTIGATIONID = generateApiUrl(
  apiHost,
  `${masterBase}package/investigation/testId/`,
);
export const GETINVESTIGATIONIDNEW = generateApiUrl(
  apiHost,
  `${masterBase}charge/investigation/testId/`,
);
export const OTPLAN = generateApiUrl(apiHost, `${masterBase}otplan/get`);
export const CREATEOTPLAN = generateApiUrl(apiHost, `${masterBase}otplan/save`);
export const CREATECHARGETYPE = generateApiUrl(
  apiHost,
  `${masterBase}chargetype/create`,
);
export const SEARCHCHARGETYPELIST = generateApiUrl(
  apiHost,
  `${masterBase}chargetype/search`,
);
export const UPDATECHARGEDETAILS = generateApiUrl(
  apiHost,
  `${masterBase}charge/update`,
);
export const CREATECHAREMASTER = generateApiUrl(
  apiHost,
  `${masterBase}charge/create`,
);
export const CREATEPROCEDURECHARGE = generateApiUrl(
  apiHost,
  `${masterBase}procedure/requests`,
);
export const APROVEPROCEDURECHARGE = generateApiUrl(
  apiHost,
  `${masterBase}procedure/approve`,
);
export const GETMASTERNAMELIST = generateApiUrl(
  apiHost,
  `${masterBase}charge/list`,
);
export const GETSTATESLIST = generateApiUrl(apiHost, `${masterBase}state/get`);
export const GETCITYLIST = generateApiUrl(apiHost, `${masterBase}city/get/`);
export const CREATESTATE = generateApiUrl(apiHost, `${masterBase}state/create`);
export const GETSTATEDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}state/getAll`,
);
export const CREATECITY = generateApiUrl(apiHost, `${masterBase}city/create`);
export const DELETECITY = generateApiUrl(apiHost, `${masterBase}city/delete/`);
export const GETCOUNTRY = generateApiUrl(apiHost, `${masterBase}country/get`);
export const GETTHIRDPARTY = generateApiUrl(
  apiHost,
  `${masterBase}thirdpartytype/get`,
);
export const SAVETHIRDPARTY = generateApiUrl(
  apiHost,
  `${masterBase}thirdpartytype/save`,
);
export const DELETETHIRDPARTY = generateApiUrl(
  apiHost,
  `${masterBase}thirdpartytype/delete/`,
);
export const EDITTHIRDPARTY = generateApiUrl(
  apiHost,
  `${masterBase}thirdpartytype/edit/`,
);
export const NEWTHIRDPARTYSAVE = generateApiUrl(
  apiHost,
  `${masterBase}thirdparty/save`,
);
export const EDITTHIRDPARTYSAVE = generateApiUrl(
  apiHost,
  `${masterBase}thirdparty/edit/`,
);
export const GETDISCOUNTTEAM = generateApiUrl(
  apiHost,
  `${masterBase}discountteams/get`,
);
export const CREATEDISCOUNTTEAM = generateApiUrl(
  apiHost,
  `${masterBase}discountteams/create`,
);
export const DELETEDISCOUNTTEAM = generateApiUrl(
  apiHost,
  `${masterBase}discountteams/delete/`,
);
export const EDITDISCOUNTTEAM = generateApiUrl(
  apiHost,
  `${masterBase}discountteams/get/`,
);
export const UPDATEDISCOUNTTEAM = generateApiUrl(
  apiHost,
  `${masterBase}discountteams/update`,
);
export const ANESTHISIATYPELIST = generateApiUrl(
  apiHost,
  `${masterBase}otanesthesiatype/list`,
);
export const ANESTHISIATYPESAVE = generateApiUrl(
  apiHost,
  `${masterBase}otanesthesiatype/save`,
);
export const CREATEJOBTITLE = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/create`,
);
export const DELETEJOBTITLE = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/delete/`,
);
export const UPDATEJOBTITLE = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/update`,
);
export const GETGROUPJOBTITLE = generateApiUrl(
  apiHost,
  `${masterBase}jobtitlegroup/get`,
);
export const GETJOBTITLEBYID = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/getjobtitle/`,
);
export const GETJOBTITLELIMIT = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/getall/`,
);
export const GETINVENTORYLIST = generateApiUrl(
  apiHost,
  `${masterBase}inventorycategory/get/`,
);
export const CREATEINVENTORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorycategory/create`,
);
export const DELETEINVENTORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorycategory/delete/`,
);
export const GETBYIDINVENTORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorycategory/getinventory/`,
);
export const EDITINVENTORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorycategory/update`,
);
export const GETINVENTORYWAREHOUSE = generateApiUrl(
  apiHost,
  `${masterBase}inventorywarehouse/get`,
);
export const GETINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorysubcategory/getall/`,
);
export const GETINVENTORYSUBCATEGORYLIST = generateApiUrl(
  apiHost,
  `${masterBase}inventorycategory/get`,
);
export const GETINVENTORYSUBCATEGORYBYID = generateApiUrl(
  apiHost,
  `${masterBase}inventorysubcategory/getinventory/`,
);
export const CREATEINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorysubcategory/create`,
);
export const DELETEINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorysubcategory/delete/`,
);
export const EDITINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorysubcategory/update`,
);
export const GETBYIDINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventorysubcategory/getinventory/`,
);
export const GETMEDICINEDOSE = generateApiUrl(
  apiHost,
  `${masterBase}medicinedosage/get`,
);
export const GETBYIDMEDICINEDOSE = generateApiUrl(
  apiHost,
  `${masterBase}medicinedosage/get/`,
);
export const CREATEMEDICINEDOSE = generateApiUrl(
  apiHost,
  `${masterBase}medicinedosage/create`,
);
export const DELETEMEDICINEDOSE = generateApiUrl(
  apiHost,
  `${masterBase}medicinedosage/delete/`,
);
export const UPDATEMEDICINEDOSE = generateApiUrl(
  apiHost,
  `${masterBase}medicinedosage/update`,
);
export const GETPRETIME = generateApiUrl(
  apiHost,
  `${masterBase}priscriptiontime/get`,
);
export const UPDATEPRETIME = generateApiUrl(
  apiHost,
  `${masterBase}priscriptiontime/update`,
);
export const GETBYIDPRETIME = generateApiUrl(
  apiHost,
  `${masterBase}priscriptiontime/get/`,
);
export const CREATEPRETIME = generateApiUrl(
  apiHost,
  `${masterBase}priscriptiontime/create`,
);
export const DELETEPRETIME = generateApiUrl(
  apiHost,
  `${masterBase}priscriptiontime/delete/`,
);
export const GETPREUNIT = generateApiUrl(
  apiHost,
  `${masterBase}prescriptionunit/get`,
);
export const UPDATEPREUNIT = generateApiUrl(
  apiHost,
  `${masterBase}prescriptionunit/update`,
);
export const GETBYIDPREUNIT = generateApiUrl(
  apiHost,
  `${masterBase}prescriptionunit/get/`,
);
export const CREATEPREUNIT = generateApiUrl(
  apiHost,
  `${masterBase}prescriptionunit/create`,
);
export const DELETEPREUNIT = generateApiUrl(
  apiHost,
  `${masterBase}prescriptionunit/delete/`,
);
export const GETDOSAGENOTES = generateApiUrl(
  apiHost,
  `${masterBase}dosagenote/get`,
);
export const CREATEDOSAGENOTES = generateApiUrl(
  apiHost,
  `${masterBase}dosagenote/create`,
);
export const UPDATEDOSAGENOTES = generateApiUrl(
  apiHost,
  `${masterBase}dosagenote/update`,
);
export const GETBYIDDOSAGENOTES = generateApiUrl(
  apiHost,
  `${masterBase}dosagenote/get/`,
);
export const DELETEDOSAGENOTES = generateApiUrl(
  apiHost,
  `${masterBase}dosagenote/delete/`,
);
export const GETBANKNAME = generateApiUrl(apiHost, `${masterBase}bankName/get`);
export const DEPARTMENTSHELFLIST = generateApiUrl(
  apiHost,
  `${masterBase}inventoryshelf/getShelList/`,
);
export const ADDNEWSHELF = generateApiUrl(
  apiHost,
  `${masterBase}inventoryshelf/save`,
);
export const GETALLBEDLIST = generateApiUrl(
  apiHost,
  `${masterBase}bed/getAll/`,
);
export const CHARGEMASTERDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}charge/dashboard`,
);
export const CHARGEMASTERCHARGES = generateApiUrl(
  apiHost,
  `${masterBase}charge/search`,
);
export const GETCHARGEMASTERDETAIL = generateApiUrl(
  apiHost,
  `${masterBase}charge/get/`,
);
export const CREATECHARGEMASTER = generateApiUrl(
  apiHost,
  `${masterBase}charge/create`,
);
export const CREATEALLCHARGEMASTER = generateApiUrl(
  apiHost,
  `${masterBase}charge/create/all`,
);
export const UPDATECHARGEMASTER = generateApiUrl(
  apiHost,
  `${masterBase}charge/update`,
);
export const REQUESTCHARGEMASTER = generateApiUrl(
  apiHost,
  `${masterBase}newcharge/request`,
);
export const DOWNLOADCHARGESTEMPLATE = generateApiUrl(
  apiHost,
  `${masterBase}charge/template/download`,
);
export const DOWNLOADCHARGESMASTER = generateApiUrl(
  apiHost,
  `${masterBase}charge/download`,
);
export const UPLOADCHARGES = generateApiUrl(
  apiHost,
  `${masterBase}charge/template/upload`,
);
export const APPROVECHARGES = generateApiUrl(
  apiHost,
  `${masterBase}newcharge/approve`,
);
export const REJECTCHARGES = generateApiUrl(
  apiHost,
  `${masterBase}newcharge/reject`,
);
export const SEARCHREQUESTCHARGES = generateApiUrl(
  apiHost,
  `${masterBase}newcharge/request/search`,
);
export const SEARCHCHARGENAMEBYINV = generateApiUrl(
  apiHost,
  `${masterBase}newcharge/get/investigationId/`,
);
export const GETPREVIOUSCHARGEAMOUNT = generateApiUrl(
  apiHost,
  `${masterBase}newcharge/get/previousChargeAmount`,
);
export const CREATESTDCHARGE = generateApiUrl(
  apiHost,
  `${masterBase}charge/to-standard`,
);
export const MASTERTHIRDPARTYLIST = generateApiUrl(
  apiHost,
  `${masterBase}thirdparty/mainThirdPartyList`,
);
export const INVESTIGATIONPACKAGELIST = generateApiUrl(
  apiHost,
  `${masterBase}package/packagelist`,
);
export const GETPATIENTRELATIONS = generateApiUrl(
  apiHost,
  `${masterBase}patientrelation/getAll`,
);
export const GETALLDIAGNOSIS = generateApiUrl(
  apiHost,
  `${masterBase}diagnosis/getAll`,
);
export const DELETEDIAGNOSIS = generateApiUrl(
  apiHost,
  `${masterBase}diagnosis/delete/`,
);
export const CREATEUPDATEDIAGNOSIS = generateApiUrl(
  apiHost,
  `${masterBase}diagnosis/saveUpdate`,
);
export const BEDDASHBOARDLIST = generateApiUrl(
  apiHost,
  `${masterBase}bed/dashboardList`,
);
export const CREATEBED = generateApiUrl(apiHost, `${masterBase}bed/createBed`);
export const CREATEWARD = generateApiUrl(
  apiHost,
  `${masterBase}ward/createWard`,
);
export const CREATESECTION = generateApiUrl(
  apiHost,
  `${masterBase}section/createSection`,
);
export const BEDSECTIONLIST = generateApiUrl(
  apiHost,
  `${masterBase}section/getAll/`,
);
export const WARDWISEBEDLISTALL = generateApiUrl(
  apiHost,
  `${masterBase}bed/getAll/`,
);
export const CREATEEQUIPMENT = generateApiUrl(
  apiHost,
  `${masterBase}equipment/createEquipment`,
);
export const DELETEBED = generateApiUrl(apiHost, `${masterBase}bed/deleteBed/`);
export const CREATENEWREFERANCE = generateApiUrl(
  apiHost,
  `${masterBase}reference/save`,
);
export const GETALLREFERANCE = generateApiUrl(
  apiHost,
  `${masterBase}reference/getAll`,
);
export const SAVERETAILER = generateApiUrl(
  apiHost,
  `${masterBase}retailer/save`,
);
export const FETCHRETAILER = generateApiUrl(
  apiHost,
  `${masterBase}retailer/fetch`,
);

export const SAVESUPPLIERTYPE = generateApiUrl(
  apiHost,
  `${masterBase}suppliertype/save`,
);
export const FETCHSUPPLIERTTYPEDETAILS = generateApiUrl(
  apiHost,
  `${masterBase}suppliertype/fetch/`,
);
export const EDITSUPPLIERTTYPE = generateApiUrl(
  apiHost,
  `${masterBase}suppliertype/list`,
);
export const EDITPRODUCTTYPE = generateApiUrl(
  apiHost,
  `${masterBase}product/type/fetch`,
);
export const SAVEPRODUCTTYPE = generateApiUrl(
  apiHost,
  `${masterBase}product/type/save`,
);
export const SAVEINVENTORYCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventory/category/create`,
);
export const SAVEINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventory/subcategory/create`,
);
export const FETCHINVENTORYCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventory/category/get`,
);
export const FETCHINVENTORYSUBCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}inventory/subcategory/get`,
);
export const FETCHINVENTORYSUBCATEGORYLIST = generateApiUrl(
  apiHost,
  `${masterBase}inventory/subcategory/getsubcategoryList/`,
);
export const BRANDNAMELIST = generateApiUrl(
  apiHost,
  `${masterBase}inventory/brandmaster/getAll`,
);
export const SAVEBRANDNAME = generateApiUrl(
  apiHost,
  `${masterBase}inventory/brandmaster/createorupdate`,
);
export const SAVEGENERICNAME = generateApiUrl(
  apiHost,
  `${masterBase}inventory/genericname/saveOrUpdate`,
);
export const GENERICNAMELIST = generateApiUrl(
  apiHost,
  `${masterBase}inventory/genericname/getAll`,
);
export const SAVEWAREHOUSE = generateApiUrl(
  apiHost,
  `${masterBase}inventory/warehouse/create`,
);
export const WAREHOUSELISTDATA = generateApiUrl(
  apiHost,
  `${masterBase}inventory/warehouse/get`,
);
export const SAVEMFGNAME = generateApiUrl(
  apiHost,
  `${masterBase}inventory/manufacturer/saveOrUpdateMfg`,
);
export const MFGLISTDATA = generateApiUrl(
  apiHost,
  `${masterBase}inventory/manufacturer/getAll`,
);
export const CREATECOUNTRY = generateApiUrl(
  apiHost,
  `${masterBase}country/create`,
);
export const DELETECOUNTRY = generateApiUrl(
  apiHost,
  `${masterBase}country/delete`,
);
export const DELETESTATE = generateApiUrl(apiHost, `${masterBase}state/delete`);
export const NEWCHARGETYPELIST = generateApiUrl(
  apiHost,
  `${masterBase}chargetype/search`,
);
export const NEWCHARGELIST = generateApiUrl(
  apiHost,
  `${masterBase}charge/search`,
);
export const DOWNLOADUSERTEMPLATE = generateApiUrl(
  apiHost,
  `${masterBase}upload/user/userUploadTemplate`,
);
export const UPLOADUSERS = generateApiUrl(
  apiHost,
  `${masterBase}upload/user/uploadUser`,
);
export const GETDEPARTMENTLIST = generateApiUrl(
  apiHost,
  `${masterBase}usermanagement/getdepartmentlist`,
);
export const GETGROUPTOTITLELIST = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/getjobtitlebygroupid/`,
);
export const GETRESPONSIBLEDRLIST = generateApiUrl(
  apiHost,
  `${masterBase}usermanagement/getdoctorlist`,
);
export const GETROLEGROUPLIST = generateApiUrl(
  apiHost,
  `${masterBase}jobtitlegroup/get`,
);
export const GETSPECIALIZATIONLIST = generateApiUrl(
  apiHost,
  `${masterBase}usermanagement/getdisciplinelist`,
);
export const OUTSOURCEDELETE = generateApiUrl(
  apiHost,
  `${masterBase}outsource/delete`,
);
export const OUTSOURCEINVESIGATION = generateApiUrl(
  apiHost,
  `${masterBase}outsource/get`,
);
export const OUTSOURCESAVE = generateApiUrl(
  apiHost,
  `${masterBase}outsource/save`,
);
export const GETJOBTITLE = generateApiUrl(
  apiHost,
  `${masterBase}jobtitle/getjobtitles/`,
);
export const GETSPECIALIZATION = generateApiUrl(
  apiHost,
  `${masterBase}department/getdisciplineList`,
);
export const GETDEPARTMENT = generateApiUrl(
  apiHost,
  `${masterBase}department/getdepartmentList`,
);
export const GETSUBDEPARTMENTLIST = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/subdepartmentList`,
);
export const ASSIGNUSERSUBDEPARTMENT = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/assignUserSubdept`,
);
export const DELETESUBDEPARTMENT = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/deleteSubdept`,
);
export const DISCHARGEMASTERSTATUS = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/status`,
);
export const DISCHARGEMASTEROUTCOME = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/outcome`,
);
export const UPDATECHARGESTATUS = generateApiUrl(
  apiHost,
  `${masterBase}charge/update/status`,
);
export const GETOPDCHARGES = generateApiUrl(
  apiHost,
  `${masterBase}charge/getOpdCharges`,
);

export const GETINVESTIGATIONCHARGE = generateApiUrl(
  apiHost,
  `${masterBase}charge/investigationcharge`,
);

export const UPDATETERMSANDCONDITIONS = generateApiUrl(
  apiHost,
  `${masterBase}terms/update`,
);

export const DELETERMSANDCONDITIONS = generateApiUrl(
  apiHost,
  `${masterBase}terms/delete/`,
);
export const UPDATEPRODUCTTYPE = generateApiUrl(
  apiHost,
  `${masterBase}product/type/update`,
);

export const IPDTEMPLATEGETALL = generateApiUrl(
  apiHost,
  `${masterBase}ipd/template/getAll`,
);

export const IPDTEMPLATECREATE = generateApiUrl(
  apiHost,
  `${masterBase}ipd/template/create`,
);

export const IPDTEMPLATEGETBYID = generateApiUrl(
  apiHost,
  `${masterBase}ipd/template/get/`,
);

export const IPDTEMPLATEDELETE = generateApiUrl(
  apiHost,
  `${masterBase}ipd/template/delete/`,
);

export const IPDTEMPLATEUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}ipd/template/create`,
);

export const CAMPMASTERGETALL = generateApiUrl(
  apiHost,
  `${masterBase}camp/getAll`,
);

export const CAMPMASTERGETBYID = generateApiUrl(
  apiHost,
  `${masterBase}camp/get/`,
);

export const CAMPMASTERCREATE = generateApiUrl(
  apiHost,
  `${masterBase}camp/create`,
);

export const CAMPMASTERDELETE = generateApiUrl(
  apiHost,
  `${masterBase}camp/delete/`,
);

export const DISCHARGEOUTCOMEMASTERADD = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/add/outcome`,
);

export const DISCHARGEOUTCOMEMASTEREDIT = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/edit/outcome`,
);

export const DISCHARGEOUTCOMEMASTERDELETE = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/delete/outcome/`,
);

export const DISCHARGEOUTCOMEMASTERGETALL = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/outcome`,
);

export const DISCHARGESTATUSMASTERADD = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/add/status`,
);

export const DISCHARGESTATUSMASTEREDIT = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/edit/status`,
);

export const DISCHARGESTATUSMASTERDELETE = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/delete/status/`,
);

export const DISCHARGESTATUSMASTERGETALL = generateApiUrl(
  apiHost,
  `${masterBase}dischargemaster/status`,
);

export const DISCIPLINEGETALL = generateApiUrl(
  apiHost,
  `${masterBase}discipline/list`,
);

export const DISCIPLINEADD = generateApiUrl(
  apiHost,
  `${masterBase}discipline/add`,
);

export const DISCIPLINEEDIT = generateApiUrl(
  apiHost,
  `${masterBase}discipline/edit`,
);

export const DISCIPLINEDELETE = generateApiUrl(
  apiHost,
  `${masterBase}discipline/delete/`,
);

export const SPECALIZATIONEGETALL = generateApiUrl(
  apiHost,
  `${masterBase}specialization/list`,
);

export const SPECALIZATIONADD = generateApiUrl(
  apiHost,
  `${masterBase}specialization/add`,
);

export const SPECALIZATIONEDIT = generateApiUrl(
  apiHost,
  `${masterBase}specialization/edit`,
);

export const SPECALIZATIONDELETE = generateApiUrl(
  apiHost,
  `${masterBase}specialization/delete/`,
);

export const REFERECEMASTERSGETALL = generateApiUrl(
  apiHost,
  `${masterBase}reference/list`,
);

export const REFERECEMASTERSSAVE = generateApiUrl(
  apiHost,
  `${masterBase}reference/save`,
);

export const REFERECEMASTERUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}reference/update`,
);

export const REFERECEMASTESDELETE = generateApiUrl(
  apiHost,
  `${masterBase}reference/delete/1616`,
);

export const STATEMASTERSGETALL = generateApiUrl(
  apiHost,
  `${masterBase}state/list`,
);

export const STATEMASTERSCREATE = generateApiUrl(
  apiHost,
  `${masterBase}state/create`,
);

export const STATEMASTERSUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}state/create`,
);

export const STATEMASTERSDELETE = generateApiUrl(
  apiHost,
  `${masterBase}state/delete/`,
);

export const CITYMASTERGETALL = generateApiUrl(
  apiHost,
  `${masterBase}city/get`,
);

export const CITYMASTERCREATE = generateApiUrl(
  apiHost,
  `${masterBase}city/create`,
);

export const CITYMASTERUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}city/create`,
);

export const CITYMASTERDELETE = generateApiUrl(
  apiHost,
  `${masterBase}city/delete/`,
);

export const SUBDEPARTMENTMASTERGETALL = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/subdepartmentList`,
);

export const SUBDEPARTMENTMASTERCREATE = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/create`,
);

export const SUBDEPARTMENTMASTERUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/create`,
);

export const SUBDEPARTMENTMASTERDELETE = generateApiUrl(
  apiHost,
  `${masterBase}subdepartment/delete/`,
);

export const SIGNATUREUSERLIST = generateApiUrl(
  apiHost,
  `${masterBase}signature/list`,
);

export const SIGNATURESAVE = generateApiUrl(
  apiHost,
  `${masterBase}signature/save`,
);

export const SIGNATUREVIEW = generateApiUrl(
  apiHost,
  `${masterBase}signature/view/base64`,
);

export const OUTSOURCEDATADOWNLOADTEMP = generateApiUrl(
  apiHost,
  `${masterBase}outsource/data/download/template`,
);

export const OUTSOURCEDATAUPLOADTEMP = generateApiUrl(
  apiHost,
  `${masterBase}outsource/data/upload/excel`,
);

export const OUTSOURCEDATASAVE = generateApiUrl(
  apiHost,
  `${masterBase}outsource/data/save`,
);

export const GETALLOUTSOURCEDATA = generateApiUrl(
  apiHost,
  `${masterBase}outsource/data/get/all`,
);
export const UPDATEOUTSOURCEDATA = generateApiUrl(
  apiHost,
  `${masterBase}outsource/data/update`,
);
export const INVUPLOADPATIENTDOCUMENT = generateApiUrl(
  apiHost,
  `${masterBase}patient/form/investigation/uploadDocument/`,
);

export const IPDNOTESSAVE = generateApiUrl(
  apiHost,
  `${masterBase}ipd/notes/save`,
);

export const GETBYIPDNOTES = generateApiUrl(
  apiHost,
  `${masterBase}ipd/notes/get/by/`,
);

export const IPDNOTESGATEPASS = generateApiUrl(
  apiHost,
  `${masterBase}ipd/notes/gate/pass/`,
);

export const DISCIPLINEUPLOADLOGO = generateApiUrl(
  apiHost,
  `${masterBase}discipline/upload/logo`,
);

// API' uSED FOR NEW BILLING
export const NEWCREATECHAREAPI = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/create`,
);
export const NEWVIEWACCOUNTAPI = generateApiUrl(
  accountingHost,
  `${apiBase}view/patient/account/`,
);
export const NEWCREATEINVOICEAPI = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/create`,
);
export const ACCONTINGPATIENTCONFIG = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/config/get`,
);
export const NEWPAYMENTRECORD = generateApiUrl(
  accountingHost,
  `${apiBase}payment/create`,
);
export const ACCOUNTMODIFYINVOICE = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/modify`,
);
export const CREATEDISCOUNT = generateApiUrl(
  accountingHost,
  `${apiBase}discount/create`,
);
export const PATIENTCHARGECANCEL = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/cancel`,
);
export const DISCOUNTSEARCH = generateApiUrl(
  accountingHost,
  `${apiBase}discount/search`,
);
export const DISCOUNTMODIFY = generateApiUrl(
  accountingHost,
  `${apiBase}discount/modify`,
);
export const REFUNDDASHBOARDNEW = generateApiUrl(
  accountingHost,
  `${apiBase}refund/dashboard`,
);
export const NEWREFUNDREQUEST = generateApiUrl(
  accountingHost,
  `${apiBase}refund/request`,
);
export const REFUNDMODIFY = generateApiUrl(
  accountingHost,
  `${apiBase}refund/modify`,
);
export const PATIENTPACKAGEAPPLY = generateApiUrl(
  accountingHost,
  `${apiBase}patient/package/apply`,
);
export const NEWCANCELINVOICE = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/cancel`,
);
export const GETPATIENTPACKAGE = generateApiUrl(
  accountingHost,
  `${apiBase}patient/package/getPackage`,
);
export const MODIFYCHARGE = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/modify`,
);
export const GETPAYMENTPRINT = generateApiUrl(
  accountingHost,
  `${apiBase}payment/getPrint/`,
);
export const MODIFYPACKAGE = generateApiUrl(
  accountingHost,
  `${apiBase}patient/package/modify`,
);
export const GETPACKAGELIST = generateApiUrl(
  accountingHost,
  `${apiBase}patient/package/getPackageList`,
);
export const GETINVOICEDETAILS = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/getInvoiceDetails`,
);
export const PHARMACYCHARGEINCLUDE = generateApiUrl(
  accountingHost,
  `${apiBase}pharmacy/charge/include`,
);
export const PHARMACYCHARGEMODIFY = generateApiUrl(
  accountingHost,
  `${apiBase}pharmacy/charge/modify`,
);
export const GETPATIENTDETAILS = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/config/getPatientDetails`,
);
export const NEWINVOICEPRINT = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/print`,
);
export const NEWINVOICEPRINTSUMMARY = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/summary`,
);
export const PAYMENTCREDITHISTORY = generateApiUrl(
  accountingHost,
  `${apiBase}payment/creditHistory`,
);
export const CREATECHARGEINVOICEPAYMENT = generateApiUrl(
  accountingHost,
  `${apiBase}invoice/createChargeInvoicePayment`,
);
export const GETCREDITBALANCE = generateApiUrl(
  accountingHost,
  `${apiBase}payment/getCreditBalance/`,
);
export const NEWCANCELINVESTIGATION = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/cancelInvestigation`,
);
export const PATIENTCHARGECREATE = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/config/create`,
);
export const REMOVEPACKAGE = generateApiUrl(
  accountingHost,
  `${apiBase}patient/package/remove`,
);
export const GETLASTUPDATEDATETIME = generateApiUrl(
  accountingHost,
  `${apiBase}payment/getLastUpdatedDateTime/`,
);
export const PAYMENTMODEMODIFY = generateApiUrl(
  accountingHost,
  `${apiBase}payment/modify`,
);
export const GETPATIENTCHARGES = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/getCharges`,
);
export const GETCONVERTEDCHARGES = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/getConvertedCharges`,
);
export const GETUPDATECONVERTEDCHARGE = generateApiUrl(
  accountingHost,
  `${apiBase}patient/charge/updateConvertedCharges`,
);
export const RONEGSTREPORT = generateApiUrl(
  apiHost,
  `${misBase}ronegst/report/gstr1/excel`,
);

// API's used for MIS reports
// export const PHARMACYDAILYSALEREPORT = generateApiUrl(apiHost, `${misBase}pharmacy/sale/dailysale`);

export const PATIENTAUDITREPORT = generateApiUrl(
  apiHost,
  `${misBase}audit/patient/report`,
);

export const INVOICEAUDITREPORT = generateApiUrl(
  apiHost,
  `${misBase}audit/invoice/report`,
);

export const PRODUCTAUDITREPORT = generateApiUrl(
  apiHost,
  `${misBase}audit/product/report`,
);

export const AUDITSTOCKREPORT = generateApiUrl(
  apiHost,
  `${misBase}audit/stock/report`,
);

export const CHARGEMASTERAUDITREPORT = generateApiUrl(
  apiHost,
  `${misBase}audit/charge/master/report`,
);

export const MISDASHBOARD = generateApiUrl(
  MISREPORTOST,
  `${misBase}misdashboard/revenuecount`,
);
export const MISREVENUEREPORT = generateApiUrl(
  MISREPORTOST,
  `${misBase}misdashboard/revenue/report`,
);
export const MISSUMMARYREPORT = generateApiUrl(
  MISREPORTOST,
  `${misBase}misdashboard/daily/report`,
);

export const MISDEPARTMENTWISECOUNT = generateApiUrl(
  MISREPORTOST,
  `${misBase}misdashboard/deptWiseCount`,
);

export const IPDWARDWISEIPCENSUSREPORT = generateApiUrl(
  apiHost,
  `${misBase}ipdreport/wardwise/ipcensus/report
`,
);

export const MISPATHOLOGYCOUNT = generateApiUrl(
  apiHost,
  `${misBase}misdashboard/sectionWiseInvestigationCount`,
);

export const SURGERYCOUNT = generateApiUrl(
  apiHost,
  `${misBase}misdashboard/surgeryCount`,
);

export const GETPATIENTRECORD = generateApiUrl(
  apiHost,
  `${misBase}opd/tatreport/getPatientDashboard`,
);

export const IPDDAILYACCOUNTREPORT = generateApiUrl(
  MISREPORTOST,
  `${misBase}ipdreport/dailyaccount`,
);
export const DISCHARGEREPORT = generateApiUrl(
  MISREPORTOST,
  `${misBase}ipdreport/dischargereport`,
);

export const OUTSOURCEREPORT = generateApiUrl(
  apiHost,
  `${misBase}investigation/report/outsourcereport`,
);

export const INVESTIGATIONTATREPORT = generateApiUrl(
  apiHost,
  `${misBase}investigation/report/tatreport`,
);

export const INVESTIGATIONWISECOUNTREPORT = generateApiUrl(
  apiHost,
  `${misBase}investigation/report/countreport`,
);

export const INVESTOPDIPDREPORT = generateApiUrl(
  apiHost,
  `${misBase}investigation/report/ipd/opd`,
);
export const OPDTATREPORT = generateApiUrl(
  apiHost,
  `${misBase}opd/tatreport/getAll`,
);
export const OPDPATIENTLIST = generateApiUrl(
  apiHost,
  `${misBase}opd/tatreport/patientList`,
);
export const GETTPAREPORT = generateApiUrl(
  apiHost,
  `${misBase}opd/tatreport/getTpaReport`,
);
export const TPAREPORTLIST = generateApiUrl(
  apiHost,
  `${misBase}opd/tatreport/getThirdPartyList`,
);
export const GETDEPARETMENTWISECOUNTREPORT = generateApiUrl(
  apiHost,
  `${misBase}opd/tatreport/getDepartmentWiseReport`,
);
export const IPDMLCREPORT = generateApiUrl(
  apiHost,
  `${misBase}ipdreport/mlcReport`,
);

export const ANESTHESIAREPORT = generateApiUrl(
  apiHost,
  `${misBase}ipdreport/anesthesia/report`,
);
export const CRITICALVALUEREPORT = generateApiUrl(
  apiHost,
  `${misBase}investigation/report/crtical/value/report
`,
);
export const GETAGINGREPORT = generateApiUrl(
  apiHost,
  `${misBase}procurementreport/get/aging/report
`,
);
export const IPDPACKAGEREPORT = generateApiUrl(
  apiHost,
  `${misBase}ipdreport/package/report
`,
);
export const WARDOCCUPANCYREPORT = generateApiUrl(
  MISREPORTOST,
  `${misBase}ipdreport/ward/occupancy/report`,
);
export const TALLYPATIENTDATALIST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/patientList`,
);
export const SAVETALLY = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/save`,
);
export const TALLYIPDINVOICES = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/invoices`,
);
export const IPDINVOICEPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/invoices/post`,
);
export const TALLYIPDPAYMENTS = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/payments`,
);
export const PAYMENTPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/payments/post`,
);
export const TALLYIPDADVANCES = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/advances`,
);
export const ADVANCEPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/advances/post`,
);
export const TALLYIPDREFUNDS = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/refunds`,
);
export const REFUNDSPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/refunds/post`,
);
export const TALLYSETTINGS = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/save/tally/setting`,
);

export const GETTALLYSETTINGSLIST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/settinglist`,
);

export const GETTALLYDISCOUNTLIST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/discounts`,
);

export const GETTPHARMACYADVANCELIST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/pharmacy/advance/list`,
);

export const GETTPHARMACYRETURNLIST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/pharmacyreturn/list`,
);

export const POSTTPHARMACYADVANCE = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/post/pharmacy/advace`,
);

export const TALLYPHARMACYSALE = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/pharmacy`,
);

export const TALLYPHARMACYSALEPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/pharmacy/post`,
);

export const TALLYPHARMACYRETURNPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/post/pharmacy/return`,
);

export const TALLYDISCOUNTPOST = generateApiUrl(
  tallyHost,
  `${tallyBase}tally-api/discount/post`,
);

// API'S USED IN FEEDBACK USING HISAPI
export const FEEDBACKQUESTIONS = generateApiUrl(
  apiHost,
  "8080/hisapi/feedback/list?UHID=",
);

//ACCESS MANAGEMENT
export const ACCESSUSERROLEGROUP = generateApiUrl(
  apiHost,
  `${settingBase}groups/roles/`,
);

export const ACCESSUSERLIST = generateApiUrl(
  apiHost,
  `${settingBase}clinic/user/branch/`,
);

export const ACCESSCLINICLOCATION = generateApiUrl(
  apiHost,
  `${settingBase}clinic/location`,
);

export const ACCESSALLMODULES = generateApiUrl(
  apiHost,
  `${settingBase}subscribed/modules/`,
);

export const ACCESSSUBSCRIBEDMODULE = generateApiUrl(
  apiHost,
  `${settingBase}clinic/subscribed/select`,
);

export const SERVICEDESCRIPTION = generateApiUrl(
  apiHost,
  `${settingBase}subscribe/services/`,
);

export const ACCESSDROPDOWN = generateApiUrl(
  apiHost,
  `${settingBase}subscribed/aureu`,
);

export const ROLEGROUPMODULE = generateApiUrl(
  apiHost,
  `${settingBase}groups/roles/select`,
);

export const ROLEGROUPIDSELECT = generateApiUrl(
  apiHost,
  `${settingBase}groups/roles/group/`,
);
export const UPDATEGROUPACCESS = generateApiUrl(
  apiHost,
  `${settingBase}groups/update/group/access`,
);
export const USERSMODULE = generateApiUrl(
  apiHost,
  `${settingBase}clinic/user/select`,
);

export const SELECTUSER = generateApiUrl(
  apiHost,
  `${settingBase}clinic/user/get/role/list`,
);

export const UPDATEUSERROLE = generateApiUrl(
  apiHost,
  `${settingBase}clinic/user/update/user/role`,
);

export const TOGGLESERVICEMODULE = generateApiUrl(
  apiHost,
  `${settingBase}subscribe/services/select`,
);

export const MASTERMODULEDROPDOWN = generateApiUrl(
  apiHost,
  `${settingBase}modules/view/modules/list`,
);

export const MASTERTABLEDATA = generateApiUrl(
  apiHost,
  `${settingBase}modules/view/master/`,
);

export const MASTERPAGINATION = generateApiUrl(
  apiHost,
  `${settingBase}modules/view/get`,
);

export const MASTERSEARCHBYKEY = generateApiUrl(
  apiHost,
  `${settingBase}modules/view/services/search`,
);

export const MASTERSAVE = generateApiUrl(
  apiHost,
  `${settingBase}access/master/save`,
);

export const ROLEGROUPSEARCH = generateApiUrl(
  apiHost,
  `${settingBase}groups/role/groups/search`,
);

export const CREATEROLEGROUP = generateApiUrl(
  apiHost,
  `${settingBase}groups/role/create`,
);

export const EDITVIEWMASTER = generateApiUrl(
  apiHost,
  `${settingBase}access/edit`,
);

export const SAVEFORMDATA = generateApiUrl(
  apiHost,
  `${masterBase}organization/form/save`,
);

export const FETCHFORMDATA = generateApiUrl(
  apiHost,
  `${masterBase}organization/form/fetch`,
);

export const UPDATEFORMDATA = generateApiUrl(
  apiHost,
  `${masterBase}organization/form/update`,
);

export const CREATESUPPORTTICKET = generateApiUrl(
  apiHost,
  `${supportBase}ticket/create`,
);

export const GETTICKETLIST = generateApiUrl(
  apiHost,
  `${supportBase}ticket/get/list`,
);
export const VIEWTICKETDETAILS = generateApiUrl(
  apiHost,
  `${supportBase}ticket/view/base64`,
);
export const UPDATETICKET = generateApiUrl(
  apiHost,
  `${supportBase}ticket/update`,
);
export const SUPPORT_MODULE_LIST = generateApiUrl(
  apiHost,
  `${supportBase}modules/list`,
);
export const OPDCRMDASHBOARD = generateApiUrl(
  apiHost,
  `${crmBase}opd/dashboard`,
);
export const OPDCRMFOLLOWUP = generateApiUrl(apiHost, `${crmBase}opd/followup`);

export const OPDCRMPATIENTTYPE = generateApiUrl(
  apiHost,
  `${crmBase}opd/patient/type`,
);
export const IPDCRMADMISSION = generateApiUrl(
  apiHost,
  `${crmBase}ipd/admission`,
);

export const IPDCRMPATIENTTYPE = generateApiUrl(
  apiHost,
  `${crmBase}ipd/patient/type`,
);
export const IPDCRMFOLLOWUP = generateApiUrl(apiHost, `${crmBase}ipd/followup`);

export const CRMPATIENTBIRTHDAY = generateApiUrl(
  apiHost,
  `${crmBase}birthday/patient/dob`,
);
export const CRMSTAFFBIRTHDAY = generateApiUrl(
  apiHost,
  `${crmBase}birthday/staff/dob`,
);
export const CRMCRITICALVALUE = generateApiUrl(
  apiHost,
  `${crmBase}investigation/critical/value`,
);
export const CRMTESTOUTSOURCE = generateApiUrl(
  apiHost,
  `${crmBase}investigation/test`,
);
export const CRMMEDREORDER = generateApiUrl(
  apiHost,
  `${crmBase}prescription/medicine`,
);

export const SAVECRMSTAFFASSIGNMENT = generateApiUrl(
  apiHost,
  `${crmBase}staff/create`,
);
export const CRMTASKMANAGER = generateApiUrl(apiHost, `${crmBase}staff/task`);
export const UPDATECRMSTATUS = generateApiUrl(
  apiHost,
  `${crmBase}staff/update`,
);
export const IPDCRMDISCHARGE = generateApiUrl(
  apiHost,
  `${crmBase}ipd/discharge`,
);

export const GETALLCATEGORYMASTER = generateApiUrl(
  apiHost,
  `${masterBase}category/master/getAll`,
);

export const GETALLSUBCATEGORYMASTER = generateApiUrl(
  apiHost,
  `${masterBase}subcategory/master/getAll`,
);

export const SAVETASKMASTER = generateApiUrl(
  apiHost,
  `${masterBase}task/master/save`,
);

export const UPDATETASKMASTER = generateApiUrl(
  apiHost,
  `${masterBase}task/master/update`,
);

export const FETCH_TASKS_BY_STATUS = generateApiUrl(
  apiHost,
  `${masterBase}task/master/fetch/`,
);

export const SAVECATEGORYMASTER_NEW = generateApiUrl(
  apiHost,
  `${masterBase}category/master/save`,
);

export const SAVESUBCATEGORYMASTER = generateApiUrl(
  apiHost,
  `${masterBase}subcategory/master/save`,
);

export const FETCH_TASK_HISTORY = generateApiUrl(
  apiHost,
  `${masterBase}task/master/history`,
);

export const FETCH_MY_TASKS = generateApiUrl(
  apiHost,
  `${masterBase}task/master/myTasks`,
);

export const IVFDONORLIST = generateApiUrl(apiHost, `${masterBase}ivf/donors`);
export const SAVEIVFDONOR = generateApiUrl(apiHost, `${masterBase}ivf/save`);

export const SEARCH_IVF_MOBILE = generateApiUrl(
  apiHost,
  `${masterBase}ivf/mobile/`,
);

export const IVFDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}ivf/dashboard`,
);

export const DECLATATIONGETALL = generateApiUrl(
  apiHost,
  `${masterBase}declaration/get/all`,
);

export const DECLARATIONUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}declaration/update`,
);

export const DECLARATIONSAVE = generateApiUrl(
  apiHost,
  `${masterBase}declaration/save`,
);

export const DECLARATIONDELETE = generateApiUrl(
  apiHost,
  `${masterBase}declaration/delete/{id}`,
);

export const SENDWHATSAPPDOCUMENT = generateApiUrl(
  apiHost,
  `${masterBase}whatsapp/document`,
);

export const DEPARTMENTWISEINVOICEREPORT = generateApiUrl(
  apiHost,
  `${misBase}ipdreport/department/revenue/report
 `,
);

export const CHARGETYPEMASTERDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}chargeType/dashboard
 `,
);

export const CHARGETYPEMASTERGETBYID = generateApiUrl(
  apiHost,
  `${masterBase}chargeType/get/by/{id}
 `,
);

export const CHARGETYPEMASTERSAVE = generateApiUrl(
  apiHost,
  `${masterBase}chargeType/save
 `,
);

export const CHARGETYPEMASTERDELETE = generateApiUrl(
  apiHost,
  `${masterBase}chargeType/delete/{id}
 `,
);

export const CHARGETYPEMASTERUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}chargeType/update/{id}
 `,
);

export const NUSRSINGCATEGORYGET = generateApiUrl(
  apiHost,
  `${masterBase}nursingcategory/get/by/{id}
 `,
);

export const NUSRSINGCATEGORYDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}nursingcategory/dashboard
 `,
);

export const NUSRSINGCATEGORYSAVE = generateApiUrl(
  apiHost,
  `${masterBase}nursingcategory/save
 `,
);


export const NUSRSINGCATEGORYUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}nursingcategory/update/{id}
 `,
);

export const NUSRSINGCATEGORYDELETE = generateApiUrl(
  apiHost,
  `${masterBase}nursingcategory/delete/{id}
 `,
);

export const NUSRSINGCAREPLANGETBYID = generateApiUrl(
  apiHost,
  `${masterBase}nursingcareplan/get/by/{id}
 `,
);


export const NUSRSINGCAREPLANDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}nursingcareplan/dashboard
 `,
);

export const NUSRSINGCAREPLANSAVE = generateApiUrl(
  apiHost,
  `${masterBase}nursingcareplan/save
 `,
);


export const NUSRSINGCAREPLANUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}nursingcareplan/update/{id}
 `,
);


export const NUSRSINGCAREPLANDELETE = generateApiUrl(
  apiHost,
  `${masterBase}nursingcareplan/delete/{id}
 `,
);

// **************************** Expense Typee API's *******************************

export const EXPENSETYPEGETALL = generateApiUrl(
  apiHost,
  `${masterBase}expense/type/get/all`,
);

export const EXPENSETYPECREATE = generateApiUrl(
  apiHost,
  `${masterBase}expense/type/save`,
);

export const EXPENSETYPEUPDATE = generateApiUrl(
  apiHost,
  `${masterBase}expense/type/update`,
);

export const EXPENSETYPEDELETE = generateApiUrl(
  apiHost,
  `${masterBase}expense/type/delete/`,
);
export const DISCHARGE_CUSTOMIZATION_SAVE_API = generateApiUrl(
  apiHost,
  `${masterBase}discharge/customization/save`,
);
export const DISCHARGE_CUSTOMIZATION_GET_ALL_API = generateApiUrl(
  apiHost,
  `${masterBase}discharge/customization/get/all`,
);

export const SAVEDISCHARGECUSTOMIZATION = generateApiUrl(
  apiHost,
  `${masterBase}discharge/customization/save`,
);
export const OPDCHARGEDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}charge/master/dashboard`,
);
export const IPDCHARGEDASHBOARD = generateApiUrl(
  apiHost,
  `${masterBase}charge/master/dashboard/ipd`,
);
export const OPDCHARGECREATE = generateApiUrl(
  apiHost,
  `${masterBase}charge/master/charge/create`,
);
export const OPDCHARGEDELETE = generateApiUrl(
  apiHost,
  `${masterBase}charge/master/delete/charge/`,
);
export const SMSGETTEMPLATE = generateApiUrl(
  apiHost,
  `${masterBase}notification/master/sms/getAll`,
);
export const SMSUPDATETEMPLATE = generateApiUrl(
  apiHost,
  `${masterBase}notification/master/sms/update`,
);

export const DEPARTMENTWISEMATERIALISSUEREPORT = generateApiUrl(
  MISREPORTOST,
  `${misBase}procurementreport/departmentreport`,
);


export const GETFORMCATEGORYLIST = generateApiUrl(
  apiHost,
  `${masterBase}form/category/get/all`,
);

export const SAVEFORMCATEGORY = generateApiUrl(
  apiHost,
  `${masterBase}form/category/save`,
);

export const SAVEFORMMASTER = generateApiUrl(
  apiHost,
  `${masterBase}form/master/save`,
);
export const GETFORMMASTERALL = generateApiUrl(
  apiHost,
  `${masterBase}form/master/get`,
);
export const SENDWHATSAPPBILL = generateApiUrl(
  apiHost,
  `${masterBase}whatsapp/bill`,
);

export const UPDATEFORMSTATUS = generateApiUrl(
  apiHost,
  `${masterBase}patient/form/status/update`,
);

export const MEDICINEMASTERLIST = generateApiUrl(
  apiHost,
  `${masterBase}medicine/list`,
);


export const MEDICINEADD = generateApiUrl(
  apiHost,
  `${masterBase}medicine/add`,
);

export const MEDICINEEDIT = generateApiUrl(
  apiHost,
  `${masterBase}medicine/edit`,
);


export const MEDICINEDELETE = generateApiUrl(
  apiHost,
  `${masterBase}medicine/delete/`,
);


export const SALEREPORTTHIRDPARTYPAYEE = generateApiUrl(
  apiHost,
  `${masterBase}thirdparty/get`,
);
export const AICOURSEGENERATE = generateApiUrl(
  apiHost,
  `${masterBase}course/hospital/generate`,
);

// export const MEDICINENAMEGETLIST = generateApiUrl(
//   apiHost,
//   `${masterBase}medicine/get`,
// );

// **************************** Expense Typee API's *******************************


export const VIDEOCOUNTERGETALL = generateApiUrl(
  videoMonitoringHost,
  `api/v1/counters`,
);

export const VIEDOCALLALERTS = generateApiUrl(
  videoMonitoringHost,
  `api/v1/alerts`,
);

export const TRANSACTIONSTART = generateApiUrl(
  videoMonitoringHost,
  `api/v1/transaction/start`,
);

export const TRANSACTIONEND = generateApiUrl(
  videoMonitoringHost,
  `api/v1/transaction/end`,
);

export const VIDEOROIGETBYCAMERA = generateApiUrl(
  videoMonitoringHost,
  `api/v1/roi/`,
);

export const VIDEOWEBRTCURL = generateApiUrl(
  videoMonitoringHost,
  `api/v1/webrtc-url`,
);

export const VIDEOALERTDISPOSITION = generateApiUrl(
  videoMonitoringHost,
  `api/v1/alerts/`,
);
