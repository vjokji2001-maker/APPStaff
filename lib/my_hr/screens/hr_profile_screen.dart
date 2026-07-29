import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../widgets/hr_widgets.dart';

class HRProfileScreen extends StatefulWidget {
  const HRProfileScreen({super.key});
  @override
  State<HRProfileScreen> createState() => _HRProfileScreenState();
}

class _HRProfileScreenState extends State<HRProfileScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Personal', 'Official', 'Family', 'Edu & Exp', 'Skills'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emp = HRMockData.employee;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        // Custom header with avatar
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 20, left: 16, right: 16),
          decoration: const BoxDecoration(
            gradient: HRTheme.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(HRTheme.radiusXXL), bottomRight: Radius.circular(HRTheme.radiusXXL)),
          ),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Spacer(),
              Text('My Profile', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18)),
            ]),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(emp.avatarInitials, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            Text(emp.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            Text('${emp.designation} · ${emp.department}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
              child: Text(emp.employeeCode, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        HRTabBar(tabs: _tabs, selectedIndex: _tabIndex, onTabChanged: (i) => setState(() => _tabIndex = i), activeColor: HRTheme.profile),
        Expanded(child: _buildTab()),
      ]),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 0: return _buildPersonalTab();
      case 1: return _buildOfficialTab();
      case 2: return _buildFamilyTab();
      case 3: return _buildEduExpTab();
      case 4: return _buildSkillsTab();
      default: return _buildPersonalTab();
    }
  }

  Widget _buildPersonalTab() {
    final emp = HRMockData.employee;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // QR Employee Card
        HRCard(child: Column(children: [
          const HRSectionHeader(title: 'Employee ID Card', icon: Icons.badge_outlined),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: HRTheme.primaryGradient,
              borderRadius: BorderRadius.circular(HRTheme.radiusMD),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 28, backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(emp.avatarInitials, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(emp.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                Text(emp.designation, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                Text(emp.department, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
                const SizedBox(height: 4),
                Text(emp.employeeCode, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
                child: const Icon(Icons.qr_code_2_rounded, size: 44, color: HRTheme.primaryDark),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          HRPrimaryButton(label: 'Download ID Card', icon: Icons.download_rounded, color: HRTheme.profile, onPressed: () {}),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Personal Information', icon: Icons.person_outlined),
          HRInfoRow(label: 'Full Name', value: emp.name, icon: Icons.person_outlined),
          HRInfoRow(label: 'Date of Birth', value: emp.dob, icon: Icons.cake_outlined),
          HRInfoRow(label: 'Gender', value: emp.gender, icon: Icons.people_outlined),
          HRInfoRow(label: 'Blood Group', value: emp.bloodGroup, icon: Icons.bloodtype_outlined, iconColor: HRTheme.error),
          HRInfoRow(label: 'Marital Status', value: emp.maritalStatus, icon: Icons.favorite_border_rounded),
          HRInfoRow(label: 'Phone', value: emp.phone, icon: Icons.phone_outlined),
          HRInfoRow(label: 'Email', value: emp.email, icon: Icons.email_outlined),
          HRInfoRow(label: 'Address', value: emp.address, icon: Icons.home_outlined, isLast: false),
          HRInfoRow(label: 'Aadhaar (last 4)', value: '****  ****  ${emp.aadhaarLast4}', icon: Icons.credit_card_outlined, isLast: true),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Emergency Contact', icon: Icons.emergency_outlined),
          HRInfoRow(label: 'Contact Name', value: emp.emergencyContact, icon: Icons.person_pin_outlined),
          HRInfoRow(label: 'Relation', value: emp.emergencyRelation, icon: Icons.group_outlined),
          HRInfoRow(label: 'Phone', value: emp.emergencyPhone, icon: Icons.phone_outlined, isLast: true),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildOfficialTab() {
    final emp = HRMockData.employee;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Employment Details', icon: Icons.work_outlined),
          HRInfoRow(label: 'Employee Code', value: emp.employeeCode, icon: Icons.badge_outlined),
          HRInfoRow(label: 'Designation', value: emp.designation, icon: Icons.star_outlined),
          HRInfoRow(label: 'Department', value: emp.department, icon: Icons.apartment_outlined),
          HRInfoRow(label: 'Employment Type', value: emp.employmentType, icon: Icons.work_history_outlined),
          HRInfoRow(label: 'Work Location', value: emp.workLocation, icon: Icons.location_on_outlined),
          HRInfoRow(label: 'Joining Date', value: emp.joiningDate, icon: Icons.calendar_today_outlined),
          HRInfoRow(label: 'Grade', value: emp.grade, icon: Icons.military_tech_outlined),
          HRInfoRow(label: 'Shift', value: emp.shift, icon: Icons.schedule_outlined),
          HRInfoRow(label: 'Reporting Manager', value: emp.reportingManager, icon: Icons.manage_accounts_outlined, isLast: true),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Statutory Details', icon: Icons.account_balance_outlined),
          HRInfoRow(label: 'PAN Number', value: emp.panNumber, icon: Icons.credit_card_outlined),
          HRInfoRow(label: 'PF Number', value: emp.pfNumber, icon: Icons.savings_outlined),
          HRInfoRow(label: 'UAN Number', value: emp.uanNumber, icon: Icons.numbers_outlined),
          HRInfoRow(label: 'ESI Number', value: emp.esiNumber, icon: Icons.health_and_safety_outlined, isLast: true),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildFamilyTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final family = HRMockData.familyMembers;
    final relations = ['👨‍👩‍👧', '👶', '👵', '👴', '👨', '👩'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: family.length,
      itemBuilder: (_, i) {
        final f = family[i];
        return HRCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 24, backgroundColor: HRTheme.profile.withOpacity(0.12),
              child: Text(i < relations.length ? relations[i] : '👤', style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : HRTheme.textPrimary)),
              Text('${f.relation} · ${f.occupation}', style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
              Text('DOB: ${f.dob}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
            ])),
            if (f.isDependent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: HRTheme.infoLight, borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text('Dependent', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: HRTheme.info)),
              ),
          ]),
        );
      },
    );
  }

  Widget _buildEduExpTab() {
    final edu = HRMockData.education;
    final exp = HRMockData.experience;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'Education', icon: Icons.school_outlined),
        ...edu.asMap().entries.map((e) => HRTimelineItem(
          title: e.value.degree,
          subtitle: '${e.value.institution} · ${e.value.field}\n${e.value.grade}',
          time: e.value.year,
          color: HRTheme.profile,
          icon: Icons.school_rounded,
          isLast: e.key == edu.length - 1,
        )),
        const SizedBox(height: 20),
        const HRSectionHeader(title: 'Work Experience', icon: Icons.work_outline_rounded),
        ...exp.asMap().entries.map((e) => HRTimelineItem(
          title: e.value.role,
          subtitle: '${e.value.company} · ${e.value.duration}',
          time: '${e.value.from} – ${e.value.to}',
          color: e.value.isCurrent ? HRTheme.success : HRTheme.textSecondary,
          icon: e.value.isCurrent ? Icons.work_rounded : Icons.work_history_rounded,
          isLast: e.key == exp.length - 1,
        )),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildSkillsTab() {
    final emp = HRMockData.employee;
    final skills = ['Critical Care', 'Patient Assessment', 'IV Therapy', 'Cardiac Monitoring', 'Wound Care', 'EMR Systems', 'Team Leadership', 'Patient Education'];
    final allergies = ['Penicillin', 'Latex'];
    final vaccinations = ['COVID-19 (Covishield x2)', 'Hepatitis B (3 doses)', 'Influenza (Annual)'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Medical Information', icon: Icons.medical_information_outlined),
          HRInfoRow(label: 'Blood Group', value: emp.bloodGroup, icon: Icons.bloodtype_outlined, iconColor: HRTheme.error),
          const Divider(height: 16),
          Text('Allergies', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 6, children: allergies.map((a) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: HRTheme.errorLight, borderRadius: BorderRadius.circular(HRTheme.radiusFull), border: Border.all(color: HRTheme.error.withOpacity(0.3))),
            child: Text(a, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.error, fontWeight: FontWeight.w600)),
          )).toList()),
          const SizedBox(height: 12),
          Text('Vaccinations', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          const SizedBox(height: 6),
          ...vaccinations.map((v) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 14, color: HRTheme.success),
              const SizedBox(width: 6),
              Text(v, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textPrimary)),
            ]),
          )),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Professional Skills', icon: Icons.psychology_outlined),
          Wrap(spacing: 8, runSpacing: 8, children: skills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: HRTheme.moduleGradient(HRTheme.profile),
              borderRadius: BorderRadius.circular(HRTheme.radiusFull),
            ),
            child: Text(s, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
          )).toList()),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }
}
