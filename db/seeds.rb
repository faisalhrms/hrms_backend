# bundle exec rake db:drop:all
# bundle exec rake db:create
# bundle exec rake db:migrate
# pg_restore -U db_user -h localhost -d hrms_db_development srl_hrms_db.sql
# pg_restore -U db_user -h localhost -d idl_hrms_db_development idl_hrms_db.sql
# pg_restore -U db_user -h localhost -d dfl_ho_hrms_db_development dfl_hrms_db.sql
# pg_restore -U db_user -h localhost -d dfl_mill_hrms_db_development dfl_mill_hrms_db.sql

# =CONCATENATE(TEXT(A2,"dd/mm/yyyy")," ",TEXT(B2,"h:mm:ss AM/PM"))
# dd/mm/yyyy h:mm:ss AM/PM

# CRON_TZ=Asia/Karachi
# sudo service crond restart
# sudo timedatectl set-time 2020-04-22
# sudo timedatectl set-time 00:29:10

# cap srl_aws deploy
# cap dfl_mill deploy
# cap dfl_ho_aws deploy
# cap idl_aws deploy
# cap syscon_aws deploy
# cap sdl_farm deploy

# ssh alche@3.82.178.28
# ssh alche@18.223.178.156
# ssh alche@18.225.13.9
# ssh alche@3.18.90.198
# ssh alche@3.18.125.67

# cd apps/tak_front_end/
# git status
# git pull origin master
# 4262646@Iai
# grunt build --force

# cd apps/tak_front_end/
# git status
# git pull origin stml_dev
# 4262646@Iai
# grunt build --force

# DataEntry.add_new_permission
# DataEntry.deactive_all_email_setting

# "grunt-contrib-imagemin": "^0.9.2",
# 106CC4 Blue 
# 641E16 Red
# User.create(:email => "portals@syscon.cc", :password => "Portals@123", :first_name => "portals", :last_name => "syscon", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
# User.create(:email => "ahsan.ali@admin.com", :password => "yahoo@1209", :first_name => "Ahsan", :last_name => "Ali", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
# User.create(:email => "saqib.shahzad@admin.com", :password => "yahoo@1209", :first_name => "Saqib", :last_name => "Shahzad", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
# User.create(:email => "syed.talal@admin.com", :password => "yahoo@1209", :first_name => "Syed", :last_name => "Talal", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
# Company.create(:name => "Sapphire Retail Limited", :code => "SRL", :short_name => "SRL", :address => "Sapphire Retail Head Office 4th Floor – Tricon Corporate Center, Gulberg 2, Lahore, Pakistan", :description => "A high-street brand introduced by one of the largest names in the textile industry, Sapphire is celebrated for combining 100% pure fabric with unprecedented design aesthetic to create designer wear at an affordable price.")
# Company.create(:name => "Sapphire Textile Mill Limited", :code => "STML", :short_name => "STML", :address => "7A-K, Gulberg, Lahore, Pakistan", :description => "")
# Company.create(:name => "Diamond Fabrics Limited", :code => "DFL", :short_name => "DFL", :address => "", :description => "")

# Company.create(:name => "Inferifi LLC.", :code => "Inferifi LLC.", :short_name => "Inferifi", :address => "", :description => "")

# countries_file = File.read "#{Rails.public_path}/countries.json"
# countries_data = JSON.parse(countries_file)

# states_file = File.read "#{Rails.public_path}/states.json"
# states_data = JSON.parse(states_file)

# cities_file = File.read "#{Rails.public_path}/cities.json"
# cities_data = JSON.parse(cities_file)


# rails g apidoco api/v1/web/dashboards

# self.errors.add(:base, "Leave Request Already Applied! from #{leave_request.start_date.to_date.strftime("%d-%b-%Y")} to #{leave_request.end_date.to_date.strftime("%d-%b-%Y")}")


ApprovalRequest.destroy_all
LeaveAllocation.destroy_all
LeaveRequest.destroy_all
LeaveTransactionHistory.destroy_all
LeaveRequestDetail.destroy_all

RelaxationRequest.destroy_all
OfficialDuty.destroy_all
FinalizeAttendance.destroy_all
EmployeeAttendance.destroy_all
EmployeeArrear.destroy_all


DataEntry.clear_leave_data
DataEntry.new_stm_ho_leave_balance
DataEntry.export_leave_balance

# ApprovalRequest.where(requestable_type: "LeaveRequest").destroy_all

######## Multi Select DropDown ########
# <div class="col-sm-6">
#   <label for="leave_type_id" class="control-label">Leave Type</label>
#   <select multiple hr-sumoselect="{selectAll: true,placeholder:'Select Employees',no_results_text:'Select Employees',search: true, searchText: 'Search...'}" name="leave_type_id" ng-model="new_bulk_leave_allocation.leave_type_id" class="form-control" ng-options="opt.id as (opt.name) for opt in leave_types  | orderBy: 'name'">
#     <option value="" disabled="" selected="">Select Leave Type</option>
#   </select>
# </div>

# <li ui-sref-active="active" ng-if="checkPermission('attendance_structure', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_structure"><fa name="fa fa-bars"></fa> Attendance Structure </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_absent_policy', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_absent_policy"><fa name="fa fa-bars"></fa> Absent Policy </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_missing_policy', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_missing_policy"><fa name="fa fa-bars"></fa> Missing Policy </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_early_left_policy', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_early_left_policy"><fa name="fa fa-bars"></fa> Early Left Policy </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_relation_policy', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_relation_policy"><fa name="fa fa-bars"></fa> Relation Policy </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_over_time_policy', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_over_time_policy"><fa name="fa fa-bars"></fa> Over Time Policy </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_earning_type', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_earning_type"><fa name="fa fa-bars"></fa> Earning Type </a>
# </li>
# <li ui-sref-active="active" ng-if="checkPermission('attendance_deduction_type', 'index_access') == true">
#   <a ui-sref="app.attendance_management.attendance_deduction_type"><fa name="fa fa-bars"></fa> Deduction Type </a>
# </li>



