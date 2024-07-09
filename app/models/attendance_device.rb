class AttendanceDevice < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company

	def company_name
    company.try(:name) || '-'
  end

  # AttendanceDevice.auto_fetch_attendance_log
  def self.auto_fetch_attendance_log
    puts "\n\n Started fetch/process Script => #{Time.now} \n\n"
    puts "\n\n started #{Time.now.strftime('%I:%M:%S %p')} \n\n"
    current_time = Time.now
    Company.where(:is_active => true).order('id ASC').each do |company|
      system_setting = SystemSetting.find_by(:company_id => company.id)
      if system_setting
        if system_setting.auto_attendance_fetching
          if system_setting.schedule_time.split(',').include?(current_time.hour.to_s)
            fetch_start_date = (Time.now - system_setting.attendance_days.day).to_date
            AttendanceDevice.where(:auto_fetch_allowed => true).order('id ASC').each do |attendance_device|
              begin
                AttendanceMachineLog.fetch_attendance_machine_data(attendance_device, fetch_start_date, Time.now.to_date)
                puts "#{attendance_device.name} fetched sucessfully from #{fetch_start_date} to #{Time.now.to_date}"
              rescue StandardError => error
                puts "====Unable to fetch #{attendance_device.name}==============="
                UserMailer.send_email_notification('retail.bi@srl.com.pk', 'dev.team@sapphiretextiles.com.pk', "Unable to fetch device #{attendance_device.name} from #{fetch_start_date} to #{Time.now.to_date}", error, nil).deliver_later
                puts error
              end
            end
          end
        end
      end
    end
    Company.where(:is_active => true).order('id ASC').each do |company|
      system_setting = SystemSetting.find_by(:company_id => company.id)
      if system_setting
        if system_setting.auto_attendance_process
          if system_setting.schedule_time.split(',').include?(current_time.hour.to_s)
            min_attendance_days = system_setting.attendance_days
            begin
              AttendanceDevice.auto_process_attendance(company, min_attendance_days)
              puts 'Processed fetched attendance success'
            rescue StandardError => error
              puts '====Unable to process attendance==============='
              UserMailer.send_email_notification('retail.bi@srl.com.pk', 'dev.team@sapphiretextiles.com.pk', 'Unable to process attendance', error, nil).deliver_later
              puts error
            end
          end
        end
      end
    end
    puts "\n\n Ended Auto process/fetch script #{Time.now.strftime('%I:%M:%S %p')} \n\n"
    puts "\n\n Ended => #{Time.now} \n\n"
  end

  # AttendanceDevice.auto_process_attendance(company)
  def self.auto_process_attendance(company, min_attendance_days)
    start_date  = Time.now - min_attendance_days.day
    end_date    = Time.now
    date_range  = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}    
    Location.where(:is_active => true, :company_id => company.id).order('id ASC').each do |location|
      Branch.where(:is_active => true, :location_id => location.id).order('id ASC').each do |branch|
        employees = Employee.where(:is_active => true, :company_id => company.id, :location_id => location.id, :branch_id => branch.id).order('id DESC')
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

end
