import '../models/employee.dart';
import '../models/employer.dart';
import '../models/withdrawal_request.dart';

class MockData {
  static final employer = Employer(
    id: 'emp_LGH_001',
    companyName: 'Lagos General Hospital',
    email: 'hr@lagosgeneral.ng',
    phone: '+2348012345678',
    payazaVirtualAccountNumber: '0123456789',
    payrollPoolBalance: 4720000,
    payDay: 30,
    totalStaff: 47,
    createdAt: DateTime(2025, 1, 10),
  );

  static final employees = [
    Employee(id: 'staff_001', fullName: 'Amaka Okonkwo', monthlySalary: 150000, staffId: 'LGH/NRS/001', bankName: 'GTBank', bankCode: '058', bankAccountNumber: '0123456789', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348011111111', employmentStartDate: DateTime(2023, 3, 1)),
    Employee(id: 'staff_002', fullName: 'Chidi Nwosu', monthlySalary: 200000, staffId: 'LGH/LAB/002', bankName: 'First Bank', bankCode: '011', bankAccountNumber: '9876543210', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348022222222', employmentStartDate: DateTime(2022, 8, 15)),
    Employee(id: 'staff_003', fullName: 'Fatima Bello', monthlySalary: 180000, staffId: 'LGH/ADM/003', bankName: 'UBA', bankCode: '033', bankAccountNumber: '1122334455', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348033333333', employmentStartDate: DateTime(2024, 1, 5)),
    Employee(id: 'staff_004', fullName: 'Emeka Eze', monthlySalary: 250000, staffId: 'LGH/DOC/004', bankName: 'Zenith', bankCode: '057', bankAccountNumber: '5566778899', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348044444444', employmentStartDate: DateTime(2021, 6, 20)),
  ];

  static final withdrawals = [
    WithdrawalRequest(id: 'wdr_001', employeeId: 'staff_001', employerId: 'emp_LGH_001', amount: 30000, platformFee: 150, payazaReference: 'EN_REF_20260415_001', status: WithdrawalStatus.success, requestedAt: DateTime(2026, 4, 15)),
    WithdrawalRequest(id: 'wdr_002', employeeId: 'staff_001', employerId: 'emp_LGH_001', amount: 20000, platformFee: 100, payazaReference: 'EN_REF_20260422_001', status: WithdrawalStatus.success, requestedAt: DateTime(2026, 4, 22)),
    WithdrawalRequest(id: 'wdr_003', employeeId: 'staff_003', employerId: 'emp_LGH_001', amount: 25000, platformFee: 125, payazaReference: 'EN_REF_20260505_001', status: WithdrawalStatus.success, requestedAt: DateTime.now().subtract(const Duration(hours: 3))),
  ];
}