# folder = "/Users/khawajatayyab/Downloads"
# input_filenames = ['summary-report-2018-11-27-1543369505.xlsx']

# zipfile_name = "/Users/khawajatayyab/Downloads/summary-report-2018-11-27-1543369505.zip"

# Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
#   input_filenames.each do |filename|
#     zipfile.add(filename, File.join(folder, filename))
#   end
# end


employee_attendance = FinalizeAttendance.where(:employee_id => employee_ids, :attendance_date => start_date.to_date..end_date.to_date)
employee_attendance.each do |final_attendance|
	final_attendance.off_day_payment = 0.0
	final_attendance.over_time_hours = 0.0
	final_attendance.over_time_minutes = 0.0
	final_attendance.over_time_seconds = 0.0
	final_attendance.encashable_quota = 0.0
	final_attendance.save
end

employee_code = "271820"
start_date = Time.now - 78.day
end_date = Time.now
employee_attendance = FinalizeAttendance.where(:employee_id => employee_ids, :attendance_date => start_date.to_date..end_date.to_date).collect(&:branch_name)
employee_attendances = EmployeeAttendance.where(:attendance_date => start_date.to_date..end_date.to_date, :no_of_cpl => 1.0).collect(&:quota_earned)
employee_attendance.each do |attendance|
	attendance.branch_id = 11
	attendance.branch_name = "Gulberg"
	attendance.save
end

employee_code = "771634"
start_date = "February 1, 2020".to_date
end_date = "February 29, 2020".to_date
employee_attendance = EmployeeAttendance.where(:employee_code => ['771029', '771045', '771059', '771501', '771559', '771661', '773183', '771620', '771014', '771015', '771021', '771028', '771053', '771057', '771080', '771086', '771089', '771097', '771535', '771540', '771541', '771547', '771549', '771551', '771558', '771560', '771568', '771587', '771622', '771627', '771629', '771631', '771638', '771649', '771651', '771663', '771664', '771668', '771672', '773004', '774516', '771044', '771069', '771507', '771577', '771653', '771550', '771662', '771006', '771604', '771608', '773320', '771034', '771046', '771083', '771087', '771088', '771538', '771589', '771599', '771617', '771619', '775619', '775645', '771048', '771072', '771076', '771084', '771510', '771580', '771582', '771586', '771600', '771628', '771630', '771511', '771027', '771040', '771095', '771642', '771643', '771644', '772018', '771020', '771566', '180029', '771067', '771584', '773104', '771033', '771512', '771575', '771626', '771656', '771670', '771671', '774106', '771581', '771552', '771563', '771564', '771591', '771615', '771625', '771650', '771652', '771655', '771657', '771658', '771659', '771666', '771571', '771641', '771079', '771614', '771632', '771635', '771636', '771639', '771646', '771648', '771660', '771667', '771669', '771718', '775605', '771637', '771618', '771616', '771621', '771640', '771654', '771704', '771716', '771708', '771721', '771720', '771522', '771702', '771703', '771719', '771722', '771723', '771724', '771725', '771709', '771707'], :attendance_date => start_date.to_date..end_date.to_date, :no_of_cpl => 1.0).collect(&:no_of_cpl)
employee_attendances = EmployeeAttendance.where(:employee_code => ['771029', '771045', '771059', '771501', '771559', '771661', '773183', '771620', '771014', '771015', '771021', '771028', '771053', '771057', '771080', '771086', '771089', '771097', '771535', '771540', '771541', '771547', '771549', '771551', '771558', '771560', '771568', '771587', '771622', '771627', '771629', '771631', '771638', '771649', '771651', '771663', '771664', '771668', '771672', '773004', '774516', '771044', '771069', '771507', '771577', '771653', '771550', '771662', '771006', '771604', '771608', '773320', '771034', '771046', '771083', '771087', '771088', '771538', '771589', '771599', '771617', '771619', '775619', '775645', '771048', '771072', '771076', '771084', '771510', '771580', '771582', '771586', '771600', '771628', '771630', '771511', '771027', '771040', '771095', '771642', '771643', '771644', '772018', '771020', '771566', '180029', '771067', '771584', '773104', '771033', '771512', '771575', '771626', '771656', '771670', '771671', '774106', '771581', '771552', '771563', '771564', '771591', '771615', '771625', '771650', '771652', '771655', '771657', '771658', '771659', '771666', '771571', '771641', '771079', '771614', '771632', '771635', '771636', '771639', '771646', '771648', '771660', '771667', '771669', '771718', '775605', '771637', '771618', '771616', '771621', '771640', '771654', '771704', '771716', '771708', '771721', '771720', '771522', '771702', '771703', '771719', '771722', '771723', '771724', '771725', '771709', '771707'], :attendance_date => start_date.to_date..end_date.to_date, :no_of_cpl => 1.0)
employee_attendance_ids = employee_attendances.collect(&:id)

employee_attendances.each do |attendance|
	attendance.no_of_cpl = 0
	attendance.quota_earned = false
	attendance.save
end

EmployeeAttendance.where(:is_finalized => false, :employee_code => employee_code, :attendance_date => start_date.to_date..end_date.to_date).order('attendance_date ASC').each do |employee_attendance|
	LeaveRequest.employee_wise_leave_impact(employee_attendance)
end


employee_code = "771662"
attendance_date = "04-04-2020".to_date
employee_attendance = EmployeeAttendance.where(:employee_code => employee_code, :attendance_date => attendance_date.to_date).last
attendance_structure = employee_attendance.attendance_master_policy(employee_attendance)
cut_off_date_range = AttendanceCutoff.get_attendance_cutoff_date_range(employee_attendance)
absent_policy = attendance_structure.absent_policy
attendance_relaxation = attendance_structure.attendance_relaxation
attendance_overtime = attendance_structure.attendance_overtime
missing_punch = attendance_structure.missing_punch
early_left = attendance_structure.early_left

# scp -r bower_components alche@18.225.13.9:/home/alche/apps/tak_front_end/
# scp -r node_modules alche@18.225.13.9:/home/alche/apps/tak_front_end/
# scp -r pgsql-9.6 alche@18.223.178.156:/home/alche/




