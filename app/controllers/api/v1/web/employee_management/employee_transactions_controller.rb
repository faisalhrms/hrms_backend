class Api::V1::Web::EmployeeManagement::EmployeeTransactionsController < ApplicationController

	before_action :set_employee_transaction, :only => [:show, :update, :destroy]

	def index
		@employee_transactions = EmployeeTransactionHistory.where(:employee_id => params[:employee_id]).order('id DESC')
		render status:200, template: 'api/v1/web/employee_management/employee_transactions/index'
	end

	def save_employee_change
		employee_change_data = params[:employee_change_data]
		selected_employee_list = params[:selected_employee_list]
		if selected_employee_list.present?
			Array.new(selected_employee_list.count).each_index do |index|
				employee_transaction = EmployeeTransactionHistory.new
				employee_id = selected_employee_list[index.to_s][:id].to_i
				employee_transaction.transaction_date = Time.now.to_date
				employee = Employee.find(employee_id)
					employee_status = "Active"
					employment_status = "Probation"
					if employee.on_probation == true
						employment_status = "Probation"
					else
						employment_status = "Confirmed"
					end
					if employee.is_active == true
						employee_status = "Active"
					else
						employee_status = "In-Active"
					end
				if employee_change_data[:transaction_type] == "Employee Status"
					employee_transaction.old_employee_status = employee_status
					employee_transaction.new_employee_status = employee_change_data[:employee_status]
				elsif employee_change_data[:transaction_type] == "Employment Status"
					employee_transaction.old_employment_status = employment_status
					employee_transaction.new_employment_status = employee_change_data[:employment_status]
					employee_transaction.transaction_date = employee_change_data[:transaction_date].to_date
				elsif employee_change_data[:transaction_type] == "Gross Salary"
					employee_transaction.old_gross_salary = employee.gross_salary
					employee_transaction.new_gross_salary = employee_change_data[:gross_salary].to_f
					employee_transaction.transaction_date = employee_change_data[:transaction_date].to_date
				elsif employee_change_data[:transaction_type] == "Change Joining Date"
					employee_transaction.old_joining_date = employee.joining_date.to_date
					employee_transaction.new_joining_date = employee_change_data[:transaction_date].to_date
				elsif employee_change_data[:transaction_type] == "Line Manager"
					employee_transaction.old_line_manager_id = employee.line_manager_id
					employee_transaction.new_line_manager_id = employee_change_data[:line_manager_id].to_i
				elsif employee_change_data[:transaction_type] == "Head of Department"
					employee_transaction.old_hod_id = employee.hod_id
					employee_transaction.new_hod_id = employee_change_data[:hod_id].to_i
				elsif employee_change_data[:transaction_type] == "Transfer"
					employee_transaction.transfer_type = employee_change_data[:transfer_type]
					if employee_change_data[:transfer_type] == "Branch"
						employee_transaction.old_location_id = employee.location_id
						employee_transaction.new_location_id = employee_change_data[:location_id]
						employee_transaction.old_branch_id = employee.branch_id
						employee_transaction.new_branch_id = employee_change_data[:branch_id]
						employee_transaction.transaction_date = employee_change_data[:transaction_date].to_date
					elsif employee_change_data[:transfer_type] == "Department"
						employee_transaction.old_department_id = employee.department_id
						employee_transaction.new_department_id = employee_change_data[:department_id]
						employee_transaction.old_sub_department_id = employee.sub_department_id
						employee_transaction.new_sub_department_id = employee_change_data[:sub_department_id]
						employee_transaction.transaction_date = employee_change_data[:transaction_date].to_date
					end
				elsif employee_change_data[:transaction_type] == "Change Grade" or employee_change_data[:transaction_type] == "Change Designation"
					employee_transaction.old_grade_id = employee.grade_id
					employee_transaction.new_grade_id = employee_change_data[:grade_id]
					employee_transaction.old_designation_id = employee.designation_id
					employee_transaction.new_designation_id = employee_change_data[:designation_id]
				elsif employee_change_data[:transaction_type] == "Change Job Title"
					employee_transaction.old_job_title_id = employee.job_title_id
					employee_transaction.new_job_title_id = employee_change_data[:job_title_id]
				elsif employee_change_data[:transaction_type] == "Change Employee Type"
					employee_transaction.old_employee_type_id = employee.employee_type_id
					employee_transaction.new_employee_type_id = employee_change_data[:employee_type_id]
				elsif employee_change_data[:transaction_type] == "Change Salary Unit"
					employee_transaction.old_salary_unit_id = employee.salary_unit_id
					employee_transaction.new_salary_unit_id = employee_change_data[:salary_unit_id]
					employee_transaction.old_cost_center_id = employee.cost_center_id
					employee_transaction.new_cost_center_id = employee_change_data[:cost_center_id]
				elsif employee_change_data[:transaction_type] == "End of Employment"
					employee_transaction.hold_salary 	= employee_change_data[:hold_salary] if employee_change_data[:left_type] != "Struck Off"
					employee_transaction.is_struck_off 	= employee_change_data[:struck_off] if employee_change_data[:left_type] == "Struck Off"
					employee_transaction.left_type 		= employee_change_data[:left_type]
					employee_transaction.left_reason 	= employee_change_data[:left_reason]
					employee_transaction.resign_date 	= employee_change_data[:resign_date]
					employee_transaction.transaction_date = employee_change_data[:transaction_date].to_date
				elsif employee_change_data[:transaction_type] == "Probation Extension"
					employee_transaction.probation_extension_days 	= employee_change_data[:probation_extension_days]
					if employee.confimration_due_date.nil?
						employee_transaction.old_confimration_due_date 	= (employee.joining_date + 3.month).to_date
						employee_transaction.new_confimration_due_date 	= (employee.joining_date + 3.month).to_date + employee_transaction.probation_extension_days.days
					else	
						employee_transaction.old_confimration_due_date 	= employee.confimration_due_date
						employee_transaction.new_confimration_due_date 	= employee.confimration_due_date.to_date + employee_transaction.probation_extension_days.days
					end
				end
				employee_transaction.transaction_type = employee_change_data[:transaction_type]
				employee_transaction.employee_id 			= selected_employee_list[index.to_s][:id].to_i
				employee_transaction.action_performed = current_user.full_name
				employee_transaction.save

				if employee_change_data[:left_type] == "Struck Off" and employee_change_data[:struck_off] == 'true'
					EmployeeRoster.where(:employee_id => employee_transaction.employee_id).where(['roster_date >= ?', employee_transaction.transaction_date.to_date.beginning_of_day]).destroy_all
					EmployeeAttendance.where(:employee_id => employee_transaction.employee_id).where(['attendance_date >= ?', employee_transaction.transaction_date.to_date.beginning_of_day]).destroy_all
					employee.update(social_security_allowed: false, life_insurance_allowed: false)
				end
			end
		end
		render json: {}, status: 204
	end

	def show
		render status:200, template: 'api/v1/web/employee_management/employee_transactions/show'
	end

	private

  def set_employee_transaction
    @employee_transaction = EmployeeTransactionHistory.find(params[:id])
  end	

end
