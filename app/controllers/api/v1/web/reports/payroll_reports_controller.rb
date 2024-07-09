class Api::V1::Web::Reports::PayrollReportsController < ApplicationController

	def salary_register
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find (params[:pay_execution_id])
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')

		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:sub_department_id].blank?
			@pay_invoices = PayInvoice.sub_department_related_invoices(@pay_invoices, params[:sub_department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/salary_register.json.jbuilder'
			elsif params[:report_type].to_i == 3
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department", "Gross Salary"]
				table_header << "Total Pay Days"
				pay_items.each do |pay_item|
					if pay_item.name != "Attendance Deduction"
						table_header << pay_item.name
					end
				end
				table_header << "Salary Earned"
				if params[:location_id].to_s == "9"
					table_header << "Total Paydays"
				else
					table_header << "Attendance Deduction"
				end
				table_header << "Income Tax"
				table_header << "Total Earning"
				table_header << "Total Deduction"
				table_header << "Net Payable"
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@pay_invoices.each do |pay_invoice|
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

					current_row_value << pay_invoice.employee_code
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary
						current_row_style << row_format
						current_row_type << :float
						if pay_invoice.location_name == "Daily Wager" or pay_invoice.location_name == "Contract"
							month_start_date = pay_invoice.pay_month.to_date.beginning_of_month
							month_end_date = pay_invoice.pay_month.to_date.end_of_month
							total_attendance_days = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date).count
							total_rest_days = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Rest Day").count
							total_holidays = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Public Holiday").count
							total_early_gone = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :early_left_status => "Early Gone").count * 0.25
							total_half_day = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :early_left_status => "Half Day").count * 0.5
							total_half = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Half Day").count * 0.5
							total_late = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Late").count
							total_late_absent = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Late", :early_left_status => "Absent").count
							if total_late_absent > 0
								total_late_absent = total_late_absent * 0.25
							end
							if total_late > 3
								total_late = total_late - 3
								total_late = total_late * 0.25
							else
								total_late = 0.0
							end
							total_absent = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :early_left_status => "Absent").count
							total_absent2 = EmployeeAttendance.where(employee_id: pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Absent").count
							total_pay_days = total_attendance_days - total_rest_days - total_holidays - total_absent2 - total_early_gone - total_half_day - total_absent - total_late - total_half + total_late_absent

							current_row_value << total_pay_days
							current_row_style << row_format
							current_row_type << :float
						elsif pay_invoice.location_name == "Piece Rate"
							month_start_date = pay_invoice.pay_month.to_date.beginning_of_month
							month_end_date = pay_invoice.pay_month.to_date.end_of_month
							employee_total_month_attnd = EmployeeAttendance.where(:employee_id => pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date).count.to_f
							holiday = EmployeeAttendance.where(:employee_id => pay_invoice.employee.id, :attendance_date => month_start_date..month_end_date, :attendance_status => "Public Holiday").count.to_f
							total_deductions = 0.0
							date_range = (month_start_date.to_date..month_end_date.to_date).to_a.map{|x| x.to_date}
							date_range.each do |date|
								emp_atnd = EmployeeAttendance.where(:employee_id => pay_invoice.employee.id, :attendance_date => date).last
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
							total_pay_day = employee_total_month_attnd - total_deductions - holiday
							current_row_value << total_pay_day
							current_row_style << row_format
							current_row_type << :float
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
						advance_salary = 0.0
						pay_invoice.pay_invoice_details.order('sort_order ASC').each do |item_detail|
							if item_detail.item_name != "Attendance Deduction"
								if item_detail.item_name == "Advance Salary"
									advance_salary = item_detail.amount.round
								end
								current_row_value << item_detail.amount.round
								current_row_style << row_format
								current_row_type << :float
							end
						end
						current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round
						current_row_style << row_format
						current_row_type << :float


						attendance_deduction = pay_invoice.pay_invoice_details.get_by_item_name("Attendance Deduction")
						current_row_value << attendance_deduction
						current_row_style << row_format
						current_row_type << :float


						current_row_value << pay_invoice.monthly_tax.round
						current_row_style << row_format
						current_row_type << :float

						if pay_invoice.location_name == "Piece Rate"
							PieceSlab.first.piece_slab_details.each do |slab|
								if total_pay_day >= slab.lower_limit and total_pay_day <= slab.upper_limit
									pay_invoice.total_earning = slab.fixed_amount
									break
								end
							end
							# if total_pay_day >= 22.5
							# 	pay_invoice.total_earning = 6000
							# elsif total_pay_day >= 21.5 and total_pay_day < 22.5
							# 	pay_invoice.total_earning = 4000
							# elsif total_pay_day >= 20.5 and total_pay_day < 21.5
							# 	pay_invoice.total_earning = 3000
							# else
							# 	pay_invoice.total_earning = 0
							# end
							current_row_value << pay_invoice.total_earning.round
							current_row_style << row_format
							current_row_type << :float
						else
							current_row_value << pay_invoice.total_earning.round
							current_row_style << row_format
							current_row_type << :float
						end


						cresset_instance = ENV.fetch("APP_URL").include?('attendancebe.cressettech.com')

						if cresset_instance
							current_row_value << (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round + attendance_deduction)
							current_row_style << row_format
							current_row_type << :float
						else
							current_row_value << (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)
							current_row_style << row_format
							current_row_type << :float
						end

						if cresset_instance
							current_row_value << (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round + attendance_deduction)).round
							current_row_style << row_format
							current_row_type << :float
						else
							if pay_invoice.location_name == "Daily Wager"
								total_salary = (pay_invoice.actual_salary / pay_invoice.no_of_pay_days)*total_pay_days
								current_row_value << (total_salary - advance_salary).round
								current_row_style << row_format
								current_row_type << :float
							elsif pay_invoice.location_name == "Piece Rate"
								current_row_value << "-"
								current_row_style << row_format
								current_row_type << :string
							else
								current_row_value << (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
								current_row_style << row_format
								current_row_type << :float
							end

						end
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						pay_invoice.pay_invoice_details.order('sort_order ASC').each do |item_detail|
							if item_detail.item_name != "Attendance Deduction"
								current_row_value << "-"
								current_row_style << row_format
								current_row_type << :string
							end
						end

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 4
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department"]
				table_header << "Basic Salary"
				table_header << "House Rent"
				table_header << "Medical"
				table_header << "Utility Allowance"
				table_header << "Gross Salary"
				table_header << "Medical Allowance (OPD)"
				table_header << "Other Allowance"
				table_header << "Increment Arrears"
				table_header << "Arrears"
				table_header << "Total"
				table_header << "LWP"
				table_header << "Income Tax"
				table_header << "Advance"
				table_header << "Loan"
				table_header << "Provident Fund"
				table_header << "Arrear Provident Fund"
				table_header << "EOBI"
				table_header << "Other Deduction"
				table_header << "Bike Loan"
				table_header << "Mess Deduction"
				table_header << "Total Deduction"
				table_header << "Net Amount"
				table_header << "Net Payable"
				table_header << "Employeer Contribution"
				table_header << "Tax on Tax"
				table_header << "Total"
				table_header << "Employeer Provident Fund"
				table_header << "Employeer Arrear Provident Fund"
				table_header << "Total Provident Fund"

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@pay_invoices.each do |pay_invoice|
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

					current_row_value << pay_invoice.employee_code.to_s
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.actual_salary
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment","Increment Arrears"]).sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.monthly_tax
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round - item_value)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Other Deduction").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float


					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).round + pay_invoice.monthly_tax + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Deduction").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round)
					current_row_style << row_format
					current_row_type << :float

					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).round + pay_invoice.monthly_tax + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Deduction").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round)

					current_row_value << net_amount
					current_row_style << row_format
					current_row_type << :float

					current_row_value << net_amount
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.employer_yearly_contribution.round/12.0
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.tax_on_tax.round/12.0
					current_row_style << row_format
					current_row_type << :float

					current_row_value << (pay_invoice.employee_taxable_income.employer_yearly_contribution.round/12.0) + (pay_invoice.employee_taxable_income.tax_on_tax.round/12.0)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.employeer_pf_value - item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round + pay_invoice.employee_taxable_income.employeer_pf_value
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def multi_salary_register
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_executions = PayExecution.where(:id => params[:pay_execution_ids])
		@employees 			= Employee.where(:company_id => params[:company_id]).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_execution_id => @pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')

		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
			@location_name = Location.find(params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:sub_department_id].blank?
			@pay_invoices = PayInvoice.sub_department_related_invoices(@pay_invoices, params[:sub_department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].map(&:to_i))
		end
		if not params[:salary_unit_id].blank?
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if not params[:excluded_employees].blank?
			@pay_invoices = PayInvoice.exclude_employees(@pay_invoices, params[:excluded_employees] == 'true' ? true : false)
		end
		@pay_invoices = PayInvoice.payment_method_related_invoices(@pay_invoices, params[:payment_method]) if params[:payment_method].present?
		if params[:employment_status] == ''
			@pay_invoices = PayInvoice.on_roll_employees(@pay_invoices, true)
			@pay_invoices = PayInvoice.struck_off_employees(@pay_invoices, false)
		elsif params[:employment_status] == 'resigned'
			@pay_invoices = PayInvoice.on_roll_employees(@pay_invoices, false)
		elsif params[:employment_status] == 'struck_off'
			@pay_invoices = PayInvoice.struck_off_employees(@pay_invoices, true)
		end
		if params[:taxable] == "taxable"
			@pay_invoices = PayInvoice.taxable_employees(@pay_invoices)
		elsif params[:taxable] == "non_taxable"
			@pay_invoices = PayInvoice.non_taxable_employees(@pay_invoices)
		end

		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/multi_salary_register.json.jbuilder'
			elsif params[:report_type].to_i == 2
				check_directory("#{Rails.public_path}/pdf")
				file_name = ENV['APP_URL'].include?('millshrmsbe.dfl.com.pk') ? "multi_salary_register_mill" : "multi_salary_register"
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.3in',
						:bottom   => '0.3in',
						:left     => '0.3in',
						:right    => '0.3in'
					},
					dpi: 340,
					disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'A3'
				)
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 6 and ENV['APP_URL'].include?('millshrmsbe.dfl.com.pk')
				check_directory("#{Rails.public_path}/pdf")
				file_name = "sub_dept_salary_register_mill"
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.3in',
						:bottom   => '0.3in',
						:left     => '0.3in',
						:right    => '0.3in'
					},
					dpi: 340,
					disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'A3'
				)
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3
				pay_item_ids = []
				@pay_executions.each do |pay_execution|
					pay_execution.item_execution_details.where(:status => "Allowed").each do |item_execution_detail|
						pay_item_ids << item_execution_detail.pay_item_id
					end
				end
				pay_item_ids = pay_item_ids.uniq
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Job Title", "Department","Sub Department","Pay Days", "Gross Salary"]
				pay_items.order('sort_order ASC').each do |pay_item|
					if pay_item.name != "Attendance Deduction"
						table_header << pay_item.name
					end
				end
				table_header << "Salary Earned"
				table_header << "Attendance Deduction"
				table_header << "Income Tax"
				table_header << "Total Earning"
				table_header << "Total Deduction"
				table_header << "Net Payable"
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@pay_invoices.each do |pay_invoice|
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

					current_row_value << pay_invoice.employee_code.to_s
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.job_title_name
					current_row_style << row_format
					current_row_type << :string


					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.sub_department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << (pay_invoice.no_of_pay_days - pay_invoice.deduction_days)
					current_row_style << row_format
					current_row_type << :float

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary
						current_row_style << row_format
						current_row_type << :float

						pay_items.order('sort_order ASC').each do |pay_item|
							if pay_invoice.pay_invoice_details.collect(&:item_id).include?(pay_item.id) == true
								if pay_item.name != "Attendance Deduction"
									current_row_value << pay_invoice.pay_invoice_details.where(:item_id => pay_item.id).sum(:amount).round
									current_row_style << row_format
									current_row_type << :float
								end
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end

						current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Attendance Deduction").sum(:amount).round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.monthly_tax.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.total_earning.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						pay_invoice.pay_invoice_details.order('sort_order ASC').each do |item_detail|
							if item_detail.item_name != "Attendance Deduction"
								current_row_value << "-"
								current_row_style << row_format
								current_row_type << :string
							end
						end

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 4
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department"]
				table_header << "Basic Salary"
				table_header << "House Rent"
				table_header << "Utility Allowance"
				table_header << "Gross Salary"
				table_header << "Medical Allowance (OPD)"
				table_header << "Other Allowance"
				table_header << "Increment Arrears"
				table_header << "Arrears"
				table_header << "Total"
				table_header << "LWP"
				table_header << "Income Tax"
				table_header << "Advance"
				table_header << "Loan"
				table_header << "Provident Fund"
				table_header << "Arrear Provident Fund"
				table_header << "EOBI"
				table_header << "Other Deduction"
				table_header << "Bike Loan"
				table_header << "Mess Deduction"
				table_header << "Total Deduction"
				table_header << "Net Amount"
				table_header << "Net Payable"
				table_header << "Employeer Contribution"
				table_header << "Tax on Tax"
				table_header << "Total"
				table_header << "Employeer Provident Fund"
				table_header << "Employeer Arrear Provident Fund"
				table_header << "Total Provident Fund"

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@pay_invoices.each do |pay_invoice|
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

					current_row_value << pay_invoice.employee_code.to_s
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.actual_salary
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.monthly_tax
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round - item_value)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Other Deduction").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round
					current_row_style << row_format
					current_row_type << :float


					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).round + pay_invoice.monthly_tax + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Deduction").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round)
					current_row_style << row_format
					current_row_type << :float

					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).round + pay_invoice.monthly_tax + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Other Deduction").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round)

					current_row_value << net_amount
					current_row_style << row_format
					current_row_type << :float

					current_row_value << net_amount
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.employer_yearly_contribution.round/12.0
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.tax_on_tax.round/12.0
					current_row_style << row_format
					current_row_type << :float

					current_row_value << (pay_invoice.employee_taxable_income.employer_yearly_contribution.round/12.0) + (pay_invoice.employee_taxable_income.tax_on_tax.round/12.0)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.employeer_pf_value - item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round + pay_invoice.employee_taxable_income.employeer_pf_value
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 5 and ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
				time = Time.now
				file_name = "consolidated_salary_summary"
				grade_ids = params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : ""
				grade_name = (grade_ids.blank? or grade_ids.count > 1) ? "" : Grade.find(grade_ids).last.name
				file_name = "workers_consolidated_salary_summary" if grade_name == "W"
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top => '0.3in',
						:bottom => '0.3in',
						:left => '0.3in',
						:right => '0.3in'
					},
					dpi: 340,
					# dpi: 300,
					disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size: 'A3'
				)
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def salary_register_month_wise
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find_by(:formated_pay_month => params[:pay_month].to_date.strftime("%B %Y"))
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		@salary_unit_name = ""


		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq)
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if not params[:employee_type_id].blank?
			@pay_invoices = PayInvoice.employee_type_related_invoices(@pay_invoices, params[:employee_type_id])
		end
		@pay_invoices = @pay_invoices.order('employee_id ASC')
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/salary_register_month_wise.json.jbuilder'
			elsif params[:report_type].to_i == 2
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/salary_register_month_wise.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = "salary_register_month_wise"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 9
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/salary_register_cost_wise.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = "salary_register_month_wise"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 5
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/leave_encashment.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = "leave_encashment"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 6
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/annual_bonus.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = "annual_bonus"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 8
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/special_bonus.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = 'special_bonus'
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 7
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/salary_register_dept_wise.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = "salary_register_month_wise"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department", "Gross Salary"]
				pay_items.each do |pay_item|
					if pay_item.name != "Attendance Deduction"
						table_header << pay_item.name
					end
				end
				table_header << "Salary Earned"
				table_header << "Attendance Deduction"
				table_header << "Income Tax"
				table_header << "Total Earning"
				table_header << "Total Deduction"
				table_header << "Net Payable"
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@pay_invoices.each do |pay_invoice|
					diff_amount = pay_invoice.actual_pay_month.to_date >= Date.new(2021,3,1) ? pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round : 0
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

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary
						current_row_style << row_format
						current_row_type << :float

						pay_items.each do |pay_item|
							item_detail = pay_invoice.pay_invoice_details.find_by(item_id: pay_item.id)
							if pay_item.name == "Utility Allowance"
								current_row_value << item_detail.amount.round + diff_amount
								current_row_style << row_format
								current_row_type << :float
							elsif pay_item.name != "Attendance Deduction"
								if item_detail.present?
									current_row_value << item_detail.amount.round
									current_row_style << row_format
									current_row_type << :float
								else
									current_row_value << 0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end

						current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Attendance Deduction").sum(:amount).round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.monthly_tax.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.total_earning.round + diff_amount
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						pay_items.each do |pay_item|
							if pay_item.name != "Attendance Deduction"
								current_row_value << "-"
								current_row_style << row_format
								current_row_type << :string
							end
						end

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 4
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				selling_departments = Department.where(:name => ['Marketing', 'Export', 'Marketing&Export', 'Supply Chain'])
				admin_departments 	= Department.where.not(:name => ['Marketing', 'Export', 'Marketing&Export', 'Supply Chain'])

				admin_data 		= @pay_invoices.where(:department_id => admin_departments.collect(&:id))
				selling_data 	= @pay_invoices.where(:department_id => selling_departments.collect(&:id))

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department"]
				table_header << "Working Days"
				table_header << "Basic Salary"
				table_header << "House Rent"
				table_header << "Medical"
				table_header << "Utility Allowance"
				table_header << "Gross Salary"
				table_header << "Medi. Allow"
				table_header << "Other Allow"
				table_header << "Incentive"
				table_header << "Annual Bonus"
				# table_header << "Incre Arrears"
				table_header << "Leave Encash Arrears"
				table_header << "Leave Encashment"
				table_header << "Leave Fare Assistance"
				table_header << "Arrears"
				table_header << "Total"
				table_header << "LWP"
				table_header << "Income Tax"
				table_header << "Advance"
				table_header << "Loan"
				table_header << "EPF"
				table_header << "AERPF"
				table_header << "EOBI"
				table_header << "EOBI Deduction"
				table_header << "Other Deduction"
				table_header << "Bike Loan"
				table_header << "Mess Deduction"
				table_header << "Insurance Premium GLI"
				table_header << "Total Deduction"
				table_header << "Net Amount"
				table_header << "Net Payable"
				table_header << "ERPF"
				table_header << "AERPF"
				table_header << "PF Total"

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				sheet.add_row ['']
				sheet.add_row ['Administration']
				sheet.add_row ['']

				admin_data.each do |pay_invoice|
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

					current_row_value << pay_invoice.employee_code
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << (pay_invoice.no_of_pay_days - pay_invoice.deduction_days)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.to_f.round + diff_amount.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).round + diff_amount
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					# current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
					# current_row_style << row_format
					# current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment","Increment Arrears"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.monthly_tax.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float


					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float


					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
					current_row_style << row_format
					current_row_type << :float

					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)

					current_row_value << net_amount.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << net_amount.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				column_no_1 = 0
				column_no_2 = 0
				column_no_3 = 0
				column_no_4 = 0
				column_no_5 = 0
				column_no_6 = 0
				column_no_7 = 0
				column_no_30 = 0
				column_no_31 = 0
				# column_no_8 = 0
				column_no_9 = 0
				column_no_10 = 0
				column_no_11 = 0
				column_no_12 = 0
				column_no_13 = 0
				column_no_14 = 0
				column_no_15 = 0
				column_no_16 = 0
				column_no_17 = 0
				column_no_18 = 0
				column_no_19 = 0
				column_no_20 = 0
				column_no_21 = 0
				column_no_22 = 0
				column_no_23 = 0
				column_no_24 = 0
				column_no_25 = 0
				column_no_26 = 0
				column_no_27 = 0
				column_no_32 = 0
				column_no_33 = 0
				column_no_28 = 0
				column_no_29 = 0

				admin_data.each do |pay_invoice|
					column_no_1 = column_no_1 + pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
					column_no_2 = column_no_2 + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
					column_no_3 = column_no_3 + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
					diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round
					column_no_4 = column_no_4 + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + diff_amount
					column_no_5 = column_no_5 + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).to_f.round + diff_amount
					column_no_6 = column_no_6 + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
					column_no_7 = column_no_7 + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
					column_no_30 = column_no_30 + pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
					column_no_31 = column_no_31 + pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round
					# column_no_8 = column_no_8 + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
					column_no_27 = column_no_27 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
					column_no_32 = column_no_32 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
					column_no_33 = column_no_33 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round

					column_no_9 = column_no_9 + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round
					column_no_10 = column_no_10 + (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears", "Leave Encashment","Leave Fare Assistance","Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round) + diff_amount
					column_no_11 = column_no_11 + pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
					column_no_12 = column_no_12 + pay_invoice.monthly_tax.to_f.round
					column_no_13 = column_no_13 + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
					column_no_14 = column_no_14 + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
					column_no_15 = column_no_15 + (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round)
					column_no_16 = column_no_16 + item_value
					column_no_17 = column_no_17 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
					column_no_28 = column_no_28 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
					column_no_18 = column_no_18 + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
					column_no_19 = column_no_19 + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
					column_no_20 = column_no_20 + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
					column_no_29 = column_no_29 + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
					column_no_21 = column_no_21 + (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round)
					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears", "Leave Encashment", "Leave Fare Assistance","Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round)
					column_no_22 = column_no_22 + net_amount.to_f.round
					column_no_23 = column_no_23 + net_amount.to_f.round
					column_no_24 = column_no_24 + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
					column_no_25 = column_no_25 + item_value.to_f.round
					column_no_26 = column_no_26 + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
				end

				row_format = old_row_format

				if count.even? == true
					row_format = even_row_format
				else
					row_format = old_row_format
				end

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << "Sub Total"
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << column_no_1
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_2
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_3
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_4
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_5
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_6
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_7
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_30
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_31
				current_row_style << row_format
				current_row_type << :float

				# current_row_value << 0
				# current_row_style << row_format
				# current_row_type << :float

				current_row_value << column_no_27
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_32
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_33
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_9
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_10
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_11
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_12
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_13
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_14
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_15
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_16
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_17
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_28
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_18
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_19
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_20
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_29
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_21
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_22
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_23
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_24
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_25
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_26
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row ['']
				sheet.add_row ['Selling']
				sheet.add_row ['']

				selling_data.each do |pay_invoice|
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

					current_row_value << pay_invoice.employee_code
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << (pay_invoice.no_of_pay_days - pay_invoice.deduction_days)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.to_f.round + diff_amount.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).to_f.round + diff_amount
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					# current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
					# current_row_style << row_format
					# current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment","Increment Arrears"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.monthly_tax.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round

					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round)
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
					current_row_style << row_format
					current_row_type << :float



					current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round)
					current_row_style << row_format
					current_row_type << :float

					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)

					current_row_value << net_amount.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << net_amount.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round - item_value.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << item_value.to_f.round
					current_row_style << row_format
					current_row_type << :float

					current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				column_no_1 = 0
				column_no_2 = 0
				column_no_3 = 0
				column_no_4 = 0
				column_no_5 = 0
				column_no_6 = 0
				column_no_7 = 0
				column_no_30 = 0
				column_no_31 = 0
				# column_no_8 = 0
				column_no_9 = 0
				column_no_10 = 0
				column_no_11 = 0
				column_no_12 = 0
				column_no_13 = 0
				column_no_14 = 0
				column_no_15 = 0
				column_no_16 = 0
				column_no_17 = 0
				column_no_18 = 0
				column_no_19 = 0
				column_no_20 = 0
				column_no_21 = 0
				column_no_22 = 0
				column_no_23 = 0
				column_no_24 = 0
				column_no_25 = 0
				column_no_26 = 0
				column_no_27 = 0
				column_no_32 = 0
				column_no_33 = 0
				column_no_28 = 0
				column_no_29 = 0

				selling_data.each do |pay_invoice|
					column_no_1 = column_no_1 + pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
					column_no_2 = column_no_2 + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
					column_no_3 = column_no_3 + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
					diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round
					column_no_4 = column_no_4 + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + diff_amount
					column_no_5 = column_no_5 + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).to_f.round + diff_amount
					column_no_6 = column_no_6 + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
					column_no_7 = column_no_7 + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
					column_no_30 = column_no_30 + pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
					column_no_31 = column_no_31 + pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round

					# column_no_8 = column_no_8 + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
					column_no_27 = column_no_27 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
					column_no_32 = column_no_32 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
					column_no_33 = column_no_33 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
					column_no_9 = column_no_9 + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round
					column_no_10 = column_no_10 + (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round) + diff_amount
					column_no_11 = column_no_11 + pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
					column_no_12 = column_no_12 + pay_invoice.monthly_tax.to_f.round
					column_no_13 = column_no_13 + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
					column_no_14 = column_no_14 + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
					column_no_15 = column_no_15 + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round
					column_no_16 = column_no_16 + item_value.to_f.round
					column_no_17 = column_no_17 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
					column_no_28 = column_no_28 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
					column_no_18 = column_no_18 + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
					column_no_19 = column_no_19 + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
					column_no_20 = column_no_20 + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
					column_no_29 = column_no_29 + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
					column_no_21 = column_no_21 + (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round)
					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
					column_no_22 = column_no_22 + net_amount.to_f.round
					column_no_23 = column_no_23 + net_amount.to_f.round
					column_no_24 = column_no_24 + pay_invoice.employee_taxable_income.employeer_pf_value
					column_no_25 = column_no_25 + item_value.to_f.round
					column_no_26 = column_no_26 + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
				end

				row_format = old_row_format

				if count.even? == true
					row_format = even_row_format
				else
					row_format = old_row_format
				end

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << "Sub Total"
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << column_no_1
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_2
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_3
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_4
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_5
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_6
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_7
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_30
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_31
				current_row_style << row_format
				current_row_type << :float

				# current_row_value << 0
				# current_row_style << row_format
				# current_row_type << :float

				current_row_value << column_no_27
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_32
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_33
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_9
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_10
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_11
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_12
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_13
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_14
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_15
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_16
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_17
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_28
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_18
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_19
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_20
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_29
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_21
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_22
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_23
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_24
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_25
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_26
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row ['']

				column_no_1 = 0
				column_no_2 = 0
				column_no_3 = 0
				column_no_4 = 0
				column_no_5 = 0
				column_no_6 = 0
				column_no_7 = 0
				column_no_30 = 0
				column_no_31 = 0
				# column_no_8 = 0
				column_no_9 = 0
				column_no_10 = 0
				column_no_11 = 0
				column_no_12 = 0
				column_no_13 = 0
				column_no_14 = 0
				column_no_15 = 0
				column_no_16 = 0
				column_no_17 = 0
				column_no_18 = 0
				column_no_19 = 0
				column_no_20 = 0
				column_no_21 = 0
				column_no_22 = 0
				column_no_23 = 0
				column_no_24 = 0
				column_no_25 = 0
				column_no_26 = 0
				column_no_27 = 0
				column_no_32 = 0
				column_no_33 = 0
				column_no_28 = 0
				column_no_29 = 0

				@pay_invoices.each do |pay_invoice|
					column_no_1 = column_no_1 + pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
					column_no_2 = column_no_2 + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
					column_no_3 = column_no_3 + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
					diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round
					column_no_4 = column_no_4 + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.to_f.round + diff_amount.to_f.round
					column_no_5 = column_no_5 + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).to_f.to_f.round + diff_amount.to_f.round
					column_no_6 = column_no_6 + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
					column_no_7 = column_no_7 + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
					column_no_30 = column_no_30 + pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
					column_no_31 = column_no_31 + pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round
					# column_no_8 = column_no_8 + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
					column_no_27 = column_no_27 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
					column_no_32 = column_no_32 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
					column_no_33 = column_no_33 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
					column_no_9 = column_no_9 + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round
					column_no_10 = column_no_10 + (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round) + diff_amount
					column_no_11 = column_no_11 + pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
					column_no_12 = column_no_12 + pay_invoice.monthly_tax.to_f.round
					column_no_13 = column_no_13 + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
					column_no_14 = column_no_14 + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
					column_no_15 = column_no_15 + (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round)
					column_no_16 = column_no_16 + item_value.to_f.round
					column_no_17 = column_no_17 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
					column_no_28 = column_no_28 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
					column_no_18 = column_no_18 + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
					column_no_19 = column_no_19 + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
					column_no_20 = column_no_20 + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
					column_no_29 = column_no_29 + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
					column_no_21 = column_no_21 + (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
					column_no_22 = column_no_22 + net_amount.to_f.round
					column_no_23 = column_no_23 + net_amount.to_f.round
					column_no_24 = column_no_24 + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
					column_no_25 = column_no_25 + item_value.to_f.round
					column_no_26 = column_no_26 + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
				end

				row_format = old_row_format

				if count.even? == true
					row_format = even_row_format
				else
					row_format = old_row_format
				end

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << "Grand Total"
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << column_no_1
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_2
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_3
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_4
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_5
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_6
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_7
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_30
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_31
				current_row_style << row_format
				current_row_type << :float

				# current_row_value << 0
				# current_row_style << row_format
				# current_row_type << :float

				current_row_value << column_no_27
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_32
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_33
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_9
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_10
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_11
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_12
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_13
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_14
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_15
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_16
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_17
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_28
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_18
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_19
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_20
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_29
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_21
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_22
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_23
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_24
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_25
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_26
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 15
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Register')
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

				# selling_departments = Department.where(:name => ['Marketing', 'Export', 'Marketing&Export', 'Supply Chain'])
				# admin_departments 	= Department.where.not(:name => ['Marketing', 'Export', 'Marketing&Export', 'Supply Chain'])

				# admin_data 		= @pay_invoices.where(:department_id => admin_departments.collect(&:id))
				# selling_data 	= @pay_invoices.where(:department_id => selling_departments.collect(&:id))

				if params[:cost_center_id].present?
					cost_center_ids = params[:cost_center_id]
					salary_unit_ids = params[:salary_unit_id]
				else
					if params[:salary_unit_id].present?
						salary_unit_ids = params[:salary_unit_id]
						cost_center_ids = SalaryUnit.find(params[:salary_unit_id]).cost_centers.where(:is_active => true).pluck(:id).uniq
					else
						salary_unit_ids = SalaryUnit.where(:is_active => true).pluck(:id)
					end
				end

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department"]
				table_header << "Working Days"
				table_header << "Basic Salary"
				table_header << "House Rent"
				table_header << "Medical"
				table_header << "Utility Allowance"
				table_header << "Gross Salary"
				table_header << "Medi. Allow"
				table_header << "Other Allow"
				table_header << "Incentive"
				table_header << "Annual Bonus"
				# table_header << "Incre Arrears"
				table_header << "Leave Encash Arrears"
				table_header << "Leave Encashment"
				table_header << "Leave Fare Assistance"
				table_header << "Arrears"
				table_header << "Total"
				table_header << "LWP"
				table_header << "Income Tax"
				table_header << "Advance"
				table_header << "Loan"
				table_header << "EPF"
				table_header << "AERPF"
				table_header << "EOBI"
				table_header << "EOBI Deduction"
				table_header << "Other Deduction"
				table_header << "Bike Loan"
				table_header << "Mess Deduction"
				table_header << "Insurance Premium GLI"
				table_header << "Total Deduction"
				table_header << "Net Amount"
				table_header << "Net Payable"
				table_header << "ERPF"
				table_header << "AERPF"
				table_header << "PF Total"

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				[salary_unit_ids].flatten.each do |salary_unit_id|
					salary_unit = SalaryUnit.find(salary_unit_id)
					cost_center_ids = salary_unit.cost_centers.where(:is_active => true).pluck(:id).uniq
					[cost_center_ids].flatten.each do |cost_center_id|
						cost_center = CostCenter.find(cost_center_id)

						sheet.add_row ['']
						sheet.add_row ["#{cost_center.name}"]
						sheet.add_row ['']

						admin_data = @pay_invoices.where(:cost_center_id => cost_center_id)

						admin_data.each do |pay_invoice|
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

							current_row_value << pay_invoice.employee_code
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.employee_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.grade_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.location_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.branch_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.department_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << (pay_invoice.no_of_pay_days - pay_invoice.deduction_days)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.to_f.round + diff_amount.to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).round + diff_amount
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							# current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
							# current_row_style << row_format
							# current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment","Increment Arrears"]).sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount)
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.monthly_tax.to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
							item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round

							current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round)
							current_row_style << row_format
							current_row_type << :float

							current_row_value << item_value
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float


							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
							current_row_style << row_format
							current_row_type << :float


							current_row_value << (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
							current_row_style << row_format
							current_row_type << :float

							net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)

							current_row_value << net_amount.to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << net_amount.to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << item_value
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
							current_row_style << row_format
							current_row_type << :float

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end

						column_no_1 = 0
						column_no_2 = 0
						column_no_3 = 0
						column_no_4 = 0
						column_no_5 = 0
						column_no_6 = 0
						column_no_7 = 0
						column_no_30 = 0
						column_no_31 = 0
						# column_no_8 = 0
						column_no_9 = 0
						column_no_10 = 0
						column_no_11 = 0
						column_no_12 = 0
						column_no_13 = 0
						column_no_14 = 0
						column_no_15 = 0
						column_no_16 = 0
						column_no_17 = 0
						column_no_18 = 0
						column_no_19 = 0
						column_no_20 = 0
						column_no_21 = 0
						column_no_22 = 0
						column_no_23 = 0
						column_no_24 = 0
						column_no_25 = 0
						column_no_26 = 0
						column_no_27 = 0
						column_no_32 = 0
						column_no_33 = 0
						column_no_28 = 0
						column_no_29 = 0

						admin_data.each do |pay_invoice|
							column_no_1 = column_no_1 + pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
							column_no_2 = column_no_2 + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
							column_no_3 = column_no_3 + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
							diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round
							column_no_4 = column_no_4 + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + diff_amount
							column_no_5 = column_no_5 + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).to_f.round + diff_amount
							column_no_6 = column_no_6 + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
							column_no_7 = column_no_7 + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
							column_no_30 = column_no_30 + pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
							column_no_31 = column_no_31 + pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round

							# column_no_8 = column_no_8 + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
							column_no_27 = column_no_27 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
							column_no_32 = column_no_32 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
							column_no_33 = column_no_33 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
							column_no_9 = column_no_9 + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round
							column_no_10 = column_no_10 + (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round) + diff_amount
							column_no_11 = column_no_11 + pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
							column_no_12 = column_no_12 + pay_invoice.monthly_tax.to_f.round
							column_no_13 = column_no_13 + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
							column_no_14 = column_no_14 + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
							pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
							item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
							column_no_15 = column_no_15 + pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round
							column_no_16 = column_no_16 + item_value.to_f.round
							column_no_17 = column_no_17 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
							column_no_28 = column_no_28 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
							column_no_18 = column_no_18 + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
							column_no_19 = column_no_19 + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
							column_no_20 = column_no_20 + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
							column_no_29 = column_no_29 + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
							column_no_21 = column_no_21 + (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round)
							net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
							column_no_22 = column_no_22 + net_amount.to_f.round
							column_no_23 = column_no_23 + net_amount.to_f.round
							column_no_24 = column_no_24 + pay_invoice.employee_taxable_income.employeer_pf_value
							column_no_25 = column_no_25 + item_value.to_f.round
							column_no_26 = column_no_26 + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
						end

						row_format = old_row_format

						if count.even? == true
							row_format = even_row_format
						else
							row_format = old_row_format
						end

						current_row_value = []
						current_row_style = []
						current_row_type = []

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "Sub Total"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ""
						current_row_style << row_format
						current_row_type << :string

						current_row_value << column_no_1
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_2
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_3
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_4
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_5
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_6
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_7
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_30
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_31
						current_row_style << row_format
						current_row_type << :float

						# current_row_value << 0
						# current_row_style << row_format
						# current_row_type << :float

						current_row_value << column_no_27
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_32
						current_row_style << row_format
						current_row_type << :float

            current_row_value << column_no_33
            current_row_style << row_format
            current_row_type << :float

						current_row_value << column_no_9
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_10
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_11
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_12
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_13
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_14
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_15
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_16
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_17
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_28
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_18
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_19
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_20
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_29
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_21
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_22
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_23
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_24
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_25
						current_row_style << row_format
						current_row_type << :float

						current_row_value << column_no_26
						current_row_style << row_format
						current_row_type << :float

						sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					end
				end

				sheet.add_row ['']

				column_no_1 = 0
				column_no_2 = 0
				column_no_3 = 0
				column_no_4 = 0
				column_no_5 = 0
				column_no_6 = 0
				column_no_7 = 0
				column_no_30 = 0
				column_no_31 = 0
				# column_no_8 = 0
				column_no_9 = 0
				column_no_10 = 0
				column_no_11 = 0
				column_no_12 = 0
				column_no_13 = 0
				column_no_14 = 0
				column_no_15 = 0
				column_no_16 = 0
				column_no_17 = 0
				column_no_18 = 0
				column_no_19 = 0
				column_no_20 = 0
				column_no_21 = 0
				column_no_22 = 0
				column_no_23 = 0
				column_no_24 = 0
				column_no_25 = 0
				column_no_26 = 0
				column_no_27 = 0
				column_no_32 = 0
				column_no_33 = 0
				column_no_28 = 0
				column_no_29 = 0

				@pay_invoices.where(:salary_unit_id => [salary_unit_ids].flatten).each do |pay_invoice|
					column_no_1 = column_no_1 + pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round
					column_no_2 = column_no_2 + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round
					column_no_3 = column_no_3 + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round
					diff_amount = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount)).to_f.round
					column_no_4 = column_no_4 + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.to_f.round + diff_amount.to_f.round
					column_no_5 = column_no_5 + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Medical", "Utility Allowance"]).sum(:amount).to_f.to_f.round + diff_amount.to_f.round
					column_no_6 = column_no_6 + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round
					column_no_7 = column_no_7 + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round
					column_no_30 = column_no_30 + pay_invoice.pay_invoice_details.where(:item_name => ["Incentive"]).sum(:amount).to_f.round
					column_no_31 = column_no_31 + pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).to_f.round
					# column_no_8 = column_no_8 + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round
					column_no_27 = column_no_27 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment Arrears").sum(:amount).to_f.round
					column_no_32 = column_no_32 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Encashment").sum(:amount).to_f.round
					column_no_33 = column_no_33 + pay_invoice.pay_invoice_details.where(:item_name => "Leave Fare Assistance").sum(:amount).to_f.round
					column_no_9 = column_no_9 + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Increment Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round
					column_no_10 = column_no_10 + (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round) + diff_amount
					column_no_11 = column_no_11 + pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
					column_no_12 = column_no_12 + pay_invoice.monthly_tax.to_f.round
					column_no_13 = column_no_13 + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round
					column_no_14 = column_no_14 + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round
					pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
					item_value = pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
					column_no_15 = column_no_15 + (pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).to_f.round)
					column_no_16 = column_no_16 + item_value.to_f.round
					column_no_17 = column_no_17 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round
					column_no_28 = column_no_28 + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round
					column_no_18 = column_no_18 + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round
					column_no_19 = column_no_19 + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round
					column_no_20 = column_no_20 + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round
					column_no_29 = column_no_29 + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round
					column_no_21 = column_no_21 + (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
					net_amount = (pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).to_f.round  + pay_invoice.pay_invoice_details.where(:item_name => "Incentive").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Annual Bonus").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "House Rent").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Utility Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Medical Allowance (OPD)").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance","Bike Fuel Allowance"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Fuel Allowance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Increment Arrears").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Leave Encashment Arrears","Leave Encashment","Leave Fare Assistance", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round + diff_amount) - (pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round + pay_invoice.monthly_tax.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "EOBI Deduction").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => ["Allowance Deduction", "Salary Deduction", "Other Deduction"]).sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Bike Loan").sum(:amount).to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).to_f.round+ pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).to_f.round)
					column_no_22 = column_no_22 + net_amount.to_f.round
					column_no_23 = column_no_23 + net_amount.to_f.round
					column_no_24 = column_no_24 + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round
					column_no_25 = column_no_25 + item_value.to_f.round
					column_no_26 = column_no_26 + pay_invoice.pay_invoice_details.where(:item_name => ["Provident Fund","Arrears Provident Fund"]).sum(:amount).to_f.round + pay_invoice.employee_taxable_income.employeer_pf_value.to_f.round + pay_invoice.pay_invoice_details.where(:item_name => "Arrears Provident Fund").sum(:amount).to_f.round
				end

				row_format = old_row_format

				if count.even? == true
					row_format = even_row_format
				else
					row_format = old_row_format
				end

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << "Grand Total"
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << column_no_1
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_2
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_3
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_4
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_5
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_6
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_7
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_30
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_31
				current_row_style << row_format
				current_row_type << :float

				# current_row_value << 0
				# current_row_style << row_format
				# current_row_type << :float

				current_row_value << column_no_27
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_32
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_33
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_9
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_10
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_11
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_12
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_13
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_14
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_15
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_16
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_17
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_28
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_18
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_19
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_20
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_29
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_21
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_22
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_23
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_24
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_25
				current_row_style << row_format
				current_row_type << :float

				current_row_value << column_no_26
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				file_name = "salary_register"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		end
	end


	def salary_sheet
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find (params[:pay_execution_id])
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')

		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
			end
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end

		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				department_ids = @pay_invoices.collect(&:department_id)
				@departments = Department.where(:id => department_ids).order('id ASC')
				render status:200, template: 'api/v1/web/reports/payroll_reports/salary_sheet.json.jbuilder'
			elsif params[:report_type].to_i == 2
				department_ids = @pay_invoices.collect(&:department_id)
				@departments = Department.where(:id => department_ids).order('id ASC')
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/salary_sheet.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 280,
					disable_smart_shrinking: false,
					orientation: 'Landscape',
					page_size:'A3'
				)
				file_name = "salary_sheet"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3
				department_ids = @pay_invoices.collect(&:department_id)
				@departments = Department.where(:id => department_ids).order('id ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Salary Sheet')
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

				sheet.add_row ["", "", "", "", "", "", "", "", "#{@company.name}"], :style => cell_style
				sheet.add_row ["", "", "", "", "", "", "", "", "Salary Sheet Detail for the Month of #{@pay_execution.formated_pay_month}"], :style => cell_style
				sheet.add_row ["", "", "", "", "", "", "", "", "Date From: #{ReportFormat.salary_sheet_date_format(@pay_execution.start_date)} To: #{ReportFormat.salary_sheet_date_format(@pay_execution.end_date)}"], :style => cell_style
				sheet.add_row ['']

				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				row_count = 9

				total_gross_salary = 0
				total_arrears = 0
				total_days = 0
				total_deduction_days = 0
				total_work_days = 0
				total_incentive = 0
				total_earned_salary = 0
				total_salary = 0
				total_income_tax = 0
				total_other_deduction = 0
				total_mobile = 0
				total_loan_advance = 0
				total_vehicle_deduction = 0
				total_eobi = 0
				total_other = 0
				total_total_deduction = 0
				total_net_salary = 0

				@departments.each do |department|
					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << department.name
					current_row_style << bold_column_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					row_count = row_count + 1

					sheet.add_row ["Sr #", "Emp Code", "Name", "Father Name", "Designation", "Date of Joining", "Service (Months)", "Gross Salary", "Work Days", "Incentive", "Earned Salary", "Arrears", "Total Salary", "Income tax", "Other Deduction", "Mobile", "Loan / Advance", "Vehicle Deduction", "EOBI", "Other", "Total Deduction", "Net Salary", "ABL A/C Number"], :style => header_style
					row_count = row_count + 1

					count = 0
					depatment_wise_pay_invoices = @pay_invoices.where(:department_id => department.id).order('employee_id ASC')
					depatment_wise_pay_invoices.each do |pay_invoice|
						employee = pay_invoice.employee
						if not employee.nil?
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

							current_row_value << employee.father_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee.designation_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.date_format(employee.joining_date)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.month_difference(employee.joining_date, pay_invoice.actual_pay_month)
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.actual_salary.to_f
							current_row_style << row_format
							current_row_type << :float

							current_row_value << PayInvoice.invoice_worked_days(pay_invoice)
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Incentive Amount"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["ARREARS"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.total_earning.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.monthly_tax.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Deduction"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Mobile"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Loan & Advance"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Vehicle Deduction"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["EOBI"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Amount"]).sum(:amount).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << pay_invoice.total_deduction.round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
							current_row_style << row_format
							current_row_type << :float

							current_row_value << employee.bank_account_number
							current_row_style << row_format
							current_row_type << :string

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
							row_count = row_count + 1

							total_gross_salary = total_gross_salary + pay_invoice.actual_salary.to_f
							total_days = total_days + pay_invoice.pay_execution.total_pay_days(employee).to_f
							total_deduction_days = total_deduction_days + pay_invoice.deduction_days.to_f
							total_work_days = total_work_days + (pay_invoice.pay_execution.total_pay_days(employee).to_f - pay_invoice.short_joining_days.to_f)
							total_incentive = total_incentive + pay_invoice.pay_invoice_details.where(:item_name => ["Incentive Amount"]).sum(:amount).round
							total_earned_salary = total_earned_salary + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round
							total_arrears = total_arrears + pay_invoice.pay_invoice_details.where(:item_name => ["ARREARS"]).sum(:amount).round
							total_salary = total_salary + pay_invoice.total_earning.round
							total_income_tax = total_income_tax + pay_invoice.monthly_tax.round
							total_other_deduction = total_other_deduction + pay_invoice.pay_invoice_details.where(:item_name => ["Other Deduction"]).sum(:amount).round
							total_mobile = total_mobile + pay_invoice.pay_invoice_details.where(:item_name => ["Mobile"]).sum(:amount).round
							total_loan_advance = total_loan_advance + pay_invoice.pay_invoice_details.where(:item_name => ["Loan & Advance"]).sum(:amount).round
							total_vehicle_deduction = total_vehicle_deduction + pay_invoice.pay_invoice_details.where(:item_name => ["Vehicle Deduction"]).sum(:amount).round
							total_eobi = total_eobi + pay_invoice.pay_invoice_details.where(:item_name => ["EOBI"]).sum(:amount).round
							total_other = total_other + pay_invoice.pay_invoice_details.where(:item_name => ["Other Amount"]).sum(:amount).round
							total_total_deduction = total_total_deduction + pay_invoice.total_deduction.round
							total_net_salary = total_net_salary + (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
						end
					end
				end

				sheet.add_row []
				row_count = row_count + 1

				current_row_value = []
				current_row_style = []
				current_row_type = []

				sheet.add_row ["Total", "Total", "Total", "Total", "Total", "Total", "Total", "Gross Salary", "Work Days", "Incentive", "Earned Salary", "Arrears", "Total Salary", "Income tax", "Other Deduction", "Mobile", "Loan / Advance", "Vehicle Deduction", "EOBI", "Other", "Total Deduction", "Net Salary", "ABL A/C Number"], :style => header_style
				sheet.merge_cells Axlsx::cell_r(0,row_count) + ':' + Axlsx::cell_r(6,row_count)
				row_count = row_count + 1

				row_format = old_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_gross_salary
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_work_days
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_incentive
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_earned_salary
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_arrears
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_salary
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_income_tax
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_other_deduction
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_mobile
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_loan_advance
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_vehicle_deduction
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_eobi
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_other
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_total_deduction
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_net_salary
				current_row_style << row_format
				current_row_type << :float

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				sheet.merge_cells Axlsx::cell_r(0,row_count) + ':' + Axlsx::cell_r(6,row_count)

				file_name = "salary_sheet"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def payment_register
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find(params[:company_id])
		@pay_executions 	= PayExecution.where(:id => params[:pay_execution_ids])
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_execution_id => @pay_executions.collect(&:id))

		@pay_execution = @pay_executions.last

		@location_name = ""
		@branch_name = ""
		@department_name = ""
		@grade_name = ""
		@salary_unit_name = ""

		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
			@employees = Employee.multiple_salary_unit_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => @pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
			@employees = Employee.multiple_salary_unit_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => @pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
			@employees = Employee.multiple_salary_unit_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => @pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
			@employees = Employee.multiple_salary_unit_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => @pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
				@employees = Employee.multiple_salary_unit_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => @pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
			end
		end
		#################### Hierarchical Permission ####################

		unless params[:location_id].blank?
			@location_name = Location.find(params[:location_id]).name
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		unless params[:branch_id].blank?
			@branch_name = Branch.find(params[:branch_id]).name
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		unless params[:department_id].blank?
			@department_name = Department.find(params[:department_id]).name
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		unless params[:sub_department_id].blank?
			@pay_invoices = PayInvoice.sub_department_related_invoices(@pay_invoices, params[:sub_department_id].to_i)
		end
		unless params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		unless params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		unless params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		unless params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		unless params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		unless params[:excluded_employees].blank?
			@pay_invoices = PayInvoice.exclude_employees(@pay_invoices, params[:excluded_employees] == 'true' ? true : false)
		end
		unless params[:payment_method].blank?
			@pay_invoices = PayInvoice.payment_method_related_invoices(@pay_invoices, params[:payment_method])
		end
		if params[:employment_status] == ''
			@pay_invoices = PayInvoice.on_roll_employees(@pay_invoices, true)
			@pay_invoices = PayInvoice.struck_off_employees(@pay_invoices, false)
		elsif params[:employment_status] == 'resigned'
			@pay_invoices = PayInvoice.on_roll_employees(@pay_invoices, false)
		elsif params[:employment_status] == 'struck_off'
			@pay_invoices = PayInvoice.struck_off_employees(@pay_invoices, true)
		end
		if params[:taxable] == "taxable"
			@pay_invoices = PayInvoice.taxable_employees(@pay_invoices)
		elsif params[:taxable] == "non_taxable"
			@pay_invoices = PayInvoice.non_taxable_employees(@pay_invoices)
		end
		unless params[:hiring_shift].blank?
			@pay_invoices = PayInvoice.hiring_shifts(@pay_invoices, params[:hiring_shift])
		end
		unless params[:pay_item_ids].blank?
			@pay_items  	= PayItem.where(:id => params[:pay_item_ids]).order('name ASC')
			@pay_invoices = @pay_invoices.includes(:pay_invoice_details).where(pay_invoice_details: {item_id: @pay_items})
		end

		@pay_invoices = @pay_invoices.includes(employee: :designation).where(:employee_type_id => params[:employee_type_ids].map(&:to_i)).order('employees.employee_code ASC')

		if @pay_invoices.count > 0
			orientation = 'Landscape'
			page_size = 'A3'
			file_name = ""
			top = '1.5in'
			bottom = '0.3in'
			left = '0.3in'
			right = '0.3in'
			dpi = 700
			dfl_report_check = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/payment_register.json.jbuilder'
			elsif params[:report_type].to_i == 2
				file_name = dfl_report_check ? "bank_sheet" : "multiple_invoice"
				if file_name == "bank_sheet"
					grade_ids = params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : ""
					grade_name = (grade_ids.blank? or grade_ids.count > 1) ? "" : Grade.find(grade_ids).last.name
					file_name = "worker_bank_sheet" if grade_name == "W"
					orientation = 'Portrait'
					page_size = 'A3'
				end
			elsif params[:report_type].to_i == 15 and dfl_report_check
				grade_ids = params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : ""
				grade_name = (grade_ids.blank? or grade_ids.count > 1) ? "" : Grade.find(grade_ids).last.name
				file_name = "workers_payment_sheet" if grade_name == "W"
				orientation = 'Portrait'
				page_size = 'A3'
			elsif params[:report_type].to_i == 3 and dfl_report_check
				file_name = "advance_deductions"
			elsif params[:report_type].to_i == 4 and dfl_report_check
				file_name = "income_tax_deductions"
			elsif params[:report_type].to_i == 5
				file_name = "pay_item_deductions"
			elsif params[:report_type].to_i == 6 and dfl_report_check
				file_name = "provident_fund_deductions"
			elsif params[:report_type].to_i == 7 and dfl_report_check
				file_name = "provident_fund_summary"
			elsif params[:report_type].to_i == 9 and dfl_report_check
				file_name = "multiple_invoice_mill"
				orientation = 'Portrait'
				page_size = 'A4'
				top = '0.1in'
				bottom = '0.1in'
				left = '0.1in'
				right = '0.1in'
				dpi = 320
			end
			if not [1, 8, 10, 11, 12, 13, 14].include?(params[:report_type].to_i)
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					header: {content: render_to_string("api/v1/web/pdf_templates/header.pdf.erb", locals: { :@file_name => file_name})},
					:margin => {
						:top      => top,
						:bottom   => bottom,
						:left     => left,
						:right    => right
					},
					dpi: dpi,
					# disable_smart_shrinking: true,
					orientation: orientation,
					page_size: page_size
				)
				file_name = "payment_register_#{file_name}"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			else
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				if params[:report_type].to_i == 8
					book = PaymentRegisterMillService.new({
																									pay_invoices: @pay_invoices
																								}).bank_sheet_excel(book)
					file_name = "bank_sheet"
				elsif params[:report_type].to_i == 10 and dfl_report_check
					book = PaymentRegisterMillService.new({
																									pay_invoices: @pay_invoices
																								}).advance_deductions_excel(book)
					file_name = "advance_deductions"
				elsif params[:report_type].to_i == 11 and dfl_report_check
					book = PaymentRegisterMillService.new({
																									pay_invoices: @pay_invoices
																								}).income_tax_excel(book)
					file_name = "income_tax"
				elsif params[:report_type].to_i == 12
					book = PaymentRegisterMillService.new({
																									pay_invoices: @pay_invoices
																								}).pay_item_report_excel(book, @pay_items)
					file_name = "pay_item_report"
				elsif params[:report_type].to_i == 13 and dfl_report_check
					book = PaymentRegisterMillService.new({
																									pay_invoices: @pay_invoices
																								}).pf_deduction_excel(book)
					file_name = "pf_deduction"
				elsif params[:report_type].to_i == 14 and dfl_report_check
					book = PaymentRegisterMillService.new({
																									pay_invoices: @pay_invoices
																								}).pf_summary_excel(book, @company)
					file_name = "pf_summary"
				end
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def salary_letter
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find(params[:company_id])
		@pay_executions = PayExecution.where(:formated_pay_month => params[:pay_month].to_date.strftime("%B %Y"))
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq).order('id ASC')

		@pay_invoices = @pay_invoices.where(:employee_type_id => params[:employee_type_ids].map(&:to_i))
		salary_unit_ids  = params[:salary_unit_ids].map(&:to_i)
		@salary_units = SalaryUnit.where(:id => salary_unit_ids).order('id ASC')

		@employees = @employees.where(:payment_method => params[:payment_method])

		@pay_invoices = @pay_invoices.where(:employee_id => @employees.collect(&:id))
		@letter_type = params['letter_type']
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 2
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/salary_letter.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/salary_letter_footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.2in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 360,
					disable_smart_shrinking: true,
					page_size:'A3'
				)
				file_name = "salary_letter"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/salary_letter_sdl.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/salary_letter_footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.2in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 360,
					disable_smart_shrinking: true,
					page_size:'A3'
				)
				file_name = "salary_letter"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def eobi_report
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find_by(:formated_pay_month => params[:pay_month].to_date.strftime("%B %Y"))
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).non_struck_off.order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq).order('id ASC')
		@salary_unit_name = ""
		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
			end
		end
		#################### Hierarchical Permission ####################

		@pay_invoices = @pay_invoices.where(:employee_type_id => params[:employee_type_ids].map(&:to_i))

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if @pay_invoices.count > 0
			dfl_mill_report_check = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/eobi_report.json.jbuilder'
			elsif params[:report_type].to_i == 2
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/eobi_group_report.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "eobi_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 4
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				file_name = dfl_mill_report_check ? "eobi" : "eobi_report"
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "eobi_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 8
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/eobi_work_days_report.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "eobi_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 9
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/eobi_pr_02_report.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "eobi_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 10
				time = Time.now
				url_path = ""
				file_name = "eobi_form_report"
				url_path = save_pdf_file(pdf, file_name)
				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3 and dfl_mill_report_check
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				book = EOBIMillService.new({
																		 pay_invoices: @pay_invoices
																	 }).eobi_excel(book)
				file_name = "eobi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 3 and not dfl_mill_report_check
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'EOBI Report')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "CNIC", "Grade", "Designation", "Location", "Branch", "Department", "DOB", "DOJ", "Gross Salary", "Employee Contribution", "Employeer Contribution", "Total Contribution"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee
					employee_eobi_value 	=	PayRollReportData.employee_eobi_value(pay_invoice)
					employeer_eobi_value 	= PayRollReportData.employeer_eobi_value(pay_invoice)

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employee_eobi_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employeer_eobi_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (employee_eobi_value.to_f.round + employeer_eobi_value.to_f.round).to_f.round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "eobi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 5
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'EOBI Report')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				sheet.sheet_view.pane do |pane|
					pane.state = :frozen
					pane.y_split = 1
					pane.x_split = 2
				end

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				# sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				# sheet.add_row ['']
				# sheet.add_row ['']
				# sheet.add_row ['']
				# sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "CNIC", "Designation", "DOB", "DOJ", "Gross Salary", "Days", "Net Pay", "Employer Contribution", "	Employee Contribution", "Total Contribution"]
				sheet.add_row table_header, :style => header_style
				old_row_format 		= wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				footer_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				even_row_format 	= wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				total_actual_salary = 0
				total_net_pay = 0
				total_employeer_eobi_value = 0
				total_employee_eobi_value = 0
				total_contribution = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee
					employee_eobi_value 	=	PayRollReportData.employee_eobi_value(pay_invoice)
					employeer_eobi_value 	= PayRollReportData.employeer_eobi_value(pay_invoice)

					total_actual_salary 				= total_actual_salary + pay_invoice.actual_salary.to_f.round
					total_net_pay 							= total_net_pay + ((pay_invoice.total_earning.to_f.round - (pay_invoice.total_deduction.to_f.round + pay_invoice.monthly_tax.to_f.round)).to_f.round)
					total_employeer_eobi_value 	= total_employeer_eobi_value + employeer_eobi_value.to_f.round
					total_employee_eobi_value 	= total_employee_eobi_value + employee_eobi_value.to_f.round
					total_contribution 					= total_contribution + (employeer_eobi_value.to_f.round + employee_eobi_value.to_f.round).to_f.round

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						# current_row_value << (pay_invoice.no_of_pay_days - pay_invoice.deduction_days)
						# current_row_style << row_format
						# current_row_type << :float

						current_row_value << ((@pay_execution.pay_month.to_date.end_of_month).day - pay_invoice.deduction_days - pay_invoice.short_joining_days)
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.total_earning.to_f.round - (pay_invoice.total_deduction.to_f.round + pay_invoice.monthly_tax.to_f.round)).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employeer_eobi_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employee_eobi_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (employee_eobi_value.to_f.round + employeer_eobi_value.to_f.round).to_f.round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				sheet.add_row []

				row_format = old_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total"
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << total_actual_salary.to_f.round
				current_row_style << row_format
				current_row_type << :float

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << total_net_pay.to_f.round
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_employeer_eobi_value.to_f.round
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_employee_eobi_value.to_f.round
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_contribution.to_f.round
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row []

				row_format = old_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "NOTE: This calculation does not included Over time Incentive etc."
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row []
				sheet.add_row []
				sheet.add_row []

				row_format = footer_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Authorised Signature"
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row []
				sheet.add_row []
				sheet.add_row []

				row_format = old_row_format

				sheet.add_row ["", "", "", "", "", "", "", "", "", "EOBI -  Apportionment"], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string]
				sheet.add_row ["", "", "", "", "", "", "", "", "", "COST CENTER", "Employer", "Employee", "Total"], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format, row_format, row_format, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string, :string, :string, :string]
				sheet.add_row []

				cc_grand_total_employeer_eobi_value = 0
				cc_grand_total_employee_eobi_value = 0
				cc_grand_total_contribution = 0

				CostCenter.all.order('id ASC').each do |cost_center|
					cc_total_employeer_eobi_value = 0
					cc_total_employee_eobi_value = 0
					cc_total_contribution = 0
					@pay_invoices.where(:cost_center_id => cost_center.id).each do |pay_invoice|
						employee = pay_invoice.employee
						employee_eobi_value 	=	PayRollReportData.employee_eobi_value(pay_invoice)
						employeer_eobi_value 	= PayRollReportData.employeer_eobi_value(pay_invoice)

						cc_total_employeer_eobi_value 	= cc_total_employeer_eobi_value + employeer_eobi_value.to_f.round
						cc_total_employee_eobi_value 		= cc_total_employee_eobi_value + employee_eobi_value.to_f.round
						cc_total_contribution 					= cc_total_contribution + (employeer_eobi_value.to_f.round + employee_eobi_value.to_f.round).to_f.round
					end

					cc_grand_total_employeer_eobi_value = cc_grand_total_employeer_eobi_value + cc_total_employeer_eobi_value.to_f.round
					cc_grand_total_employee_eobi_value 	= cc_grand_total_employee_eobi_value + cc_total_employee_eobi_value.to_f.round
					cc_grand_total_contribution 				= cc_grand_total_contribution + cc_total_contribution.to_f.round


					sheet.add_row ["", "", "", "", "", "", "", "", "", cost_center.name, cc_total_employeer_eobi_value, cc_total_employee_eobi_value, cc_total_contribution], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format, row_format, row_format, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string, :float, :float, :float]
				end

				sheet.add_row []
				sheet.add_row ["", "", "", "", "", "", "", "", "", "Total", cc_grand_total_employeer_eobi_value, cc_grand_total_employee_eobi_value, cc_grand_total_contribution], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format, row_format, row_format, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string, :float, :float, :float]

				file_name = "eobi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 6
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'EOBI Report')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "Designation", "CNIC", "DOB", "DOJ", "EOBI No.", "Work Days", "Gross Salary", "Salary", "Amount. Witch Cont. Paid", "EOBI Amount (5%)", "Employeer Amount (1%)"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee
					employee_eobi_value 	=	PayRollReportData.employee_eobi_value(pay_invoice)
					employeer_eobi_value 	= PayRollReportData.employeer_eobi_value(pay_invoice)

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee.eobi_number
					current_row_style << row_format
					current_row_type << :string

					current_row_value << 26.0
					current_row_style << row_format
					current_row_type << :float

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 3000.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employee_eobi_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employeer_eobi_value.to_f.round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "eobi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 7
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'EOBI Report')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Insurance Person Registration No.", "CNIC", "Name", "Father Name", "Gender", "DOB", "DOJ", "DOL", "Days", "Employee Contribution", "Employeer Contribution", "Total Contribution"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee
					employee_eobi_value 	=	PayRollReportData.employee_eobi_value(pay_invoice)
					employeer_eobi_value 	= PayRollReportData.employeer_eobi_value(pay_invoice)

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << "-"
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee.gender
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << "-"
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "eobi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def pessi_report
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find_by(:formated_pay_month => params[:pay_month].to_date.strftime("%B %Y"))
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq).order('id ASC')
		@salary_unit_name = ""
		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
			end
		end
		#################### Hierarchical Permission ####################

		@pay_invoices = @pay_invoices.where(:employee_type_id => params[:employee_type_ids].map(&:to_i))

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if @pay_invoices.count > 0
			dfl_mill_report_check = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/pessi_report.json.jbuilder'
			elsif params[:report_type].to_i == 2
				file_name = "pessi_report"
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "pessi_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 4
				file_name = "pessi"
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "pessi_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3 and dfl_mill_report_check
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				book = PESSIMillService.new({
																			pay_invoices: @pay_invoices
																		}).pessi_excel(book)
				file_name = "pessi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 3 and not dfl_mill_report_check
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'PESSI Report')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "Designation", "CNIC", "DOB", "W.Days", "Gross Rate", "Salary", "Contribution Payable Amount", "PESSI Contribution"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << 26.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 10000
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 600
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "pessi_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def social_security_report
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find_by(:formated_pay_month => params[:pay_month].to_date.strftime("%B %Y"))
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :employee_id => @employees.collect(&:id).uniq).order('id ASC')
		@salary_unit_name = ""
		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
			end
		end
		#################### Hierarchical Permission ####################

		@pay_invoices = @pay_invoices.where(:employee_type_id => params[:employee_type_ids].map(&:to_i))

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/social_security_report.json.jbuilder'
			elsif params[:report_type].to_i == 3
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'SS Report')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				sheet.sheet_view.pane do |pane|
					pane.state = :frozen
					pane.y_split = 1
					pane.x_split = 2
				end

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				# sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				# sheet.add_row ['']
				# sheet.add_row ['']
				# sheet.add_row ['']
				# sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "CNIC", "Designation", "DOB", "DOJ", "Gross Salary", "Days", "Net Pay", "Contribution"]
				sheet.add_row table_header, :style => header_style
				old_row_format 		= wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				footer_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				even_row_format 	= wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				total_actual_salary = 0
				total_net_pay = 0
				total_social_security_pay = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee

					total_actual_salary 				= total_actual_salary + pay_invoice.actual_salary.to_f.round
					total_net_pay 							= total_net_pay + pay_invoice.payable_gross.to_f.round
					if pay_invoice.actual_salary.to_f.round <= 22000
						total_social_security_pay = total_social_security_pay + ((pay_invoice.payable_gross.to_f.round * 6).to_f/100.0).to_f.round
					end

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.no_of_pay_days - pay_invoice.deduction_days)
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.payable_gross.to_f.round
						current_row_style << row_format
						current_row_type << :float

						if pay_invoice.actual_salary.to_f.round <= 22000
							current_row_value << ((pay_invoice.payable_gross.to_f.round * 6).to_f/100.0).to_f.round
							current_row_style << row_format
							current_row_type << :float
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				sheet.add_row []

				row_format = old_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total"
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << total_actual_salary.to_f.round
				current_row_style << row_format
				current_row_type << :float

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				current_row_value << total_net_pay.to_f.round
				current_row_style << row_format
				current_row_type << :float

				current_row_value << total_social_security_pay.to_f.round
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row []

				row_format = old_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "NOTE: This calculation does not included Over time Incentive etc."
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "It is certified that the names of all permanent /temporary employees"
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "mentioned in above schedule who are working in this company against salary/wages."
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Further, the list of Left employees and new joiners is also in attachment."
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "All above credentials are best of my knowledge."
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row []
				sheet.add_row []
				sheet.add_row []

				row_format = footer_row_format

				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Authorised Signature"
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				sheet.add_row []
				sheet.add_row []
				sheet.add_row []

				row_format = old_row_format

				sheet.add_row ["", "", "", "", "", "", "", "", "", "Social Security Apportionment"], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string]
				sheet.add_row ["", "", "", "", "", "", "", "", "", "COST CENTER", "Amount"], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string, :string]
				sheet.add_row []

				cc_grand_total_social_security_pay = 0

				CostCenter.all.order('id ASC').each do |cost_center|
					cc_total_social_security_pay = 0
					@pay_invoices.where(:cost_center_id => cost_center.id).each do |pay_invoice|
						if pay_invoice.actual_salary.to_f.round <= 22000
							cc_total_social_security_pay = cc_total_social_security_pay + ((pay_invoice.payable_gross.to_f.round * 6).to_f/100.0).to_f.round
						end
					end
					cc_grand_total_social_security_pay = cc_grand_total_social_security_pay + cc_total_social_security_pay.to_f.round

					sheet.add_row ["", "", "", "", "", "", "", "", "", cost_center.name, cc_total_social_security_pay], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string, :float]
				end

				sheet.add_row []
				sheet.add_row ["", "", "", "", "", "", "", "", "", "Total", cc_grand_total_social_security_pay], :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, row_format, row_format], :types => [nil, nil, nil, nil, nil, nil, nil, nil, nil, :string, :float]

				file_name = "social_security_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def provident_fund_report
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@pay_execution 	= PayExecution.find_by(:formated_pay_month => params[:pay_month].to_date.strftime("%B %Y"))
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_month => params[:pay_month].to_date.strftime("%B %Y")).order('id ASC')
		@salary_unit_name = ""
		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
				@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
			end
		end
		#################### Hierarchical Permission ####################

		@pay_invoices = @pay_invoices.where(:employee_type_id => params[:employee_type_ids].map(&:to_i))

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/provident_fund_report.json.jbuilder'
			elsif params[:report_type].to_i == 2
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/provident_fund_group_report.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "provident_fund_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 4
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/provident_fund_report.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
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
				file_name = "provident_fund_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'PF Report')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "CNIC", "Grade", "Designation", "Location", "Branch", "Department", "Salary Unit", "Account Number", "DOB", "DOJ", "Gross Salary", "Basic Salary", "Employee PF", "Employeer PF", "Total PF"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee
					employee_pf_value 		=	PayRollReportData.employee_pf_value(pay_invoice)
					employeer_pf_value 		= PayRollReportData.employeer_pf_value(pay_invoice)
					basic_salary_value 		= PayRollReportData.basic_salary_value(pay_invoice)

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.employee.bank_account_number
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << basic_salary_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employee_pf_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << employeer_pf_value.to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (employee_pf_value.to_f.round + employeer_pf_value.to_f.round).to_f.round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "provident_fund_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def tax_certificate_filter_data
		@tax_certificate = TaxCertificate.where(:employee_id => params[:employee_id], :fiscal_year_id => params[:fiscal_year_id])
		render status:200, template: 'api/v1/web/reports/payroll_reports/tax_certificate_filter_data.json.jbuilder'
	end

	def export_tax_certificate
		@employee = Employee.find(params[:employee_id])
		@company = Company.find(@employee.company_id)
		fiscal_year = FiscalYear.find(params[:fiscal_year])
		@employee_tax_detail = EmployeeTaxableIncome.where(employee_id: @employee.id, status: true, :fiscal_year_id => fiscal_year.id)
		if @employee_tax_detail.present?
			check_tax_certificate_data = TaxCertificate.where(fiscal_year_id: params[:fiscal_year], employee_id: params[:employee_id])
			unless check_tax_certificate_data.present?
				tax_certificate_data = TaxCertificate.new(sr_number: params[:sr_number], employee_id: params[:employee_id], fiscal_year_id: params[:fiscal_year], date_of_issue: params[:date_of_issue])
				tax_certificate_data.save
			end
			check_directory("#{Rails.public_path}/pdf")
			pdf = WickedPdf.new.pdf_from_string(
				render_to_string("api/v1/web/reports/tax_certificate/tax_certificate.pdf.erb"),
				:margin => {
					:top      => '0.2in',
					:bottom   => '0.2in',
					:left     => '0.2in',
					:right    => '0.2in'
				},
				dpi: 300,
				orientation: 'Portrait',
				page_size: 'A4'
			)
			file_name = "tax_certificate"
			url_path = save_pdf_file(pdf, file_name)
			render json: {message: "Pdf Created", path: url_path}
		else
			render json: {errors: "No Tax Record Found"}, status: :unprocessable_entity
		end
	end

	def tax_report

		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@employees 			= if not params[:employees].blank?
												Employee.where(id:  params[:employees], :company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
											else
												Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
											end
		@pay_execution 	= PayExecution.find (params[:pay_execution_id])
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_execution_id => params[:pay_execution_id], :employee_id => @employees.collect(&:id).uniq).order('id ASC')
		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@pay_invoices = PayInvoice.where(:employee_id => @employees.collect(&:id).uniq)
			end
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
		end
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/tax_report.json.jbuilder'
			elsif params[:report_type].to_i == 3
				pay_item_ids 	= @pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
				pay_items  		= PayItem.where(:id => pay_item_ids).order('sort_order ASC')
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Tax Report')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Father Name", "CNIC", "Grade", "Designation", "Location", "Branch", "Department", "DOB", "DOJ", "Gross Salary", "Payable Salary", "Net Pay", "Income Tax"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@pay_invoices.each do |pay_invoice|
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

					employee = pay_invoice.employee
					monthly_tax_amount 		=	PayRollReportData.monthly_tax_amount(pay_invoice)

					current_row_value << pay_invoice.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << pay_invoice.employee_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.father_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.location_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << pay_invoice.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.date_of_birth)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee.joining_date)
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << pay_invoice.actual_salary.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << pay_invoice.payable_gross.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << monthly_tax_amount.round
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "tax_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 4
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Monthly Payable Tax Report')
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
				table_header = ["Sr #", "Payment Section", "TaxPayer_NTN", "TaxPayer_CNIC", "TaxPayer_Name", "TaxPayer_City", "TaxPayer_Address", "TaxPayer_Status", "TaxPayer_Business_Name", "Taxable_Amount", "Tax_Amount"]
				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				@pay_invoices.each_with_index do |pay_invoice, count|

					count = count + 1
					if count.even?
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
					total_amount = 0
					employee = pay_invoice.employee
					monthly_tax_amount 		=	PayRollReportData.monthly_tax_amount(pay_invoice)

					current_row_value << "149/4"
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.ntn_number
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.cnic_format(employee.cnic_number)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << "Lahore"
					current_row_style << row_format
					current_row_type << :string

					current_row_value << "7-AK Main Boulevard Gulberg 2 Lahore"
					current_row_style << row_format
					current_row_type << :string

					current_row_value << "INDIVIDUAL"
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ""
					current_row_style << row_format
					current_row_type << :string

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.total_taxable_amount.to_f
						end
					end

					current_row_value << ReportFormat.verification_of_nan(total_amount).to_f.round / 12
					current_row_style << row_format
					current_row_type << :float

					current_row_value << monthly_tax_amount.round
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "monthly_payable_tax_report"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def tax_structure
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false, :is_active => true).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		@salary_unit_name = ""

		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false, :is_active => true).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false, :is_active => true).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false, :is_active => true).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false, :is_active => true).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false, :is_active => true).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false, :is_active => true).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id DESC')
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@pay_invoices = PayInvoice.location_related_invoices(@pay_invoices, params[:location_id].to_i)
			@employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@pay_invoices = PayInvoice.branch_related_invoices(@pay_invoices, params[:branch_id].to_i)
			@employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@pay_invoices = PayInvoice.department_related_invoices(@pay_invoices, params[:department_id].to_i)
			@employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@pay_invoices = PayInvoice.designation_related_invoices(@pay_invoices, params[:designation_id].to_i)
			@employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@pay_invoices = PayInvoice.job_title_related_invoices(@pay_invoices, params[:job_title_id].to_i)
			@employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@pay_invoices = PayInvoice.grade_related_invoices(@pay_invoices, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
			@employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
			@pay_invoices = PayInvoice.salary_unit_related_invoices(@pay_invoices, params[:salary_unit_id].to_i)
			@employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@pay_invoices = PayInvoice.cost_center_related_invoices(@pay_invoices, params[:cost_center_id].to_i)
			@employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
		end
		if not params[:employee_type_id].blank?
			@pay_invoices = PayInvoice.employee_type_related_invoices(@pay_invoices, params[:employee_type_id].to_i)
			@employees = Employee.employee_type_related_employee(@employees, params[:employee_type_id].to_i)
		end

		fiscal_year = FiscalYear.find(params[:fiscal_year_id])

		start_date 	= fiscal_year.start_date
		end_date 		= fiscal_year.end_date
		date_range_monthly 	= (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date.strftime("%B %Y")}.uniq

		# @employees = @employees.where(:employee_code => "771501")
		# @pay_invoices = @pay_invoices.where(employee_id: Employee.find_by_employee_code('771501'))
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/tax_structure.json.jbuilder'
			elsif params[:report_type].to_i == 3
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook

				########################################################################################
				################################### Basic Salary 67% ###################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Basic Salary 67%')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				#################################### House Rent 37% ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'House Rent 37%')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["House Rent"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["House Rent"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Medical 8% ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Medical 8%')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Utilities 4.25% ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Utilities 4.25%')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Utility Allowance"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Utility Allowance"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Medical 2% ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Medical 2%')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical Allowance (OPD)"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical Allowance (OPD)"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				######################################### LWP ##########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'LWP')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Attendance Deduction"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Attendance Deduction"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Eid Reward ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Eid Reward')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				table_header << "Leave Encashment"
				table_header << "Annual Bonus"
				table_header << "Eid Reward 1"
				table_header << "Eid Reward 2"
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
						if pay_invoice_ids.count > 0
							pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
						end

						if not pay_invoice.nil?
							employee_taxable_income = pay_invoice.employee_taxable_income
							if not employee_taxable_income.nil?
								predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
								predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
								index0 = predition_item_names.index("Leave Encashment")
								index1 = predition_item_names.index("Annual Bonus")
								index2 = predition_item_names.index("Eid Reward 1")
								index3 = predition_item_names.index("Eid Reward 2")
								# if not index0.nil?
								# 	total_amount = total_amount + predition_item_amounts[index0].round
								# 	current_row_value << predition_item_amounts[index0].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end

								# if not index1.nil?
								# 	total_amount = total_amount + predition_item_amounts[index1].round
								# 	current_row_value << predition_item_amounts[index1].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end

								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								if not index2.nil?
									total_amount = total_amount + predition_item_amounts[index2].round
									current_row_value << predition_item_amounts[index2].round
									current_row_style << row_format
									current_row_type << :float
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end

								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Eid Reward 2"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Eid Reward 2"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								# if not index3.nil?
								# 	total_amount = total_amount + predition_item_amounts[index3].round
								# 	current_row_value << predition_item_amounts[index3].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						else
							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float
						end
					else
						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Arrears #########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Arrears')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				####################################### Allowance ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Allowance')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Increment Arrears ##################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Increment Arrears')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Increment Arrears"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Increment Arrears"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				########################################## Loan ########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Loan')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							employee_loan	= EmployeeLoan.find_by(:employee_id => employee.id)

							if not employee_loan.nil?
								total_amount = total_amount + employee_loan.employee_loan_details.where(:formated_month => single_item).sum(:loan_interest_amount).round
								current_row_value << employee_loan.employee_loan_details.where(:formated_month => single_item).sum(:loan_interest_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				######################################## Tax Paid ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Paid')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.monthly_tax.to_f.round
								current_row_value << pay_invoice.monthly_tax.to_f.round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Tax Credit ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Credit')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							total_amount = total_amount + EmployeeTaxCredit.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year.id, :tax_credit_formatted_month => single_item).sum(:tax_credit_amount).round
							current_row_value << EmployeeTaxCredit.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year.id, :tax_credit_formatted_month => single_item).sum(:tax_credit_amount).round
							current_row_style << row_format
							current_row_type << :float
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Tax Computation ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Computation')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit", "Prev Taxable Amount", "Current Taxable Amount", "Taxable Amount To Date", "Predicated Taxable Amount", "Loan Interest Amount", "Gross Salary", "Total Taxable Amount", "Tax Created", "Yearly Total Tax", "Monthly Tax Amount", "Total Paid Tax", "Remaing Tax To Be Paid", "Leave Encashment", "Annual Bonus", "Eid Reward 1", "Eid Reward 2", "Conveyance @ 5 % of purchase price (Notional Income)", "PF Tax Value", "Other Allowance Prediction"]

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				old1_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@employees.each do |employee|

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
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

							current_row_value << employee.employee_code.to_i
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee.salary_unit_name
							current_row_style << row_format
							current_row_type << :string

							if @show_salary == true

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.prev_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.taxable_amount_to_date.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.predicated_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.loan_interest_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.gross_salary.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount).to_f.round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.yearly_total_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.monthly_tax_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_paid_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.remaing_tax_to_be_paid.to_f)
								current_row_style << row_format

								predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
								predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
								index0 = predition_item_names.index("Leave Encashment")
								index1 = predition_item_names.index("Annual Bonus")
								index2 = predition_item_names.index("Eid Reward 1")
								index3 = predition_item_names.index("Eid Reward 2")
								# if not index0.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index0].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << ReportFormat.zero_to_dash(0.0)
								# 	current_row_style << row_format
								# end

								# if not index1.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index1].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << ReportFormat.zero_to_dash(0.0)
								# 	current_row_style << row_format
								# end

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).round)
								current_row_style << row_format

								if not index2.nil?
									current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index2].round)
									current_row_style << row_format
								else
									current_row_value << ReportFormat.zero_to_dash(0.0)
									current_row_style << row_format
								end

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Eid Reward 2"]).sum(:amount).round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.pf_tax_value.to_f)
								current_row_style << row_format


								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.annualize_predicated_taxable_amount.to_f)
								current_row_style << row_format
							end

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end

				end

				file_name = "tax_structure"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 4
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook

				########################################################################################
				################################### Basic Salary 67% ###################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Basic Salary 67%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				basic_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					basic_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Basic Salary")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					basic_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					basic_array << basic_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				#################################### House Rent 37% ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'House Rent 37%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				house_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					house_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["House Rent"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["House Rent"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "House Rent")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					house_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					house_array << house_obj

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Medical 8% ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Medical 8%')
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

				medical_array = []

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					# if @show_salary == true

					# 	total_amount = 0

					# 	date_range_monthly.each do |single_item|

					# 		pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

					# 		if not pay_invoice.nil?
					# 			total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:taxable_amount).round
					# 			current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:taxable_amount).round
					# 			current_row_style << row_format
					# 			current_row_type << :float
					# 		else
					# 			current_row_value << 0.0
					# 			current_row_style << row_format
					# 			current_row_type << :float
					# 		end
					# 	end
					# else
					# 	date_range_monthly.each do |single_item|
					# 		current_row_value << "-"
					# 		current_row_style << row_format
					# 		current_row_type << :string
					# 	end
					# end

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					medical_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Medical")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					medical_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					medical_array << medical_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Utilities 4.25% ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Utilities 4.25%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				utility_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					utility_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Utility Allowance"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Utility Allowance"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Utility Allowance")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					utility_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					utility_array << utility_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Medical 2% ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Medical 2%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				medical_allowance_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					utility_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical Allowance (OPD)"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical Allowance (OPD)"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Medical Allowance (OPD)")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					medical_allowance_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					medical_allowance_array << medical_allowance_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				######################################### LWP ##########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'LWP')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Deduction", "Allowance Deduction", "Attendance Deduction"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Deduction", "Allowance Deduction", "Attendance Deduction"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Eid Reward ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Eid Reward')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				table_header << "Leave Encashment"
				table_header << "Annual Bonus"
				table_header << "Eid Reward 1"
				table_header << "Eid Reward 2"
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
						if pay_invoice_ids.count > 0
							pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
						end

						if not pay_invoice.nil?
							employee_taxable_income = pay_invoice.employee_taxable_income
							if not employee_taxable_income.nil?
								predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
								predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
								index0 = predition_item_names.index("Leave Encashment")
								index1 = predition_item_names.index("Annual Bonus")
								index2 = predition_item_names.index("Eid Reward 1")
								index3 = predition_item_names.index("Eid Reward 2")

								# if not index0.nil?
								# 	total_amount = total_amount + predition_item_amounts[index0].round
								# 	current_row_value << predition_item_amounts[index0].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end

								# if not index1.nil?
								# 	total_amount = total_amount + predition_item_amounts[index1].round
								# 	current_row_value << predition_item_amounts[index1].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end


								total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Leave Encashment"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float


								total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round
								current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								if not index2.nil?
									total_amount = total_amount + predition_item_amounts[index2].round
									current_row_value << predition_item_amounts[index2].round
									current_row_style << row_format
									current_row_type << :float
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end

								total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
								current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								# if not index3.nil?
								# 	total_amount = total_amount + predition_item_amounts[index3].round
								# 	current_row_value << predition_item_amounts[index3].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						else
							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float
						end
					else
						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Arrears #########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Arrears')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				####################################### Allowance ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Allowance')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				annualize_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					annualize_obj = {}
					if @show_salary == true

						total_amount = 0
						employee_total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:taxable_amount).round
								employee_total_amount = employee_total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											total_item_value = 0
											pay_item = PayItem.find_by(:name => "Other Allowance")
											if not pay_item.nil?
												if pay_item.annualize == true
													total_item_value = total_item_value + PayItem.calculate_formula(employee, pay_item, pay_invoice).to_f.round
												end
											end
											pay_item = PayItem.find_by(:name => "Fuel Allowance")
											if not pay_item.nil?
												if pay_item.annualize == true
													total_item_value = total_item_value + PayItem.calculate_formula(employee, pay_item, pay_invoice).to_f.round
												end
											end
											total_amount = total_amount + total_item_value.to_f.round
											current_row_value << total_item_value.to_f.round
											current_row_style << row_format
											current_row_type << :float
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float
					annualize_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => employee_total_amount
					}
					annualize_array << annualize_obj
					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Increment Arrears ##################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Increment Arrears')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Increment Arrears"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Increment Arrears"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				########################################## Loan ########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Loan')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							employee_loan	= EmployeeLoan.find_by(:employee_id => employee.id)

							if not employee_loan.nil?
								total_amount = total_amount + employee_loan.employee_loan_details.where(:formated_month => single_item).sum(:loan_interest_amount).round
								current_row_value << employee_loan.employee_loan_details.where(:formated_month => single_item).sum(:loan_interest_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				######################################## Tax Paid ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Paid')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.monthly_tax.to_f.round
								current_row_value << pay_invoice.monthly_tax.to_f.round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Tax Credit ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Credit')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							total_amount = total_amount + EmployeeTaxCredit.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year.id, :tax_credit_formatted_month => single_item).sum(:tax_credit_amount).round
							current_row_value << EmployeeTaxCredit.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year.id, :tax_credit_formatted_month => single_item).sum(:tax_credit_amount).round
							current_row_style << row_format
							current_row_type << :float
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Tax Computation ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Computation')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)

				table_header = ["#{@company.name}"]
				sheet.add_row table_header, :style => header_style

				table_header = ["Employees I.Tax calculation"]
				sheet.add_row table_header, :style => header_style

				table_header = ["#{fiscal_year.name}"]

				@employees.each_with_index do |employee, index|
					table_header << "#{index + 1}"
				end
				sheet.add_row table_header, :style => header_style

				table_header = ["Employee Code"]

				@employees.each do |employee|
					table_header << "#{employee.employee_code}"
				end
				sheet.add_row table_header, :style => header_style

				table_header = ["Taxable persons"]

				@employees.each do |employee|
					table_header << "#{employee.first_name}"
				end
				sheet.add_row table_header, :style => header_style

				table_header = ["Description"]

				@employees.each do |employee|
					table_header << "#{employee.last_name}"
				end
				sheet.add_row table_header, :style => header_style

				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				old1_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				sheet.add_row []

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Car provided by Company"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					current_row_value << ReportFormat.boolean_in_text(employee.velicle_allowed)
					current_row_style << row_format
					current_row_type << :string
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Purchase price of Car"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					current_row_value << ReportFormat.zero_to_dash(employee.vehicle_value.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Computation of taxable income"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					current_row_value << ""
					current_row_style << row_format
					current_row_type << :string
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type


				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Basic Salary"
				current_row_style << row_format
				current_row_type << :string
				@employees.each do |employee|
					basic_amount = 0
					basic_selected_item = basic_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if basic_selected_item.count == 1
						basic_amount = basic_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(basic_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "House Rent @ 37 % of Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					house_amount = 0
					house_selected_item = house_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if house_selected_item.count == 1
						house_amount = house_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(house_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Medical Allowance @ 8% of Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					medical_amount = 0
					medical_selected_item = medical_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_selected_item.count == 1
						medical_amount = medical_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(medical_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Utilities @ 4.25 % of Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					utility_amount = 0
					utility_selected_item = utility_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if utility_selected_item.count == 1
						utility_amount = utility_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(utility_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type


				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Eid Reward 50% of Basic Salary of each eid"
				current_row_style << row_format
				current_row_type << :string
				employee_bonus = {}
				@employees.each do |employee|
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end
					total_amount = 0

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
							predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
							index2 = predition_item_names.index("Eid Reward 1")
							index1 = predition_item_names.index("Eid Reward 2")
							# here
							index3 = predition_item_names.index("Leave Encashment")
							index4 = predition_item_names.index("Annual Bonus")
							total_amount = total_amount + predition_item_amounts[index2].round if index2.present?
							total_amount = total_amount + predition_item_amounts[index1].round if index1.present?
							bonus_data = {}
							bonus_data['leaves'] =predition_item_amounts[index3].round if index3.present?
							bonus_data['bonus'] = predition_item_amounts[index4].round if index4.present?
							bonus_data['eid_reward'] = total_amount
							employee_bonus[employee.employee_code] = bonus_data
						end
					end

					current_row_value << ReportFormat.zero_to_dash(total_amount)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Annual Bonus"
				current_row_style << row_format
				current_row_type << :string
				@employees.each do |employee|
					if employee_bonus[employee].present?
						current_row_value << employee_bonus[employee.employee_code]['bonus']
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float
					end
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Leaves Encashment"
				current_row_style << row_format
				current_row_type << :string
				single_item = PayItem.find_by_name('Leave Encashment')

				@employees.each do |employee|
					if employee_bonus[employee].present?
						current_row_value << employee_bonus[employee.employee_code]['leaves']
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float
					end
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type


				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Mark up on Loan @  10 % p.a (Notional Income)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					loan_interest_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							loan_interest_amount = loan_interest_amount + employee_taxable_income.loan_interest_amount.to_f
						end
					end

					current_row_value << ReportFormat.zero_to_dash(loan_interest_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Other Allowance"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					(date_range_monthly).each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance", "Bike Fuel Allowance"]).sum(:taxable_amount).round
						end
					end

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.annualize_predicated_taxable_amount.to_f
						end
					end

					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Arrears/Overtime"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Employer PF Contribution above 150,000 (Notional Income)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					pf_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							pf_tax_value = pf_tax_value + employee_taxable_income.pf_tax_value.to_f
						end
					end

					current_row_value << ReportFormat.zero_to_dash(pf_tax_value.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Conveyance @ 5 % of purchase price (Notional Income)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					vehicle_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							vehicle_tax_value = vehicle_tax_value + (employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
						end
					end

					current_row_value << ReportFormat.zero_to_dash(vehicle_tax_value.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Medical Allowance @ 2 % of Basic Salary(Exempt)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					medical_allowance_amount = 0
					medical_allowance_selected_item = medical_allowance_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_allowance_selected_item.count == 1
						medical_allowance_amount = medical_allowance_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(medical_allowance_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total Employer Contribution of Tax"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0

					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_salary = 0

					basic_selected_item = basic_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if basic_selected_item.count == 1
						total_salary = total_salary + basic_selected_item[0][:employee_total_amount]
					end

					house_selected_item = house_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if house_selected_item.count == 1
						total_salary = total_salary + house_selected_item[0][:employee_total_amount]
					end

					medical_amount = 0
					medical_selected_item = medical_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_selected_item.count == 1
						total_salary = total_salary + medical_selected_item[0][:employee_total_amount]
					end

					utility_amount = 0
					utility_selected_item = utility_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if utility_selected_item.count == 1
						total_salary = total_salary + utility_selected_item[0][:employee_total_amount]
					end

					# pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					# total_salary = total_salary + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Leave Encashment"]).sum(:amount).round

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end
					total_amount = 0

					# if not pay_invoice.nil?
					# 	employee_taxable_income = pay_invoice.employee_taxable_income
					# 	if not employee_taxable_income.nil?
					# 		predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
					# 		predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
					# 		index2 = predition_item_names.index("Eid Reward 1")
					# 		index1 = predition_item_names.index("Eid Reward 2")
					# 		if not index2.nil?
					# 			total_amount = total_amount + predition_item_amounts[index2].round
					# 		end
					# 		if not index1.nil?
					# 			total_amount = total_amount + predition_item_amounts[index1].round
					# 		end
					# 	end
					# end

					# total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
					# total_salary = total_salary + total_amount

					# pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					# total_salary = total_salary + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round

					loan_interest_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							loan_interest_amount = loan_interest_amount + employee_taxable_income.loan_interest_amount.to_f
						end
					end

					total_salary = total_salary + loan_interest_amount.to_f

					total_amount = 0
					(date_range_monthly).each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance", "Bike Fuel Allowance"]).sum(:taxable_amount).round
						end
					end

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.annualize_predicated_taxable_amount.to_f
						end
					end

					total_salary = total_salary + total_amount.to_f

					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
						end
					end
					total_salary = total_salary + total_amount.to_f

					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear"]).sum(:amount).round
						end
					end
					total_salary = total_salary + total_amount.to_f

					pf_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							pf_tax_value = pf_tax_value + employee_taxable_income.pf_tax_value.to_f
						end
					end
					total_salary = total_salary + pf_tax_value

					vehicle_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							vehicle_tax_value = vehicle_tax_value + (employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
						end
					end

					total_salary = total_salary + vehicle_tax_value.to_f

					medical_allowance_amount = 0
					medical_allowance_selected_item = medical_allowance_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_allowance_selected_item.count == 1
						medical_allowance_amount = medical_allowance_selected_item[0][:employee_total_amount]
					end
					if employee_bonus[employee].present?
						total_salary = total_salary + medical_allowance_amount.to_f + employee_bonus[employee.employee_code]['bonus'].to_f + employee_bonus[employee.employee_code]['leaves'].to_f + employee_bonus[employee.employee_code]['eid_reward'].to_f
					else
						total_salary = total_salary + medical_allowance_amount.to_f
					end


					current_row_value << ReportFormat.zero_to_dash(total_salary.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Exempt"
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Medical Allowance @ 10 % of Basic Salary(Exempt)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					medical_selected_item = medical_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_selected_item.count == 1
						total_amount = total_amount + medical_selected_item[0][:employee_total_amount]
					end

					medical_allowance_selected_item = medical_allowance_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_allowance_selected_item.count == 1
						total_amount = total_amount + medical_allowance_selected_item[0][:employee_total_amount]
					end

					md_total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							md_total_amount = md_total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear"]).sum(:taxable_amount).round
						end
					end
					total_amount = total_amount + md_total_amount.to_f

					extra_md_total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							salary_arrears = pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears"]).sum(:taxable_amount).round
							if salary_arrears > 0
								taxable_amount = ((((salary_arrears.to_f/100.0)*67)/100.0)*8)
								extra_md_total_amount = extra_md_total_amount + taxable_amount.round
							end
						end
					end
					total_amount = total_amount + extra_md_total_amount.to_f

					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Leave Without Pay"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Attendance Deduction", "Salary Deduction", "Allowance Deduction"]).sum(:amount).round
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Taxable Income"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.total_taxable_amount.to_f
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end
				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Taxpayable (Normal)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.yearly_total_tax.to_f
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Tax Deducted"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + (employee_taxable_income.total_paid_tax.to_f + employee_taxable_income.monthly_tax_amount.to_f)
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total Balance Tax"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + (employee_taxable_income.remaing_tax_to_be_paid.to_f - employee_taxable_income.monthly_tax_amount.to_f)
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				file_name = "tax_structure"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			elsif params[:report_type].to_i == 5
				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook

				########################################################################################
				################################### Basic Salary 67% ###################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Basic Salary 67%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				basic_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					basic_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Basic Salary")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					basic_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					basic_array << basic_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				#################################### House Rent 37% ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'House Rent 37%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				house_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					house_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["House Rent"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["House Rent"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "House Rent")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					house_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					house_array << house_obj

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Medical 8% ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Medical 8%')
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

				medical_array = []

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					# if @show_salary == true

					# 	total_amount = 0

					# 	date_range_monthly.each do |single_item|

					# 		pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

					# 		if not pay_invoice.nil?
					# 			total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:taxable_amount).round
					# 			current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:taxable_amount).round
					# 			current_row_style << row_format
					# 			current_row_type << :float
					# 		else
					# 			current_row_value << 0.0
					# 			current_row_style << row_format
					# 			current_row_type << :float
					# 		end
					# 	end
					# else
					# 	date_range_monthly.each do |single_item|
					# 		current_row_value << "-"
					# 		current_row_style << row_format
					# 		current_row_type << :string
					# 	end
					# end

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					medical_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Medical")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					medical_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					medical_array << medical_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Utilities 4.25% ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Utilities 4.25%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				utility_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					utility_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Utility Allowance"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Utility Allowance"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Utility Allowance")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					utility_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					utility_array << utility_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Medical 2% ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Medical 2%')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				medical_allowance_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					utility_obj = {}

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Medical Allowance (OPD)"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Medical Allowance (OPD)"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											pay_item = PayItem.find_by(:name => "Medical Allowance (OPD)")
											if not pay_item.nil?
												item_value = PayItem.calculate_formula(employee, pay_item, pay_invoice)
												total_amount = total_amount + item_value.to_f.round
												current_row_value << item_value.to_f.round
												current_row_style << row_format
												current_row_type << :float
											else
												current_row_value << 0.0
												current_row_style << row_format
												current_row_type << :float
											end
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					medical_allowance_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => total_amount
					}
					medical_allowance_array << medical_allowance_obj

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				######################################### LWP ##########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'LWP')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Deduction", "Allowance Deduction", "Attendance Deduction"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Deduction", "Allowance Deduction", "Attendance Deduction"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Eid Reward ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Eid Reward')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				table_header << "Leave Encashment"
				table_header << "Annual Bonus"
				table_header << "Eid Reward 1"
				table_header << "Eid Reward 2"
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
						if pay_invoice_ids.count > 0
							pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
						end

						if not pay_invoice.nil?
							employee_taxable_income = pay_invoice.employee_taxable_income
							if not employee_taxable_income.nil?
								predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
								predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
								index0 = predition_item_names.index("Leave Encashment")
								index1 = predition_item_names.index("Annual Bonus")
								index2 = predition_item_names.index("Eid Reward 1")
								index3 = predition_item_names.index("Eid Reward 2")

								# if not index0.nil?
								# 	total_amount = total_amount + predition_item_amounts[index0].round
								# 	current_row_value << predition_item_amounts[index0].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end

								# if not index1.nil?
								# 	total_amount = total_amount + predition_item_amounts[index1].round
								# 	current_row_value << predition_item_amounts[index1].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end


								total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Leave Encashment"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float


								total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round
								current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								if not index2.nil?
									total_amount = total_amount + predition_item_amounts[index2].round
									current_row_value << predition_item_amounts[index2].round
									current_row_style << row_format
									current_row_type << :float
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end

								total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
								current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float

								# if not index3.nil?
								# 	total_amount = total_amount + predition_item_amounts[index3].round
								# 	current_row_value << predition_item_amounts[index3].round
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# 	current_row_type << :float
								# end
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float

								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						else
							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float

							current_row_value << 0.0
							current_row_style << row_format
							current_row_type << :float
						end
					else
						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Arrears #########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Arrears')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				####################################### Allowance ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Allowance')
				book.use_autowidth = false
				sheet.sheet_view do |view|
					view.show_outline_symbols = true
				end
				book.use_autowidth = true

				annualize_array = []

				cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
				sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']
				sheet.add_row ['']

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					remaining_tax_year_month = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						last_invoice = @pay_invoices.find(pay_invoice_ids.last)
						if not last_invoice.nil?
							remaining_tax_year_month = last_invoice.remaining_tax_year_month
						end
					end

					annualize_obj = {}
					if @show_salary == true

						total_amount = 0
						employee_total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:taxable_amount).round
								employee_total_amount = employee_total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								if remaining_tax_year_month > 0
									item_index = date_range_monthly.index(single_item)
									if not item_index.nil?
										item_index = item_index + 1
										if item_index > (12 - remaining_tax_year_month)
											total_item_value = 0
											pay_item = PayItem.find_by(:name => "Other Allowance")
											if not pay_item.nil?
												if pay_item.annualize == true
													total_item_value = total_item_value + PayItem.calculate_formula(employee, pay_item, pay_invoice).to_f.round
												end
											end
											pay_item = PayItem.find_by(:name => "Fuel Allowance")
											if not pay_item.nil?
												if pay_item.annualize == true
													total_item_value = total_item_value + PayItem.calculate_formula(employee, pay_item, pay_invoice).to_f.round
												end
											end
											total_amount = total_amount + total_item_value.to_f.round
											current_row_value << total_item_value.to_f.round
											current_row_style << row_format
											current_row_type << :float
										else
											current_row_value << 0.0
											current_row_style << row_format
											current_row_type << :float
										end
									else
										current_row_value << 0.0
										current_row_style << row_format
										current_row_type << :float
									end
								else
									current_row_value << 0.0
									current_row_style << row_format
									current_row_type << :float
								end
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float
					annualize_obj = {
						:employee_code => employee.employee_code,
						:employee_total_amount => employee_total_amount
					}
					annualize_array << annualize_obj
					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Increment Arrears ##################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Increment Arrears')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Increment Arrears"]).sum(:taxable_amount).round
								current_row_value << pay_invoice.pay_invoice_details.where(:item_name => ["Increment Arrears"]).sum(:taxable_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				########################################## Loan ########################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Loan')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							employee_loan	= EmployeeLoan.find_by(:employee_id => employee.id)

							if not employee_loan.nil?
								total_amount = total_amount + employee_loan.employee_loan_details.where(:formated_month => single_item).sum(:loan_interest_amount).round
								current_row_value << employee_loan.employee_loan_details.where(:formated_month => single_item).sum(:loan_interest_amount).round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				######################################## Tax Paid ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Paid')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

							if not pay_invoice.nil?
								total_amount = total_amount + pay_invoice.monthly_tax.to_f.round
								current_row_value << pay_invoice.monthly_tax.to_f.round
								current_row_style << row_format
								current_row_type << :float
							else
								current_row_value << 0.0
								current_row_style << row_format
								current_row_type << :float
							end
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				###################################### Tax Credit ######################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Credit')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit"]
				date_range_monthly.each do |single_item|
					table_header << single_item
				end
				table_header << "Total"
				sheet.add_row table_header, :style => header_style
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.salary_unit_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true

						total_amount = 0

						date_range_monthly.each do |single_item|

							total_amount = total_amount + EmployeeTaxCredit.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year.id, :tax_credit_formatted_month => single_item).sum(:tax_credit_amount).round
							current_row_value << EmployeeTaxCredit.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year.id, :tax_credit_formatted_month => single_item).sum(:tax_credit_amount).round
							current_row_style << row_format
							current_row_type << :float
						end
					else
						date_range_monthly.each do |single_item|
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << total_amount
					current_row_style << row_format
					current_row_type << :float

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end

				########################################################################################
				################################### Tax Computation ####################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Computation')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit", "Prev Taxable Income", "Current Taxable Income", "Taxable Amount To Date", "Predicated Taxable Amount", "Loan Interest Amount", "Gross Salary", "Total Taxable Amount", "Tax Created", "Yearly Total Tax", "Monthly Tax Amount", "Total Paid Tax", "Remaing Tax To Be Paid", "Leave Encashment", "Annual Bonus", "Eid Reward 1", "Eid Reward 2", "Conveyance @ 5 % of purchase price (Notional Income)", "PF Tax Value", "Other Allowance Prediction"]

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				old1_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@employees.each do |employee|

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
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

							current_row_value << employee.employee_code.to_i
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee.salary_unit_name
							current_row_style << row_format
							current_row_type << :string

							if @show_salary == true

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.prev_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.taxable_amount_to_date.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.predicated_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.loan_interest_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.gross_salary.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount).to_f.round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.yearly_total_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.monthly_tax_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_paid_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.remaing_tax_to_be_paid.to_f)
								current_row_style << row_format

								predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
								predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
								index0 = predition_item_names.index("Leave Encashment")
								index1 = predition_item_names.index("Annual Bonus")
								index2 = predition_item_names.index("Eid Reward 1")
								index3 = predition_item_names.index("Eid Reward 2")

								# if not index0.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index0].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << ReportFormat.zero_to_dash(0.0)
								# 	current_row_style << row_format
								# end

								# if not index1.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index1].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << ReportFormat.zero_to_dash(0.0)
								# 	current_row_style << row_format
								# end

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).round)
								current_row_style << row_format

								if not index2.nil?
									current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index2].round)
									current_row_style << row_format
								else
									current_row_value << ReportFormat.zero_to_dash(0.0)
									current_row_style << row_format
								end

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Eid Reward 2"]).sum(:amount).round)
								current_row_style << row_format

								# if not index3.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index3].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# end

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.pf_tax_value.to_f)
								current_row_style << row_format


								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.annualize_predicated_taxable_amount.to_f)
								current_row_style << row_format
							end

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end

				end

				########################################################################################
				################################## Tax Computation 2 ###################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Computation 2')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Salary Unit", "Gross Salary", "Total Vehicle Value", "Basic Salary", "House Rent", "Utility Allowance", "Leave Encashment", "Annual Bonus", "Eid Reward 1", "Eid Reward 2", "Arrears", "Conveyance @ 5 % of purchase price (Notional Income)", "Loan Interest Amount", "PF Tax Value", "Other Allowance Prediction", "Total Taxable Amount", "Tax Created", "Yearly Total Tax", "Monthly Tax Amount", "Total Paid Tax", "Remaing Tax To Be Paid"]

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				old1_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				@employees.each do |employee|

					arrear_total_amount = 0

					date_range_monthly.each do |single_item|

						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)

						if not pay_invoice.nil?
							arrear_total_amount = arrear_total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:taxable_amount).round
						end
					end

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
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

							current_row_value << employee.employee_code.to_i
							current_row_style << row_format
							current_row_type << :integer

							current_row_value << employee.full_name
							current_row_style << row_format
							current_row_type << :string

							current_row_value << employee.salary_unit_name
							current_row_style << row_format
							current_row_type << :string

							if @show_salary == true

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.gross_salary.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee.vehicle_value.to_f)
								current_row_style << row_format

								basic_amount = 0
								basic_selected_item = basic_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

								if basic_selected_item.count == 1
									basic_amount = basic_selected_item[0][:employee_total_amount]
								end

								current_row_value << ReportFormat.zero_to_dash(basic_amount.to_f)
								current_row_style << row_format

								house_amount = 0
								house_selected_item = house_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

								if house_selected_item.count == 1
									house_amount = house_selected_item[0][:employee_total_amount]
								end

								current_row_value << ReportFormat.zero_to_dash(house_amount.to_f)
								current_row_style << row_format

								utility_amount = 0
								utility_selected_item = utility_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

								if utility_selected_item.count == 1
									utility_amount = utility_selected_item[0][:employee_total_amount]
								end

								current_row_value << ReportFormat.zero_to_dash(utility_amount.to_f)
								current_row_style << row_format

								predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
								predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
								index0 = predition_item_names.index("Leave Encashment")
								index1 = predition_item_names.index("Annual Bonus")
								index2 = predition_item_names.index("Eid Reward 1")
								index3 = predition_item_names.index("Eid Reward 2")

								# if not index0.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index0].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << ReportFormat.zero_to_dash(0.0)
								# 	current_row_style << row_format
								# end

								# if not index1.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index1].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << ReportFormat.zero_to_dash(0.0)
								# 	current_row_style << row_format
								# end

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Leave Encashment"]).sum(:amount).round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Annual Bonus"]).sum(:amount).round)
								current_row_style << row_format

								if not index2.nil?
									current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index2].round)
									current_row_style << row_format
								else
									current_row_value << ReportFormat.zero_to_dash(0.0)
									current_row_style << row_format
								end

								current_row_value << ReportFormat.zero_to_dash(pay_invoice.pay_invoice_details.where(:item_name => ["Eid Reward 2"]).sum(:amount).round)
								current_row_style << row_format

								# if not index3.nil?
								# 	current_row_value << ReportFormat.zero_to_dash(predition_item_amounts[index3].round)
								# 	current_row_style << row_format
								# else
								# 	current_row_value << 0.0
								# 	current_row_style << row_format
								# end

								current_row_value << ReportFormat.zero_to_dash(arrear_total_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.loan_interest_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.pf_tax_value.to_f)
								current_row_style << row_format

								annualize_predicated_taxable_amount = employee_taxable_income.annualize_predicated_taxable_amount.to_f
								selected_item = annualize_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

								if selected_item.count == 1
									annualize_predicated_taxable_amount = employee_taxable_income.annualize_predicated_taxable_amount.to_f + selected_item[0][:employee_total_amount]
								end
								current_row_value << ReportFormat.zero_to_dash(annualize_predicated_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_taxable_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount).to_f.round)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.yearly_total_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.monthly_tax_amount.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_paid_tax.to_f)
								current_row_style << row_format

								current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.remaing_tax_to_be_paid.to_f)
								current_row_style << row_format

							end

							sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
						end
					end

				end

				########################################################################################
				############################### Tax Computation Master #################################
				########################################################################################

				sheet = wb.add_worksheet(name: 'Tax Computation Master')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)

				table_header = ["#{@company.name}"]
				sheet.add_row table_header, :style => header_style

				table_header = ["Employees I.Tax calculation"]
				sheet.add_row table_header, :style => header_style

				table_header = ["#{fiscal_year.name}"]

				@employees.each_with_index do |employee, index|
					table_header << "#{index + 1}"
				end
				sheet.add_row table_header, :style => header_style

				table_header = ["Employee Code"]

				@employees.each do |employee|
					table_header << "#{employee.employee_code}"
				end
				sheet.add_row table_header, :style => header_style

				table_header = ["Taxable persons"]

				@employees.each do |employee|
					table_header << "#{employee.first_name}"
				end
				sheet.add_row table_header, :style => header_style

				table_header = ["Description"]

				@employees.each do |employee|
					table_header << "#{employee.last_name}"
				end
				sheet.add_row table_header, :style => header_style

				old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				old1_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0

				sheet.add_row []

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Car provided by Company"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					current_row_value << ReportFormat.boolean_in_text(employee.velicle_allowed)
					current_row_style << row_format
					current_row_type << :string
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Purchase price of Car"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					current_row_value << ReportFormat.zero_to_dash(employee.vehicle_value.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Computation of taxable income"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					current_row_value << ""
					current_row_style << row_format
					current_row_type << :string
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type


				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					basic_amount = 0
					basic_selected_item = basic_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if basic_selected_item.count == 1
						basic_amount = basic_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(basic_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "House Rent @ 37 % of Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					house_amount = 0
					house_selected_item = house_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if house_selected_item.count == 1
						house_amount = house_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(house_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Medical Allowance @ 8% of Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					medical_amount = 0
					medical_selected_item = medical_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_selected_item.count == 1
						medical_amount = medical_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(medical_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Utilities @ 4.25 % of Basic Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					utility_amount = 0
					utility_selected_item = utility_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if utility_selected_item.count == 1
						utility_amount = utility_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(utility_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Leaves Encashment"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					current_row_value << ReportFormat.zero_to_dash(PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Leave Encashment"]).sum(:amount).round)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Eid Reward 50% of Basic Salary of each eid"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end
					total_amount = 0

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
							predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
							index2 = predition_item_names.index("Eid Reward 1")
							if not index2.nil?
								total_amount = total_amount + predition_item_amounts[index2].round
							end
						end
					end

					total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
					current_row_value << ReportFormat.zero_to_dash(total_amount)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Annual Bonus"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					current_row_value << ReportFormat.zero_to_dash(PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Mark up on Loan @  10 % p.a (Notional Income)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					loan_interest_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							loan_interest_amount = loan_interest_amount + employee_taxable_income.loan_interest_amount.to_f
						end
					end

					current_row_value << ReportFormat.zero_to_dash(loan_interest_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Other Allowance"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance", "Bike Fuel Allowance"]).sum(:taxable_amount).round
						end
					end

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.annualize_predicated_taxable_amount.to_f
						end
					end

					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Arrears/Overtime"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Employer PF Contribution above 150,000 (Notional Income)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					pf_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							pf_tax_value = pf_tax_value + employee_taxable_income.pf_tax_value.to_f
						end
					end

					current_row_value << ReportFormat.zero_to_dash(pf_tax_value.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Conveyance @ 5 % of purchase price (Notional Income)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					vehicle_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							vehicle_tax_value = vehicle_tax_value + (employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
						end
					end

					current_row_value << ReportFormat.zero_to_dash(vehicle_tax_value.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Medical Allowance @ 2 % of Basic Salary(Exempt)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					medical_allowance_amount = 0
					medical_allowance_selected_item = medical_allowance_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_allowance_selected_item.count == 1
						medical_allowance_amount = medical_allowance_selected_item[0][:employee_total_amount]
					end

					current_row_value << ReportFormat.zero_to_dash(medical_allowance_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total Employer Contribution of Tax"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0

					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total Salary"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_salary = 0

					basic_selected_item = basic_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if basic_selected_item.count == 1
						total_salary = total_salary + basic_selected_item[0][:employee_total_amount]
					end

					house_selected_item = house_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if house_selected_item.count == 1
						total_salary = total_salary + house_selected_item[0][:employee_total_amount]
					end

					medical_amount = 0
					medical_selected_item = medical_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_selected_item.count == 1
						total_salary = total_salary + medical_selected_item[0][:employee_total_amount]
					end

					utility_amount = 0
					utility_selected_item = utility_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if utility_selected_item.count == 1
						total_salary = total_salary + utility_selected_item[0][:employee_total_amount]
					end

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					total_salary = total_salary + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Leave Encashment"]).sum(:amount).round

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end
					total_amount = 0

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							predition_item_amounts 	= employee_taxable_income.predition_item_amounts.split(',').map(&:to_f)
							predition_item_names 		= employee_taxable_income.predition_item_names.split(',')
							index2 = predition_item_names.index("Eid Reward 1")
							if not index2.nil?
								total_amount = total_amount + predition_item_amounts[index2].round
							end
						end
					end

					total_amount = total_amount + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Eid Reward 2"]).sum(:amount).round
					total_salary = total_salary + total_amount

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					total_salary = total_salary + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Annual Bonus"]).sum(:amount).round

					loan_interest_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							loan_interest_amount = loan_interest_amount + employee_taxable_income.loan_interest_amount.to_f
						end
					end

					total_salary = total_salary + loan_interest_amount.to_f

					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Other Allowance", "Fuel Allowance", "Bike Fuel Allowance"]).sum(:taxable_amount).round
						end
					end

					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.annualize_predicated_taxable_amount.to_f
						end
					end

					total_salary = total_salary + total_amount.to_f

					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears", "Allowance Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).round
						end
					end
					total_salary = total_salary + total_amount.to_f

					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear"]).sum(:amount).round
						end
					end
					total_salary = total_salary + total_amount.to_f

					pf_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							pf_tax_value = pf_tax_value + employee_taxable_income.pf_tax_value.to_f
						end
					end
					total_salary = total_salary + pf_tax_value

					vehicle_tax_value = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							vehicle_tax_value = vehicle_tax_value + (employee_taxable_income.current_month_vehicle_tax.to_f + employee_taxable_income.predicted_vehicle_tax.to_f + employee_taxable_income.prev_vehicle_tax.to_f)
						end
					end

					total_salary = total_salary + vehicle_tax_value.to_f

					medical_allowance_amount = 0
					medical_allowance_selected_item = medical_allowance_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_allowance_selected_item.count == 1
						medical_allowance_amount = medical_allowance_selected_item[0][:employee_total_amount]
					end

					total_salary = total_salary + medical_allowance_amount.to_f

					current_row_value << ReportFormat.zero_to_dash(total_salary.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Exempt"
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Medical Allowance @ 10 % of Basic Salary(Exempt)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					medical_selected_item = medical_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_selected_item.count == 1
						total_amount = total_amount + medical_selected_item[0][:employee_total_amount]
					end

					medical_allowance_selected_item = medical_allowance_array.select { |favor| favor[:employee_code].to_s == employee.employee_code.to_s }

					if medical_allowance_selected_item.count == 1
						total_amount = total_amount + medical_allowance_selected_item[0][:employee_total_amount]
					end

					md_total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							md_total_amount = md_total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Manual Arrear"]).sum(:taxable_amount).round
						end
					end
					total_amount = total_amount + md_total_amount.to_f

					extra_md_total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							salary_arrears = pay_invoice.pay_invoice_details.where(:item_name => ["Salary Arrears"]).sum(:taxable_amount).round
							if salary_arrears > 0
								taxable_amount = ((((salary_arrears.to_f/100.0)*67)/100.0)*8)
								extra_md_total_amount = extra_md_total_amount + taxable_amount.round
							end
						end
					end
					total_amount = total_amount + extra_md_total_amount.to_f

					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Leave Without Pay"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					date_range_monthly.each do |single_item|
						pay_invoice	= @pay_invoices.find_by(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id, :pay_month => single_item)
						if not pay_invoice.nil?
							total_amount = total_amount + pay_invoice.pay_invoice_details.where(:item_name => ["Attendance Deduction", "Salary Deduction", "Allowance Deduction"]).sum(:amount).round
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
					current_row_type << :float
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Taxable Income"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.total_taxable_amount.to_f
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end
				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << ""
				current_row_style << row_format
				current_row_type << :string

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Taxpayable (Normal)"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + employee_taxable_income.yearly_total_tax.to_f
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Tax Deducted"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + (employee_taxable_income.total_paid_tax.to_f + employee_taxable_income.monthly_tax_amount.to_f)
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				row_format = old_row_format
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << "Total Balance Tax"
				current_row_style << row_format
				current_row_type << :string

				@employees.each do |employee|
					total_amount = 0
					pay_invoice_ids = @pay_invoices.where(:fiscal_year_id => fiscal_year.id, :status => true, :employee_id => employee.id).collect(&:id).sort
					if pay_invoice_ids.count > 0
						pay_invoice	= @pay_invoices.find(pay_invoice_ids.last)
					end

					if not pay_invoice.nil?
						employee_taxable_income = pay_invoice.employee_taxable_income
						if not employee_taxable_income.nil?
							total_amount = total_amount + (employee_taxable_income.remaing_tax_to_be_paid.to_f - employee_taxable_income.monthly_tax_amount.to_f)
						end
					end
					current_row_value << ReportFormat.zero_to_dash(total_amount.to_f)
					current_row_style << row_format
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				file_name = "tax_structure"
				url_path = save_excel_file(book, file_name)
				render json: {message: "Excel Created", path: url_path}
			end
		else
			render json: {errors: "No Record Found"}, status: :unprocessable_entity
		end
	end

	def comman_staff_report
		pay_executions 	= PayExecution.where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date.beginning_of_day, params[:end_date].to_date.end_of_day])
		@show_salary 		= User.show_salary(current_user)
		@company 				= Company.find (params[:company_id])
		@employees 			= Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
		@pay_invoices 	= PayInvoice.where(:status => true, :company_id => params[:company_id], :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		@salary_unit_name = ""

		#################### Hierarchical Permission ####################
		if current_user.is_location_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_branch_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.all_company_department == true
			@employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif current_user.is_sub_department_head == true
			@employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
			@employees = Employee.multiple_branch_data(@employees, current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		elsif not current_user.employee.nil?
			if current_user.employee.is_line_manager == true
				sub_ordinates_ids = []
				employee_ids = []
				employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
				employee_ids = employee_ids.flatten.uniq
				employee_ids << current_user.employee.id
				@employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
				@employees = Employee.multiple_branch_data(@employees, current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
			elsif current_user.multi_branch_allowed == true
				@employees = Employee.multiple_branch_data([], current_user)
				@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
			end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
			@pay_invoices = PayInvoice.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq)
		end
		#################### Hierarchical Permission ####################

		if not params[:location_id].blank?
			@employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
		end
		if not params[:branch_id].blank?
			@employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
		end
		if not params[:department_id].blank?
			@employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
		end
		if not params[:designation_id].blank?
			@employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
		end
		if not params[:job_title_id].blank?
			@employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
		end
		if not params[:grade_id].blank?
			@employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
		end
		if not params[:salary_unit_id].blank?
			@employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
		end
		if not params[:cost_center_id].blank?
			@employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
		end

		@pay_invoices = @pay_invoices.where(:status => true, :pay_execution_id => pay_executions.collect(&:id), :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
		if @pay_invoices.count > 0
			if params[:report_type].to_i == 1
				render status:200, template: 'api/v1/web/reports/payroll_reports/comman_staff_report.json.jbuilder'
			elsif params[:report_type].to_i == 2
				time = Time.now
				url_path = ""
				check_directory("#{Rails.public_path}/pdf")
				pdf = WickedPdf.new.pdf_from_string(
					render_to_string("api/v1/web/reports/payroll_reports/comman_staff_report.pdf.erb"),
					footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
					:margin => {
						:top      => '0.1in',
						:bottom   => '0.1in',
						:left     => '0.1in',
						:right    => '0.1in'
					},
					dpi: 300,
					# disable_smart_shrinking: true,
					orientation: 'Landscape',
					page_size:'Legal'
				)
				file_name = "comman_staff_report"
				url_path = save_pdf_file(pdf, file_name)

				render json: {message: "Pdf Created", path: url_path}
			elsif params[:report_type].to_i == 3

				time = Time.now
				book = Axlsx::Package.new
				check_directory("#{Rails.public_path}/excel")
				wb = book.workbook
				sheet = wb.add_worksheet(name: 'Comman Staff')
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

				bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
				header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
				table_header = ["Sr #", "Emp Code", "Name", "Designation", "Department ", "Gross Salary", "Medical", "Others", "Arrears/Over Time", "LWP", "EPF", "Tax on Tax", "EOBI", "Conveyance Allowance", "Leave Encashment", "December Bonus", "Eid Bonus", "Total"]

				sheet.add_row table_header, :style => header_style
				old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
				count = 0
				@employees.each do |employee|
					pay_invoices_ids = @pay_invoices.where(:employee_id => employee.id)
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

					current_row_value << employee.employee_code.to_i
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee.department_name
					current_row_style << row_format
					current_row_type << :string

					if @show_salary == true
						current_row_value << @pay_invoices.where(:employee_id => employee.id).sum(:actual_salary).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Medical Allowance (OPD)"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Other Allowance", "Fuel Allowance"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["LWP", "Attendance Deduction"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Provident Fund", "Arrears Provident Fund"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << 0.0
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["EOBI"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Conveyance Allowance"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Leave Encashment"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Annual Bonus"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Eid Reward 2"]).sum(:amount).to_f.round
						current_row_style << row_format
						current_row_type << :float

						current_row_value << (PayInvoiceDetail.where(:pay_invoice_id => pay_invoices_ids, :item_name => ["Medical Allowance (OPD)", "Other Allowance", "Fuel Allowance", "Salary Arrears", "Allowance Arrear", "Deduction Reimbursement Arrear", "Manual Arrear", "Arrears", "Over Time", "Off Day Payment", "LWP", "Attendance Deduction", "Provident Fund", "Arrears Provident Fund", "EOBI", "Conveyance Allowance", "Leave Encashment", "Annual Bonus", "Eid Reward 2"]).sum(:amount).to_f.round + @pay_invoices.where(:employee_id => employee.id).sum(:actual_salary).to_f.round)
						current_row_style << row_format
						current_row_type << :float
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
				end
				file_name = "comman_staff_report"
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
end