# scp -r alche@202.142.167.187:/home/alche/apps/tak_back_end_production/shared/public/excel/daily_attendance_1583912068.xlsx daily_attendance_1583912068.xlsx
# scp -r device_transaction_log.csv alche@3.82.178.28:/home/alche/apps/tak_back_end_production/current/public/srl_data/device_transaction_log.csv
# scp -r stm_hrms_db.sql alche@124.29.211.54:/home/alche/	
# scp -r feb1.csv alche@125.209.75.92:/home/alche/apps/tak_back_end_production/current/public/sdl_farm/feb1.csv
# scp -r feb2.csv alche@125.209.75.92:/home/alche/apps/tak_back_end_production/current/public/sdl_farm/feb2.csv
# scp -r farm_cutoff.csv alche@125.209.75.92:/home/alche/apps/tak_back_end_production/current/public/sdl_farm/farm_cutoff.csv
# scp -r process_cutoff.csv alche@125.209.75.92:/home/alche/apps/tak_back_end_production/current/public/sdl_farm/process_cutoff.csv

# scp -r dfl_hrms_db.sql alche@124.29.211.54:/home/alche/
# 192.168.51.55

# = URI.parse()



# OfficialDuty.where(:request_sender_name => "").each do |official_duty|
# request_sender_name = RequestFlow.request_flow_username(official_duty.employee, "Official Duty Request")
# official_duty.update_columns(:request_sender_name => request_sender_name)
# end


# LeaveRequest.where(:request_sender_name => "").each do |leave_request|
# request_sender_name = RequestFlow.request_flow_username(leave_request.employee, "Leave Request")
# leave_request.update_columns(:request_sender_name => request_sender_name)
# end


# Employee.where(:confirmation_date => nil, :on_probation => true, :confimration_due_date => nil).count
# Employee.where(:confirmation_date => nil, :on_probation => true, :confimration_due_date => nil).each do |employee|
# 	confimration_due_date = employee.joining_date + (3.month - 1.day)
# 	employee.confimration_due_date = confimration_due_date.to_date
# 	employee.save
# end


# DataEntry.deactive_all_email_setting


# employee_code = "1251"
# attendance_date = "21-01-2019".to_date
# employee_attendance = EmployeeAttendance.where(:employee_code => employee_code, :attendance_date => attendance_date.to_date).last




# e = Employee.last
# Employee.all.each do |employee|
# begin
# file = File.new(open("#{Rails.public_path}/idl_data/picture/#{employee.employee_code}.png"))
# if employee.avatar_file_name.nil?
# employee.avatar = file
# employee.save
# end			
# rescue Errno::ENOENT
	
# end

# end


files = Dir.glob(File.join("#{Rails.public_path}/employee_pictures", '**', '*')).select { |file| File.file?(file) }
files.each do |file|
file_name = file.split('/').last
employee_code = file_name.split('.').first
employee = Employee.find_by(:employee_code => employee_code)
if not employee.nil?
image = File.new("#{Rails.public_path}/employee_pictures/#{file_name}", "r")
employee.avatar = image
employee.save
end
end


pay_invoice_ids = PayInvoice.where(:employee_id => employee.id, :status => true).collect(&:id)
EmployeeTaxableIncome.where(:pay_invoice_id => pay_invoice_ids).collect(&:prev_taxable_amount)

employee = Employee.find_by_employee_code("771662")
:q
pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
:q
pay_execution = pay_invoice.pay_execution
employee_taxable_income = pay_invoice.employee_taxable_income



employee_taxable_income.prev_vehicle_tax = 0.0
employee_taxable_income.save
(employee_taxable_income.taxable_amount_to_date + employee_taxable_income.predicated_taxable_amount + employee_taxable_income.loan_interest_amount + employee_taxable_income.prev_incentive_amount + employee_taxable_income.current_incentive_amount + employee_taxable_income.predition_amount + employee_taxable_income.prev_vehicle_tax + employee_taxable_income.current_month_vehicle_tax + employee_taxable_income.predicted_vehicle_tax + employee_taxable_income.pf_tax_value + employee_taxable_income.annualize_predicated_taxable_amount)






# ActiveRecord::Base.connection.execute("TRUNCATE table employees RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table employee_rosters RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table employee_attendances RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table attendance_cutoffs RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table finalize_attendances RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table attendance_machine_logs RESTART IDENTITY")

# ActiveRecord::Base.connection.execute("TRUNCATE table departments RESTART IDENTITY")
# ActiveRecord::Base.connection.execute("TRUNCATE table sub_departments RESTART IDENTITY")
# ActiveRecord::Base.connection.execute("TRUNCATE table designations RESTART IDENTITY")




payroll_info = SmarterCSV.process("#{Rails.public_path}/dfl_mill/update_employee_data.csv")
payroll_info.each do |single_item|
employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
if not employee.nil?
branch = Branch.find_by(:location => employee.location_id, :name => single_item[:branch])
employee.branch_id = branch.id
employee.save
end
end


deduction_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/dfl_mill_deduction_days.csv")
deduction_data.each do |single_item|
employee = Employee.find_by(:attendance_cutoff_id => [31, 32, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66], :employee_code => single_item[:emp_code].to_s)
if not employee.nil?
FinalizeAttendance.where(:employee_id => employee.id).each do |final_attendance|
final_attendance.pay_deduction = 0.0
final_attendance.save
end
end
end

deduction_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/dfl_mill_deduction_days.csv")
deduction_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s)
if not employee.nil?
final_attendance = FinalizeAttendance.where(:attendance_cutoff_id => [31, 32, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66], :employee_id => employee.id).last
if not final_attendance.nil?
final_attendance.pay_deduction = single_item[:deduction_days].to_f
final_attendance.save
end
end
end

	


employee_codes = ['271523', '271432', '271698', '271676', '271584', '271576', '271573', '271529', '271492', '271557', '271373', '271452', '271281', '271218', '271307', '271023', '270895', '270828', '270826', '270786', '270763', '270751', '270539', '270135', '270290']

