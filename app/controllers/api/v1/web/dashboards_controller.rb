class Api::V1::Web::DashboardsController < ApplicationController

	def main_dashboard 
		@year_start_date 		= Time.now.beginning_of_year
		@year_end_date 			= Time.now.end_of_year
		@month_start_date 	= Time.now.beginning_of_month
		@month_end_date 		= Time.now.end_of_month

		if current_user.is_admin == true
			@locations 					= Location.where(:is_active => true).order('id DESC')
			@branches 					= Branch.where(:is_active => true).order('id DESC')
			@departments 				= Department.where(:is_active => true).order('id DESC')
			@documents 					= Document.where(:is_active => true).order('id DESC')
			@holidays 					= Holiday.where(:is_active => true).order('id DESC')
			@employees 					= Employee.active.where(:excluded_from_reports => false).order('id DESC')
		else
			@locations 					= Location.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
			@branches 					= Branch.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
			@departments 				= Department.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
			@documents 					= Document.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
			@holidays 					= Holiday.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
			@employees 					= Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
		end

		@employee_list = Employee.where(:is_active => true, :excluded_from_reports => false).order('id DESC')
		if not current_user.employee.nil?
			if current_user.is_location_head == true
				@employee_list = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
			elsif current_user.is_branch_head == true
				@employee_list = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
			elsif current_user.is_department_head == true
				@employee_list = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
			elsif current_user.employee.is_line_manager == true
				employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
				employee_ids << current_user.employee.id
				@employee_list = Employee.where(:id => employee_ids, :is_active => true, :excluded_from_reports => false).order('id DESC')
			else
				@employee_list = []
			end
		end

		if not current_user.employee.nil?
			if current_user.request_on_dashboard == true
				employee = current_user.employee
				@leave_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "LeaveRequest", :request_receiver_id => employee.id, :approval_request_status => "Waiting For Approval").order('id DESC')
			else
				@leave_approvals = []
			end
		else
			@leave_approvals = []
		end

		if not current_user.employee.nil?
			if current_user.request_on_dashboard == true
				employee = current_user.employee
				@official_duty_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "OfficialDuty", :request_receiver_id => employee.id, :approval_request_status => "Waiting For Approval").order('id DESC')
			else
				@official_duty_approvals = []
			end
		else
			@official_duty_approvals = []
		end

		if not current_user.employee.nil?
			if current_user.request_on_dashboard == true
				employee = current_user.employee
				@relaxation_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "RelaxationRequest", :request_receiver_id => employee.id, :approval_request_status => "Waiting For Approval").order('id DESC')
			else
				@relaxation_approvals = []
			end
		else
			@relaxation_approvals = []
		end

		render status:200, template: 'api/v1/web/dashboards/main_dashboard.json.jbuilder'
	end

	def hris_dashboard

		if not params[:location_ids].blank?
			location_ids = params[:location_ids].map(&:to_i)
		else
			location_ids = Location.where(:company_id => current_user.company_id,:is_active => true).collect(&:id).uniq
		end

		if not params[:branch_ids].blank?
			branch_ids = params[:branch_ids].map(&:to_i)
		else
			branch_ids = Branch.where(:company_id => current_user.company_id,:location_id => location_ids, :is_active => true).collect(&:id).uniq
		end


		if current_user.is_admin == true
			@employees = Employee.where(:excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		elsif current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@employee_attendances = Employee.where(:id => @employees.collect(&:id).uniq)
		end


		@on_roll_strength    = Employee.where(:company_id => current_user.company_id,:id => @employee_attendances.pluck(:id),  :location_id => location_ids, :branch_id => branch_ids, :is_active => true)
		@employee_list          = Employee.where(:company_id => current_user.company_id,:id => @employee_attendances.pluck(:id), :location_id => location_ids, :branch_id => branch_ids, :is_active => true)
		@all_employee_list      = Employee.where(:company_id => current_user.company_id,:id => @employee_attendances.pluck(:id), :location_id => location_ids, :branch_id => branch_ids)
		@archive_employee_list  = Employee.where(:company_id => current_user.company_id,:id => @employee_attendances.pluck(:id), :location_id => location_ids, :branch_id => branch_ids, :is_active => false)
		@branches = Branch.where(:company_id => current_user.company_id, :location_id => location_ids ,:is_active => true,  :id => @employee_list.collect(&:branch_id)).order('id ASC')
		@grades                 = Grade.where(:company_id => current_user.company_id, :is_active => true)
		@departments      = Department.where(:company_id => current_user.company_id, :id => @employee_list.collect(&:department_id), :is_active => true).order('name ASC')
		@employee_types   = EmployeeType.where( :id => @employee_list.collect(&:employee_type_id), :is_active => true).order('name ASC')
		@employee_grades  = Grade.where(:company_id => current_user.company_id, :id => @employee_list.collect(&:grade_id), :is_active => true).order('sort_order ASC')
		@cities           = City.where(:id => @employee_list.collect(&:current_city_id)).order('name ASC')
		@employee_religions  = Religion.where(:id => @employee_list.collect(&:religion_id)).order('name ASC')

		@management_grade_ids      = @grades.where(:management_type => "Management").collect(&:id)
		@non_management_grade_ids  = @grades.where(:management_type => "Non-Management").collect(&:id)

		@senior_management_tier      = @grades.where(:management_tier => "Senior-Management").collect(&:id)
		@middle_management_tier      = @grades.where(:management_tier => "Middle-Management").collect(&:id)
		@junior_management_tier      = @grades.where(:management_tier => "Junior-Management").collect(&:id)
		@non_management_tier         = @grades.where(:management_tier => "Non-Management").collect(&:id)

		render status:200, template: 'api/v1/web/dashboards/hris_dashboard.json.jbuilder'
	end

	def salary_dashboard

		if not params[:location_ids].blank?
			location_ids = params[:location_ids].map(&:to_i)
		else
			location_ids = Location.where(:company_id => current_user.company_id, :is_active => true).collect(&:id).uniq
		end

		if not params[:branch_ids].blank?
			branch_ids = params[:branch_ids].map(&:to_i)
		else
			branch_ids = Branch.where(:company_id => current_user.company_id,:location_id => location_ids, :is_active => true).collect(&:id).uniq
		end

		if not params[:department_id].blank?
			department_ids = params[:department_id].map(&:to_i)
		else
			department_ids = Department.where(:company_id => current_user.company_id,:is_active => true ).collect(&:id).uniq
		end

		if  current_user.is_admin == true
			@employees = Employee.where(:excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif  current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true,:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@pay_invoices = PayInvoice.where(:status => true,:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		end

		@start_date = params[:start_date]
		@end_date   = params[:end_date]

		@branches = Branch.where(:company_id => current_user.company_id, :location_id => location_ids, :is_active => true, :id => branch_ids).order('id ASC')

		@employee_list   = Employee.where(:company_id => current_user.company_id,:id => @pay_invoices.pluck(:employee_id),:location_id => location_ids, :branch_id => branch_ids,:department_id => department_ids,:is_active => true)
		@all_employee_list      = Employee.where(:company_id => current_user.company_id,:id => @pay_invoices.pluck(:employee_id), :location_id => location_ids, :branch_id => branch_ids)

		@departments_salary      = Department.where(:company_id => current_user.company_id, :id => @employee_list.collect(&:department_id), :is_active => true).order('name ASC')
		@pf_depart      = Department.where(:company_id => current_user.company_id, :id => @employee_list.collect(&:department_id), :is_active => true).order('name ASC')
		@careem_employee      = FixedPayItem.where(:pay_item_id => 41).collect(&:employee_id)

		render status:200, template: 'api/v1/web/dashboards/salary_dashboard.json.jbuilder'
	end

	def attendance_dashboard

		if not params[:location_ids].blank?
			location_ids = params[:location_ids].map(&:to_i)
		else
			location_ids = Location.where(:company_id => current_user.company_id, :is_active => true).collect(&:id).uniq
		end

		if not params[:branch_ids].blank?
			branch_ids = params[:branch_ids].map(&:to_i)
		else
			branch_ids = Branch.where(:company_id => current_user.company_id,:location_id => location_ids, :is_active => true).collect(&:id).uniq
		end

		if not params[:department_id].blank?
			department_ids = params[:department_id].map(&:to_i)
		else
			department_ids = Department.where(:company_id => current_user.company_id,:is_active => true ).collect(&:id).uniq
		end

		if not params[:grade_id].blank?
			grade_ids = params[:grade_id].map(&:to_i)
		else
			grade_ids = Grade.where(:company_id => current_user.company_id,:is_active => true ).collect(&:id).uniq
		end

		if current_user.is_admin == true
			@employees = Employee.where(:excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		end
		
		@start_date = params[:start_date]
		@end_date   = params[:end_date]

		@branches = Branch.where(:company_id => current_user.company_id, :location_id => location_ids, :is_active => true, :id => branch_ids).order('id ASC')
		@on_roll_strength    = Employee.where(:company_id => current_user.company_id,:id => @employee_attendances.pluck(:employee_id), :is_active => true)
		@employee_list          = Employee.where(:company_id => current_user.company_id,:location_id => location_ids,:id => @employee_attendances.pluck(:employee_id) , :branch_id => branch_ids, :is_active => true)
		@employee_lists          = Employee.where(:company_id => current_user.company_id, :location_id => location_ids,:id => @employee_attendances.pluck(:employee_id) ,:branch_id => branch_ids, :department_id => department_ids ,:is_active => true)
		@employee          = Employee.where(:company_id => current_user.company_id,:id => @employee_attendances.pluck(:employee_id) ,:location_id => location_ids, :branch_id => branch_ids, :department_id => department_ids ,:is_active => true).collect(&:id)
		@all_employee_list      = Employee.where(:company_id => current_user.company_id, :location_id => location_ids, :branch_id => branch_ids)
		@departments_absents      = Department.where(:company_id => current_user.company_id, :id => @employee_list.collect(&:department_id), :is_active => true).order('name ASC')
		@departments_leave      = Department.where(:company_id => current_user.company_id, :id => @employee_lists.collect(&:department_id), :is_active => true).order('name ASC')
		@locations 					= Location.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
		@employee_attendance = @employee_attendances.where(:location_id => location_ids, :branch_id => branch_ids,:department_id => department_ids,:grade_id => grade_ids, :attendance_date => @start_date.to_date..@end_date.to_date)

		@leave_type      	= LeaveType.where(:is_active => true,:location_id => location_ids).pluck(:id).uniq

		render status:200, template: 'api/v1/web/dashboards/attendance_dashboard.json.jbuilder'
	end

	def company_wise_dashboard
		@employee_list = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
		if not current_user.employee.nil?
			if current_user.is_location_head == true
				@employee_list = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
			elsif current_user.is_branch_head == true
				@employee_list = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
			elsif current_user.is_department_head == true
				@employee_list = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
			elsif current_user.employee.is_line_manager == true
				employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
				employee_ids << current_user.employee.id
				@employee_list = Employee.where(:id => employee_ids, :is_active => true, :excluded_from_reports => false).order('id DESC')
			else
				@employee_list = []
			end
		end

		@year_start_date 		= Time.now.beginning_of_year
		@year_end_date 			= Time.now.end_of_year
		@month_start_date 	= Time.now.beginning_of_month
		@month_end_date 		= Time.now.end_of_month

		@locations 					= Location.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
		@branches 					= Branch.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
		@departments 				= Department.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
		@documents 					= Document.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
		@holidays 					= Holiday.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
		@employees 					= Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')

		if not current_user.employee.nil?
			if current_user.request_on_dashboard == true
				employee = current_user.employee
				@leave_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "LeaveRequest", :request_receiver_id => employee.id, :approval_request_status => "Waiting For Approval").order('id DESC')
			else
				@leave_approvals = []
			end
		else
			@leave_approvals = []
		end

		if not current_user.employee.nil?
			if current_user.request_on_dashboard == true
				employee = current_user.employee
				@official_duty_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "OfficialDuty", :request_receiver_id => employee.id, :approval_request_status => "Waiting For Approval").order('id DESC')
			else
				@official_duty_approvals = []
			end
		else
			@official_duty_approvals = []
		end

		if not current_user.employee.nil?
			if current_user.request_on_dashboard == true
				employee = current_user.employee
				@relaxation_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "RelaxationRequest", :request_receiver_id => employee.id).order('id DESC')
			else
				@relaxation_approvals = []
			end
		else
			@relaxation_approvals = []
		end

		render status:200, template: 'api/v1/web/dashboards/main_dashboard.json.jbuilder'
	end

end
