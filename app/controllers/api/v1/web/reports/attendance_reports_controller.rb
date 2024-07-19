class Api::V1::Web::Reports::AttendanceReportsController < ApplicationController

	def attendance_summary
		@company = Company.find (params[:company_id])
		if params[:employee_type_id].to_i == 7 and params[:report_type].to_i == 4
				time = Time.now83004766
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/attendance_reports/piecerate_machine_utilization_report", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 340,
					disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'A3'
				)
				file_name = "attendance_summary"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
		elsif params[:employee_type_id].to_i == 7 and params[:report_type].to_i == 5
			if params[:employee_status].present?
				if params[:employee_status] == "active"
					is_active = true
				else
					is_active = false
				end
			else
				is_active = [true, false]
			end
			if params[:department_id].present?
				@employees = Employee.where(:employee_type_id => 7, :department_id => params[:department_id],:is_active =>is_active)
				@department_name = Department.find(params[:department_id].to_i).name
			else
				@employees = Employee.where(:employee_type_id => 7, :is_active =>is_active)
			end
			@date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
					time = Time.now
					url_path = ""
					check_directory("#{Rails.public_path}/pdf")
					pdf = WickedPdf.new.pdf_from_string(
						render_to_string("api/v1/web/reports/attendance_reports/piecerate_attendance_summary", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
						footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
						:margin => {
							:top      => '0.1in',
							:bottom   => '0.1in',
							:left     => '0.1in',
							:right    => '0.1in'
						},
						dpi: 340,
						disable_smart_shrinking: true,
						orientation: 'Landscape',
						page_size:'A3'
					)
					file_name = "attendance_summary"
					url_path = save_pdf_file(pdf, file_name)

					render json: {message: "Pdf Created", path: url_path}
		elsif params[:employee_type_id].to_i == 7 or params[:employee_type_id].to_i == 9 or params[:employee_type_id].to_i == 8 and params[:report_type].to_i == 6
			if params[:employee_status].present?
				if params[:employee_status] == "active"
					is_active = true
				else
					is_active = false
				end
			else
				is_active = [true, false]
			end
			if params[:employee_type_id].to_i == 7
				@employees = Employee.where(:employee_type_id => 7,:is_active =>is_active)
			elsif params[:employee_type_id].to_i == 9
				@employees = Employee.where(:employee_type_id => 9,:is_active =>is_active)
			elsif params[:employee_type_id].to_i == 8
				@employees = Employee.where(:employee_type_id => 8,:is_active =>is_active)
			end
			if params[:department_id].present?
				@employees = @employees.where(:department_id => params[:department_id],:is_active =>is_active)
				@department_name = Department.find(params[:department_id].to_i).name
			else
				@employees = @employees.where(:is_active =>is_active)
			end
			@date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
			@date_range2 = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date.strftime("%d %b")}
			time = Time.now
			book = Axlsx::Package.new
			check_directory("#{Rails.public_path}/excel")
			wb = book.workbook
			sheet = wb.add_worksheet(name: 'Employee Attendance Summary')
			book.use_autowidth = false
			sheet.sheet_view do |view|
				view.show_outline_symbols = true
			end
			book.use_autowidth = true

			cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
			sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
			sheet.add_row ['']
			sheet.add_row ['']
			sheet.add_row ['']
			sheet.add_row ['']

			header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
			bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
			sheet.add_row ["Sr #", "Emp Code", "Name", "Employee Type", "Status", "Date of Joining", "Father Name", 'Designation'] + @date_range2 + ["Total Days", "Total Working Hours"], :style => header_style
			old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
			even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
			count = 0

			@employees.each do |employee|
				count = count + 1
				row_format = old_row_format

				if count.even? == true
					row_format = even_row_format
				else
					row_format = old_row_format
				end

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << count
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << employee.employee_code
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.full_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.employee_type.name
				current_row_style << row_format
				current_row_type << :string

				if employee.is_active == true
					current_row_value << "Active"
				else
					current_row_value << "In-Active"
				end
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.joining_date.to_date.strftime("%b %d, %Y")
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.father_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.designation.name
				current_row_style << row_format
				current_row_type << :string

				@date_range.each do |date|
					emp_attendance = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => date.to_date).last
					if emp_attendance.present?
						if emp_attendance.in_time.present? and emp_attendance.in_time.present? and not emp_attendance.in_time.nil? and not emp_attendance.out_time.nil?
                working_hours = TimeDifference.between(emp_attendance.in_time, emp_attendance.out_time).in_hours

								current_row_value << Time.at(working_hours * 60 * 60).utc.strftime("%H:%M")
								current_row_style << row_format
								current_row_type << :string
						else
								current_row_value << "-"
								current_row_style << row_format
								current_row_type << :string
						end
					else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
					end
				end

				employee_total_month_attnd = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => @date_range).count.to_f
				holiday = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => @date_range, :attendance_status => "Public Holiday").count.to_f
				total_deductions = 0.0
				@date_range.each do |date|
					emp_atnd = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => date).last
					if emp_atnd.present?
						if emp_atnd.checkout_deduction.present?
							checkout = emp_atnd.checkout_deduction
						else
							checkout = 0.0
						end
						if emp_atnd.checkin_deduction.present?
							checkin = emp_atnd.checkin_deduction
						else
							checkin = 0.0
						end
						decution = (checkin.to_f + checkout.to_f).round(2)
						if decution > 1
							total_deductions = total_deductions + 1
						else
							total_deductions = total_deductions + decution
						end
					end
				end
				employee_total_month_attnd = employee_total_month_attnd - total_deductions - holiday

				current_row_value << employee_total_month_attnd
				current_row_style << row_format
				current_row_type << :string

				total_working_hours = 0.0
				@date_range.each do |date|
					emp_attendance = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => date.to_date).last
					if emp_attendance.present?
						if emp_attendance.in_time.present? and emp_attendance.in_time.present? and not emp_attendance.in_time.nil? and not emp_attendance.out_time.nil?
							working_hours = TimeDifference.between(emp_attendance.in_time, emp_attendance.out_time).in_hours
							total_working_hours = total_working_hours + (working_hours * 60 * 60)
						end
					end
				end

				current_row_value << ReportFormat.overtime_value_into_overtime_hours(total_working_hours)
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
			end
			file_name = "employee_attendance_report"
			url_path = save_excel_file(book, file_name)
			render json: {message: "Excel Created", path: url_path}
		else
			@show_salary 		= User.show_salary(current_user)
			date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
			@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
			@location_name = ""
			@branch_name = ""
			@department_name = ""
			@grade_name = ""
			@salary_unit_name = ""

			#################### Hierarchical Permission ####################
			if current_user.is_location_head == true
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
			#################### Hierarchical Permission ####################

			if not params[:location_id].blank?
				@location_name = Location.find(params[:location_id]).name
				@employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
			end
			if not params[:branch_id].blank?
				@branch_name = Branch.find(params[:branch_id]).name
				@employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
			end
			if not params[:department_id].blank?
				@department_name = Department.find(params[:department_id]).name
				@employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
			end
			if not params[:sub_department_id].blank?
				@employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
			end
			if not params[:designation_id].blank?
				@employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
			end
			if not params[:job_title_id].blank?
				@employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
			end
			if not params[:grade_id].blank?
				@employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
			end
			if not params[:salary_unit_id].blank?
				@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
				@employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
			end
			if not params[:cost_center_id].blank?
				@employee_attendances = EmployeeAttendance.cost_center_related_employee_attendance(@employee_attendances, params[:cost_center_id].to_i)
			end
			if @employee_attendances.count > 0
				department_ids = @employee_attendances.collect(&:department_id)
				@departments = Department.where(:id => department_ids).order('id ASC')
				if params[:report_type].to_i == 1
					render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_summary'
				elsif params[:report_type].to_i == 2
					time = Time.now
					url_path = ""
					check_directory("#{Rails.public_path}/pdf")
					pdf = WickedPdf.new.pdf_from_string(
						render_to_string("api/v1/web/reports/attendance_reports/attendance_summary", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
						footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
						:margin => {
							:top      => '0.1in',
							:bottom   => '0.1in',
							:left     => '0.1in',
							:right    => '0.1in'
						},
						dpi: 340,
						disable_smart_shrinking: true,
						orientation: 'Landscape',
						page_size:'A3'
					)
					file_name = "attendance_summary"
					url_path = save_pdf_file(pdf, file_name)

					render json: {message: "Pdf Created", path: url_path}
				elsif params[:report_type].to_i == 3
					time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Attendance Summary')
					book.use_autowidth = false
					sheet.sheet_view do |view|
						view.show_outline_symbols = true
					end
					book.use_autowidth = true

					header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					row_count = 0

					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << "Attendance Cutoff Date: #{params[:start_date].to_date.strftime('%d-%b-%Y')} - #{params[:end_date].to_date.strftime('%d-%b-%Y')}"
					current_row_style << bold_column_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					sheet.merge_cells Axlsx::cell_r(0,row_count) + ':' + Axlsx::cell_r(20,row_count)
					row_count = row_count + 1

					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << ""
					current_row_style << old_row_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					sheet.merge_cells Axlsx::cell_r(0,row_count) + ':' + Axlsx::cell_r(20,row_count)
					row_count = row_count + 1

					leave_type_ids = LeaveType.where(:short_name => ["CPL"]).collect(&:id)

					@departments.each do |department|
						current_row_value = []
						current_row_style = []
						current_row_type = []

						current_row_value << department.name
						current_row_style << bold_column_format
						current_row_type << :string

						sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						sheet.merge_cells Axlsx::cell_r(0,row_count) + ':' + Axlsx::cell_r(20,row_count)
						row_count = row_count + 1

						sheet.add_row ["Sr #", "EMP. ID", "EMPLOYEE NAME", "LOCATION", "BRANCH", "SALARY UNIT", "GRADE", "DESIGNATION", "MONTH DAYS", "LATE", "HALF DAY", "ABSENTS", "CPL AVAILED", "LEAVE AVAILED", "LEAVE DEDUCT", "DEDUCTION", "ARREAR", "OVER TIME", "OFF DAY", "CPL EARNED", "WORKED DAYS","TOTAL PAY DAYS"], :style => header_style
						row_count = row_count + 1

						count = 0
						if params[:employee_status] == "active"
							is_active = true
						else
							is_active = false
						end
						depatment_wise_attendances = @employee_attendances.where(:department_id => department.id).order('employee_code ASC')
						employee_codes = depatment_wise_attendances.collect(&:employee_code).uniq.map(&:to_i).sort
						employee_codes.each do |employee_code|
							employee = Employee.find_by_employee_code(employee_code)
							if not employee.nil?
								if employee.is_active == is_active && employee.salary_exempted == false && employee.excluded_from_reports == false
								count = count + 1
								row_format = old_row_format

								current_row_value = []
								current_row_style = []
								current_row_type = []

								current_row_value << count
								current_row_style << row_format
								current_row_type << :integer

								current_row_value << employee.employee_code.to_s
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee.full_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee.location_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee.branch_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee.salary_unit_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee.grade_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee.designation_name
								current_row_style << row_format
								current_row_type << :string

								if params[:as_on_month] == 'false'
									if not employee.joining_date.nil?
										if employee.joining_date.to_date <= params[:start_date].to_date
											start_date  = params[:start_date].to_date
											date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
											date_range = date_range.count
										else
											end_date = params[:end_date].to_date
											date_range = (employee.joining_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
											date_range = date_range.count
										end
									else
										start_date  = params[:start_date].to_date
										date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
										date_range = date_range.count
									end
								else
									if not employee.joining_date.nil?
										if employee.joining_date.to_date <= params[:start_date].to_date
											date_range = params[:end_date].to_date.end_of_month.day.to_f
										else
											if employee.joining_date.to_date <= (params[:start_date].to_date).to_date
												date_range = params[:end_date].to_date.end_of_month.day.to_f
											else
												date_range = (TimeDifference.between(employee.joining_date.to_date, params[:end_date].to_date.end_of_month).in_days) + 1
											end
										end
									else
										date_range = 0
									end
								end

								arrear_days           = EmployeeArrear.where(:employee_id => employee.id).where("arrears_month >= ? AND arrears_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:arrear_days).to_f.round(2)
								deduction_days        = EmployeeDeduction.where(:employee_id => employee.id).where("deductions_month >= ? AND deductions_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:deduction_days).to_f.round(2)
								pay_deduction         = depatment_wise_attendances.where(:employee_id => employee.id, :deduction_from_salary => true).sum(:pay_deduction)
								pay_deduction 				= pay_deduction + deduction_days
								working_days          = date_range - pay_deduction.to_f.round(2)

								current_row_value << date_range
								current_row_style << row_format
								current_row_type << :float

								current_row_value << depatment_wise_attendances.where(:attendance_status => "Late", :employee_id => employee.id).count
								current_row_style << row_format
								current_row_type << :float

								current_row_value << depatment_wise_attendances.where(:attendance_status => "Half Day", :employee_id => employee.id).count
								current_row_style << row_format
								current_row_type << :float

								current_row_value << depatment_wise_attendances.where(:attendance_status => "Absent", :employee_id => employee.id).count
								current_row_style << row_format
								current_row_type << :float

								current_row_value << LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "Availed", :employee_id => employee.id, :leave_type_id => leave_type_ids).sum(:request_count)
								current_row_style << row_format
								current_row_type << :float

								current_row_value << LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "Availed", :employee_id => employee.id).sum(:request_count)
								current_row_style << row_format
								current_row_type << :float

								current_row_value << LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "System Deducted", :employee_id => employee.id).sum(:request_count).round(2)
								current_row_style << row_format
								current_row_type << :float

								current_row_value << pay_deduction
								current_row_style << row_format
								current_row_type << :float

								current_row_value << arrear_days
								current_row_style << row_format
								current_row_type << :float

								if employee.approval_base_overtime == true
									current_row_value << depatment_wise_attendances.where(:employee_id => employee.id).sum(:approved_overtime)
									current_row_style << row_format
									current_row_type << :float
								else
									current_row_value << depatment_wise_attendances.where(:employee_id => employee.id).sum(:over_time_hours)
									current_row_style << row_format
									current_row_type << :float
								end

								current_row_value << depatment_wise_attendances.where(:employee_id => employee.id).sum(:off_days_payment_days)
								current_row_style << row_format
								current_row_type << :float

								current_row_value << depatment_wise_attendances.where(:employee_id => employee.id).sum(:no_of_cpl)
								current_row_style << row_format
								current_row_type << :float

								current_row_value << working_days.to_f.round(2)
								current_row_style << row_format
								current_row_type << :float


								current_row_value << (working_days.to_f.round(2) + depatment_wise_attendances.where(:employee_id => employee.id).sum("off_days_payment_days")).round(2) + arrear_days.to_f.round(2)
								current_row_style << row_format
								current_row_type << :float

								sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
								row_count = row_count + 1
							end
						end
						end
						end

					file_name = "attendance_summary"
					url_path = save_excel_file(book, file_name)
					render json: {message: "Excel Created", path: url_path}
				end
			else
				render json: {errors: "No Record Found"}, status: :unprocessable_entity
			end
		end




	end

	def attendance_summary_detail
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
		@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
    
    if params[:grade_ids].blank?
      grade_ids = []
    else
      grade_ids = params[:grade_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)    
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
	      @employees = Employee.multiple_branch_data(@employees, current_user)
	      @employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
	    elsif current_user.multi_branch_allowed == true
		  	@employees = Employee.multiple_branch_data([], current_user)
	    	@employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
		  end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
	    @employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    end
    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
    end
    if not params[:sub_department_id].blank?
      @employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
    end
    
    if grade_ids.count > 0
      @employee_attendances = EmployeeAttendance.multi_grade_related_employee_attendance(@employee_attendances, grade_ids)
    end

    # if not params[:grade_id].blank?
    #   @employee_attendances = EmployeeAttendance.multi_grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    # end

    if not params[:salary_unit_id].blank?
      @employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employee_attendances = EmployeeAttendance.cost_center_related_employee_attendance(@employee_attendances, params[:cost_center_id].to_i)
    end

	  if @employee_attendances.count > 0
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_summary_detail'
	    elsif params[:report_type].to_i == 2
	    	time = Time.now
	      url_path = ""
	      check_directory("#{Rails.public_path}/pdf")
	      pdf = WickedPdf.new.pdf_from_string(
	        render_to_string("api/v1/web/reports/attendance_reports/attendance_summary_detail", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
	        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
	        :margin => {
		        :top      => '0.1in',
		        :bottom   => '0.1in',
		        :left     => '0.1in',
		        :right    => '0.1in'
		      },
		      dpi: 340,
		      disable_smart_shrinking: true,
		      orientation: 'Landscape',
		      page_size:'A3'
	      )
				file_name = "attendance_summary"
				url_path = save_pdf_file(pdf, file_name)
	      
	      render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 4
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/attendance_reports/dept_daily_attendance", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 340,
					disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'A3'
				)
				file_name = "dept_daily_attendance"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
	    elsif params[:report_type].to_i == 3
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Attendance Summary')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true

				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})

				if srl_instance?
				sheet.add_row ["Sr #", "EMP. ID", "EMPLOYEE NAME", "LOCATION", "BRANCH","DEPARTMENT","GRADE", "DESIGNATION","GROSS SALARY","MONTH DAYS", "LATE", "HALF DAY", "EARLY GONE", "ABSENTS", "LEAVE AVAILED", "LEAVE DEDUCT", "DEDUCTION", "ARREAR", "OVER TIME", "OFF DAY", "CPL EARNED", "ENCASHABLE QUOTA", "LEAVE AWAITED", "OD AWAITED", "WORKED DAYS","NORMAL DAYS","NORMAL DAYS OT","REST DAYS","REST DAYS OT", "TOTAL PAY DAYS"], :style => header_style
				else
					sheet.add_row ["Sr #", "EMP. ID", "EMPLOYEE NAME", "LOCATION", "BRANCH","DEPARTMENT","GRADE", "DESIGNATION","GROSS SALARY","MONTH DAYS", "LATE", "HALF DAY", "EARLY GONE", "ABSENTS", "LEAVE AVAILED", "LEAVE DEDUCT", "DEDUCTION", "ARREAR", "OVER TIME", "OFF DAY", "CPL EARNED", "ENCASHABLE QUOTA", "LEAVE AWAITED", "OD AWAITED", "WORKED DAYS", "TOTAL PAY DAYS"], :style => header_style
				end
					count = 0
        employee_codes = @employee_attendances.collect(&:employee_code).uniq.map(&:to_i).sort
				employee_codes.each do |employee_code|

					if params[:is_active] == "Active"
						is_active = true
					else params[:is_active] == "Archive"
						is_active = false
					end

          employee = Employee.find_by_employee_code(employee_code)
          if employee.is_active == is_active && employee.salary_exempted == false && employee.excluded_from_reports == false
	          count = count + 1
						row_format = old_row_format	
						
						current_row_value = []
						current_row_style = []
						current_row_type = []

						current_row_value << count
						current_row_style << row_format
						current_row_type << :integer

						current_row_value << employee.employee_code.to_i
						current_row_style << row_format
						current_row_type << :integer

						current_row_value << employee.full_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.location_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.branch_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.department_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.grade_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.designation_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.gross_salary
						current_row_style << row_format
						current_row_type << :string

	          if params[:as_on_month] == 'false'
	            if not employee.joining_date.nil?
	              if employee.joining_date.to_date <= params[:start_date].to_date
	                start_date  = params[:start_date].to_date
	                date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
	                date_range = date_range.count
	              else
	                end_date = params[:end_date].to_date
	                date_range = (employee.joining_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
	                date_range = date_range.count
	              end
	            else
	              start_date  = params[:start_date].to_date
	              date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
	              date_range = date_range.count
	            end
	          else
	            if not employee.joining_date.nil?
	              if employee.joining_date.to_date <= params[:start_date].to_date
	                date_range = params[:end_date].to_date.end_of_month.day.to_f
	              else
	                if employee.joining_date.to_date <= (params[:start_date].to_date).to_date
	                  date_range = params[:end_date].to_date.end_of_month.day.to_f
	                else
	                  date_range = (TimeDifference.between(employee.joining_date.to_date, params[:end_date].to_date.end_of_month).in_days) + 1  
	                end
	              end
	            else
	              date_range = 0
	            end
	          end

	          arrear_days           = EmployeeArrear.where(:employee_id => employee.id).where("arrears_month >= ? AND arrears_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:arrear_days).to_f.round(2)
	          deduction_days        = EmployeeDeduction.where(:employee_id => employee.id).where("deductions_month >= ? AND deductions_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:deduction_days).to_f.round(2)
	          pay_deduction         = @employee_attendances.where(:employee_id => employee.id, :deduction_from_salary => true).sum(:pay_deduction)
	          pay_deduction 				= pay_deduction + deduction_days
	          working_days          = date_range - pay_deduction.to_f.round(2)
	          
	          current_row_value << date_range
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << @employee_attendances.where(:attendance_status => "Late", :employee_id => employee.id).count
	          current_row_style << row_format
						current_row_type << :float

	          # current_row_value << @employee_attendances.where(:attendance_status => "Half Day", :employee_id => employee.id).count
						current_row_value << @employee_attendances.where(:early_left_status => "Half Day", :employee_id => employee.id).count + @employee_attendances.where(:attendance_status => "Half Day", :employee_id => employee.id).count
	          current_row_style << row_format
						current_row_type << :float

						current_row_value << @employee_attendances.where(:early_left_status => "Early Gone", :employee_id => employee.id).count
						current_row_style << row_format
						current_row_type << :float

	          current_row_value << @employee_attendances.where(:attendance_status => "Absent", :employee_id => employee.id).count + @employee_attendances.where(:early_left_status => "Absent", :employee_id => employee.id).count - @employee_attendances.where(:attendance_status => "Absent", :early_left_status => "Absent", :employee_id => employee.id).count
						current_row_style << row_format
						current_row_type << :float

	          current_row_value << @employee_attendances.where(:is_on_leave => true, :employee_id => employee.id).count
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "System Deducted", :employee_id => employee.id).sum(:request_count)
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << pay_deduction
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << arrear_days
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << @employee_attendances.where(:employee_id => employee.id).sum(:over_time_hours)
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << @employee_attendances.where(:employee_id => employee.id).sum("off_days_payment_days")
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << @employee_attendances.where(:employee_id => employee.id).sum("no_of_cpl")
	          current_row_style << row_format
						current_row_type << :float

						current_row_value << @employee_attendances.where(:employee_id => employee.id).sum("encashable_quota")
	          current_row_style << row_format
						current_row_type << :float

						current_row_value << LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "Waiting For Approval", :employee_id => employee.id).sum(:request_count)
	          current_row_style << row_format
						current_row_type << :float

						current_row_value << OfficialDuty.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "Waiting For Approval", :employee_id => employee.id).count
	          current_row_style << row_format
						current_row_type << :float

	          current_row_value << working_days.to_f.round(2)
	          current_row_style << row_format
						current_row_type << :float

						if srl_instance?
						rest_day = 0
						total_over_time = 0.0
						normal_days = 0
						normal_days_ot = 0.0
						@employee_attendances.where(:employee_id => employee.id).each do |attnd|
							if attnd.attendance_status == "Rest Day" and attnd.over_time_hours > 0.0
								rest_day = rest_day + 1
								total_over_time = total_over_time + attnd.over_time_hours

							elsif (attnd.attendance_status == "Present" or attnd.attendance_status == "Late" or attnd.attendance_status == "Half Day" or attnd.attendance_status == "On Official Duty") and attnd.over_time_hours > 0.0
								normal_days = normal_days + 1
								normal_days_ot = normal_days_ot + attnd.over_time_hours
							end
						end

						current_row_value << normal_days
						current_row_style << row_format
						current_row_type << :float


						current_row_value << normal_days_ot
						current_row_style << row_format
						current_row_type << :float

						current_row_value << rest_day
						current_row_style << row_format
						current_row_type << :float

						current_row_value << total_over_time
						current_row_style << row_format
						current_row_type << :float
						end

	          current_row_value << (working_days.to_f.round(2) + @employee_attendances.where(:employee_id => employee.id).sum("off_days_payment_days")).round(2) + arrear_days.to_f.round(2)
	          current_row_style << row_format
						current_row_type << :float

						sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					end
					
        end

				file_name = "attendance_summary_detail"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    end
	   else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def attendance_detail
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
		@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
    
    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
	    @employees = Employee.multiple_branch_data(@employees, current_user)
    	@attendance_logs = AttendanceMachineLog.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@attendance_logs = AttendanceMachineLog.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@attendance_logs = AttendanceMachineLog.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@attendance_logs = AttendanceMachineLog.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@attendance_logs = AttendanceMachineLog.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
	      @employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
	    end
    end
    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
    end
    if not params[:sub_department_id].blank?
      @employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employee_attendances = EmployeeAttendance.cost_center_related_employee_attendance(@employee_attendances, params[:cost_center_id].to_i)
    end
	  if @employee_attendances.count > 0
	  	department_ids = @employee_attendances.collect(&:department_id)
	  	@departments = Department.where(:id => department_ids).order('id ASC')
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_detail'
	    elsif params[:report_type].to_i == 2
	    	time = Time.now
	      url_path = ""
	      check_directory("#{Rails.public_path}/pdf")
	      pdf = WickedPdf.new.pdf_from_string(
	        render_to_string("api/v1/web/reports/attendance_reports/attendance_detail", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
	        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
	        :margin => {
		        :top      => '0.1in',
		        :bottom   => '0.1in',
		        :left     => '0.1in',
		        :right    => '0.1in'
		      },
		      dpi: 340,
		      disable_smart_shrinking: true,
		      orientation: 'Landscape',
		      page_size:'A3'
	      )

	      file_name = "attendance_detail"
				url_path = save_pdf_file(pdf, file_name)
	      render json: {message: "Pdf Created", path: url_path}
	    elsif params[:report_type].to_i == 3
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Attendance Detail')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true

				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				row_count = 0
				@departments.each do |department|
	        current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << department.name
					current_row_style << bold_column_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					sheet.merge_cells Axlsx::cell_r(0,row_count) + ':' + Axlsx::cell_r(19,row_count)
					row_count = row_count + 1

					sheet.add_row ["SR No.", "Card No.", "Name of Employee", "Total days of the month", "Working days", "No. of Present", "No. of Absents", "No. of Lates", "No. of Half Days", "No. of Relaxation Form Applied", "No. of OD Applied", "No. of Leaves Applied"], :style => header_style
	        row_count = row_count + 1

	        count = 0
	        depatment_wise_attendances = @employee_attendances.where(:department_id => department.id).order('employee_code ASC')
	        employee_codes = depatment_wise_attendances.collect(&:employee_code).uniq.map(&:to_i).sort
					employee_codes.each do |employee_code|
            employee = Employee.find_by_employee_code(employee_code)  
            count = count + 1
						row_format = old_row_format	
						
						current_row_value = []
						current_row_style = []
						current_row_type = []

						current_row_value << count
						current_row_style << row_format
						current_row_type << :integer

						current_row_value << employee.employee_code.to_i
						current_row_style << row_format
						current_row_type << :integer

						current_row_value << employee.full_name
						current_row_style << row_format
						current_row_type << :string

            if params[:as_on_month] == 'false'
              if not employee.joining_date.nil?
                if employee.joining_date.to_date <= params[:start_date].to_date
                  start_date  = params[:start_date].to_date
                  date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
                  date_range = date_range.count
                else
                  end_date = params[:end_date].to_date
                  date_range = (employee.joining_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
                  date_range = date_range.count
                end
              else
                start_date  = params[:start_date].to_date
                date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
                date_range = date_range.count
              end
            else
              if not employee.joining_date.nil?
                if employee.joining_date.to_date <= params[:start_date].to_date
                  date_range = params[:end_date].to_date.end_of_month.day.to_f
                else
                  if employee.joining_date.to_date <= (params[:start_date].to_date).to_date
                    date_range = params[:end_date].to_date.end_of_month.day.to_f
                  else
                    date_range = (TimeDifference.between(employee.joining_date.to_date, params[:end_date].to_date.end_of_month).in_days) + 1  
                  end
                end
              else
                date_range = 0
              end
            end

            arrear_days           = EmployeeArrear.where(:employee_id => employee.id).where("arrears_month >= ? AND arrears_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:arrear_days).to_f.round(2)
            pay_deduction         = depatment_wise_attendances.where(:employee_id => employee.id, :deduction_from_salary => true).sum(:pay_deduction)
            working_days          = date_range - pay_deduction.to_f.round(2)
            
            current_row_value << date_range
            current_row_style << row_format
						current_row_type << :float

						current_row_value << arrear_days
            current_row_style << row_format
						current_row_type << :float

						current_row_value << depatment_wise_attendances.where(:attendance_status => "Present", :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

						current_row_value << depatment_wise_attendances.where(:attendance_status => "Absent", :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

						current_row_value << depatment_wise_attendances.where(:attendance_status => "Late", :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

						current_row_value << depatment_wise_attendances.where(:attendance_status => "Half Day", :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

            current_row_value << depatment_wise_attendances.where(:is_relaxation => true, :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

						current_row_value << depatment_wise_attendances.where(:is_official_duty => true, :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

						current_row_value << depatment_wise_attendances.where(:is_on_leave => true, :employee_id => employee.id).count
            current_row_style << row_format
						current_row_type << :float

						sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						row_count = row_count + 1
          end
				end

				file_name = "attendance_detail"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    end
	  else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def attendance_log
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		if params[:in_time].present? and params[:out_time].present?
			@attendance_logs 	= AttendanceMachineLog.where(:company_id => params[:company_id], :actual_attendance_date => params[:in_time].to_datetime..params[:out_time].to_datetime).order('attendance_datetime')
			@flexi_logs 			= FlexiLog.where(:company_id => params[:company_id], :actual_attendance_date => params[:in_time].to_datetime..params[:out_time].to_datetime)
		else
			@attendance_logs 	= AttendanceMachineLog.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
			@flexi_logs 			= FlexiLog.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
		end
	  @employees = Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')

		#################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = @employees.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
    	@attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.is_branch_head == true
      @employees = @employees.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
    	@attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.is_department_head == true
      @employees = @employees.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
    	@attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif current_user.all_company_department == true
      @employees = @employees.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
    	@attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)    
    elsif current_user.is_sub_department_head == true
      @employees = @employees.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
    	@attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = @employees.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
	      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
	    end
    end
    #################### Hierarchical Permission ####################
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:sub_department_id].blank?
      @employees = Employee.sub_department_related_employee(@employees, params[:sub_department_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
      @attendance_logs = @attendance_logs.where(:employee_code => @employees.collect(&:employee_code).uniq)
    end

	  if @attendance_logs.count > 0
			@attendance_logs = @attendance_logs.includes(employee: [:department, :designation, :sub_department])
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_log'
	    elsif params[:report_type].to_i == 3
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Attendance Log')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true
				
				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				sheet.add_row ["Sr #", "Emp Code", "Name", 'Designation', 'Department', 'Sub Department', 'Working Shift', "Machine Name", "Attendance Date/Time", 'Device ID'], :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@attendance_logs.each do |attendance_log|
					count = count + 1
					row_format = old_row_format	

					if count.even? == true
						row_format = even_row_format
					else
						row_format = old_row_format	
					end
					
					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << count
					current_row_style << row_format
					current_row_type << :integer

					employee = attendance_log.employee
					[attendance_log.employee_code.to_s, employee.full_name, employee.designation_name, employee.department_name, employee.sub_department_name, employee.hiring_shift].each do |column_value|
						current_row_value << column_value
						current_row_style << row_format
						current_row_type << :string
					end

					current_row_value << attendance_log.machine_name
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << attendance_log.actual_attendance_date
					current_row_style << row_format
					current_row_type << :string

					current_row_value << attendance_log.device_id
					current_row_style << row_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "attendance_log"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    elsif params[:report_type].to_i == 4
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Flexi Log')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true
				
				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				sheet.add_row ["Sr #", "Emp Code", "Name", 'Designation', 'Department', 'Sub Department', 'Working Shift', "Machine Name", "Attendance Date/Time"], :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				if params[:in_time].present? and params[:out_time].present?
					@flexi_logs = @flexi_logs.where(:employee_code => @employees.pluck(:employee_code).uniq)
					excluded = @flexi_logs.group(:employee_code).having("count(*) > 1").count.keys
					@flexi_logs = @flexi_logs.where.not(employee_code: excluded).includes(employee: [:department, :designation, :sub_department]).order('attendance_datetime')
				end
				@flexi_logs.each do |attendance_log|
					count = count + 1
					row_format = old_row_format	

					if count.even? == true
						row_format = even_row_format
					else
						row_format = old_row_format	
					end
					
					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << count
					current_row_style << row_format
					current_row_type << :integer

					employee = attendance_log.employee
					[attendance_log.employee_code.to_s, employee.full_name, employee.designation_name, employee.department_name, employee.sub_department_name, employee.hiring_shift].each do |column_value|
						current_row_value << column_value
						current_row_style << row_format
						current_row_type << :string
					end

					current_row_value << attendance_log.machine_name
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << attendance_log.actual_attendance_date
					current_row_style << row_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "flexi_log"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    end
	  else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def daily_attendance
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}

		if params[:employee_status].present?
			if params[:employee_status] == "Active"
				is_active = true
			else
				is_active = false
			end
		else
			is_active = [true, false]
		end

    if params[:employee_type_ids].blank?
      employee_type_ids = []
    else
      employee_type_ids = params[:employee_type_ids].map(&:to_i)
    end

    if params[:shift_ids].blank?
      shift_ids = []
    else
      shift_ids = params[:shift_ids].map(&:to_i)
    end

    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

		@employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
		@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    
    #################### Hierarchical Permission ####################
		if current_user.is_admin == true
      @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    elsif current_user.is_company_head == true  
      @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active).order('id DESC')
	      @employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
	    end
		end
		if params[:hiring_shift_id].present?
			@hiring_shift_name = GeneralType.find(params[:hiring_shift_id]).try(:name)
			@employees = @employees.get_by_hiring_shift(params[:hiring_shift_id])
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.pluck(:id).uniq, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC')
		end
		#################### Hierarchical Permission ####################

    if not params[:location_id].blank?
    	@location_name = Location.find(params[:location_id]).name
      @employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
    	@branch_name = Branch.find(params[:branch_id]).name
      @employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
    end
		if (@current_user.email == "syedali.imran@srl.com.pk") or (@current_user.email == "murtaza.khan@srl.com.pk")
				@employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, 73.to_i)
		else
			if not params[:department_id].blank?
				@employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
			end
		end
    if not params[:sub_department_id].blank?
      @employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
    	@grade_name = Grade.find(params[:grade_id]).name
      @employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
    	@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
    end
    
    if shift_ids.count > 0
      @employee_attendances = @employee_attendances.where(:time_slot_id => shift_ids).order('id DESC')
    end

    if employee_type_ids.count > 0
      @employees = @employees.where(:employee_type_id => employee_type_ids).order('id DESC')
      @employee_attendances = @employee_attendances.where(:employee_id => @employees.collect(&:id).uniq)
    end
    
    if params[:empty_logs] == "true"
    	@employee_attendances = @employee_attendances.where.not(:in_time => nil, :out_time => nil)
    end
		@employees = @employees.where(excluded_from_reports: false) if @employees.exists?
		@employee_attendances = @employee_attendances.where(:employee_id => @employees.ids) if @employee_attendances.exists?

		if @employee_attendances.exists?
	    if params[:report_view] == "Absent Only"
	    	@employee_absent_attendances = @employee_attendances.where(:attendance_status => ['Absent'])
	    	if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_absent_only'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_absent_only", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )

					file_name = "daily_attendance_absent_only"
					url_path = save_pdf_file(pdf, file_name)
		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Absent Only')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation","Job Title", "Employee Type", "Date", "Shift", "Rest Day", "Shift Timing", "Status"], :style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_absent_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_absent_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.employee_roster.time_slot_name
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.is_rest_day == true
							  current_row_value << employee_attendance.attendance_date.to_date.strftime("%A")
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
							  current_row_style << row_format
							  current_row_type << :string
							end

							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string
							
							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end	
					file_name = "daily_attendance_absent_only"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Late Arrival"
				@employee_attendances = @employee_attendances.where(:attendance_status => ['Late', 'Short Leave', 'Full Day', 'Half Day'])
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_late_arrival'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_late_arrival", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_late_arrival"
					url_path = save_pdf_file(pdf, file_name)
		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Late Arrival')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Shift", "Shift Timing", "In Time", "Arrival Status", "Late Minutes"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string

							else
							  current_row_value << employee_attendance.employee_roster.time_slot_name
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
							  current_row_style << row_format
							  current_row_type << :string
							end
							if employee_attendance.in_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end
							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string

							current_shift_start_time = Time.new(employee_attendance.in_time.year, employee_attendance.in_time.month, employee_attendance.in_time.day, employee_attendance.employee_roster.start_time.hour)
							current_row_value << "#{TimeDifference.between(employee_attendance.in_time, current_shift_start_time).in_minutes} Minutes"
							current_row_style << row_format
							current_row_type << :string
							
							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end	
					file_name = "daily_attendance_late_arrival"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Early Gone"
				@employee_attendances = @employee_attendances.where.not(:in_time => nil, :out_time => nil)
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_early_gone'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_early_gone", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_early_gone"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Early Gone')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Shift", "Shift Timing", "In Time", "Out Time", "Worked Hours"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							if not employee_attendance.in_time.nil?
								if not employee_attendance.out_time.nil?
									served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
									if served_hours < 8
										count = count + 1
										row_format = old_row_format	

										if count.even? == true
											row_format = even_row_format
										else
											row_format = old_row_format	
										end
										
										current_row_value = []
										current_row_style = []
										current_row_type = []

										current_row_value << count
										current_row_style << row_format
										current_row_type << :integer

										current_row_value << employee_attendance.employee.employee_code
										current_row_style << row_format
										current_row_type << :string

										current_row_value << employee_attendance.employee.full_name
										current_row_style << row_format
										current_row_type << :string

										current_row_value << employee_attendance.employee.branch_name
										current_row_style << row_format
										current_row_type << :string

										current_row_value << employee_attendance.employee.grade_name
										current_row_style << row_format
										current_row_type << :string

										current_row_value << employee_attendance.employee.designation_name
										current_row_style << row_format
										current_row_type << :string

										current_row_value << employee_attendance.employee.job_title_name
										current_row_style << row_format
										current_row_type << :string

										current_row_value << employee_attendance.employee.employee_type_name
										current_row_style << row_format
										current_row_type << :string

										current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
										current_row_style << row_format
										current_row_type << :string

										if employee_attendance.employee_roster.nil?
										  current_row_value << "No Roster Assinged"
										  current_row_style << row_format
										  current_row_type << :string

										  current_row_value << "No Roster Assinged"
										  current_row_style << row_format
										  current_row_type << :string

										else
										  current_row_value << employee_attendance.employee_roster.time_slot_name
										  current_row_style << row_format
										  current_row_type << :string

										  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
										  current_row_style << row_format
										  current_row_type << :string
										end
										
										if employee_attendance.in_time.nil?
										  current_row_value << "-"
										  current_row_style << row_format
										  current_row_type << :string
										else
										  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
										  current_row_style << row_format
										  current_row_type << :string
										end

										if employee_attendance.out_time.nil?
										  current_row_value << "-"
										  current_row_style << row_format
										  current_row_type << :string
										else
										  current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
										  current_row_style << row_format
										  current_row_type << :string
										end
										
										if not employee_attendance.in_time.nil?
											if not employee_attendance.out_time.nil?
												current_row_value << Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
												current_row_style << row_format
										  	current_row_type << :string
											else
												current_row_value << "-"
												current_row_style << row_format
										  	current_row_type << :string
											end
										else
											current_row_value << "-"
											current_row_style << row_format
										  current_row_type << :string
										end
										
										sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
									end
								end
							end
						end
					end	
					file_name = "daily_attendance_early_gone"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
		  elsif params[:report_view] == "Missing Out"
				@employee_attendances = @employee_attendances.where(:out_time => nil).where.not(:in_time => nil)
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_missing_out'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_missing_out", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_missing_out"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Missing Out')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Shift", "Shift Timing", "In Time", "Out Time", "Arrival Status"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string

							else
							  current_row_value << employee_attendance.employee_roster.time_slot_name
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
							  current_row_style << row_format
							  current_row_type << :string
							end
							
							if employee_attendance.in_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.out_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string
							
							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end	
					file_name = "daily_attendance_missing_out"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "OD"
				@employee_attendances = @employee_attendances.where(:is_official_duty => true)
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_od'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_od", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_od"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance OD')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Day", "Remarks"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.attendance_date.to_date.strftime("%A")
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.remarks
							current_row_style << row_format
							current_row_type << :string

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

						end
					end	
					file_name = "daily_attendance_od"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Rest Day Only"
				@employee_attendances = @employee_attendances.where(:is_rest_day => true)
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_rest_day'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_rest_day", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_rest_day"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Rest Day')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Rest Day"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.attendance_date.to_date.strftime("%A")
							current_row_style << row_format
							current_row_type << :string

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end	
					file_name = "daily_attendance_rest_day"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Time IN Only"
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_in_time'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_in_time", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_in_time"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Time IN')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Rest Day", "Shift", "Shift Timing", "In Time"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							if not employee_attendance.in_time.nil?
								count = count + 1
								row_format = old_row_format	

								if count.even? == true
									row_format = even_row_format
								else
									row_format = old_row_format	
								end
								
								current_row_value = []
								current_row_style = []
								current_row_type = []

								current_row_value << count
								current_row_style << row_format
								current_row_type << :integer

								current_row_value << employee_attendance.employee.employee_code
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee_attendance.employee.full_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee_attendance.employee.branch_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee_attendance.employee.grade_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee_attendance.employee.designation_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee_attendance.employee.job_title_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << employee_attendance.employee.employee_type_name
								current_row_style << row_format
								current_row_type << :string

								current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
								current_row_style << row_format
								current_row_type << :string

								if employee_attendance.is_rest_day == true
								  current_row_value << employee_attendance.attendance_date.to_date.strftime("%A")
								  current_row_style << row_format
								  current_row_type << :string
								else
								  current_row_value << "-"
								  current_row_style << row_format
								  current_row_type << :string
								end
								if employee_attendance.employee_roster.nil?
								  current_row_value << "No Roster Assinged"
								  current_row_style << row_format
								  current_row_type << :string
								  
								  current_row_value << "No Roster Assinged"
								  current_row_style << row_format
								  current_row_type << :string
								else
								  current_row_value << employee_attendance.employee_roster.time_slot_name
								  current_row_style << row_format
								  current_row_type << :string
								  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
								  current_row_style << row_format
								  current_row_type << :string
								end
								if employee_attendance.in_time.nil?
								  current_row_value << "-"
								  current_row_style << row_format
								  current_row_type << :string
								else
								  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
								  current_row_style << row_format
								  current_row_type << :string
								end
								
								sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
							end
						end
					end	
					file_name = "daily_attendance_in_time"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Time OUT Only"
				if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_out_time'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_out_time", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_out_time"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance Time OUT')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Shift", "Shift Timing", "In Time", "Out Time", "Worked Hours", "Arrival Status"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.employee_roster.time_slot_name
							  current_row_style << row_format
							  current_row_type << :string
							  
							  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.in_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.out_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							if not employee_attendance.in_time.nil?
							  if not employee_attendance.out_time.nil?
							    served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							    current_row_value << Time.at(((served_hours * 60 * 60))).utc.strftime("%H:%M")
						      current_row_style << row_format
						      current_row_type << :string
							  else
							    current_row_value << "-"
							    current_row_style << row_format
							    current_row_type << :string
							  end
							else
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							end

							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string
							
							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end	
					file_name = "daily_attendance_out_time"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "In-Out Time Only"
		    if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance_in_out_time'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance_in_out_time", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance_in_out_time"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name","Branch" ,"Grade", "Designation", "Job Title", "Employee Type", "Date", "Shift", "Shift Timing", "In Time", "Out Time", "Worked Hours", "Arrival Status"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format	

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string
							  
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.employee_roster.time_slot_name
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.in_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.out_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							if not employee_attendance.in_time.nil?
							  if not employee_attendance.out_time.nil?
							    served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							    current_row_value << Time.at(((served_hours * 60 * 60))).utc.strftime("%H:%M")
						      current_row_style << row_format
						      current_row_type << :string
							  else
							    current_row_value << "-"
							    current_row_style << row_format
							    current_row_type << :string
							  end
							else
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							end

							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string
							
							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

						end
					end	
					file_name = "daily_attendance_in_out_time"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Shop ID"
		    if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					# sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      # sheet.add_row ['']
		      # sheet.add_row ['']
		      # sheet.add_row ['']
		      # sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["EmpID", "Name", "Role", "StoreID", "TimeIn", "TimeOut"],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.shop_id_name
							current_row_style << row_format
							current_row_type << :integer

							if employee_attendance.in_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << ReportFormat.twenty_four_hour_time_format(employee_attendance.in_time.to_datetime)
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.out_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << ReportFormat.twenty_four_hour_time_format(employee_attendance.out_time.to_datetime)
							  current_row_style << row_format
							  current_row_type << :string
							end
							
							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

						end
					end	
					file_name = "daily_attendance"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
			elsif params[:report_view] == "Bulk Time Card"
				@date_range = date_range
				@employees = Employee.where(:id => @employee_attendances.collect(&:employee_id).uniq, :is_active => is_active)
				time = Time.now
		    url_path = ""
		    check_directory("#{Rails.public_path}/pdf")
		    pdf = WickedPdf.new.pdf_from_string(
		      render_to_string("api/v1/web/reports/attendance_reports/bulk_time_card2", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		      footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		      :margin => {
		        :top      => '0.1in',
		        :bottom   => '0.1in',
		        :left     => '0.1in',
		        :right    => '0.1in'
		      },
		      dpi: 320,
		    )
				file_name = "bulk_time_card2"
				url_path = save_pdf_file(pdf, file_name)

		    render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_view] == "Daily Status of Payroll"
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Daily Attendance OD')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true
				
				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      
				employee_ids = @employee_attendances.collect(&:employee_id).uniq
				employees = Employee.where(:id => employee_ids).order('employee_code ASC')
				
				sheet.add_row ['Starting Employees:', employees.count]
	      sheet.add_row ['Resignations:', 0]
	      sheet.add_row ['New Hires:', 0]
	      sheet.add_row ['Current Employees:', employees.count]

	      sheet.add_row ['']
	      sheet.add_row ['']

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				sheet.add_row ["Date", "No of People", "Present", "Absent", "Leaves Availed", "Total Salary Bill", "OT Amount", "MTD", "Status"],:style => header_style
				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})

				row_format = old_row_format	

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << params[:start_date].to_date.strftime("%d %B %Y")
				current_row_style << row_format
				current_row_type << :string

				salary_employee_ids = @employee_attendances.where(:attendance_status => ["Present", "Late", "Short Leave", "Half Day"]).collect(&:employee_id).uniq
				leave_employee_ids = @employee_attendances.where(:is_on_leave => true).collect(&:employee_id).uniq

				total_employee_ids = salary_employee_ids + leave_employee_ids
				total_employee_ids = total_employee_ids.uniq
				final_employees = Employee.where(:id => total_employee_ids).order('employee_code ASC')

				current_row_value << employees.count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:attendance_status => ["Present", "Late", "Short Leave", "Half Day"]).count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:attendance_status => "Absent").count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:is_on_leave => true).count
				current_row_style << row_format
				current_row_type << :float					

				current_row_value << (final_employees.sum(:gross_salary).to_f/26.0).round(2)
				current_row_style << row_format
				current_row_type << :float

				current_row_value << 0.0
				current_row_style << row_format
				current_row_type << :float

				current_row_value << 0.0
				current_row_style << row_format
				current_row_type << :float

				current_row_value << "Open"
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				file_name = "status_of_payroll"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
			else
		    if params[:report_type].to_i == 1
		    	render status:200, template: 'api/v1/web/reports/attendance_reports/daily_attendance'
		    elsif params[:report_type].to_i == 2
		    	department_ids = @employee_attendances.collect(&:department_id)
		  		@departments = Department.where(:id => department_ids).order('name ASC')
		    	time = Time.now
		      url_path = ""
		      check_directory("#{Rails.public_path}/pdf")
		      pdf = WickedPdf.new.pdf_from_string(
		        render_to_string("api/v1/web/reports/attendance_reports/daily_attendance", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
		        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
		        :margin => {
			        :top      => '0.1in',
			        :bottom   => '0.1in',
			        :left     => '0.1in',
			        :right    => '0.1in'
			      },
			      dpi: 340,
			      disable_smart_shrinking: true,
			      orientation: 'Landscape',
			      page_size:'A3'
		      )
					file_name = "daily_attendance"
					url_path = save_pdf_file(pdf, file_name)

		      render json: {message: "Pdf Created", path: url_path}
		    elsif params[:report_type].to_i == 3
		    	time = Time.now
					book = Axlsx::Package.new
					check_directory("#{Rails.public_path}/excel")
					wb = book.workbook
					sheet = wb.add_worksheet(name: 'Daily Attendance')
					book.use_autowidth = false
					sheet.sheet_view do |view|
					  view.show_outline_symbols = true
					end
					book.use_autowidth = true
					
					cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
					sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']
		      sheet.add_row ['']

		      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
					bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
					sheet.add_row ["SR NO.", "Emp Code", "Name", "Branch","Grade", "Designation", "Job Title", "Employee Type","Employee Status", "Department", "Sub Department", "Date", "Rest Day", "Hiring Shift", "Shift", "Shift Timing", "In Time", "Out Time", "Attendance Mark", "Arrival Status", "Left Status", "Worked Hours", "Actual OT", "Approved OT", "OT Action", 'Request Status', 'Approval Authority'],:style => header_style
					old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
					count = 0
					employee_ids = @employee_attendances.collect(&:employee_id).uniq
					employees = Employee.where(:id => employee_ids).order('employee_code ASC')
					employees.each do |employee|
						employee_total_wh = 0.0
						@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
							count = count + 1
							row_format = old_row_format

							if count.even? == true
								row_format = even_row_format
							else
								row_format = old_row_format	
							end
							
							current_row_value = []
							current_row_style = []
							current_row_type = []

							current_row_value << count
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee_attendance.employee.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.job_title_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.employee_type_name
							current_row_style << row_format
							current_row_type << :string

							if params[:employee_status].present?
								if params[:employee_status] == "active"
									is_active = true
								else
									is_active = false
								end
							else
								is_active = [true, false]
							end

							current_row_value << is_active
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.department_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.sub_department_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.rest_day_name(employee_attendance)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.employee.hiring_shift
							current_row_style << row_format
							current_row_type << :string

							if employee_attendance.employee_roster.nil?
							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << "No Roster Assinged"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << ReportFormat.shift_name(employee_attendance)
							  current_row_style << row_format
							  current_row_type << :string

							  current_row_value << ReportFormat.shift_timing(employee_attendance)
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.in_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end
							
							if employee_attendance.out_time.nil?
							  current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							else
							  current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
							  current_row_style << row_format
							  current_row_type << :string
							end

							if employee_attendance.mark_as_manual == true
								current_row_value << "Manual"
								current_row_style << row_format
								current_row_type << :string
							else
								current_row_value << "Automatic"
								current_row_style << row_format
								current_row_type << :string
							end

							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee_attendance.early_left_status
							current_row_style << row_format
							current_row_type << :string

							served_hours = 0
							if not employee_attendance.in_time.nil?
                if not employee_attendance.out_time.nil?
                  served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
                  current_row_value << Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
								  current_row_style << row_format
								  current_row_type << :string
                else
                	current_row_value << "-"
								  current_row_style << row_format
								  current_row_type << :string
                end
              else
              	current_row_value << "-"
							  current_row_style << row_format
							  current_row_type << :string
							end

							employee_total_wh = employee_total_wh + (served_hours * 60 * 60)

							if dtl_instance?
								# if not employee_attendance.out_time.nil? and not employee_attendance.in_time.nil? and employee_attendance.out_time > employee_attendance.office_out_time
								# 	if not employee_attendance.employee_roster.nil?
								# 		if not employee_attendance.employee_roster.time_slot.nil?
								# 			if employee_attendance.employee_roster.time_slot.is_flexi == true and employee_attendance.sub_time_slot_id != nil
								# 				ot = TimeDifference.between(employee_attendance.sub_time_slot.actual_end_time, employee_attendance.out_time).in_hours
								# 			else
								# 				ot = TimeDifference.between(employee_attendance.in_time.to_datetime.strftime("%d-%B-%Y ") + employee_attendance.employee_roster.formated_end_time.to_datetime.strftime("%H:%M %p"), employee_attendance.out_time).in_hours
								# 			end
								# 		else
								# 			ot = TimeDifference.between(employee_attendance.in_time.to_datetime.strftime("%d-%B-%Y ") + employee_attendance.employee_roster.formated_end_time.to_datetime.strftime("%H:%M %p"), employee_attendance.out_time).in_hours
								# 		end
								# 	else
								# 		ot = TimeDifference.between(employee_attendance.in_time.to_datetime.strftime("%d-%B-%Y ") + employee_attendance.employee_roster.formated_end_time.to_datetime.strftime("%H:%M %p"), employee_attendance.out_time).in_hours
								# 	end
								# 	if ot > 0
								# 		current_row_value << Time.at(ot * 60 * 60).utc.strftime("%H:%M")
								# 		current_row_style << row_format
								# 		current_row_type << :string
								# 	else
								# 		current_row_value << "-"
								# 		current_row_style << row_format
								# 		current_row_type << :string
								# 	end
								# else
								# 	current_row_value << "-"
								# 	current_row_style << row_format
								# 	current_row_type << :string
								# end
								# current_row_value << "-"
								# current_row_style << row_format
								# current_row_type << :string
							else
								######### Code Shift To Below End ##########
							end
							####### Above Code ########
							if employee_attendance.approval_base_overtime == false
								if employee_attendance.over_time_hours > 0
									current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
									current_row_style << row_format
									current_row_type << :string

									current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
									current_row_style << row_format
									current_row_type << :string
								else
									current_row_value << "-"
									current_row_style << row_format
									current_row_type << :string

									current_row_value << "-"
									current_row_style << row_format
									current_row_type << :string
								end
							else
								if employee_attendance.over_time_hours > 0
									current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
									current_row_style << row_format
									current_row_type << :string
								else
									current_row_value << "-"
									current_row_style << row_format
									current_row_type << :string
								end
								if employee_attendance.approved_overtime > 0
									first_value = employee_attendance.approved_overtime.to_s.split('.')[0]
									last_value 	= (employee_attendance.approved_overtime.to_s.split('.')[1].to_f/2.0).to_i
									current_row_value << "#{first_value}:#{last_value}"
									# current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.approved_overtime * 60 * 60)
									current_row_style << row_format
									current_row_type << :string
								else
									current_row_value << "-"
									current_row_style << row_format
									current_row_type << :string
								end
							end

							if employee_attendance.approval_base_overtime == false
							  if employee_attendance.over_time_hours > 0
							    current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							    current_row_style << row_format
							    current_row_type << :string

							    current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							    current_row_style << row_format
							    current_row_type << :string
							  else
							    current_row_value << "-"
							    current_row_style << row_format
							    current_row_type << :string

							    current_row_value << "-"
							    current_row_style << row_format
							    current_row_type << :string
							  end
							else
							  if employee_attendance.over_time_hours > 0
							    current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							    current_row_style << row_format
							    current_row_type << :string
							  else
							    current_row_value << "-"
							    current_row_style << row_format
							    current_row_type << :string
							  end
							  if employee_attendance.approved_overtime > 0
							  	first_value = employee_attendance.approved_overtime.to_s.split('.')[0]
									last_value 	= (employee_attendance.approved_overtime.to_s.split('.')[1].to_f/2.0).to_i
							    current_row_value << "#{first_value}:#{last_value}"
							    # current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.approved_overtime * 60 * 60)
							    current_row_style << row_format
							    current_row_type << :string
							  else
							    current_row_value << "-"
							    current_row_style << row_format
							    current_row_type << :string
							  end
							end

							current_row_value << ReportFormat.boolean_in_text(employee_attendance.is_ot_approved)
					    current_row_style << row_format
					    current_row_type << :string

              request_status = 'Request Not Applied'
              if employee.leave_requests.where(':date BETWEEN leave_requests.start_date AND leave_requests.end_date', date: employee_attendance.attendance_date).count >= 1
                request_status = 'Leave Requested'
              end
              if employee.official_duties.where(':date BETWEEN official_duties.start_date AND official_duties.end_date', date: employee_attendance.attendance_date).count >= 1
                request_status = 'OfficialDuty Requested'
              end
              if employee.relaxation_requests.where(':date BETWEEN relaxation_requests.start_date AND relaxation_requests.end_date', date: employee_attendance.attendance_date).count >= 1
                request_status = 'Relaxation Requested'
              end

							current_row_value << request_status
					    current_row_style << row_format
					    current_row_type << :string

							current_row_value << (employee.line_manager.try(:full_name) || '-')
					    current_row_style << row_format
					    current_row_type << :string

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
						# if dtl_instance?
						# 	@date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
						# 	employee_total_month_attnd = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => @date_range).count.to_f
            # holiday = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => @date_range, :attendance_status => "Public Holiday").count.to_f
            # total_deductions = 0.0
						# 	@date_range.each do |date|
            #   emp_atnd = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => date).last
            #   if emp_atnd.present?
						# 	if emp_atnd.checkout_deduction.present?
						# 		checkout = emp_atnd.checkout_deduction
						# 	else
            #       checkout = 0.0
						# 		end
						# 		if emp_atnd.checkin_deduction.present?
            #       checkin = emp_atnd.checkin_deduction
						# 				 else
            #       checkin = 0.0
						# 		end
						# 		decution = (checkin.to_f + checkout.to_f).round(2)
						# 		if decution > 1
						# 		 total_deductions = total_deductions + 1
						# 		else
            #       total_deductions = total_deductions + decution
						# 		end
						# 		end
						# 	end
						# employee_total_month_attnd = employee_total_month_attnd - total_deductions - holiday
						# 	sheet.add_row ["", "", "", "","", "", "", "", "", "", "", "", "", "", "", "", "", "", "#{employee_total_month_attnd}", "Total Working Hours", "#{ReportFormat.overtime_value_into_overtime_hours(employee_total_wh)}", "", "", "", '', ''],:style => header_style
						# end
					end	
					file_name = "daily_attendance"
					url_path = save_excel_file(book, file_name)
		      render json: {message: "Excel Created", path: url_path}
		    end
		  end
	  else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def attendance_execution_log
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
		@attendance_execution_transactions = AttendanceExecutionTransaction.where(:company_id => params[:company_id]).where("Date(execution_start_time) >= ? AND Date(execution_end_time) <= ?", params[:start_date].to_date, params[:end_date].to_date).order('id ASC')
    
    #################### Hierarchical Permission ####################
		if current_user.is_admin == true
			@attendance_execution_transactions = AttendanceExecutionTransaction.where(:company_id => params[:company_id]).where("Date(execution_start_time) >= ? AND Date(execution_end_time) <= ?", params[:start_date].to_date, params[:end_date].to_date).order('id ASC')
		elsif current_user.is_company_head == true
			@attendance_execution_transactions = AttendanceExecutionTransaction.where(:company_id => params[:company_id]).where("Date(execution_start_time) >= ? AND Date(execution_end_time) <= ?", params[:start_date].to_date, params[:end_date].to_date).order('id ASC')
		elsif current_user.is_location_head == true
      @attendance_execution_transactions = AttendanceExecutionTransaction.where(:location_id => current_user.employee.location_id).order('id DESC')
    elsif current_user.is_branch_head == true
      @attendance_execution_transactions = AttendanceExecutionTransaction.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
    elsif current_user.is_department_head == true
      @attendance_execution_transactions = AttendanceExecutionTransaction.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
    elsif current_user.all_company_department == true
      @attendance_execution_transactions = AttendanceExecutionTransaction.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')    
    end
    #################### Hierarchical Permission ####################

	  if @attendance_execution_transactions.count > 0
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_execution_log'
	    elsif params[:report_type].to_i == 3
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Execution Logs')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true
				
				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				sheet.add_row ['Sr No.','Location', 'Branch', 'Department', 'Process Start Date', 'Process End Date', 'Execution Start Date', 'Execution End Date', 'Execution Start Time', 'Execution End Time'],:style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				
				@attendance_execution_transactions.each do |attendance_execution_transaction|
					count = count + 1
					row_format = old_row_format	

					if count.even? == true
						row_format = even_row_format
					else
						row_format = old_row_format	
					end
					
					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << count
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << attendance_execution_transaction.actual_location_name
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << attendance_execution_transaction.actual_branch_name
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << attendance_execution_transaction.actual_department_name
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << ReportFormat.date_format(attendance_execution_transaction.start_date)
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << ReportFormat.date_format(attendance_execution_transaction.end_date)
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << ReportFormat.date_format(attendance_execution_transaction.execution_start_time)
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << ReportFormat.date_format(attendance_execution_transaction.execution_end_time)
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << ReportFormat.twelve_hours_time_format(attendance_execution_transaction.execution_start_time)
					current_row_style << row_format
					current_row_type << :string
					
					current_row_value << ReportFormat.twelve_hours_time_format(attendance_execution_transaction.execution_end_time)
					current_row_style << row_format
					current_row_type << :string
					
					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end	
				file_name = "attendance_execution_log"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    end
	  else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def detail_overtime
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find(params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
		@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date)
    
    #################### Hierarchical Permission ####################
		if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id)
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id)
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id)
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id)
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id)
      @employees = Employee.multiple_branch_data(@employees, current_user)
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq)
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
    #################### Hierarchical Permission ####################

		unless params[:location_id].blank?
			@employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
		end
		unless params[:branch_id].blank?
			@employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
		end
		unless params[:department_id].blank?
			@employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
		end
		unless params[:sub_department_id].blank?
			@employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
		end
		unless params[:designation_id].blank?
			@employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
		end
		unless params[:job_title_id].blank?
			@employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
		end
		unless params[:grade_id].blank?
			@employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		unless params[:salary_unit_id].blank?
			@employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
		end
		unless params[:cost_center_id].blank?
			@employee_attendances = EmployeeAttendance.cost_center_related_employee_attendance(@employee_attendances, params[:cost_center_id].to_i)
		end
		unless params[:excluded_employees].blank?
			@employee_attendances = EmployeeAttendance.exclude_employees(@employee_attendances, params[:excluded_employees] == 'true' ? true : false)
		end
		if params[:employment_status] == ''
			@employee_attendances = EmployeeAttendance.on_roll_employees(@employee_attendances, true)
			@employee_attendances = EmployeeAttendance.struck_off_employees(@employee_attendances, false)
		elsif params[:employment_status] == 'resigned'
			@employee_attendances = EmployeeAttendance.on_roll_employees(@employee_attendances, false)
		elsif params[:employment_status] == 'struck_off'
			@employee_attendances = EmployeeAttendance.struck_off_employees(@employee_attendances, true)
		end
		@employee_attendances = EmployeeAttendance.payment_method_related_attendances(@employee_attendances, params[:payment_method]) if params[:payment_method].present?
		is_mill = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
		if is_mill
			in_strength = params[:in_strength] == "true" ? true : false
			over_strength = params[:over_strength] == "true" ? true : false
			gazetted = params[:gazetted] == "true" ? true : false
			@employee_attendances = @employee_attendances.get_by_in_over_strength(in_strength, over_strength, gazetted)
		end
	  if @employee_attendances.count > 0
	  	employee_ids = @employee_attendances.collect(&:employee_id)
	  	@employees = Employee.where(:id => employee_ids)
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/detail_overtime'
	    elsif params[:report_type].to_i == 3
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Detail Overtime')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

				ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk') ? report_for_mill(sheet, wb) : normal_overtime_report(sheet, wb)
				file_name = "detail_overtime"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 2  and is_mill
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
						render_to_string("api/v1/web/reports/payroll_reports/over_time_payment_sheet", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
						footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
						:margin => {
								:top      => '0.3in',
								:bottom   => '0.3in',
								:left     => '0.3in',
								:right    => '0.3in'
						},
						dpi: 340,
						# dpi: 300,
						disable_smart_shrinking: true,
						orientation: 'Landscape',
						page_size:'A3'
				)
				file_name = "over_time_payment_sheet"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 4 and is_mill
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
						render_to_string("api/v1/web/reports/payroll_reports/over_time_check_sheet", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
						footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
						:margin => {
								:top      => '0.3in',
								:bottom   => '0.3in',
								:left     => '0.3in',
								:right    => '0.3in'
						},
						dpi: 340,
						# dpi: 300,
						disable_smart_shrinking: true,
						orientation: 'Landscape',
						page_size:'A3'
				)
				file_name = "over_time_check_sheet"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 5 and is_mill
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
						render_to_string("api/v1/web/reports/payroll_reports/over_time_summary_mill", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
						footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
						:margin => {
								:top      => '0.3in',
								:bottom   => '0.3in',
								:left     => '0.3in',
								:right    => '0.3in'
						},
						dpi: 340,
						# dpi: 300,
						disable_smart_shrinking: true,
						orientation: 'Landscape',
						page_size:'A3'
				)
				file_name = "over_time_summary_mill"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 6 and is_mill
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
						render_to_string("api/v1/web/reports/payroll_reports/over_time_summary_sub_dept_mill", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
						footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
						:margin => {
								:top      => '0.3in',
								:bottom   => '0.3in',
								:left     => '0.3in',
								:right    => '0.3in'
						},
						dpi: 340,
						# dpi: 300,
						disable_smart_shrinking: true,
						orientation: 'Landscape',
						page_size:'A3'
				)
				file_name = "over_time_summary_mill"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			end
	   else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def attendance_register
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
		@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
    
    #################### Hierarchical Permission ####################
		if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
	      @employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
	    elsif current_user.multi_branch_allowed == true
		  	@employees = Employee.multiple_branch_data([], current_user)
	    	@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
		  end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
	    @employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq)
    end
    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
    end
    if not params[:sub_department_id].blank?
      @employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employee_attendances = EmployeeAttendance.cost_center_related_employee_attendance(@employee_attendances, params[:cost_center_id].to_i)
    end
	  if @employee_attendances.count > 0
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_register'
	    elsif params[:report_type].to_i == 3
	    	date_ranges = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
	    	employee_ids = @employee_attendances.collect(&:employee_id).uniq
				employees = Employee.where(:id => employee_ids, :excluded_from_reports => false).order('employee_code ASC')
				
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Attendance Register')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true
				
				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				
				header_columns = []
				header_columns << 'Sr No.'
				header_columns << 'Emp Code.'
				header_columns << 'Name'
				header_columns << 'Grade'
				header_columns << 'Designation'
				header_columns << 'Sub Department'
				header_columns << 'Shift'
				date_ranges.each do |single_date|
					header_columns << ReportFormat.date_format2(single_date)
				end
				if mill_instance?
					header_columns << 'Work Days'
				end
				sheet.add_row header_columns, :style => header_style

				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				employees.each do |employee|
					count = count + 1
					row_format = old_row_format	

					if count.even? == true
						row_format = even_row_format
					else
						row_format = old_row_format	
					end
					
					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << count
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.employee_code
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.sub_department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.hiring_shift
					current_row_style << row_format
					current_row_type << :string

					Array.new(date_ranges.count).each_index do |index|
						employee_attendance = @employee_attendances.find_by(:employee_id => employee.id, :attendance_date => date_ranges[index].to_date)
						if not employee_attendance.nil?
							current_row_value << employee_attendance.attendance_status
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					if mill_instance?
						if employee.is_active == true
							current_row_value << 26 - @employee_attendances.where(:attendance_status => ["Absent", "Short Leave", "Half Day"], :employee_id => employee.id).count - @employee_attendances.where(:employee_id => employee.id, is_on_leave: true, is_leave_without_pay: true, roster_exist: true).count
							current_row_style << row_format
							current_row_type << :float
						else
							current_row_value << @employee_attendances.where(:employee_id => employee.id, attendance_status: ["Present", "Late", "Half Day"], roster_exist: true).count + @employee_attendances.where(:employee_id => employee.id, is_on_leave: true, is_leave_without_pay: false, roster_exist: true).count + @employee_attendances.where(:employee_id => employee.id, is_public_holiday: true, roster_exist: true, attendance_status: 'Public Holiday').count + @employee_attendances.where(:employee_id => employee.id, is_official_duty: true, roster_exist: true, attendance_status: 'On Official Duty').count + @employee_attendances.where(:employee_id => employee.id, is_cpl: true, roster_exist: true).count
							current_row_style << row_format
							current_row_type << :float
						end
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				end

				file_name = "attendance_register"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    end
	  else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	def attendance_register_detail
		@show_salary 		= User.show_salary(current_user)
		@company = Company.find (params[:company_id])
		date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
		@employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('id ASC')
    
    #################### Hierarchical Permission ####################
		if current_user.is_location_head == true
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
    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @employee_attendances = EmployeeAttendance.location_related_employee_attendance(@employee_attendances, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employee_attendances = EmployeeAttendance.branch_related_employee_attendance(@employee_attendances, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employee_attendances = EmployeeAttendance.department_related_employee_attendance(@employee_attendances, params[:department_id].to_i)
    end
    if not params[:sub_department_id].blank?
      @employee_attendances = EmployeeAttendance.sub_department_related_employee_attendance(@employee_attendances, params[:sub_department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employee_attendances = EmployeeAttendance.designation_related_employee_attendance(@employee_attendances, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employee_attendances = EmployeeAttendance.job_title_related_employee_attendance(@employee_attendances, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employee_attendances = EmployeeAttendance.grade_related_employee_attendance(@employee_attendances, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employee_attendances = EmployeeAttendance.salary_unit_related_employee_attendance(@employee_attendances, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employee_attendances = EmployeeAttendance.cost_center_related_employee_attendance(@employee_attendances, params[:cost_center_id].to_i)
    end
	  if @employee_attendances.count > 0
	    if params[:report_type].to_i == 1
	    	render status:200, template: 'api/v1/web/reports/attendance_reports/attendance_register_detail'
	    elsif params[:report_type].to_i == 3
	    	date_ranges = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
	    	employee_ids = @employee_attendances.collect(&:employee_id).uniq
				employees = Employee.where(:id => employee_ids, :excluded_from_reports => false).order('employee_code ASC')
				
	    	time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Attendance Register')
				book.use_autowidth = false
				sheet.sheet_view do |view|
				  view.show_outline_symbols = true
				end
				book.use_autowidth = true
				
				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				
				header_columns = []
				header_columns << 'Sr No.'
				header_columns << 'Emp Code.'
				header_columns << 'Name'
				header_columns << 'Grade'
				header_columns << 'Designation'
				date_ranges.each do |single_date|
					header_columns << ReportFormat.date_format2(single_date)
				end
				sheet.add_row header_columns, :style => header_style

				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				employees.each do |employee|
					if employee.is_active == true && employee.salary_exempted == false
						count = count + 1
						row_format = old_row_format	

						if count.even? == true
							row_format = even_row_format
						else
							row_format = old_row_format	
						end
						
						current_row_value = []
						current_row_style = []
						current_row_type = []

						current_row_value << count
						current_row_style << row_format
						current_row_type << :integer

						current_row_value << employee.employee_code
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.full_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.grade_name
						current_row_style << row_format
						current_row_type << :string

						current_row_value << employee.designation_name
						current_row_style << row_format
						current_row_type << :string

						Array.new(date_ranges.count).each_index do |index|
							employee_attendance = @employee_attendances.find_by(:employee_id => employee.id, :attendance_date => date_ranges[index].to_date)
							if not employee_attendance.nil?
								if employee_attendance.is_rest_day == true
									if employee_attendance.in_time.nil?
										current_row_value << employee_attendance.attendance_status		
									else
										current_row_value << "Present"
									end
								elsif employee_attendance.is_public_holiday == true
									if employee_attendance.in_time.nil?
										current_row_value << employee_attendance.attendance_status		
									else
										current_row_value << "Present"
									end
								else
									current_row_value << employee_attendance.attendance_status
								end
								current_row_style << row_format
								current_row_type << :string
							else
								current_row_value << "-"
								current_row_style << row_format
								current_row_type << :string
							end
						end
						sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					end
				end

				file_name = "attendance_register_detail"
				url_path = save_excel_file(book, file_name)
	      render json: {message: "Excel Created", path: url_path}
	    end
	  else
	   	render json: {errors: "No Record Found"}, status: :unprocessable_entity
	  end
	end

	private

  def delete_pdf_reports
    files = Dir.glob(File.join("#{Rails.public_path}/pdf", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def delete_excel_reports
  	files = Dir.glob(File.join("#{Rails.public_path}/excel", '**', '*')).select { |file| File.file?(file) }
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

	def report_for_mill(sheet, wb)
		header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
		bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
		old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
		even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})

		sheet.add_row ["Sr #", "Emp Code", "Name", "Designation", "Department", "Gross Rate", "Hours", "Worked Days", "Payable Amount", "Account No"], :style => header_style
		count = 0
		grand_overtime = 0
		total_employees = 0
		grand_gross = 0
		grand_hours = 0
		grand_worked_days = 0
		@employees.active.each do |employee|
			total_overtime_hours = 0
			total_overtime_amount = 0
			daily_salary = employee.gross_salary.to_f/TimeDifference.between(params[:start_date].to_date.beginning_of_month - 1.day,params[:end_date].to_date.end_of_month).in_days
			employee_attendances = @employee_attendances.where(:employee_id => employee.id).where("attendance_date >= ? and attendance_date <= ?", params[:start_date].to_date, params[:end_date].to_date).order('attendance_date ASC')
			employee_attendances.each do |employee_attendance|
				if params[:overtime_restriction] == "all"
					total_overtime_hours = total_overtime_hours + (employee_attendance.approved_overtime_hours)
					total_overtime_amount = total_overtime_amount + ((employee.gross_salary/26)/8) * 2 * (employee_attendance.approved_overtime_hours)
				elsif params[:overtime_restriction] == "lesser"
					if employee_attendance.approved_overtime_hours <= PayInvoice::OVERTIME_CHECK_VALUE
						total_overtime_hours = total_overtime_hours + (employee_attendance.approved_overtime_hours)
						total_overtime_amount = total_overtime_amount + ((employee.gross_salary/26)/8) * 2 * (employee_attendance.approved_overtime_hours)
					end
				elsif params[:overtime_restriction] == "greater"
					if employee_attendance.approved_overtime_hours > PayInvoice::OVERTIME_CHECK_VALUE
						total_overtime_hours = total_overtime_hours + (employee_attendance.approved_overtime_hours)
						total_overtime_amount = total_overtime_amount + ((employee.gross_salary/26)/8) * 2 * (employee_attendance.approved_overtime_hours)
					end
				end
			end
			row_format = old_row_format

			if total_overtime_hours > 0
				grand_overtime += total_overtime_amount
				total_employees += 1
				grand_gross += employee.gross_salary
				grand_hours += total_overtime_hours
				grand_worked_days += (total_overtime_hours/8)

				current_row_value = []
				current_row_style = []
				current_row_type = []
				count = count + 1

				current_row_value << count
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << employee.employee_code
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.full_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.designation_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.department_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.gross_salary
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << total_overtime_hours.round(1)
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << (total_overtime_hours/8).round(1)
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << total_overtime_amount.round
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << employee.bank_account_number
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
			end
		end
		sheet.add_row [total_employees, "", "", "", "", grand_gross, grand_hours, grand_worked_days, grand_overtime.round, ""], :style => header_style
	end

	def normal_overtime_report(sheet, wb)
		header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
		bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
		old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
		even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})

		@employees.active.each do |employee|

			total_over_time_amount = 0
			total_overtime_hours_in_seconds = 0

			sheet.add_row ["Sr #", "Emp Code", "Name", "Designation", "Job Title", "Attendance Date", "In Time", "Out Time", "Total Hrs", "OT Hrs", "Gross Salary", "OT Amount"], :style => header_style
			count = 0
			@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
				daily_salary = employee_attendance.employee.gross_salary.to_f/TimeDifference.between(params[:start_date].to_date.beginning_of_month - 1.day,params[:end_date].to_date.end_of_month).in_days
				count = count + 1
				row_format = old_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << count
				current_row_style << row_format
				current_row_type << :integer

				current_row_value << employee.employee_code
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.full_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.designation_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee.job_title_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee_attendance.attendance_date.strftime("%B %d, %Y")
				current_row_style << row_format
				current_row_type << :string

				if employee_attendance.in_time.nil?
					current_row_value << "-"
				else
					current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
				end
				current_row_style << row_format
				current_row_type << :string

				if employee_attendance.out_time.nil?
					current_row_value << "-"
				else
					current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
				end
				current_row_style << row_format
				current_row_type << :string

				if not employee_attendance.in_time.nil?
					if not employee_attendance.out_time.nil?
						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						current_row_value << Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
					else
						current_row_value << "-"
					end
				else
					current_row_value << "-"
				end
				current_row_style << row_format
				current_row_type << :string

				if params[:is_actual] == "true"
					if employee_attendance.over_time_hours > 0
						total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (employee_attendance.over_time_hours * 60 * 60)
						current_row_value << Time.at(employee_attendance.over_time_hours * 60 * 60).utc.strftime("%H:%M")
					else
						current_row_value << "-"
					end
					current_row_style << row_format
					current_row_type << :string
				else
					if employee_attendance.is_rest_day == true
						dummy_over_time_hours = ReportFormat.overtime_hours(employee_attendance.in_time, employee_attendance.out_time, 0)
						if dummy_over_time_hours > 0
							total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (dummy_over_time_hours * 60 * 60)
							current_row_value << Time.at(dummy_over_time_hours * 60 * 60).utc.strftime("%H:%M")
						else
							current_row_value << "-"
						end
					elsif employee_attendance.is_public_holiday == true
						dummy_over_time_hours = ReportFormat.overtime_hours(employee_attendance.in_time, employee_attendance.out_time, 0)
						if dummy_over_time_hours > 0
							total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (dummy_over_time_hours * 60 * 60)
							current_row_value << Time.at(dummy_over_time_hours * 60 * 60).utc.strftime("%H:%M")
						else
							current_row_value << "-"
						end
					else
						dummy_over_time_hours = ReportFormat.overtime_hours(employee_attendance.in_time, employee_attendance.out_time, params[:selected_working_hours].to_f)
						if dummy_over_time_hours > 0
							total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (dummy_over_time_hours * 60 * 60)
							current_row_value << Time.at(dummy_over_time_hours * 60 * 60).utc.strftime("%H:%M")
						else
							current_row_value << "-"
						end
					end
					current_row_style << row_format
					current_row_type << :string
				end

				if @show_salary == true
					current_row_value << employee.gross_salary.to_f.round(2)
					current_row_style << row_format
					current_row_type << :float
				else
					current_row_value << "-"
					current_row_style << row_format
					current_row_type << :string
				end

				if params[:is_actual] == "true"
					if @show_salary == true
						current_row_value << (employee_attendance.over_time_hours.to_f * (daily_salary.to_f/8.0)).round(2)
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end
					total_over_time_amount = total_over_time_amount + (employee_attendance.over_time_hours.to_f * (daily_salary.to_f/8.0))
				else
					if @show_salary == true
						current_row_value << (dummy_over_time_hours.to_f * (daily_salary.to_f/params[:selected_working_hours].to_f)).round(2)
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end
					total_over_time_amount = total_over_time_amount + (dummy_over_time_hours.to_f * (daily_salary.to_f/params[:selected_working_hours].to_f))
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
			end
			if @show_salary == true
				sheet.add_row ['','','','','','','','','',ReportFormat.overtime_value_into_overtime_hours(total_overtime_hours_in_seconds),'',total_over_time_amount], :style => [old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format ,old_row_format], :types => [:string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :string, :float]
			end
			sheet.add_row
			sheet.add_row
		end
	end
end