Employee.where(:employee_code => employee_codes).each do |employee|
final_attendance = FinalizeAttendance.where(:employee_id => employee.id).last
if not final_attendance.nil?
final_attendance.pay_deduction = final_attendance.pay_deduction + 0.5
final_attendance.save
end
end



mill_tax_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/mill_tax_data.csv")
mill_tax_data.each do |single_item|
employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
if not employee.nil?
employee_tax_adjustment = EmployeeTaxAdjustment.new
employee_tax_adjustment.employee_id = employee.id
employee_tax_adjustment.company_id = employee.company_id
employee_tax_adjustment.amount = single_item[:tax_amount].to_f
employee_tax_adjustment.reason = "No Opening Balance"
employee_tax_adjustment.is_active = true
employee_tax_adjustment.tax_adjustment_month = (Time.now - 1.month).beginning_of_month.to_date
employee_tax_adjustment.tax_adjustment_formatted_month = (Time.now - 1.month).beginning_of_month.to_date.strftime("%B %Y")
employee_tax_adjustment.save
end
end

employee_codes = ['113538', '113539', '113540', '113541', '113543', '113544', '113546', '113547', '113548', '113550', '113551', '271687', '271688', '271689', '271692', '271695', '271696', '271697', '271698', '271699', '271701', '271702', '271703', '271704', '271705', '271706', '271707', '271708', '271709', '271710', '271711', '271712', '271713', '271714', '271715', '271716', '271717', '271718', '271719', '271720', '271721', '271722', '271723', '271724', '271725', '271726', '271727', '271728', '271729', '301026', '301028', '301029', '301030', '301031', '301032', '301033', '301034', '301035', '301036', '301037', '301038', '301039', '301040', '301041', '301042', '301043', '301044', '301045', '301046', '301048', '400681', '400684', '400685', '700130', '700131', '700132', '800543', '800544', '800545', '800546', '800547', '800548', '800549', '800550', '800551', '800552', '800554', '800556', '800557', '800558', '800559', '800560', '800561', '800562', '800563', '800564', '800565', '800566', '800568', '800569']


Employee.where(:employee_code => employee_codes).each do |employee|
employee.joining_date = (Time.now - 1.month).beginning_of_month.to_date
employee.save
end


employee_codes = ['270119', '271547', '271727', '271729', '301024']
Employee.where(:employee_code => employee_codes).each do |employee|
employee.tax_exempted = true
employee.save
end

