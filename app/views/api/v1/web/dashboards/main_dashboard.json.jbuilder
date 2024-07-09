json.dashboard_data do
	json.total_locations 		@locations.count
	json.total_branches 		@branches.count
	json.total_departments 	@departments.count
	json.total_employees 		@employees.count
end

if @employee_list.count > 0
	employee_types_color 					= []
	locations_color 							= []
	leave_summaries_color = []
	json.employees_by_ages Array.new(4).each_index do |index|
		if index == 0
			color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
			json.value 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 25.to_i.years),(Date.today - 18.to_i.years)).count
			json.label	"18-25 Age"
			json.color	color
		elsif index == 1
			color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
			json.value 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 35.to_i.years),(Date.today - 26.to_i.years)).count
			json.label	"26-35 Age"
			json.color	color
		elsif index == 2
			color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
			json.value 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 45.to_i.years),(Date.today - 36.to_i.years)).count
			json.label	"36-45 Age"
			json.color	color
		elsif index == 3
			color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
			json.value 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 60.to_i.years),(Date.today - 46.to_i.years)).count
			json.label	"46-60 Age"
			json.color	color
		end
	end
	# json.pie_employees_by_ages Array.new(4).each_index do |index|
	# 	if index == 0
	# 		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
	# 		json.data 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 25.to_i.years),(Date.today - 18.to_i.years)).count
	# 		json.label	"18-25 Age"
	# 	elsif index == 1
	# 		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
	# 		json.data 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 35.to_i.years),(Date.today - 26.to_i.years)).count
	# 		json.label	"26-35 Age"
	# 	elsif index == 2
	# 		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
	# 		json.data 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 45.to_i.years),(Date.today - 36.to_i.years)).count
	# 		json.label	"36-45 Age"
	# 	elsif index == 3
	# 		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
	# 		json.data 	@employee_list.where('date_of_birth BETWEEN ? AND ?',(Date.today - 60.to_i.years),(Date.today - 46.to_i.years)).count
	# 		json.label	"46-60 Age"
	# 	end
	# end
	json.employee_types EmployeeType.all do |employee_type|
		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
		json.label 	employee_type.name
		json.value 	@employee_list.where(employee_type_id: employee_type.id).count
		json.color	color
		employee_types_color << color
	end
	# json.pie_employee_types EmployeeType.all do |employee_type|
	# 	json.label 	employee_type.name
	# 	json.data 	@employee_list.where(employee_type_id: employee_type.id).count
	# 	employee_types_color << "##{Random.new.bytes(3).unpack('H*')[0]}"
	# end
	json.locations Location.where(:is_active => true).each do |location|
		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
		json.label 	location.name
		json.value 	@employee_list.where(location_id: location.id).count
		json.color	color
		locations_color << color
	end
	# json.pie_locations Location.where(:is_active => true).each do |location|
	# 	json.label 	location.name
	# 	json.data 	@employee_list.where(location_id: location.id).count
	# 	locations_color << "##{Random.new.bytes(3).unpack('H*')[0]}"
	# end

	############################################################
	#################### old Logic of Leave ####################
	############################################################
	# leave_types = LeaveType.where(:is_active => true).order('sort_order ASC')
	# json.monthly_leave_summaries leave_types.each do |leave_type|
	# 	color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
	# 	json.label 	leave_type.name
	# 	json.value 	LeaveRequest.where(:leave_type_id => leave_type.id, :request_status => "Availed", :employee_id => @employee_list.collect(&:id)).count
	# 	json.color	color
	# 	leave_summaries_color << color
	# end
	############################################################
	#################### old Logic of Leave ####################
	############################################################
	
	############################################################
	################## Updated Logic of Leave ##################
	############################################################
	leave_type_names = LeaveType.where(:is_active => true, :location_id => @locations.collect(&:id).uniq).collect(&:name).uniq
	json.monthly_leave_summaries leave_type_names.each do |single_item|
		leave_types = LeaveType.where(:is_active => true, :name => single_item).order('sort_order ASC')
		color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
		json.label 	single_item
		json.value 	LeaveRequest.where(:leave_type_id => leave_types.collect(&:id), :request_status => "Availed", :employee_id => @employee_list.collect(&:id)).where(['start_date >= ? AND end_date <= ?', Time.now.to_date.beginning_of_month, Time.now.to_date.end_of_month]).count
		json.color	color
		leave_summaries_color << color
	end
	############################################################
	################## Updated Logic of Leave ##################
	############################################################ 

	# json.pie_monthly_leave_summaries leave_types.each do |leave_type|
	# 	json.label 	leave_type.name
	# 	json.data 	LeaveRequest.where(:leave_type_id => leave_type.id, :request_status => "Availed", :employee_id => @employee_list.collect(&:id)).count
	# 	leave_summaries_color << "##{Random.new.bytes(3).unpack('H*')[0]}"
	# end
	# json.employee_types_color		 	employee_types_color
	# json.locations_color				 	locations_color
	# json.leave_summaries_color 		leave_summaries_color
