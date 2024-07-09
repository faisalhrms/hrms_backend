class AddOvertimeApprovalInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances,   :approved_overtime,                   :float, 		default: 0.0
		add_column :employee_attendances,   :approved_overtime_hours,            	:float, 		default: 0.0
		add_column :employee_attendances,   :approved_overtime_minutes,          	:float, 		default: 0.0
		add_column :employee_attendances,   :actual_overtime_hours,              	:float, 		default: 0.0
		add_column :employee_attendances,   :actual_overtime_minutes,            	:float, 		default: 0.0
		add_column :employee_attendances,   :approval_base_overtime,       				:boolean, 	default: false
		add_column :employee_attendances,   :is_ot_approved,                      :boolean, 	default: false

		add_column :employees,   						:approval_base_overtime,       				:boolean, 	default: false

		add_column :benefit_structures,   	:approval_base_overtime,       				:boolean, 	default: false
  end
end