employee_codes = ['102128', '102845', '109016', '109148', '109210', '109227', '109257', '109457', '109547', '109550', '109593', '109886', '109945', '110306', '110453', '110552', '110716', '110811', '110981', '111041', '111065', '111124', '111331', '111346', '111400', '111637', '111642', '111667', '111690', '111692', '111715', '111717', '111735', '111754', '111761', '111819', '111825', '111866', '111897', '111960', '111961', '112003', '112023', '112030', '112031', '112073', '112087', '112094', '112133', '112205', '112241', '112259', '112280', '112333', '112334', '112367', '112371', '112402', '112404', '112410', '112420', '112424', '112425', '112436', '112458', '112468', '112478', '112510', '112513', '112515', '112529', '112532', '112552', '112568', '112569', '112580', '112583', '112597', '112623', '112626', '112635', '112637', '112672', '112678', '112685', '112689', '112695', '112697', '112741', '112757', '112758', '112765', '112768', '112771', '112776', '112782', '112788', '112795', '112800', '112801', '112837', '112841', '112850', '112856', '112859', '112860', '112875', '112882', '112884', '112900', '112906', '112913', '112928', '112931', '112932', '112934', '112940', '112956', '112957', '112975', '112977', '112988', '113003', '113015', '113018', '113022', '113027', '113028', '113036', '113037', '113039', '113045', '113047', '113049', '113050', '113056', '113064', '113070', '113072', '113075', '113090', '113091', '113096', '113097', '113107', '113111', '113113', '113123', '113131', '113134', '113138', '113139', '113141', '113153', '113155', '113168', '113171', '113175', '113176', '113188', '113194', '113204', '113205', '113211', '113216', '113217', '113219', '113220', '113223', '113224', '113225', '113226', '113229', '113230', '113234', '113235', '113236', '113242', '113250', '113252', '113254', '113262', '113263', '113266', '113270', '113273', '113274', '113277', '113278', '113283', '113284', '113285', '113298', '113300', '113305', '113311', '113314', '113315', '113326', '113328', '113329', '113330', '113333', '113334', '113335', '113336', '113340', '113342', '113350', '113351', '113353', '113355', '113358', '113359', '113360', '113362', '113369', '113370', '113372', '113374', '113375', '113377', '113379', '113381', '113382', '113383', '113384', '113385', '113386', '113388', '113393', '113396', '113397', '113401', '113402', '113406', '113407', '113411', '113413', '113414', '113415', '113417', '113418', '113420', '113426', '113430', '113432', '113435', '113438', '113440', '113442', '113444', '113446', '113449', '113451', '113452', '113453', '113454', '113455', '113457', '113458', '113459', '113464', '113467', '113468', '113469', '113470', '113473', '113474', '113475', '113477', '113478', '113482', '113484', '113487', '113489', '113491', '113492', '113493', '113503', '113504', '113508', '113509', '113511', '113513', '113516', '113517', '113520', '113522', '113523', '113524', '113526', '113527', '113528', '113529', '113530', '113531', '113532', '113533', '113534', '113535', '113536', '113538', '113539', '113540', '113541', '113543', '113544', '113546', '113547', '113548', '113550', '113551', '151971', '152096', '152406', '152457', '159636', '159638', '159972', '160144', '160191', '160247', '160257', '160302', '160315', '160321', '160348', '160411', '160413', '160415', '160431', '160439', '160443', '160450', '160530', '160545', '160549', '160550', '160592', '160613', '160617', '160687', '160745', '160749', '160762', '160811', '160875', '160880', '160889', '160936', '160958', '160961', '160972', '160979', '160983', '160985', '161026', '161047', '161050', '161076', '161080', '161087', '161095', '161112', '161138', '161181', '161188', '161189', '161199', '161200', '161202', '161204', '161205', '161210', '161211', '161212', '161213', '161214', '161215', '161218', '161220', '161222', '161225', '161230', '161232', '161233', '161235', '161237', '161240', '161241', '161244', '161245', '161246', '161251', '161252', '161254', '161255', '171012', '171013', '171014', '171016', '171017', '171018', '171024', '270107', '270113', '270121', '270123', '270138', '270139', '270140', '270141', '270142', '270147', '270148', '270152', '270155', '270165', '270168', '270186', '270188', '270189', '270190', '270198', '270200', '270209', '270214', '270217', '270227', '270228', '270229', '270230', '270234', '270245', '270253', '270254', '270273', '270297', '270300', '270303', '270305', '270307', '270310', '270311', '270312', '270313', '270314', '270315', '270316', '270324', '270325', '270326', '270337', '270339', '270340', '270343', '270349', '270350', '270354', '270361', '270366', '270367', '270375', '270379', '270380', '270382', '270408', '270413', '270418', '270420', '270426', '270437', '270463', '270464', '270466', '270472', '270481', '270484', '270486', '270498', '270510', '270514', '270520', '270531', '270535', '270538', '270542', '270548', '270550', '270554', '270555', '270559', '270560', '270565', '270569', '270577', '270581', '270590', '270593', '270595', '270599', '270600', '270601', '270611', '270614', '270617', '270635', '270636', '270637', '270653', '270654', '270655', '270658', '270662', '270674', '270679', '270686', '270694', '270708', '270719', '270738', '270745', '270747', '270777', '270782', '270794', '270799', '270802', '270803', '270808', '270820', '270822', '270828', '270830', '270834', '270840', '270841', '270850', '270851', '270867', '270868', '270869', '270876', '270877', '270880', '270881', '270882', '270883', '270886', '270888', '270889', '270891', '270899', '270903', '270904', '270906', '270907', '270909', '270915', '270916', '270922', '270925', '270931', '270944', '270951', '270953', '270956', '270959', '270960', '270961', '270963', '270964', '270965', '270979', '270982', '270987', '270990', '270991', '271002', '271004', '271006', '271007', '271017', '271019', '271038', '271039', '271045', '271049', '271051', '271055', '271056', '271065', '271066', '271088', '271089', '271093', '271097', '271106', '271114', '271115', '271116', '271117', '271118', '271119', '271120', '271121', '271122', '271123', '271126', '271128', '271129', '271130', '271132', '271134', '271135', '271136', '271138', '271140', '271143', '271152', '271154', '271157', '271158', '271159', '271161', '271162', '271164', '271166', '271169', '271171', '271173', '271176', '271181', '271192', '271193', '271195', '271200', '271202', '271204', '271205', '271207', '271209', '271213', '271216', '271217', '271218', '271220', '271222', '271223', '271224', '271225', '271227', '271228', '271230', '271231', '271232', '271233', '271234', '271236', '271237', '271239', '271244', '271245', '271249', '271250', '271252', '271253', '271255', '271260', '271270', '271271', '271272', '271273', '271274', '271275', '271279', '271281', '271282', '271283', '271287', '271289', '271290', '271291', '271292', '271297', '271300', '271301', '271302', '271307', '271308', '271310', '271312', '271314', '271315', '271316', '271317', '271318', '271320', '271323', '271329', '271334', '271335', '271337', '271340', '271341', '271342', '271345', '271346', '271347', '271349', '271350', '271352', '271355', '271358', '271359', '271362', '271363', '271365', '271366', '271369', '271371', '271372', '271373', '271374', '271377', '271378', '271379', '271382', '271383', '271384', '271385', '271386', '271387', '271389', '271392', '271393', '271397', '271399', '271400', '271402', '271403', '271409', '271411', '271416', '271417', '271419', '271421', '271423', '271424', '271425', '271427', '271431', '271436', '271437', '271440', '271442', '271443', '271444', '271447', '271448', '271449', '271451', '271453', '271457', '271458', '271460', '271461', '271462', '271464', '271465', '271467', '271468', '271470', '271471', '271473', '271474', '271478', '271479', '271480', '271483', '271486', '271488', '271489', '271492', '271493', '271494', '271500', '271503', '271506', '271507', '271508', '271509', '271511', '271513', '271514', '271515', '271517', '271521', '271522', '271523', '271526', '271527', '271528', '271529', '271530', '271531', '271534', '271535', '271536', '271537', '271538', '271544', '271545', '271546', '271548', '271549', '271550', '271551', '271552', '271554', '271555', '271556', '271557', '271558', '271559', '271560', '271561', '271562', '271563', '271564', '271565', '271568', '271574', '271575', '271576', '271577', '271578', '271579', '271581', '271582', '271583', '271584', '271585', '271586', '271587', '271588', '271589', '271592', '271596', '271599', '271600', '271601', '271602', '271603', '271604', '271605', '271606', '271607', '271608', '271609', '271610', '271611', '271612', '271613', '271614', '271616', '271617', '271618', '271619', '271620', '271621', '271623', '271624', '271628', '271629', '271630', '271632', '271633', '271634', '271635', '271636', '271637', '271638', '271639', '271642', '271645', '271646', '271647', '271648', '271650', '271651', '271652', '271655', '271656', '271657', '271659', '271660', '271661', '271662', '271663', '271664', '271665', '271666', '271667', '271668', '271669', '271670', '271673', '271674', '271675', '271676', '271677', '271678', '271679', '271680', '271681', '271682', '271683', '271684', '271685', '271686', '271687', '271688', '271694', '271695', '271696', '271697', '271698', '271699', '271700', '271701', '271702', '271705', '271707', '271708', '271709', '271710', '271712', '271713', '271715', '271716', '271718', '271719', '271720', '271721', '271722', '271723', '271724', '271728', '300007', '300028', '300036', '300038', '300039', '300041', '300042', '300044', '300045', '300046', '300049', '300050', '300051', '300065', '300069', '300070', '300074', '300076', '300077', '300078', '300083', '300086', '300087', '300088', '300090', '300092', '300093', '300094', '300107', '300108', '300109', '300112', '300119', '300120', '300129', '300130', '300131', '300134', '300138', '300139', '300143', '300161', '300166', '300168', '300172', '300173', '300179', '300181', '300183', '300184', '300185', '300186', '300187', '300198', '300200', '300203', '300206', '300209', '300212', '300214', '300217', '300220', '300222', '300224', '300225', '300226', '300236', '300244', '300249', '300257', '300264', '300266', '300271', '300272', '300273', '300276', '300278', '300283', '300289', '300292', '300294', '300295', '300296', '300300', '300302', '300303', '300311', '300312', '300313', '300316', '300320', '300321', '300324', '300328', '300330', '300338', '300339', '300343', '300344', '300349', '300361', '300363', '300375', '300376', '300378', '300382', '300386', '300387', '300390', '300393', '300397', '300398', '300405', '300409', '300413', '300414', '300420', '300424', '300425', '300428', '300431', '300441', '300445', '300455', '300456', '300457', '300458', '300459', '300465', '300469', '300471', '300478', '300480', '300481', '300482', '300487', '300488', '300490', '300493', '300498', '300500', '300501', '300508', '300525', '300541', '300545', '300552', '300554', '300559', '300568', '300572', '300575', '300578', '300584', '300590', '300592', '300593', '300594', '300603', '300609', '300610', '300616', '300632', '300637', '300641', '300642', '300644', '300649', '300650', '300651', '300652', '300654', '300656', '300658', '300665', '300666', '300668', '300669', '300676', '300683', '300686', '300689', '300694', '300696', '300700', '300704', '300705', '300706', '300708', '300710', '300714', '300718', '300720', '300724', '300733', '300736', '300744', '300745', '300753', '300759', '300760', '300767', '300770', '300774', '300776', '300780', '300790', '300791', '300792', '300793', '300796', '300799', '300809', '300812', '300816', '300819', '300820', '300822', '300828', '300833', '300836', '300838', '300842', '300844', '300847', '300849', '300850', '300851', '300853', '300854', '300856', '300857', '300859', '300860', '300863', '300864', '300865', '300866', '300870', '300871', '300872', '300875', '300877', '300878', '300879', '300882', '300886', '300888', '300890', '300891', '300892', '300893', '300894', '300897', '300900', '300901', '300903', '300910', '300914', '300915', '300917', '300931', '300932', '300934', '300935', '300937', '300938', '300942', '300943', '300951', '300956', '300958', '300959', '300962', '300963', '300964', '300966', '300971', '300974', '300975', '300976', '300978', '300980', '300982', '300983', '300987', '300988', '300991', '300993', '300995', '301003', '301004', '301005', '301007', '301009', '301010', '301012', '301013', '301015', '301017', '301018', '301019', '301022', '301026', '301027', '301028', '301029', '301031', '301033', '301034', '301035', '301036', '301037', '301038', '301041', '301042', '301045', '301046', '400017', '400025', '400029', '400030', '400031', '400034', '400035', '400036', '400042', '400044', '400047', '400051', '400052', '400059', '400060', '400062', '400064', '400068', '400080', '400082', '400084', '400086', '400090', '400091', '400092', '400093', '400094', '400095', '400096', '400098', '400100', '400101', '400102', '400106', '400107', '400108', '400109', '400110', '400111', '400112', '400113', '400115', '400116', '400117', '400118', '400119', '400123', '400124', '400125', '400129', '400130', '400131', '400133', '400135', '400137', '400138', '400139', '400140', '400141', '400143', '400144', '400145', '400146', '400147', '400148', '400149', '400150', '400151', '400153', '400154', '400155', '400156', '400157', '400158', '400159', '400160', '400162', '400163', '400168', '400170', '400171', '400172', '400173', '400176', '400177', '400180', '400181', '400183', '400186', '400187', '400189', '400190', '400191', '400193', '400195', '400196', '400197', '400199', '400201', '400202', '400204', '400208', '400209', '400210', '400211', '400212', '400213', '400214', '400222', '400223', '400224', '400225', '400226', '400227', '400228', '400230', '400232', '400233', '400240', '400241', '400242', '400243', '400244', '400245', '400246', '400249', '400250', '400251', '400252', '400253', '400255', '400263', '400265', '400267', '400269', '400270', '400272', '400274', '400275', '400277', '400283', '400295', '400296', '400300', '400301', '400302', '400305', '400307', '400310', '400311', '400312', '400319', '400321', '400324', '400326', '400327', '400329', '400331', '400332', '400336', '400337', '400338', '400340', '400341', '400342', '400344', '400346', '400348', '400351', '400352', '400356', '400357', '400358', '400359', '400361', '400362', '400363', '400366', '400369', '400370', '400371', '400373', '400375', '400376', '400377', '400378', '400380', '400381', '400382', '400383', '400384', '400385', '400386', '400387', '400389', '400390', '400391', '400392', '400394', '400395', '400396', '400397', '400398', '400399', '400400', '400401', '400402', '400403', '400404', '400405', '400406', '400407', '400409', '400410', '400411', '400413', '400414', '400416', '400419', '400420', '400421', '400423', '400424', '400427', '400431', '400433', '400434', '400436', '400440', '400446', '400447', '400448', '400451', '400452', '400453', '400454', '400455', '400456', '400457', '400459', '400465', '400467', '400468', '400469', '400470', '400471', '400472', '400474', '400479', '400481', '400482', '400483', '400484', '400485', '400486', '400490', '400491', '400495', '400497', '400499', '400501', '400502', '400507', '400508', '400509', '400510', '400512', '400514', '400524', '400526', '400527', '400528', '400531', '400537', '400538', '400540', '400541', '400547', '400551', '400553', '400554', '400557', '400558', '400559', '400573', '400575', '400576', '400578', '400579', '400582', '400583', '400584', '400586', '400589', '400590', '400591', '400593', '400594', '400595', '400596', '400598', '400599', '400600', '400602', '400603', '400604', '400606', '400607', '400610', '400615', '400616', '400617', '400621', '400627', '400634', '400636', '400638', '400640', '400641', '400642', '400643', '400644', '400645', '400649', '400651', '400654', '400655', '400656', '400661', '400662', '400663', '400665', '400668', '400670', '400671', '400675', '400677', '400678', '400680', '400681', '400684', '400685', '600015', '600022', '600023', '600031', '600040', '600051', '600054', '600057', '600064', '600065', '600073', '600079', '600081', '600085', '600087', '600095', '600097', '600101', '600102', '600103', '600108', '600109', '600117', '600119', '600120', '600122', '600124', '600125', '600126', '600129', '600143', '600152', '600155', '600156', '600160', '600161', '600173', '600174', '600175', '600189', '600191', '600192', '600196', '600200', '600210', '600220', '600226', '600227', '600230', '600242', '600249', '600261', '600263', '600264', '600280', '600295', '600299', '600304', '600305', '600306', '600307', '600309', '600310', '600311', '600313', '600314', '600318', '600321', '600325', '600326', '600331', '600332', '600335', '600341', '600352', '600361', '600365', '600369', '600378', '600393', '600400', '600403', '600413', '600423', '600426', '600429', '600437', '600438', '600439', '600449', '600451', '600453', '600454', '600456', '600458', '600459', '600460', '600461', '600462', '600463', '600464', '700003', '700005', '700008', '700013', '700016', '700018', '700019', '700021', '700027', '700031', '700037', '700038', '700041', '700046', '700052', '700056', '700058', '700066', '700067', '700068', '700069', '700070', '700071', '700072', '700074', '700084', '700088', '700089', '700091', '700093', '700095', '700096', '700097', '700098', '700099', '700100', '700103', '700105', '700106', '700107', '700108', '700110', '700112', '700117', '700118', '700119', '700121', '700123', '700124', '700125', '700126', '700127', '700128', '700129', '700130', '700131', '800001', '800004', '800006', '800007', '800008', '800010', '800013', '800017', '800019', '800021', '800023', '800029', '800030', '800031', '800032', '800033', '800034', '800035', '800039', '800040', '800041', '800046', '800048', '800049', '800050', '800058', '800060', '800061', '800063', '800064', '800068', '800071', '800072', '800073', '800074', '800078', '800079', '800082', '800087', '800088', '800090', '800096', '800101', '800102', '800105', '800106', '800108', '800110', '800114', '800117', '800121', '800124', '800131', '800136', '800137', '800139', '800141', '800142', '800143', '800146', '800153', '800154', '800156', '800157', '800158', '800160', '800161', '800163', '800167', '800172', '800173', '800182', '800186', '800199', '800200', '800201', '800204', '800206', '800213', '800214', '800221', '800222', '800224', '800227', '800231', '800237', '800238', '800242', '800244', '800252', '800257', '800262', '800264', '800266', '800270', '800271', '800272', '800283', '800288', '800290', '800294', '800296', '800300', '800301', '800303', '800305', '800308', '800309', '800310', '800315', '800320', '800321', '800327', '800331', '800339', '800341', '800344', '800347', '800348', '800350', '800351', '800355', '800357', '800358', '800360', '800362', '800377', '800380', '800384', '800385', '800387', '800390', '800391', '800393', '800399', '800402', '800403', '800405', '800406', '800407', '800411', '800414', '800419', '800421', '800424', '800428', '800429', '800430', '800431', '800432', '800433', '800436', '800439', '800440', '800443', '800446', '800448', '800452', '800455', '800456', '800457', '800458', '800461', '800465', '800466', '800472', '800482', '800483', '800488', '800490', '800492', '800493', '800494', '800496', '800499', '800500', '800502', '800505', '800506', '800507', '800508', '800509', '800510', '800511', '800512', '800513', '800514', '800515', '800516', '800517', '800518', '800519', '800520', '800521', '800522', '800525', '800526', '800527', '800528', '800530', '800533', '800534', '800535', '800536', '800537', '800538', '800539', '800540', '800542', '800543', '800544', '800545', '800546', '800547', '800548', '800549', '800550', '800551', '800552', '800554', '800556', '800557', '800558', '800559', '800560', '800561', '800562', '800563', '800564', '800565', '800566', '800568', '800569']


