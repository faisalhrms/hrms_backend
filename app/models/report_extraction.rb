class ReportExtraction

	# ReportExtraction.employee_leave_balance
	def self.employee_leave_balance(company_id)
		time = Time.now

		########################### Make Excel File ############################

		book = Spreadsheet::Workbook.new

		date_format = Spreadsheet::Format.new :number_format => 'DD.MM.YYYY'

		new_format = Spreadsheet::Format.new :weight => :bold, :size => 12, :align => :center

		format = Spreadsheet::Format.new :size => 10, :align => :center

		########################### All Offical Duty ###########################

		sheet = book.create_worksheet :name => 'Employee Leave Balances'
		count = 0

		sheet.row(0).default_format = new_format

		sheet.row(0).height = 18

		sheet.column(0).width = 20
		sheet.column(1).width = 30
		sheet.column(2).width = 30
		sheet.column(3).width = 30
		sheet.column(4).width = 30
		sheet.column(5).width = 30
		sheet.column(6).width = 30
		sheet.column(7).width = 30
		sheet.column(8).width = 30
		sheet.column(9).width = 30
		sheet.column(0).default_format = format
		sheet.column(1).default_format = format
		sheet.column(2).default_format = format
		sheet.column(3).default_format = format
		sheet.column(4).default_format = format
		sheet.column(5).default_format = format
		sheet.column(6).default_format = format
		sheet.column(7).default_format = format
		sheet.column(8).default_format = format
		sheet.column(9).default_format = format
		sheet.row(0).push "Sr #", "Employee Name", "Employee Code", "Branch", "Leave type", "Allocated Leave", "Availed", "Balance", "Joining Date"
		count = count + 1
    Employee.where(:company_id => company_id).active.order('id ASC').each do |employee|
    	employee.leave_allocations.where(:is_active => true).each do |leave_allocation|
    		if leave_allocation.leave_type.is_composite == false
    			sheet.row(count+1).push "#{count}", employee.full_name, employee.employee_code, employee.branch_name, "#{leave_allocation.leave_type_name}", "#{leave_allocation.allocated_quota}", "#{leave_allocation.used_quota}", "#{leave_allocation.remaining_quota}", ReportFormat.date_format(employee.joining_date)
					count = count + 1		
				else
					leave_type_ids = leave_allocation.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
					leave_allocation_ids = LeaveAllocation.where(:leave_type_id => leave_type_ids, :is_active => true, :employee_id => leave_allocation.employee_id).collect(&:id)
					leave_transaction_history	= LeaveTransactionHistory.where(:leave_allocation_id => leave_allocation_ids, :company_id => leave_allocation.company_id, :leave_type_id => leave_type_ids, :employee_id => leave_allocation.employee_id).last
					if not leave_transaction_history.nil?
						sheet.row(count+1).push "#{count}", employee.full_name, employee.employee_code, employee.branch_name, "#{leave_allocation.leave_type_name}", "#{leave_transaction_history.allocated_quota}", "#{leave_transaction_history.used_quota}", "#{leave_transaction_history.remaining_quota}", ReportFormat.date_format(employee.joining_date)
						count = count + 1			
					end
    		end				
			end
    end
		file_name = 'leave_balance_report'
		save_excel_file(book, file_name)
	end

	# ReportExtraction.status_report_generation
  def self.status_report_generation
		system_setting = SystemSetting.find_by_name("MIll Setting")
  	if not system_setting.nil?
  		puts "\n Start Time => #{Time.now} \n"
			puts "\n\n started #{Time.now.strftime('%I:%M%p')} \n\n"

	  	time = Time.now
	  	book = Axlsx::Package.new

	  	ReportExtraction.auto_process_attendance
			ReportExtraction.status_report(book)
			
			file_name = "status_of_payroll_#{time.to_i}.xlsx"
			save_path = "#{Rails.public_path}/excel/#{file_name}"
			book.serialize "#{save_path}"

			puts "\n End Time => #{Time.now} \n"
			puts "\n\n ended #{Time.now.strftime('%I:%M%p')} \n\n"

	  	email_config = EmailConfigration.first
	  	uMailer = UserMailer.send_email_attch_notification(email_config.email, "Daily Status of Payroll HRMS (Garments)", "<p>Dear All,</p> <p>Find attached system generated Daily Status of Payroll HRMS (Garments)</p> <p>Regards,</p> <p>HRMS Team</p>", file_name, file_name)
			uMailer.delivery_method.settings[:host] = 'http://hcm.sapphirepakistan.pk'
			uMailer.delivery_method.settings[:address] = email_config.outgoing_server_address
			uMailer.delivery_method.settings[:domain] = email_config.domain
			uMailer.delivery_method.settings[:port] = email_config.outgoing_server_port
			uMailer.delivery_method.settings[:user_name] = email_config.user_name
			uMailer.delivery_method.settings[:password] = email_config.password
			uMailer.delivery_method.settings[:openssl_verify_mode] = 'none'
			uMailer.delivery_method.settings[:authentication] = 'login'
			uMailer.delivery_method.settings[:enable_starttls_auto] = true
			uMailer.from=email_config.email
			uMailer.deliver
  	end
  end

  # ReportExtraction.auto_process_attendance
  def self.auto_process_attendance
    start_date  = Time.now.beginning_of_month.beginning_of_day
    end_date    = (Time.now - 1.day).end_of_day
    date_range  = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}    
    location = Location.find_by_name("Garment")
  	if not location.nil?
      Branch.where(:is_active => true, :location_id => location.id).order('id ASC').each do |branch|
        employees = Employee.active.where(:location_id => location.id, :branch_id => branch.id, :excluded_from_reports => false).order('id DESC')
        employees.each do |employee|
          date_range.each do |single_date|
            if EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => single_date).empty?
              if employee.joining_date.to_date <= single_date
                EmployeeAttendance.create_empty_attenance_record(single_date, employee)
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
          EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
            EmployeeAttendance.update_employee_detail(employee_attendance, employee)
          end
          ########## Update Checkin and Checkout ##########
          EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
            AttendanceMachineLog.update_employee_checkin_checkout(employee_attendance)
          end
          ########## Process Attendance ##########
          EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
						EmployeeAttendance.single_employee_process_attendance(employee_attendance)
					end
          EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
            EmployeeAttendance.revision_of_leave_deducted(employee_attendance)
          end
          EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
            EmployeeAttendance.finalize_deuction(employee_attendance)
          end
        end
      end
    end   
  end

  # ReportExtraction.status_report
  def self.status_report(book)
  	start_date  = Time.now.beginning_of_month.beginning_of_day
  	status_date = (Time.now - 4.day).end_of_day
    end_date    = (Time.now - 1.day).end_of_day
    date_range  = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
  	location = Location.find_by_name("Garment")
  	if location
	    excluded_from_reports_ids = Employee.where(:location_id => location.id, :excluded_from_reports => true).order('id DESC').collect(&:id)
	    @employees = Employee.active.where(:location_id => location.id, :excluded_from_reports => false).order('id DESC')
	    all_employees = Employee.where(:location_id => location.id).order('id DESC')
	   	@prev_employee_attendances = EmployeeAttendance.where(:location_id => location.id, :attendance_date => start_date..end_date).order('attendance_date ASC')
			leaver_employee_last_month =  EmployeeTransactionHistory.includes(:employee).where(transaction_type: "End of Employment").where("transaction_date < ?", start_date).where(employees: {is_active: false}).pluck(:employee_id)
			start_employee_attendances = Employee.where(:location_id => location.id, :excluded_from_reports => false).where.not(id: leaver_employee_last_month).count
	  	
			wb = book.workbook
			sheet = wb.add_worksheet(name: 'Payroll Status')
			employee_detail = wb.add_worksheet(name: 'Employees Detail')
			book.use_autowidth = false
			employee_detail.sheet_view do |view|
				view.show_outline_symbols = true
			end

			employee_detail.sheet_view.pane do |view|
				view.state = :frozen_split
				view.y_split = 3
				view.x_split = 0
				view.active_pane = :bottom_right
			end

			sheet.sheet_view do |view|
			  view.show_outline_symbols = true
			end
			book.use_autowidth = true

			cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
			sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	    sheet.add_row ['']
	    sheet.add_row ['']

			employee_transactions = EmployeeTransactionHistory.where(:employee_id => all_employees.collect(&:id), :transaction_date => start_date.to_date.beginning_of_day..end_date.to_date.end_of_day, :transaction_type => "End of Employment")
			new_employees = Employee.where(:id => @employees.collect(&:id), :joining_date => start_date..start_date.to_date.end_of_month.end_of_day)
			incentive_pay_item = PayItem.find_by_name('Incentive')

			sheet.add_row ['Starting Employees:', start_employee_attendances]
	    sheet.add_row ['Resignations:', employee_transactions.count]
	    sheet.add_row ['New Hires:', new_employees.count]
	    sheet.add_row ['Current Employees:', @employees.count]

	    sheet.add_row ['']
	    sheet.add_row ['']

	    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
			wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
			sheet.add_row ["Date", "No of People", "Present", "Rest Day", "Absent", "Missed In/Out", "Leaves Availed", 'Incentive Amount', 'OT Hours', 'OT Amount', 'Salary Bill', 'Grand Total', "MTD", "Status"],:style => header_style
			old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
			wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})

			employee_detail.add_row ["Extraction Date :","#{date_range.last.strftime("%d-%b-%Y")}"], :style => cell_style
			employee_detail.add_row ['']
			employee_detail.add_row ["No of People", 'Status', 'Joining Date', "Present", "Rest Day", "Absent", "Missed In/Out", "Leaves Availed", 'Incentive Amount', 'OT Hours', 'OT Amount', 'Salary Bill', 'Remarks'], :style => header_style

			month_to_date_value = 0

			leavers_ids = []
			date_range.each do |single_date|
				row_format = old_row_format	
				
				current_row_value = []
				current_row_style = []
				current_row_type = []

				current_row_value << single_date.strftime("%d %B %Y")
				current_row_style << row_format
				current_row_type << :string

				new_leavers_ids = EmployeeTransactionHistory.where(:employee_id => all_employees.collect(&:id), :transaction_type => "End of Employment", :transaction_date => single_date.to_date).collect(&:employee_id)
				leavers_ids = leavers_ids + new_leavers_ids

				leaver_employee_ids =  EmployeeTransactionHistory.includes(:employee).where(transaction_type: "End of Employment").where("transaction_date < ?", single_date).where(employees: {is_active: false}).pluck(:employee_id)
				final_ids = excluded_from_reports_ids + leavers_ids

				@employee_attendances = @prev_employee_attendances.where.not(employee_id: final_ids + leaver_employee_ids).where(attendance_date: single_date.to_date)

				salary_employee_ids = @employee_attendances.where(:attendance_status => ["Present", "Late", "Short Leave", "Half Day", "", 'Public Holiday']).collect(&:employee_id).uniq
				leave_employee_ids = @employee_attendances.where(:is_on_leave => true).collect(&:employee_id).uniq

				total_employee_ids = salary_employee_ids + leave_employee_ids
				total_employee_ids = total_employee_ids.uniq
				final_employees = Employee.where(:id => total_employee_ids).order('employee_code ASC')

				current_row_value << Employee.where(:location_id => location.id, :excluded_from_reports => false).where.not(id: excluded_from_reports_ids + leaver_employee_ids).count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:attendance_status => ["Present", "Late", "Short Leave", "Half Day", ""]).count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:attendance_status => ['Rest Day', 'Public Holiday']).count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:attendance_status => "Absent").count
				current_row_style << row_format
				current_row_type << :float

				current_row_value << (@employee_attendances.where.not(:in_time => nil).where(:out_time => nil).count) + (@employee_attendances.where.not(:out_time => nil).where(:in_time => nil).count)
				current_row_style << row_format
				current_row_type << :float

				current_row_value << @employee_attendances.where(:is_on_leave => true).count
				current_row_style << row_format
				current_row_type << :float					

				exclude_absent_incentive = @employee_attendances.where.not(:employee_id => final_ids, :attendance_status => ['Absent', 'Rest Day']).where(:attendance_date => single_date.to_date)
				employee_incentive = (FixedPayItem.where(pay_item_id: incentive_pay_item.id, is_active: true, employee_id: exclude_absent_incentive.collect(&:employee_id).uniq).sum(:item_amount)/26.0).to_f

				current_row_value << employee_incentive.round(2)
				current_row_style << row_format
				current_row_type << :float

				current_row_value << (@employee_attendances.includes(:employee).where(approval_base_overtime: true).map{|a| a.approved_overtime_hours }.sum).round(2)
				current_row_style << row_format
				current_row_type << :float

				all_employee_basic_salary = @employee_attendances.includes(:employee).where(approval_base_overtime: true).map{|a| ((a.employee.gross_salary/26)/8) * 2 * a.approved_overtime_hours}.sum
				current_row_value << (all_employee_basic_salary).to_f.round(2)
				current_row_style << row_format
				current_row_type << :float

				total_salary_bill = final_employees.sum(:gross_salary).to_f/26.0
				current_row_value << total_salary_bill.round(2)
				current_row_style << row_format
				current_row_type << :float

				grand_total = employee_incentive + all_employee_basic_salary.to_f + total_salary_bill
				current_row_value << grand_total.round(2)
				current_row_style << row_format
				current_row_type << :float

				month_to_date_value = month_to_date_value + grand_total.to_f.round(2)
				current_row_value << month_to_date_value.to_f.round(2)
				current_row_style << row_format
				current_row_type << :float

				if single_date.to_date <= status_date.to_date
					current_row_value << 'Closed'
					current_row_style << row_format
					current_row_type << :string
				else
					current_row_value << 'Open'
					current_row_style << row_format
					current_row_type << :string
				end

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

				if single_date == date_range.last
					row_style = []
					grand_total = Array.new(13, 0)
					13.times{ row_style << wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})}
					row_type = [:string, :string, :string, :string, :string, :float, :string, :float, :float, :float, :float, :float, :string ]
					puts "Started Detail Report #{Time.now}"
					Employee.includes(:employee_attendances).where(:location_id => location.id, :excluded_from_reports => false).where.not(id: excluded_from_reports_ids + leaver_employee_ids + final_ids).find_in_batches.each do |employees|
						employees.each do |employee|
							detail_data_row = []
							grand_total[0] += 1
							attendance = employee.employee_attendances.where(attendance_date: single_date.to_date).first
							if attendance
								detail_data_row << employee.employee_code
								detail_data_row << ((employee.is_active or ((!employee.is_active) and !(leaver_employee_ids.include? employee.id))) ? 'Active': 'In-Active')
								detail_data_row << employee.joining_date.strftime("%d-%b-%Y")
								detail_data_row << (['Present', 'Late', 'Short Leave', 'Half Day', ''].include?(attendance.attendance_status) ? attendance.attendance_status : '-')
								grand_total[3] += ['Present', 'Late', 'Short Leave', 'Half Day', ''].include?(attendance.attendance_status) ? 1 : 0

								detail_data_row << (['Rest Day', 'Public Holiday'].include?(attendance.attendance_status) ? attendance.attendance_status : '-')
								grand_total[4] += ['Rest Day', 'Public Holiday'].include?(attendance.attendance_status) ? 1 : 0

								detail_data_row << (attendance.attendance_status == 'Absent' ? 1 : '-')
								grand_total[5] += attendance.attendance_status == 'Absent' ? 1 : 0
								if (!attendance.in_time.nil? and attendance.out_time.nil?) or (attendance.in_time.nil? and !attendance.out_time.nil?)
									detail_data_row << 1
									grand_total[6] += 1
								else
									detail_data_row << 0
								end

								absent_employee_count = ((attendance.is_on_leave or (["Present", "Late", "Short Leave", "Half Day", "", 'Public Holiday'].include?(attendance.attendance_status))) and attendance.attendance_status != 'Absent') ? 1 : 0
								detail_data_row << (attendance.is_on_leave ? 1: 0)
								grand_total[7] += attendance.is_on_leave ? 1: 0

								incentive = employee.fixed_pay_items.where(pay_item_id: incentive_pay_item.id, is_active: true).first.try(:item_amount)
								detail_data_row << ((incentive and absent_employee_count > 0) ? (incentive/26).round(2) : 0)
								grand_total[8] += (incentive and absent_employee_count > 0) ? (incentive/26).round(2) : 0

								approved_hours = attendance.approval_base_overtime ? attendance.approved_overtime_hours : 0
								detail_data_row << (approved_hours.to_i > 0 ? approved_hours : 0)
								grand_total[9] += approved_hours.to_i > 0 ? approved_hours : 0

								detail_data_row << (approved_hours.to_i > 0 ? ((employee.gross_salary/26)/8 * 2 * approved_hours).round(2) : 0)
								grand_total[10] += approved_hours.to_i > 0 ? ((employee.gross_salary/26)/8 * 2 * approved_hours).round(2) : 0


								detail_data_row << ((absent_employee_count > 0) ? (employee.gross_salary/26).round(2) : 0)
								grand_total[11] += ((absent_employee_count > 0) ? (employee.gross_salary/26).round(2) : 0)

								detail_data_row << 'Attendance'

								employee_detail.add_row detail_data_row, :style => row_style, :types => row_type
							else
								active = ((employee.is_active or ((!employee.is_active) and !(leaver_employee_ids.include? employee.id))) ? 'Active': 'In-Active')
								employee_detail.add_row [employee.employee_code, active, employee.joining_date.strftime('%d-%b-%Y'), '-', '-', 0, 0, 0 , 0, 0, 0, 0, 'Not Found'], :style => row_style, :types => row_type
							end
						end
					end
					employee_detail.add_row ['']
					employee_detail.add_row ['Grand Total']
					employee_detail.add_row grand_total.flatten, :style => row_style, :types => row_type
					puts "Ended Detail Report #{Time.now}"
				end
			end
  	end
  end

end