else
	json.employees_by_ages 				[]
	json.employee_types 					[]
	json.locations 								[]
	json.monthly_leave_summaries 	[]
	# json.employee_types_color		 	[]
	# json.locations_color				 	[]
	# json.leave_summaries_color 		[]
	# json.pie_employees_by_ages		[]
	# json.pie_employee_types				[]
	# json.pie_locations						[]
	# json.pie_monthly_leave_summaries []
end

json.documents @documents.each do |document|
	json.id 				document.try(:id)
	json.name 			document.try(:name)
	json.code 			document.try(:code)
	begin
		json.avatar document.try(:avatar).url
	  json.avatar_file_name document.try(:avatar_file_name)
		if document.avatar_file_name.nil? or document.avatar_file_name.blank?
	    json.avatar_present false
	  else
	    json.avatar_present true
	  end
	rescue Exception => e
		json.avatar ""
		json.avatar_file_name ""
		json.avatar_present false
	end
end

json.year_upcomming_holidays @holidays.each do |holiday|
	if holiday.start_date.to_date >= @year_start_date.to_date and holiday.end_date.to_date <= @year_end_date.to_date
		json.id							holiday.try(:id)
	  json.name 					holiday.try(:name)
	  json.start_date 		holiday.try(:start_date).strftime("%B %-d, %Y")
	  json.end_date 			holiday.try(:end_date).strftime("%B %-d, %Y")
	end
end

json.month_upcomming_holidays @holidays.each do |holiday|
	if holiday.start_date.to_date >= @month_start_date.to_date and holiday.end_date.to_date <= @month_end_date.to_date
		json.id							holiday.try(:id)
	  json.name 					holiday.try(:name)
	  json.start_date 		holiday.try(:start_date).strftime("%B %-d, %Y")
	  json.end_date 			holiday.try(:end_date).strftime("%B %-d, %Y")
	end
end

if current_user.employee.nil?
	json.personal_data do
		json.employee_name 				"-"
		json.employee_picture 		"-"
		json.employee_name 				"-"
		json.designation_name 		"-"
		json.department_name 			"-"
		json.sub_department_name 	"-"
		json.employee_code	 			"-"
		json.date_of_birth 				"-"
		json.joining_date 				"-"
		json.employee_status 			"-"
		json.grade_name 					"-"
		json.cnic_number 					"-"
		json.location_name 				"-"
		json.branch_name 					"-"
		json.line_manager_name 		"-"
		json.job_title_name 			"-"
		json.current_address 			"-"
	end
	json.attendances []
	json.leave_types []