Employee.where(:employee_code => employee_codes).each do |employee|
employee.is_medical_allowance = true
employee.save
end


pay_execution = PayExecution.find 34
employee = Employee.find_by_employee_code('649')
PayInvoice.generate_single_employee_invoice(employee, pay_execution)


FinalizeAttendance.all.order('id ASC').each do |finalize_attendance|
	finalize_attendance.salary_unit_id = finalize_attendance.employee_attendance.salary_unit_id
	finalize_attendance.save
end


bonus_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/new_annual_bonus_data.csv")
bonus_data.each do |single_item|
bonus_tbl = TempTblBonu.new
bonus_tbl.emp_code = single_item[:emp_code]
bonus_tbl.jan = single_item[:jan]
bonus_tbl.feb = single_item[:feb]
bonus_tbl.mar = single_item[:mar]
bonus_tbl.apr = single_item[:apr]
bonus_tbl.may = single_item[:may]
bonus_tbl.june = single_item[:june]
bonus_tbl.july = single_item[:july]
bonus_tbl.aug = single_item[:aug]
bonus_tbl.sep = single_item[:sep]
bonus_tbl.oct = single_item[:oct]
bonus_tbl.nov = single_item[:nov]
bonus_tbl.dec = single_item[:dec]
bonus_tbl.total = single_item[:total]
bonus_tbl.bonus = single_item[:bonus]
bonus_tbl.save
end


