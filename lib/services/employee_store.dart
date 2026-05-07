import '../models/employee.dart';
import '../utils/mock_data.dart';

class EmployeeStore {
  final List<Employee> _added = [];

  List<Employee> get allEmployees => [
        ...MockData.employees,
        ..._added,
      ];

  int get count => MockData.employees.length + _added.length;

  void addEmployee(Employee employee) {
    _added.add(employee);
  }
}