else
	json.personal_data do
		begin
			json.employee_picture current_user.employee.try(:avatar).url
		  json.avatar_file_name current_user.employee.try(:avatar_file_name)
			if current_user.employee.avatar_file_name.nil? or current_user.employee.avatar_file_name.blank?
		    json.avatar_present false
		  else
		    json.avatar_present true
		  end
		rescue Exception => e
			json.employee_picture ""
			json.avatar_file_name ""
			json.avatar_present false
		end		
		json.employee_name 				current_user.employee.full_name
		json.designation_name 		current_user.employee.designation_name
		json.department_name 			current_user.employee.department_name
		json.sub_department_name 	current_user.employee.sub_department_name
		json.employee_code 				current_user.employee.employee_code
		json.date_of_birth 				ReportFormat.date_format(current_user.employee.date_of_birth)
		json.joining_date 				ReportFormat.date_format(current_user.employee.joining_date)
		json.employee_status 			ReportFormat.boolean_in_text_as_confirmed(current_user.employee.on_probation)
		json.grade_name 					current_user.employee.grade_name
		json.cnic_number 					current_user.employee.cnic_number
		json.location_name 				current_user.employee.location_name
		json.branch_name 					current_user.employee.branch_name
		json.line_manager_name 		current_user.employee.line_manager_name
		json.job_title_name 			current_user.employee.job_title_name
		json.current_address 			current_user.employee.current_address
	end
	start_date  = Time.now - 6.day
	end_date  	= Time.now
	date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
	employee_attendances = EmployeeAttendance.where(:employee_id => current_user.employee.id, :attendance_date => date_range).order('attendance_date ASC')
	json.attendances employee_attendances.each do |employee_attendance|
		json.attendance_date 						ReportFormat.time_card_date_format(employee_attendance.attendance_date)
		if employee_attendance.in_time.nil?
			json.in_time 										"-"
		else
			json.in_time 									employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
		end
		if employee_attendance.out_time.nil?
			json.out_time 									"-"
		else
			json.out_time 								employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
		end
		json.attendance_status					employee_attendance.attendance_status
	end
	leave_types = LeaveType.where(:is_active => true, :is_composite => false).order('sort_order ASC')
	json.leave_types leave_types.each do |leave_type|
	  leave_allocation = LeaveAllocation.find_by(:employee_id => current_user.employee.id, :is_active => true, :leave_type_id => leave_type.id)
	  if not leave_allocation.nil?
	    json.leave_type_name 	leave_type.name
	    json.allocated_quota 	leave_allocation.allocated_quota.to_f.round(2).to_s
	    json.used_quota 			leave_allocation.used_quota.to_f.round(2).to_s
	    json.remaining_quota 	leave_allocation.remaining_quota.to_f.round(2).to_s
	    json.percent_leaves 	(((leave_allocation.remaining_quota.to_f/leave_allocation.allocated_quota.to_f)*100).to_f).to_f.round(2)
	  end
	end
end

json.leave_approvals @leave_approvals.each do |leave_approval|
	json.id 							leave_approval.id
	if leave_approval.requestable_type == "LeaveRequest"
		leave_request = 			LeaveRequest.find(leave_approval.requestable_id)
		json.request_type 		"Leave"
		json.request_status		leave_approval.approval_request_status
		json.employee_name		leave_request.employee_name
		json.employee_code		leave_request.employee_code
		json.request_count		leave_request.request_count
		json.apply_date				ReportFormat.date_format(leave_request.created_at)
		json.start_date				ReportFormat.date_format(leave_request.start_date)
		json.end_date					ReportFormat.date_format(leave_request.end_date)
	end
end

json.official_duty_approvals @official_duty_approvals.each do |official_duty_approval|
	json.id 							official_duty_approval.id
	if official_duty_approval.requestable_type == "OfficialDuty"
		official_duty = 			OfficialDuty.find(official_duty_approval.requestable_id)
		json.request_type 		"OD"
		json.request_status		official_duty_approval.approval_request_status
		json.employee_name		official_duty.employee_name
		json.employee_code		official_duty.employee_code
		json.request_count		official_duty.request_count
		json.apply_date				ReportFormat.date_format(official_duty.created_at)
		json.start_date				ReportFormat.date_format(official_duty.start_date)
		json.end_date					ReportFormat.date_format(official_duty.end_date)
	end
end

json.relaxation_approvals @relaxation_approvals.each do |relaxation_approval|
	json.id 								relaxation_approval.id
	if relaxation_approval.requestable_type == "RelaxationRequest"
		relaxation_request = RelaxationRequest.find(relaxation_approval.requestable_id)
		json.request_type 					"Relaxation"
		json.request_status					relaxation_approval.approval_request_status
		json.employee_name					relaxation_request.employee_name
		json.employee_code					relaxation_request.employee_code
		json.request_count					relaxation_request.request_count
		json.apply_date							ReportFormat.date_format(relaxation_request.created_at)
		json.start_date							ReportFormat.date_format(relaxation_request.start_date)
		json.end_date								ReportFormat.date_format(relaxation_request.end_date)
	end
end