pay_item = PayItem.find_by(:name => "Eid Reward 2")
employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/eid_reward2.csv")
employee_data.each do |single_item|  
employee = Employee.find_by_employee_code(single_item[:emp_code])
if not employee.nil?
pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
if not pay_invoice.nil?
PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:eid_value], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
end
end
end


leave_year = LeaveYear.find 2
employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/srl_carry_forward_balance.csv")
employee_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s, :is_active => true)
if not employee.nil?
if single_item[:carry_forward_balance] != "-"
leave_allocation = LeaveAllocation.find_by(:leave_type => [4, 10, 14], :leave_year_id => leave_year.id, :employee_id => employee.id, :is_active => true)
if not leave_allocation.nil?
if LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => leave_allocation.id, :remarks => "Carry Forward Balance").nil?
leave_allocation.allocated_quota = leave_allocation.allocated_quota + single_item[:carry_forward_balance]
leave_allocation.remaining_quota = leave_allocation.remaining_quota + single_item[:carry_forward_balance]
if leave_allocation.save(:validate => false)
leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
if not leave_transaction.nil?
leave_transaction.leave_allocation_id = leave_allocation.id
leave_transaction.save
else
LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, single_item[:carry_forward_balance], "Earned", "Carry Forward Balance", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
end
end
end
end
end
end
end
		
