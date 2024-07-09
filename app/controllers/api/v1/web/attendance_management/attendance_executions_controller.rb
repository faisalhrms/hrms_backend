class Api::V1::Web::AttendanceManagement::AttendanceExecutionsController < ApplicationController

	def employee_time_card
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		if params[:single_employee_information].present?
			single_employee_information = params[:single_employee_information]
			@employee_attendances = EmployeeAttendance.where(:employee_id => single_employee_information[:id], :attendance_date => date_range).order('attendance_date ASC')
			leverage_minute_policy
		else
			@employee_attendances = []
		end
		render status:200, template: 'api/v1/web/attendance_management/attendance_executions/bulk_index.json.jbuilder'
	end

	def download_time_card
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		if params[:single_employee_information].present?
			single_employee_information = params[:single_employee_information]
			@employee = Employee.find(single_employee_information[:id])
			@employee_attendances = EmployeeAttendance.where(:employee_id => single_employee_information[:id], :attendance_date => date_range).order('attendance_date ASC')
			leverage_minute_policy
	    check_directory("#{Rails.public_path}/pdf")
	    pdf = WickedPdf.new.pdf_from_string(
	      render_to_string("api/v1/web/reports/attendance_reports/time_card.pdf.erb"),
	      footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
	      :margin => {
	        :top      => '0.1in',
	        :bottom   => '0.1in',
	        :left     => '0.1in',
	        :right    => '0.1in'
	      },
	      dpi: 320,
	    )
			file_name = "time_card"
			url_path = save_pdf_file(pdf, file_name)

	    render json: {message: "Pdf Created", path: url_path}
		else	
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def download_multiple_time_card
		@date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		@employees = Employee.where(:company_id => params[:company_id], :employee_code => params[:employee_codes].split(','))
		if @employees.count > 0
			time = Time.now
	    url_path = ""
	    check_directory("#{Rails.public_path}/pdf")
	    pdf = WickedPdf.new.pdf_from_string(
	      render_to_string("api/v1/web/reports/attendance_reports/bulk_time_card.pdf.erb"),
	      footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
	      :margin => {
	        :top      => '0.1in',
	        :bottom   => '0.1in',
	        :left     => '0.1in',
	        :right    => '0.1in'
	      },
	      dpi: 320,
	    )
			file_name = "time_card"
			url_path = save_pdf_file(pdf, file_name)

	    render json: {message: "Pdf Created", path: url_path}
		else	
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def fetch_employee_attendance
		@date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		render status:200, template: 'api/v1/web/attendance_management/attendance_executions/fetch_employee_attendance.json.jbuilder'
	end

	def save_multi_day_attendance
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		employee = Employee.find(params[:employee_id])
		if params[:employee_attendance_list].present?
			employee_attendance_list = params[:employee_attendance_list]	
			Array.new(employee_attendance_list.count).each_index do |index|
				if employee_attendance_list[index.to_s][:employee_attendance_id].present?
					employee_attendance = EmployeeAttendance.find(employee_attendance_list[index.to_s][:employee_attendance_id])
					if employee_attendance.is_finalized == false
						attendance_date = employee_attendance_list[index.to_s][:attendance_date]
						if employee_attendance_list[index.to_s][:in_time].nil? or employee_attendance_list[index.to_s][:in_time].blank?
							employee_attendance.in_time = nil
						else
							check_in = employee_attendance_list[index.to_s][:in_time]
							employee_attendance.in_time	= Time.new(check_in.to_datetime.year, check_in.to_datetime.month, check_in.to_datetime.day, check_in.to_datetime.to_time.strftime('%H'), check_in.to_datetime.to_time.strftime('%M'), check_in.to_datetime.to_time.strftime('%S'))
						end
						if employee_attendance_list[index.to_s][:out_time].nil? or employee_attendance_list[index.to_s][:out_time].blank?
							employee_attendance.out_time = nil
						else
							check_out = employee_attendance_list[index.to_s][:out_time]
							employee_attendance.out_time = Time.new(check_out.to_datetime.year, check_out.to_datetime.month, check_out.to_datetime.day, check_out.to_datetime.to_time.strftime('%H'), check_out.to_datetime.to_time.strftime('%M'), check_out.to_datetime.to_time.strftime('%S'))
						end
						employee_attendance.mark_as_manual = true
						employee_attendance.save
					end
				else
					attendance_date = employee_attendance_list[index.to_s][:attendance_date]
					employee_attendance = EmployeeAttendance.new(:attendance_date => attendance_date.to_date, :in_time => nil, :out_time => nil)
					employee_attendance.employee_id 				= employee.id
					employee_attendance.company_id 					= employee.company_id
					employee_attendance.location_id 				= employee.location_id
					employee_attendance.branch_id 					= employee.branch_id
					employee_attendance.department_id 			= employee.department_id
					employee_attendance.sub_department_id 	= employee.sub_department_id
					employee_attendance.grade_id 						= employee.grade_id
					employee_attendance.job_title_id 				= employee.job_title_id
					employee_attendance.designation_id 			= employee.designation_id
					employee_attendance.salary_unit_id 			= employee.salary_unit_id
					employee_attendance.cost_center_id   		= employee.cost_center_id
					employee_attendance.employee_full_name 	= employee.full_name
					employee_attendance.employee_code				= employee.employee_code
					employee_attendance.company_name				= employee.company_name
					employee_attendance.location_name				= employee.location_name
					employee_attendance.branch_name					= employee.branch_name
					employee_attendance.department_name			= employee.department_name
					employee_attendance.sub_department_name	= employee.sub_department_name
					employee_attendance.grade_name					= employee.grade_name
					employee_attendance.job_title_name			= employee.job_title_name
					employee_attendance.designation_name		= employee.designation_name
					employee_attendance.salary_unit_name		= employee.salary_unit_name
					employee_attendance.cost_center_name		= employee.cost_center_name
					employee_attendance.attendance_date   	= attendance_date 
					employee_attendance.is_overtime					= employee.is_overtime
					employee_attendance.is_off_day_working	= employee.is_off_day_working
					employee_attendance.is_cpl							= employee.is_cpl
					employee_attendance.attendance_exempted = employee.attendance_exempted
					if employee_attendance_list[index.to_s][:in_time].nil? or employee_attendance_list[index.to_s][:in_time].blank?
						employee_attendance.in_time = nil
					else
						check_in = employee_attendance_list[index.to_s][:in_time]
						employee_attendance.in_time	= Time.new(check_in.to_datetime.year, check_in.to_datetime.month, check_in.to_datetime.day, check_in.to_datetime.to_time.strftime('%H'), check_in.to_datetime.to_time.strftime('%M'), check_in.to_datetime.to_time.strftime('%S'))
					end
					if employee_attendance_list[index.to_s][:out_time].nil? or employee_attendance_list[index.to_s][:out_time].blank?
						employee_attendance.out_time = nil
					else
						check_out = employee_attendance_list[index.to_s][:out_time]
						employee_attendance.out_time = Time.new(check_out.to_datetime.year, check_out.to_datetime.month, check_out.to_datetime.day, check_out.to_datetime.to_time.strftime('%H'), check_out.to_datetime.to_time.strftime('%M'), check_out.to_datetime.to_time.strftime('%S'))
					end
					employee_attendance.mark_as_manual = true
					employee_attendance.save
				end
			end
		end
		render json: {}, status: 204
	end

	def execute_single_employee_attendance
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		
		########## Empty Row Creation for Attendance ##########
		date_range.each do |single_date|
			if EmployeeAttendance.where(:employee_id => params[:employee_id], :attendance_date => single_date).empty?
				employee = Employee.find(params[:employee_id])
				if employee.joining_date.to_date <= single_date
					if employee.is_active == true and employee.is_struck_off != true
						EmployeeAttendance.create_empty_attenance_record(single_date, employee)	
					end
				end
			end
		end

		########## Update Attendance Information with Employee Roster ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
			EmployeeRoster.update_employee_roster(employee_attendance.attendance_date.to_date, employee_attendance)
		end

		########## Clear Attendance Record ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
			EmployeeAttendance.clear_attendance_record(employee_attendance)
		end

		########## Update Employee Information ##########
		if params[:update_employee_information] == "true"
			employee = Employee.find(params[:employee_id])
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.update_employee_detail(employee_attendance, employee)
			end
		end

		########## Update Checkin and Checkout ##########
		if params[:update_in_out] == "true"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
				AttendanceMachineLog.update_employee_checkin_checkout(employee_attendance)
			end
		end
		
		########## Leave Impact on Attendance ##########
		if params[:leave_impact] == "true"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_on_leave => true).each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				LeaveRequest.employee_wise_leave_impact(employee_attendance)
			end
		end

		########## Official Duty Impact on Attendance ##########
		if params[:od_impact] == "true"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_official_duty => true).each do |employee_attendance|
				EmployeeAttendance.request_clear_attendance_record(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				OfficialDuty.employee_wise_official_duty_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_official_duty => true).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.single_employee_process_attendance(employee_attendance)
			end
		end

		########## Relaxation Impact on Attendance ##########
		if params[:relaxation_impact] == "true"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_relaxation => true).each do |employee_attendance|
				EmployeeAttendance.request_clear_attendance_record(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				RelaxationRequest.employee_wise_relaxation_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_relaxation => true).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.single_employee_process_attendance(employee_attendance)
			end
		end

		########## Process Attendance ##########
		if params[:update_attendance] == "true"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.single_employee_process_attendance(employee_attendance)
			end
		end

		if params[:update_attendance] == "true"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.revision_of_leave_deducted(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => params[:employee_id], :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.finalize_deuction(employee_attendance)
			end
		end

		render json: {}, status: 204
	end

	def bulk_execute_employee_attendance
		execution_start_time = Time.now
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		
		employees = Employee.where(:is_active => true, :company_id => params[:company_id].to_i, :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i).order('id DESC')
		
		if params[:department_id].try(:map, &:to_i)
			employees = employees.where(:department_id => params[:department_id].map(&:to_i))
		end

		if params[:sub_department_id].try(:map, &:to_i)
			employees = employees.where(:sub_department_id => params[:sub_department_id].map(&:to_i))
		end

		employees.each do |employee|
			########## Empty Row Creation for Attendance ##########
			date_range.each do |single_date|
				if EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => single_date).empty?
					if employee.joining_date.to_date <= single_date
						if employee.is_active == true and employee.is_struck_off != true
							EmployeeAttendance.create_empty_attenance_record(single_date, employee)
						end
					end
				end
			end

			########## Update Attendance Information with Employee Roster ##########
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeRoster.update_employee_roster(employee_attendance.attendance_date.to_date, employee_attendance)
			end

			########## Clear Attendance Record ##########
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record(employee_attendance)
			end

			########## Update Employee Information ##########
			if params[:update_employee_information] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.update_employee_detail(employee_attendance, employee)
				end
			end

			########## Update Checkin and Checkout ##########
			if params[:update_in_out] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
					AttendanceMachineLog.update_employee_checkin_checkout(employee_attendance)
				end
			end
			
			########## Leave Impact on Attendance ##########
			if params[:leave_impact] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => true).each do |employee_attendance|
					EmployeeAttendance.request_clear_attendance_record(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					LeaveRequest.employee_wise_leave_impact(employee_attendance)
				end
			end

			########## Official Duty Impact on Attendance ##########
			if params[:od_impact] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).each do |employee_attendance|
					EmployeeAttendance.request_clear_attendance_record(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					OfficialDuty.employee_wise_official_duty_impact(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.single_employee_process_attendance(employee_attendance)
				end
			end

			########## Relaxation Impact on Attendance ##########
			if params[:relaxation_impact] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_relaxation => true).each do |employee_attendance|
					EmployeeAttendance.request_clear_attendance_record(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					RelaxationRequest.employee_wise_relaxation_impact(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_relaxation => true).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.single_employee_process_attendance(employee_attendance)
				end
			end

			########## Process Attendance ##########
			if params[:update_attendance] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.single_employee_process_attendance(employee_attendance)
				end
			end

			if params[:update_attendance] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.revision_of_leave_deducted(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.finalize_deuction(employee_attendance)
				end
			end
		end

		execution_end_time = Time.now
		department_name = "-"
		department_id = nil
		if params[:department_id].try(:map, &:to_i)
			department_id = params[:department_id].try(:map, &:to_i)
			department_name = Department.where(id: params[:department_id].try(:map, &:to_i)).pluck(:name)
		end
		company_name = Company.find(params[:company_id].to_i).name
		location_name = Location.find(params[:location_id].to_i).name
		branch_name = Branch.find(params[:branch_id].to_i).name

		AttendanceExecutionTransaction.create(:company_id => params[:company_id].to_i, :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :department_id => department_id.try(:join,(',')), :company_name => company_name, :location_name => location_name, :branch_name => branch_name, :department_name => department_name.try(:join,(',')), :start_date => params[:start_date].to_date, :end_date => params[:end_date].to_date, :execution_start_time => execution_start_time, :execution_end_time => execution_end_time)
		render json: {}, status: 204
	end

	def bulk_salary_unit_execute_employee_attendance
		execution_start_time = Time.now
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		
		employees = Employee.where(:is_active => true, :company_id => params[:company_id].to_i, :salary_unit_id => params[:salary_unit_id].to_i).order('id DESC')

		employees.each do |employee|
			########## Empty Row Creation for Attendance ##########
			date_range.each do |single_date|
				if EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => single_date).empty?
					if employee.joining_date.to_date <= single_date
						if employee.is_active == true and employee.is_struck_off != true
							EmployeeAttendance.create_empty_attenance_record(single_date, employee)
						end
					end
				end
			end

			########## Update Attendance Information with Employee Roster ##########
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				EmployeeRoster.update_employee_roster(employee_attendance.attendance_date.to_date, employee_attendance)
			end

			########## Clear Attendance Record ##########
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record(employee_attendance)
			end

			########## Update Employee Information ##########
			if params[:update_employee_information] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.update_employee_detail(employee_attendance, employee)
				end
			end

			########## Update Checkin and Checkout ##########
			if params[:update_in_out] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
					AttendanceMachineLog.update_employee_checkin_checkout(employee_attendance)
				end
			end
			
			########## Leave Impact on Attendance ##########
			if params[:leave_impact] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => true).each do |employee_attendance|
					EmployeeAttendance.request_clear_attendance_record(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					LeaveRequest.employee_wise_leave_impact(employee_attendance)
				end
			end

			########## Official Duty Impact on Attendance ##########
			if params[:od_impact] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).each do |employee_attendance|
					EmployeeAttendance.request_clear_attendance_record(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					OfficialDuty.employee_wise_official_duty_impact(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.single_employee_process_attendance(employee_attendance)
				end
			end

			########## Relaxation Impact on Attendance ##########
			if params[:relaxation_impact] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_relaxation => true).each do |employee_attendance|
					EmployeeAttendance.request_clear_attendance_record(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
					RelaxationRequest.employee_wise_relaxation_impact(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_relaxation => true).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.single_employee_process_attendance(employee_attendance)
				end
			end

			########## Process Attendance ##########
			if params[:update_attendance] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.single_employee_process_attendance(employee_attendance)
				end
			end

			if params[:update_attendance] == "true"
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.revision_of_leave_deducted(employee_attendance)
				end
				EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
					EmployeeAttendance.finalize_deuction(employee_attendance)
				end
			end
		end

		execution_end_time = Time.now
		company_name = Company.find(params[:company_id].to_i).name
		salary_unit_name = SalaryUnit.find(params[:salary_unit_id].to_i).name

		AttendanceExecutionTransaction.create(:company_id => params[:company_id].to_i, :location_id => nil, :branch_id =>  nil, :department_id => nil, :company_name => company_name, :location_name => "", :branch_name => "", :department_name => "", :start_date => params[:start_date].to_date, :end_date => params[:end_date].to_date, :execution_start_time => execution_start_time, :execution_end_time => execution_end_time)
		render json: {}, status: 204
	end

	def fetch_overtime_employee_attendance
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => date_range, :approval_base_overtime => true).order('id ASC')
		
		if current_user.is_admin == true
      @employees = Employee.where(:is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
	      @employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
	    else
	    	@employees = Employee.where(:id => current_user.employee.id).order('id DESC')
	  		@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq) 
	    end
	  end
		
    if not params[:location_id].blank?
      @employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
    end
		if not params[:branch_id].blank?
      @employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
    end
		if not params[:department_id].blank?
      @employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
    end
    if not params[:grade_id].blank?
      @employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].to_i)
    end
    if not params[:employee_type_id].blank?
      @employee_attendances = EmployeeAttendance.employee_type_related_employee_attendance(@employee_attendances, params[:employee_type_id].to_i)
    end
    if not params[:employee_id].blank?
      @employee_attendances = EmployeeAttendance.employee_related_employee_attendance(@employee_attendances, params[:employee_id].to_i)
    end
    
		render status:200, template: 'api/v1/web/attendance_management/attendance_executions/fetch_overtime_employee_attendance.json.jbuilder'
	end

	def bulk_approved_overtime
		ot_error_msg = []
		if params[:employee_attendance_list].present?
			employee_attendance_list = params[:employee_attendance_list]
			Array.new(employee_attendance_list.count).each_index do |index|
				employee_attendance = EmployeeAttendance.find(employee_attendance_list[index.to_s][:employee_attendance_id])
				unless employee_attendance.is_ot_approved
					if employee_attendance_list[index.to_s][:is_ot] == "false"
						employee_attendance.approved_overtime_hours 	= 0.0
						employee_attendance.approved_overtime_minutes = 0.0
					else
						time_in_clock = params[:employee_attendance_list][index.to_s][:approved_earned_overtime_hours].to_datetime.strftime("%H:%M:%S")
						total_seconds = time_in_clock.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b}
						if employee_attendance.actual_overtime_hours >= 24 and time_in_clock.split(':').first.to_i <= 4
							employee_attendance.approved_overtime_hours 	= employee_attendance.actual_overtime_hours
							employee_attendance.approved_overtime_minutes = employee_attendance.actual_overtime_minutes
						else
							employee_attendance.approved_overtime_hours 	= (total_seconds.to_f/3600.0).round(2)
							employee_attendance.approved_overtime_minutes = (total_seconds.to_f/60.0)
						end
					end
					employee_attendance.approved_overtime = employee_attendance.approved_overtime_hours
					employee_attendance.is_ot_approved 		= true
					employee_attendance.over_strength = params[:over_strength] == "true" ? true : false
					employee_attendance.in_strength = params[:in_strength] == "true" ? true : false
					employee_attendance.gazetted = params[:gazetted] == "true" ? true : false
					unless employee_attendance.save
						ot_error_msg[0] = employee_attendance.errors.full_messages
						ot_error_msg << employee_attendance.attendance_date.strftime('%d-%b')
					end
				end
			end
		end
		if ot_error_msg.present?
			render json: {errors: ot_error_msg}, status: :unprocessable_entity
		else
			render json: {}, status: 204
		end
	end

	def reverse_bulk_approved_overtime
		if params[:employee_attendance_list].present?
			employee_attendance_list = params[:employee_attendance_list]
			Array.new(employee_attendance_list.count).each_index do |index|
				employee_attendance = EmployeeAttendance.find(employee_attendance_list[index.to_s][:employee_attendance_id])
				if employee_attendance.is_ot_approved == true
					employee_attendance.is_ot_approved 		= false
					employee_attendance.approved_overtime = 0.0
					employee_attendance.over_time_hours 	= 0.0
					employee_attendance.over_time_minutes = 0.0
					employee_attendance.over_time_seconds = 0.0
					employee_attendance.over_strength = false if employee_attendance.over_strength == true
					employee_attendance.in_strength = false if employee_attendance.in_strength == true
					employee_attendance.gazetted = false if employee_attendance.gazetted == true
					employee_attendance.save
				end
			end
		end
		render json: {}, status: 204
	end

	def download_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["employee_code", "attendance_date"]
      csv << ["1251", "11/22/18 1:50 PM"]
      csv << ["1251", "11/22/18 1:53 PM"]
      csv << ["1251", "11/22/18 1:53 PM"]
      csv << ["1251", "11/22/18 1:55 PM"]
    end
		render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import_attendance
  	response_messages = []
    file = params[:file]
    attendance_data = SmarterCSV.process(file.tempfile)
    attendance_data.each_with_index do |attendance_detail,index|
      remarks = []
      employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
      if not employee.nil?
      	company = employee.company
      	if not company.nil?
      		if attendance_detail[:attendance_date].present?
      			if employee.joining_date.to_date <= attendance_detail[:attendance_date].to_date
		      		attendance_log = AttendanceMachineLog.new
				      attendance_log.employee_code 					= employee.employee_code
							attendance_log.machine_name 					= "Manual"
							attendance_log.attendance_datetime 		= attendance_detail[:attendance_date].to_datetime
							attendance_log.attendance_date 				= attendance_detail[:attendance_date].to_date
							attendance_log.actual_attendance_date = attendance_detail[:attendance_date]
							attendance_log.formatted_hour 				= attendance_detail[:attendance_date].to_datetime.hour
							attendance_log.formatted_minute 			= attendance_detail[:attendance_date].to_datetime.minute
							attendance_log.formatted_second 			= attendance_detail[:attendance_date].to_datetime.second
							attendance_log.log_id 								= "9999999999"
							attendance_log.employee_full_name 		= employee.full_name
							attendance_log.employee_id 						= employee.id
							attendance_log.company_id 						= employee.company_id
				    	attendance_log.save
				    	remarks << "Attendance Log Created"
				    else
				    	remarks << "Attendance Not Updated bcoz of joining date"
				    end
			    else
			    	remarks << "Attendance Log Not Present"
			    end
      	else
      		remarks << "Company Not Found"
      	end
      else
      	remarks << "Employee Not Found"
      end
      temp_obj = {
        employee_code: attendance_detail[:employee_code],
        remarks: remarks.join(',')
      }
      response_messages << temp_obj
    end
    render json:{:response_messages => response_messages}, status: 200
  end

  def download_second_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["employee_code", "attendance_date", "in_time", "out_time"]
      csv << ["1020", "09/02/2019", "10:23:02", "16:52:37"]
      csv << ["1020", "11/02/2019", "10:50:35", "19:33:05"]
      csv << ["1020", "12/02/2019", "10:00:02", "17:26:31"]
      csv << ["1020", "14/02/2019", "10:01:35", "17:57:05"]
      csv << ["1020", "15/02/2019", "10:08:17", "18:02:22"]
      csv << ["1232", "09/02/2019", "10:03:15", "16:09:23"]
      csv << ["1232", "11/02/2019", "10:32:45", "20:24:48"]
      csv << ["1232", "12/02/2019", "9:57:13", "18:49:18"]
      csv << ["1232", "13/02/2019", "9:49:06", "15:52:40"]
      csv << ["1232", "14/02/2019", "19:32:33", ""]
      csv << ["1232", "15/02/2019", "10:08:36", "18:35:23"]
      csv << ["654", "09/02/2019", "9:43:14", ""]
      csv << ["654", "11/02/2019", "10:51:24", "10:53:36"]
      csv << ["654", "12/02/2019", "10:02:40", "19:58:34"]
      csv << ["654", "13/02/2019", "9:29:25", "22:32:13"]
      csv << ["654", "14/02/2019", "10:06:08", "19:32:57"]
      csv << ["654", "15/02/2019", "8:28:03", "17:55:14"]
    end
		render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import_second_attendance
  	response_messages = []
    file = params[:file]
    attendance_data = SmarterCSV.process(file.tempfile)
    attendance_data.each_with_index do |attendance_detail,index|
      remarks = []
      employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
      if not employee.nil?
      	company = employee.company
      	if not company.nil?
      		if employee.joining_date.to_date <= attendance_detail[:attendance_date].to_date
	      		attendance1_time = "#{attendance_detail[:attendance_date]} #{attendance_detail[:in_time]}"
	      		attendance_log = AttendanceMachineLog.new
			      attendance_log.employee_code 					= employee.employee_code
						attendance_log.machine_name 					= "Manual"
						attendance_log.attendance_datetime 		= attendance1_time.to_datetime
						attendance_log.attendance_date 				= attendance1_time.to_date
						attendance_log.actual_attendance_date = attendance1_time
						attendance_log.formatted_hour 				= attendance1_time.to_datetime.hour
						attendance_log.formatted_minute 			= attendance1_time.to_datetime.minute
						attendance_log.formatted_second 			= attendance1_time.to_datetime.second
						attendance_log.log_id 								= "9999999999"
						attendance_log.employee_full_name 		= employee.full_name
						attendance_log.employee_id 						= employee.id
						attendance_log.company_id 						= employee.company_id
			    	attendance_log.save
			    	if attendance_detail[:out_time].present?
			    		attendance2_time = "#{attendance_detail[:attendance_date]} #{attendance_detail[:out_time]}"
							attendance_log = AttendanceMachineLog.new
							attendance_log.employee_code = employee.employee_code
							attendance_log.machine_name = "Manual"
							attendance_log.attendance_datetime = attendance2_time.to_datetime
							attendance_log.attendance_date = attendance2_time.to_date
							attendance_log.actual_attendance_date = attendance2_time
							attendance_log.formatted_hour = attendance2_time.to_datetime.hour
							attendance_log.formatted_minute = attendance2_time.to_datetime.minute
							attendance_log.formatted_second = attendance2_time.to_datetime.second
							attendance_log.log_id = "9999999999"
							attendance_log.employee_full_name = employee.full_name
							attendance_log.employee_id = employee.id
							attendance_log.company_id = employee.company_id
							attendance_log.save
						end
			    	remarks << "Attendance Log Created"
			    else
			    	remarks << "Attendance Not Updated bcoz of joining date"
			    end
      	else
      		remarks << "Company Not Found"
      	end
      else
      	remarks << "Employee Not Found"
      end
      temp_obj = {
        employee_code: attendance_detail[:employee_code],
        remarks: remarks.join(',')
      }
      response_messages << temp_obj
    end
    render json:{:response_messages => response_messages}, status: 200
  end

	private

	def leverage_minute_policy
		@minute_policy = SystemSetting.find_by(:company_id => @employee_attendances.last.try(:company_id)).try(:leverage_minutes)
		@minute_policy = (mill_instance? && @employee_attendances.last && @employee_attendances.last.grade_id == 4) if mill_instance?
	end

	def filter_employee_attendance_data_on_request
		if params[:location_id].to_i != 0
			@employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
		end
		if params[:branch_id].to_i != 0
			@employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
		end
	end

	def delete_pdf_reports
    files = Dir.glob(File.join("#{Rails.public_path}/pdf", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end