ActiveRecord::Base.connection.execute("TRUNCATE table employee_rosters RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table leave_requests RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table official_duties RESTART IDENTITY")
ActiveRecord::Base.connection.execute("TRUNCATE table employees RESTART IDENTITY")
	
EmployeeRoster.where(:location_id => 2, :roster_date => start_date.to_date..end_date.to_date).update_all(:is_rest_day => true)

start_date = "21-03-2020".to_date
end_date = "31-03-2020".to_date




cut_off = AttendanceCutoff.find 33
overtime_data = SmarterCSV.process("#{Rails.public_path}/stml4_data/attendance_cut_off.csv")
overtime_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s)
if not employee.nil?
final_attendance = cut_off.finalize_attendances.where(:employee_id => employee.id).last
if not final_attendance.nil?
final_attendance.over_time_hours 	= single_item[:overtime_hours].to_f
final_attendance.save
end
end
end

employee_codes = ['271300', '271589', '271613', '400472', '800537', '800558']


Employee.where(:employee_code => employee_codes).each do |e|
	e.is_active = false
	e.save
end


e = Employee.find_by_employee_code('400695')
:q
e.hiring_shift = "G"
e.save




SubTimeSlot.all.each do |a|
	a.end_buffer = 200
	a.save
end



emp_list = SmarterCSV.process("#{Rails.public_path}/dfl_mill/dec/Book3.csv")
emp_list.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s)
if not employee.nil?
employee.gross_salary = single_item[:gross_rate].to_f
employee.save
end
end

start_date = "24-02-2020".to_date.beginning_of_day.to_date
end_date = "27-06-2020".to_date.end_of_day.to_date
date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
employee = Employee.find_by_employee_code("771729")
if not employee.nil?
	company = employee.company
	if not company.nil?
		date_range.each do |single_date|
			roster = EmployeeRoster.find_by(:employee_id => employee.id, :roster_date => single_date.to_date)
			if not roster.nil?
				employee_roster = roster
				if single_date.to_date.strftime("%A").upcase == "Saturday".upcase
					employee_roster.is_rest_day = false
				end
				employee_roster.save
			end
		end
	end
end


emp_list = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_enrollment/spinning.csv")
emp_list.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:employeeid].to_s)
if not employee.nil?
employee.hiring_shift = single_item[:shift]
employee.save
end
end

emp_list1 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_enrollment/dfl2.csv")
emp_list1.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:employeeid].to_s)
if not employee.nil?
employee.hiring_shift = single_item[:shift]
employee.save
end
end

emp_list2 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_enrollment/dfl1.csv")
emp_list2.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:employeeid].to_s)
if not employee.nil?
employee.hiring_shift = single_item[:shift]
employee.save
end
end

emp_list3 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_enrollment/denim	.csv")
emp_list3.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:employeeid].to_s)
if not employee.nil?
employee.hiring_shift = single_item[:shift]
employee.save
end
end

emp_list4 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_enrollment/apparel.csv")
emp_list4.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:employeeid].to_s)
if not employee.nil?
employee.hiring_shift = single_item[:shift]
employee.save
end
end	


employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/garment_employee.csv")
employee_data.each do |single_item|
employee = Employee.find_by_employee_code(single_item[:emp_code])
if not employee.nil?
location = Location.find_by_name("Garment")
branch = Branch.find_by(:name => single_item[:branch], :location => location.id)
employee.branch_id = branch.id
employee.save
end
end


deduction_data = SmarterCSV.process("#{Rails.public_path}/sdl_farm/process_cutoff.csv")
deduction_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s)
if not employee.nil?
FinalizeAttendance.where(:attendance_cutoff_id => [3, 4], :employee_id => employee.id).each do |final_attendance|
final_attendance.pay_deduction = 0.0
final_attendance.save
end
end
end

deduction_data = SmarterCSV.process("#{Rails.public_path}/sdl_farm/farm_cutoff.csv")
deduction_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s)
if not employee.nil?
FinalizeAttendance.where(:attendance_cutoff_id => [3, 4], :employee_id => employee.id).each do |final_attendance|
final_attendance.pay_deduction = 0.0
final_attendance.save
end
end
end

deduction_data = SmarterCSV.process("#{Rails.public_path}/sdl_farm/farm_cutoff.csv")
deduction_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s)
if not employee.nil?
final_attendance = FinalizeAttendance.where(:attendance_cutoff_id => [3, 4], :employee_id => employee.id).last
if not final_attendance.nil?
final_attendance.pay_deduction = single_item[:deduction].to_f
final_attendance.save
end
end
end

deduction_data = SmarterCSV.process("#{Rails.public_path}/sdl_farm/process_cutoff.csv")
deduction_data.each do |single_item|
employee = Employee.find_by(:employee_code => single_item[:emp_code].to_s)
if not employee.nil?
final_attendance = FinalizeAttendance.where(:attendance_cutoff_id => [3, 4], :employee_id => employee.id).last
if not final_attendance.nil?
final_attendance.pay_deduction = single_item[:deduction].to_f
final_attendance.save
end
end
end




employee = Employee.find_by_employee_code("272579")
employee.leave_allocations.collect(&:id).sort


l = LeaveAllocation.find 795
l.leave_type_name
l.destroy



employee_codes = ["771723", "771724", "771725", "771547", "771663", "771667", "771670", "771666", "771658", "771653", "771664", "771668", "771665"]


