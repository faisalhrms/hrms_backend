class DataEntry

	# DataEntry.dummy_name
	def self.dummy_name
		Employee.all.each do |e|
			e.first_name = Faker::Name.first_name
			e.last_name = Faker::Name.last_name
			e.father_name = Faker::Name.name_with_middle
			e.save(:validate => false)
		end

		LeaveRequest.all.each do |l|
			l.request_sender_name = Faker::Name.name_with_middle
			l.save
		end

		OfficialDuty.all.each do |l|
			l.request_sender_name = Faker::Name.name_with_middle
			l.save
		end
	end

	# DataEntry.dummy_data
	def self.dummy_data
		Array.new(300).each_index do |index|
			UserActivity.create(:action_performed => Faker::Lorem.sentence, :email => Faker::Internet.email, :full_name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			AssetType.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			CertificationType.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			LeftReason.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			QualficationType.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			Relationship.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			Specialization.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Array.new(100).each_index do |index|
			TrainingType.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}")
		end

		Company.all.each do |company|
			Array.new(5).each_index do |index|
				Holiday.create(:description => Faker::Lorem.sentence, :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}", :code => "#{Faker::Name.first_name} #{Faker::Name.last_name}", :start_date => Time.now.to_date, :end_date => (Time.now + 5.day).to_date, :company_id => company.id)
			end
		end
	end

	# DataEntry.destroy_attendance_related_data
	def self.destroy_attendance_related_data
		LeaveAllocation.destroy_all
		LeaveRequest.destroy_all
		ApprovalRequest.destroy_all
		LeaveTransactionHistory.destroy_all
		LeaveRequestDetail.destroy_all
		RelaxationRequest.destroy_all
		OfficialDuty.destroy_all
		FinalizeAttendance.destroy_all
		EmployeeAttendance.destroy_all
		EmployeeArrear.destroy_all
		Notification.destroy_all
		Employee.destroy_all
	end

	# DataEntry.add_geographical_data
	def self.add_geographical_data
		countries_file = File.read "#{Rails.public_path}/countries.json"
		countries_data = JSON.parse(countries_file)
		countries_data["countries"].each do |data|
			Country.create(:name => data["name"], :sortname => data["sortname"])
		end

		states_file = File.read "#{Rails.public_path}/states.json"
		states_data = JSON.parse(states_file)
		states_data["states"].each do |data|
			State.create(:name => data["name"], :country_id => data["country_id"])
		end
	
		cities_file = File.read "#{Rails.public_path}/cities.json"
		cities_data = JSON.parse(cities_file)
		cities_data["cities"].each do |data|
			City.create(:name => data["name"], :state_id => data["state_id"])
		end
	end

	# DataEntry.add_organization_data
	def self.add_organization_data
		Array.new(5).each_index do |index|
			Company.create(:name => Faker::Company.name, :code => Faker::Code.isbn, :short_name => Faker::Name.initials, :address => Faker::Address.full_address, :description => Faker::Lorem.paragraph)
		end
		
		company_ids = Company.all.collect(&:id)
		Array.new(50).each_index do |index|
			Location.create(:company_id => company_ids.sample, :name => Faker::Company.name, :code => Faker::Code.isbn, :description => Faker::Lorem.paragraph)
		end
		
		location_ids = Location.all.collect(&:id)
		Array.new(50).each_index do |index|
			Branch.create(:company_id => company_ids.sample, :location_id => location_ids.sample, :name => Faker::Company.name, :code => Faker::Code.isbn, :description => Faker::Lorem.paragraph)
		end

		Array.new(50).each_index do |index|
			Department.create(:company_id => company_ids.sample, :name => Faker::Company.name, :code => Faker::Code.isbn, :description => Faker::Lorem.paragraph)
		end

		Array.new(250).each_index do |index|
			Designation.create(:company_id => company_ids.sample, :name => Faker::Job.title, :code => Faker::Code.isbn, :description => Faker::Lorem.paragraph, :is_active => Faker::Boolean.boolean)
		end

		Array.new(250).each_index do |index|
			JobTitle.create(:company_id => company_ids.sample, :name => Faker::Job.title, :description => Faker::Lorem.paragraph, :is_active => Faker::Boolean.boolean)
		end
	end

	# DataEntry.add_role_permission
	def self.add_role_permission
		Company.all.each do |company|
			role = Role.new(:name => "Administrator", :company_id => company.id, :is_active => true)
			role.save
			RolePermission.create(:main_module => "organization", 							module_name: "organization_chart", 								display_name: "Organization Chart", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "company", 													display_name: "Company", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "location", 													display_name: "Location", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "branch", 														display_name: "Branch", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "department", 												display_name: "Department", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "department_allocation", 						display_name: "Department Allocation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "sub_department", 										display_name: "Sub Department", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "grade", 														display_name: "Grade", 														index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "grade_allocation", 									display_name: "Grade Allocation", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "designation", 											display_name: "Designation", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "job_title", 												display_name: "Job Title", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "salary_unit", 											display_name: "Salary Unit", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "cost_center", 											display_name: "Cost Center", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "job_title_allocation", 							display_name: "Job Title Allocation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "bank_detail", 											display_name: "Bank Detail", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "asset_detail", 											display_name: "Asset Detail",											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "user", 															display_name: "Users", 														index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "role_permission", 									display_name: "Role & Permission", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "activity_stream", 									display_name: "Activity Stream", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "general_setting", 									display_name: "General Setting", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "geographical_setting", 							display_name: "Geographical Setting", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "email_template", 										display_name: "Email Template", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "email_configration", 								display_name: "Email Configration", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "email_execution", 									display_name: "Email Execution", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "sms_template", 											display_name: "SMS Template", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "sms_configration", 									display_name: "SMS Configration", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "sms_execution", 										display_name: "SMS Execution", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "holiday_management", 								display_name: "Holiday Management", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "document_management", 							display_name: "Document Management", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "request_flow", 											display_name: "Request Flow", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "administrative_structure", 					display_name: "Administrative Structure", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "system_setting", 										display_name: "System Setting", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_enrollment", 							display_name: "Employee Enrollment", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "current_employee", 									display_name: "Current Employees", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "archive_employee", 									display_name: "Archive Employees", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_change", 									display_name: "Employees Change", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "subordinate_employee", 							display_name: "Subordinate Employee", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "temporary_staff", 									display_name: "Temporary Staff", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "internee", 													display_name: "Internee", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_leave_ledger", 						display_name: "Leave Ledger", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_leave_request", 						display_name: "Leave Request", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_leave_approval", 					display_name: "Leave Approval", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_official_duty_request",		display_name: "OD Request", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_official_duty_approval",		display_name: "OD Approval", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_relaxation_request", 			display_name: "Relaxation Request", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_relaxation_approval", 			display_name: "Relaxation Approval", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_approval_request", 				display_name: "Approval Request", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "my_profile", 												display_name: "Profile", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "my_timecard", 											display_name: "My Time Card", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "personal_information", 							display_name: "Personal Information", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employment_information", 						display_name: "Employment Information", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "user_account", 											display_name: "User Account", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "emergency_contact", 								display_name: "Emergency Contact", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "attendance_information", 						display_name: "Attendance Information", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "salary_information", 								display_name: "Salary Information", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "qualification_and_experience", 			display_name: "Qualification and Experience", 		index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "transaction_history", 							display_name: "Transaction History", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "benefit_information", 							display_name: "Benefit Information", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "download_file", 										display_name: "Download File", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "show_salary", 											display_name: "Show Salary", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "edit_employee_code", 								display_name: "Edit Employee Code", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_request", 										display_name: "Leave Request", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_approval", 										display_name: "Leave Approval", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_bulk_operation", 							display_name: "Leave Bulk Operation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_type", 												display_name: "Leave Type", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_year", 												display_name: "Leave Year", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_allocation", 									display_name: "Leave Allocation", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "official_duty_management", 	module_name: "official_duty_request", 						display_name: "Offical Duty Request", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "official_duty_management", 	module_name: "official_duty_approval", 						display_name: "Offical Duty Approval", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "official_duty_management", 	module_name: "official_duty_bulk_operation", 			display_name: "Offical Duty Bulk Operation", 			index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_list", 										display_name: "Employee List", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "objective_list", 										display_name: "Objective List", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "appraisal_list", 										display_name: "Appraisal List", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "health_insurance_report", 					display_name: "Health Insurance", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "joiner_detail", 										display_name: "Joiner Detail", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "probation_detail", 									display_name: "Probation Detail", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "transfer_detail", 									display_name: "Transfer Detail", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "line_manager_detail", 							display_name: "Line Manager Detail", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leaver_detail", 										display_name: "Leaver Detail", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "benefit_detail", 										display_name: "Benefit Detail", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_summary", 								display_name: "Attendance Summary", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_summary_detail", 				display_name: "Attendance Summary Detail", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "sale_incentive", 										display_name: "Sale Incentive", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_log", 										display_name: "Attendance Log", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "salary_register", 									display_name: "Salary Register", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "payment_register", 									display_name: "Payment Register", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "salary_sheet", 											display_name: "Salary Sheet", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "eobi_report", 											display_name: "EOBI Report", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "pessi_report", 											display_name: "PESSI Report", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "pf_report", 												display_name: "Provident Fund Report", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "tax_report", 												display_name: "Tax Report", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "daily_attendance", 									display_name: "Daily Attendance", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "detail_overtime", 									display_name: "Detail OverTime", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_register", 							display_name: "Attendance Register", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_report_menu", 							display_name: "Employee Report Menu", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "performance_management_report_menu", 	display_name: "Performance Management Report Menu", index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "incentive_report_menu", 						display_name: "Incentive Report Menu", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_report_menu", 						display_name: "Attendance Report Menu", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "payroll_report_menu", 							display_name: "PayRoll Report Menu", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_execution_log", 					display_name: "Attendance Execution Log", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_report_menu", 								display_name: "Leave Report Menu", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "official_duty_report_menu", 				display_name: "OD Report Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_balance", 										display_name: "Leave Balance", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_encashment", 									display_name: "Leave Encashment", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_ledger", 											display_name: "Leave Ledger", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "od_register", 											display_name: "OD Register", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_profile_detail", 					display_name: "Employee Profile Detail", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_bank_detail", 							display_name: "Employee Bank Detail", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_contact_detail", 					display_name: "Employee Contact Detail", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_reference_detail", 				display_name: "Employee Reference Detail", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_next_of_kin_detail", 			display_name: "Employee Next of Kin Detail", 			index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_relative_detail", 					display_name: "Employee Relative Detail", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_qualification_detail", 		display_name: "Employee Qualification Detail",		index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_last_qualification",				display_name: "Employee Last Qualification",			index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_first_experience", 				display_name: "Employee First Experience",				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_last_experience", 					display_name: "Employee Last Experience",					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_experience_detail", 				display_name: "Employee Experience Detail",				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_balance_detail", 							display_name: "Leave Balance Detail",							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_asset_detail", 						display_name: "Employee Asset Detail",						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "social_security", 									display_name: "Social Security",									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "tax_structure", 										display_name: "Tax Structure",										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "comman_staff", 											display_name: "Comman Staff",											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "overtime_approval", 								display_name: "OverTime Approval", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_cutoff", 								display_name: "Attendance Cut Off", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_exception", 							display_name: "Attendance Exception", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_type", 									display_name: "Attendance Type", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_deduction", 							display_name: "Attendance Deduction", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_earning", 								display_name: "Attendance Dearning", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_relaxation", 						display_name: "Attendance Relaxation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_overtime", 							display_name: "Attendance OverTime", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "missing_punch_policy", 							display_name: "Missing Punch Policy", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "absent_policy", 										display_name: "Absent Policy", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "early_left_policy", 								display_name: "Early Left Policy", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "over_strength_request", 						display_name: "Over Strength Request", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "relaxation_request", 								display_name: "Relaxation Request", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "relaxation_approval", 							display_name: "Relaxation Approval", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "relaxation_bulk_operation", 				display_name: "Relaxation Bulk Operation", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_structure", 							display_name: "Attendance Structure", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_device", 								display_name: "Attendance Device", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_execution", 							display_name: "Attendance Execution", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "subordinate_time_card", 						display_name: "Subordinate Time Card", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "employee_arrear", 									display_name: "Employee Arrear", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "employee_deduction", 								display_name: "Employee Deduction", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "over_time_policy", 									display_name: "OverTime Policy", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "overtime_bulk_operation", 					display_name: "OverTime Bulk Operation", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "incentive_management", 			module_name: "sale_entry", 												display_name: "Sale Entry", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "incentive_management", 			module_name: "sale_incentive", 										display_name: "Sale Incentive", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "incentive_management", 			module_name: "incentive_policy", 									display_name: "Incentive Policy", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "time_slot", 												display_name: "Time Slot", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "sub_time_slot", 										display_name: "Sub Time Slot",										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "roster", 														display_name: "Roster", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "my_roster", 												display_name: "My Roster", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "subordinate_roster", 								display_name: "Sub Ordinate Roster", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "pay_item", 													display_name: "Pay Item", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "fixed_pay_item", 										display_name: "Fixed Pay Item", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "provident_fund", 										display_name: "Provident Fund", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "eobi", 															display_name: "EOBI", 														index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "tax_slab", 													display_name: "Tax Slab", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "custom_tax_slab", 									display_name: "Custom Tax Slab", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "payitem_expression", 								display_name: "PayItem Expression", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "fiscal_year", 											display_name: "Fiscal Year", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "pay_execution", 										display_name: "Pay Execution", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "benefit_structure", 								display_name: "Benefit Structure", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "employee_loan", 										display_name: "Employee Loan", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "employee_advance", 									display_name: "Employee Advance", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "pay_invoice", 											display_name: "Salary Slip", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "subordinate_pay_invoice", 					display_name: "Subordinate Salary Slip", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "my_salary_slip", 										display_name: "My Salary Slip", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "tax_credit", 												display_name: "Tax Credit", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "tax_adjustment", 										display_name: "Tax Adjustment", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "benefit_item", 											display_name: "Benefit Item", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "employee_tax_detail", 							display_name: "Employee Tax Detail", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "fuel_card_detail", 									display_name: "Fuel Card Detail", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "request_menu", 											display_name: "Request Menu", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "employee_menu", 										display_name: "Employee Menu", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "leave_menu", 												display_name: "Leave Menu", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "official_duty_menu", 								display_name: "Official Duty Menu", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "roster_menu", 											display_name: "Roster Menu", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "attendance_menu", 									display_name: "Attendance Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "incentive_menu", 										display_name: "Incentive Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "payroll_menu", 											display_name: "Pay Roll Menu", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "organization_menu", 								display_name: "Organization Menu", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "admin_tool_menu", 									display_name: "Admin Tool Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
		end
	end

	# DataEntry.update_role_permission
	def self.update_role_permission
		RolePermission.destroy_all
		Role.all.each do |role|
			RolePermission.create(:main_module => "organization", 							module_name: "organization_chart", 								display_name: "Organization Chart", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "company", 													display_name: "Company", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "location", 													display_name: "Location", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "branch", 														display_name: "Branch", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "department", 												display_name: "Department", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "department_allocation", 						display_name: "Department Allocation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "sub_department", 										display_name: "Sub Department", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "grade", 														display_name: "Grade", 														index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "grade_allocation", 									display_name: "Grade Allocation", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "designation", 											display_name: "Designation", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "job_title", 												display_name: "Job Title", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "salary_unit", 											display_name: "Salary Unit", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "cost_center", 											display_name: "Cost Center", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "job_title_allocation", 							display_name: "Job Title Allocation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "bank_detail", 											display_name: "Bank Detail", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "organization", 							module_name: "asset_detail", 											display_name: "Asset Detail",											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "user", 															display_name: "Users", 														index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "role_permission", 									display_name: "Role & Permission", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "activity_stream", 									display_name: "Activity Stream", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "general_setting", 									display_name: "General Setting", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "geographical_setting", 							display_name: "Geographical Setting", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "email_template", 										display_name: "Email Template", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "email_configration", 								display_name: "Email Configration", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "email_execution", 									display_name: "Email Execution", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "sms_template", 											display_name: "SMS Template", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "sms_configration", 									display_name: "SMS Configration", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "sms_execution", 										display_name: "SMS Execution", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "holiday_management", 								display_name: "Holiday Management", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "document_management", 							display_name: "Document Management", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "request_flow", 											display_name: "Request Flow", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "administrative_structure", 					display_name: "Administrative Structure", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "admin_tool", 								module_name: "system_setting", 										display_name: "System Setting", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_enrollment", 							display_name: "Employee Enrollment", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "current_employee", 									display_name: "Current Employees", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "archive_employee", 									display_name: "Archive Employees", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_change", 									display_name: "Employees Change", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "subordinate_employee", 							display_name: "Subordinate Employee", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "temporary_staff", 									display_name: "Temporary Staff", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "internee", 													display_name: "Internee", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_leave_ledger", 						display_name: "Leave Ledger", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_leave_request", 						display_name: "Leave Request", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_leave_approval", 					display_name: "Leave Approval", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_official_duty_request",		display_name: "OD Request", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_official_duty_approval",		display_name: "OD Approval", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_relaxation_request", 			display_name: "Relaxation Request", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_relaxation_approval", 			display_name: "Relaxation Approval", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employee_approval_request", 				display_name: "Approval Request", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "my_profile", 												display_name: "Profile", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "my_timecard", 											display_name: "My Time Card", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "personal_information", 							display_name: "Personal Information", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "employment_information", 						display_name: "Employment Information", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "user_account", 											display_name: "User Account", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "emergency_contact", 								display_name: "Emergency Contact", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "attendance_information", 						display_name: "Attendance Information", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "salary_information", 								display_name: "Salary Information", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "qualification_and_experience", 			display_name: "Qualification and Experience", 		index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "transaction_history", 							display_name: "Transaction History", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "benefit_information", 							display_name: "Benefit Information", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "download_file", 										display_name: "Download File", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "show_salary", 											display_name: "Show Salary", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "employee_management", 				module_name: "edit_employee_code", 								display_name: "Edit Employee Code", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_request", 										display_name: "Leave Request", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_approval", 										display_name: "Leave Approval", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_bulk_operation", 							display_name: "Leave Bulk Operation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_type", 												display_name: "Leave Type", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_year", 												display_name: "Leave Year", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "leave_management", 					module_name: "leave_allocation", 									display_name: "Leave Allocation", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "official_duty_management", 	module_name: "official_duty_request", 						display_name: "Offical Duty Request", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "official_duty_management", 	module_name: "official_duty_approval", 						display_name: "Offical Duty Approval", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "official_duty_management", 	module_name: "official_duty_bulk_operation", 			display_name: "Offical Duty Bulk Operation", 			index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_list", 										display_name: "Employee List", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "objective_list", 										display_name: "Objective List", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "appraisal_list", 										display_name: "Appraisal List", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "health_insurance_report", 					display_name: "Health Insurance", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "joiner_detail", 										display_name: "Joiner Detail", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "probation_detail", 									display_name: "Probation Detail", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "transfer_detail", 									display_name: "Transfer Detail", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "line_manager_detail", 							display_name: "Line Manager Detail", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leaver_detail", 										display_name: "Leaver Detail", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "benefit_detail", 										display_name: "Benefit Detail", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_summary", 								display_name: "Attendance Summary", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_summary_detail", 				display_name: "Attendance Summary Detail", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "sale_incentive", 										display_name: "Sale Incentive", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_log", 										display_name: "Attendance Log", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "salary_register", 									display_name: "Salary Register", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "payment_register", 									display_name: "Payment Register", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "salary_sheet", 											display_name: "Salary Sheet", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "eobi_report", 											display_name: "EOBI Report", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "pessi_report", 											display_name: "PESSI Report", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "pf_report", 												display_name: "Provident Fund Report", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "tax_report", 												display_name: "Tax Report", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "daily_attendance", 									display_name: "Daily Attendance", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "detail_overtime", 									display_name: "Detail OverTime", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_register", 							display_name: "Attendance Register", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_report_menu", 							display_name: "Employee Report Menu", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "performance_management_report_menu", display_name: "Performance Management Report Menu", 	index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "incentive_report_menu", 						display_name: "Incentive Report Menu", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_report_menu", 						display_name: "Attendance Report Menu", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "payroll_report_menu", 							display_name: "PayRoll Report Menu", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "attendance_execution_log", 					display_name: "Attendance Execution Log", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_report_menu", 								display_name: "Leave Report Menu", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "official_duty_report_menu", 				display_name: "OD Report Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_balance", 										display_name: "Leave Balance", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_encashment", 									display_name: "Leave Encashment", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_ledger", 											display_name: "Leave Ledger", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "od_register", 											display_name: "OD Register", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_profile_detail", 					display_name: "Employee Profile Detail", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_bank_detail", 							display_name: "Employee Bank Detail", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_contact_detail", 					display_name: "Employee Contact Detail", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_reference_detail", 				display_name: "Employee Reference Detail", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_next_of_kin_detail", 			display_name: "Employee Next of Kin Detail", 			index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_relative_detail", 					display_name: "Employee Relative Detail", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_qualification_detail", 		display_name: "Employee Qualification Detail",		index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_last_qualification",				display_name: "Employee Last Qualification",			index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_first_experience", 				display_name: "Employee First Experience",				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_last_experience", 					display_name: "Employee Last Experience",					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_experience_detail", 				display_name: "Employee Experience Detail",				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "leave_balance_detail", 							display_name: "Leave Balance Detail",							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "employee_asset_detail", 						display_name: "Employee Asset Detail",						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "social_security", 									display_name: "Social Security",									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "tax_structure", 										display_name: "Tax Structure",										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "report_management", 					module_name: "comman_staff", 											display_name: "Comman Staff",											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "overtime_approval", 								display_name: "OverTime Approval", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_cutoff", 								display_name: "Attendance Cut Off", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_exception", 							display_name: "Attendance Exception", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_type", 									display_name: "Attendance Type", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_deduction", 							display_name: "Attendance Deduction", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_earning", 								display_name: "Attendance Dearning", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_relaxation", 						display_name: "Attendance Relaxation", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_overtime", 							display_name: "Attendance OverTime", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "missing_punch_policy", 							display_name: "Missing Punch Policy", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "absent_policy", 										display_name: "Absent Policy", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "early_left_policy", 								display_name: "Early Left Policy", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "over_strength_request", 						display_name: "Over Strength Request", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "relaxation_request", 								display_name: "Relaxation Request", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "relaxation_approval", 							display_name: "Relaxation Approval", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "relaxation_bulk_operation", 				display_name: "Relaxation Bulk Operation", 				index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_structure", 							display_name: "Attendance Structure", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_device", 								display_name: "Attendance Device", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "attendance_execution", 							display_name: "Attendance Execution", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "subordinate_time_card", 						display_name: "Subordinate Time Card", 						index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "employee_arrear", 									display_name: "Employee Arrear", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "employee_deduction", 								display_name: "Employee Deduction", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "over_time_policy", 									display_name: "OverTime Policy", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "attendance_management", 			module_name: "overtime_bulk_operation", 					display_name: "OverTime Bulk Operation", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "incentive_management", 			module_name: "sale_entry", 												display_name: "Sale Entry", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "incentive_management", 			module_name: "sale_incentive", 										display_name: "Sale Incentive", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "incentive_management", 			module_name: "incentive_policy", 									display_name: "Incentive Policy", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "time_slot", 												display_name: "Time Slot", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "sub_time_slot", 										display_name: "Sub Time Slot",										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "roster", 														display_name: "Roster", 													index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "my_roster", 												display_name: "My Roster", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "roster_management", 					module_name: "subordinate_roster", 								display_name: "Sub Ordinate Roster", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "pay_item", 													display_name: "Pay Item", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "fixed_pay_item", 										display_name: "Fixed Pay Item", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "provident_fund", 										display_name: "Provident Fund", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "eobi", 															display_name: "EOBI", 														index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "tax_slab", 													display_name: "Tax Slab", 												index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "custom_tax_slab", 									display_name: "Custom Tax Slab", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "payitem_expression", 								display_name: "PayItem Expression", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "fiscal_year", 											display_name: "Fiscal Year", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "pay_execution", 										display_name: "Pay Execution", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "benefit_structure", 								display_name: "Benefit Structure", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "employee_loan", 										display_name: "Employee Loan", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "employee_advance", 									display_name: "Employee Advance", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "pay_invoice", 											display_name: "Salary Slip", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "subordinate_pay_invoice", 					display_name: "Subordinate Salary Slip", 					index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "my_salary_slip", 										display_name: "My Salary Slip", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "tax_credit", 												display_name: "Tax Credit", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "tax_adjustment", 										display_name: "Tax Adjustment", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "benefit_item", 											display_name: "Benefit Item", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "employee_tax_detail", 							display_name: "Employee Tax Detail", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "payroll_management", 				module_name: "fuel_card_detail", 									display_name: "Fuel Card Detail", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "request_menu", 											display_name: "Request Menu", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "employee_menu", 										display_name: "Employee Menu", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "leave_menu", 												display_name: "Leave Menu", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "official_duty_menu", 								display_name: "Official Duty Menu", 							index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "roster_menu", 											display_name: "Roster Menu", 											index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "attendance_menu", 									display_name: "Attendance Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "incentive_menu", 										display_name: "Incentive Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "payroll_menu", 											display_name: "Pay Roll Menu", 										index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "organization_menu", 								display_name: "Organization Menu", 								index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
			RolePermission.create(:main_module => "main_menu", 									module_name: "admin_tool_menu", 									display_name: "Admin Tool Menu", 									index_access: true, create_access: true, view_access: true, update_access: true, delete_access: true, role_id: role.id)
		end
	end

	# DataEntry.add_new_permission
	def self.add_new_permission
		Role.all.each do |role|
			if not role.role_permissions.exists?(module_name:"eobi_report")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "eobi_report"
				role_permission.display_name 	= "EOBI Report"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"pf_report")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "pf_report"
				role_permission.display_name 	= "Provident Fund Report"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"tax_report")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "tax_report"
				role_permission.display_name 	= "Tax Report"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"salary_sheet")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "salary_sheet"
				role_permission.display_name 	= "Salary Sheet"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"leave_report_menu")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "leave_report_menu"
				role_permission.display_name 	= "Leave Report Menu"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"official_duty_report_menu")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "official_duty_report_menu"
				role_permission.display_name 	= "OD Report Menu"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"od_register")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "od_register"
				role_permission.display_name 	= "OD Register"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"leave_balance")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "leave_balance"
				role_permission.display_name 	= "Leave Balance"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"asset_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "organization"
				role_permission.module_name 	= "asset_detail"
				role_permission.display_name 	= "Asset Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"leave_encashment")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "leave_encashment"
				role_permission.display_name 	= "Leave Encashment"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"leave_ledger")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "leave_ledger"
				role_permission.display_name 	= "Leave Ledger"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_profile_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_profile_detail"
				role_permission.display_name 	= "Employee Profile Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_bank_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_bank_detail"
				role_permission.display_name 	= "Employee Bank Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_contact_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_contact_detail"
				role_permission.display_name 	= "Employee Contact Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_reference_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_reference_detail"
				role_permission.display_name 	= "Employee Reference Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_next_of_kin_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_next_of_kin_detail"
				role_permission.display_name 	= "Employee Next of Kin Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_relative_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_relative_detail"
				role_permission.display_name 	= "Employee Relative Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_qualification_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_qualification_detail"
				role_permission.display_name 	= "Employee Qualification Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_last_qualification")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_last_qualification"
				role_permission.display_name 	= "Employee Last Qualification"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_experience_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_experience_detail"
				role_permission.display_name 	= "Employee Experience Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_first_experience")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_first_experience"
				role_permission.display_name 	= "Employee First Experience"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_last_experience")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_last_experience"
				role_permission.display_name 	= "Employee Last Experience"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"leave_balance_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "leave_balance_detail"
				role_permission.display_name 	= "Leave Balance Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_asset_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "employee_asset_detail"
				role_permission.display_name 	= "Employee Asset Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"custom_tax_slab")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "payroll_management"
				role_permission.module_name 	= "custom_tax_slab"
				role_permission.display_name 	= "Custom Tax Slab"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"social_security")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "social_security"
				role_permission.display_name 	= "Social Security"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"tax_adjustment")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "payroll_management"
				role_permission.module_name 	= "tax_adjustment"
				role_permission.display_name 	= "Tax Adjustment"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"overtime_approval")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "attendance_management"
				role_permission.module_name 	= "overtime_approval"
				role_permission.display_name 	= "OverTime Approval"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"payment_register")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "payment_register"
				role_permission.display_name 	= "Payment Register"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"pessi_report")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "pessi_report"
				role_permission.display_name 	= "PESSI Report"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_tax_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "payroll_management"
				role_permission.module_name 	= "employee_tax_detail"
				role_permission.display_name 	= "Employee Tax Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"health_insurance_report")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "health_insurance_report"
				role_permission.display_name 	= "Health Insurance"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"tax_structure")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "tax_structure"
				role_permission.display_name 	= "Tax Structure"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"comman_staff")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "report_management"
				role_permission.module_name 	= "comman_staff"
				role_permission.display_name 	= "Comman Staff"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"employee_deduction")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "attendance_management"
				role_permission.module_name 	= "employee_deduction"
				role_permission.display_name 	= "Employee Deduction"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"over_strength_request")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "attendance_management"
				role_permission.module_name 	= "over_strength_request"
				role_permission.display_name 	= "Over Strength Request"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"sub_time_slot")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "roster_management"
				role_permission.module_name 	= "sub_time_slot"
				role_permission.display_name 	= "Sub Time Slot"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
			if not role.role_permissions.exists?(module_name:"fuel_card_detail")
				role_permission = role.role_permissions.build
				role_permission.main_module 	= "payroll_management"
				role_permission.module_name 	= "fuel_card_detail"
				role_permission.display_name 	= "Fuel Card Detail"
				role_permission.index_access 	= false
				role_permission.create_access = false
				role_permission.view_access 	= false
				role_permission.update_access = false
				role_permission.delete_access = false
				role_permission.save
			end
		end
	end

	# DataEntry.insert_religion_sect
	def self.insert_religion_sect
		ReligionSect.create(:name => "Shah")
		ReligionSect.create(:name => "Maseeh")
		ReligionSect.create(:name => "Deu Band")
		ReligionSect.create(:name => "Ahle Tashi")
		ReligionSect.create(:name => "Ehle Hadees")
		ReligionSect.create(:name => "Sunni")
		ReligionSect.create(:name => "Wahabi")
		ReligionSect.create(:name => "Ahmadi")
		ReligionSect.create(:name => "Shia")
	end

	# DataEntry.insert_religion
	def self.insert_religion
		Religion.create(:name => "Parsi")
		Religion.create(:name => "Judaism")
		Religion.create(:name => "Buddhism")
		Religion.create(:name => "Jainism")
		Religion.create(:name => "Kalash")
		Religion.create(:name => "Zoroastrianism")
		Religion.create(:name => "Sikhism")
		Religion.create(:name => "Baha")
		Religion.create(:name => "Christianity")
		Religion.create(:name => "Hinduism")
		Religion.create(:name => "Ahmadiyya")
		Religion.create(:name => "Sufi")
		Religion.create(:name => "Islam")
	end

	# DataEntry.clear_leave_data
	def self.clear_leave_data
		LeaveAllocation.destroy_all
		LeaveRequest.destroy_all
		ApprovalRequest.destroy_all
		LeaveTransactionHistory.destroy_all
	end

	# DataEntry.update_confrimation_due_date
	def self.update_confrimation_due_date
		Employee.all.each do |employee|
			if not employee.joining_date.nil?
				employee.confimration_due_date = (employee.joining_date + 3.month)
				employee.save
			end
		end
	end

	# DataEntry.add_qualification_program
	def self.add_qualification_program
		QualificationProgram.create(:name => "BSC")
		QualificationProgram.create(:name => "Matric")
		QualificationProgram.create(:name => "MBA")
		QualificationProgram.create(:name => "BBA")
		QualificationProgram.create(:name => "I.C.S")
		QualificationProgram.create(:name => "Matric")
		QualificationProgram.create(:name => "MBA")
		QualificationProgram.create(:name => "BBA")
		QualificationProgram.create(:name => "I.COM")
		QualificationProgram.create(:name => "Matric")
		QualificationProgram.create(:name => "Ca")
		QualificationProgram.create(:name => "Bachelors")
		QualificationProgram.create(:name => "FSC")
		QualificationProgram.create(:name => "MSC")
		QualificationProgram.create(:name => "BSC")
		QualificationProgram.create(:name => "Acca")
		QualificationProgram.create(:name => "Cat")
		QualificationProgram.create(:name => "Pre - Engineering")
		QualificationProgram.create(:name => "D. Com")
		QualificationProgram.create(:name => "B.Com")
		QualificationProgram.create(:name => "FA")
		QualificationProgram.create(:name => "Diploma")
		QualificationProgram.create(:name => "Intermediate")
		QualificationProgram.create(:name => "BA")
		QualificationProgram.create(:name => "I.C.S")
		QualificationProgram.create(:name => "Under Matric")
		QualificationProgram.create(:name => "MBA")
		QualificationProgram.create(:name => "B.Com Hons")
		QualificationProgram.create(:name => "M. Com")
		QualificationProgram.create(:name => "A - Level")
		QualificationProgram.create(:name => "O - Level")
		QualificationProgram.create(:name => "Bba Hons")
		QualificationProgram.create(:name => "BS")
		QualificationProgram.create(:name => "Masters")
		QualificationProgram.create(:name => "B.C.S")
		QualificationProgram.create(:name => "Textile Engineering")
		QualificationProgram.create(:name => "BFA")
		QualificationProgram.create(:name => "Cgma")
		QualificationProgram.create(:name => "Cima")
		QualificationProgram.create(:name => "E Mba")
		QualificationProgram.create(:name => "M. S. C")
		QualificationProgram.create(:name => "MA")
		QualificationProgram.create(:name => "C M A")
		QualificationProgram.create(:name => "C A")
		QualificationProgram.create(:name => "M.Phil")
		QualificationProgram.create(:name => "MS")
		QualificationProgram.create(:name => "DAE")
	end

	# DataEntry.add_relationship
	def self.add_relationship
		Relationship.create(:name => "Spouse")
		Relationship.create(:name => "Father-In-Law")
		Relationship.create(:name => "Mother-In-Law")
		Relationship.create(:name => "Husband")
		Relationship.create(:name => "Sister")
		Relationship.create(:name => "Brother")
		Relationship.create(:name => "Daughter")
		Relationship.create(:name => "Son")
		Relationship.create(:name => "Father")
		Relationship.create(:name => "Mother")
	end

	# DataEntry.add_srl_department
	def self.add_srl_department
		department_list = ["Stitching Meyer", "HR & Administration", "Stitching", "Stitching", "Cutting", "Quality", "GWP", "Product Development", "Product Development", "Cutting", "Quality", "Cutting", "HR & Administration", "Electrical", "HR & Administration", "Stitching", "WIP", "Quality", "P.P.C", "WIP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "HR & Administration", "P.P.C", "GWP", "Finishing & Packing", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Quality", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Cutting", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Product Development", "Quality", "Quality", "Finishing & Packing", "Quality", "Finishing & Packing", "GWP", "Finishing & Packing", "Quality", "Product Development", "Product Development", "MMC", "Product Development", "Quality", "GWP", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Electrical", "GWP", "GWP", "GWP", "GWP", "Product Development", "Product Development", "Quality", "Quality", "Mechanical", "Stitching", "Stitching", "Stitching", "GWP", "Quality", "GWP", "GWP", "Finishing & Packing", "GWP", "Product Development", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "Stitching", "Quality", "Stitching", "Cutting", "Stitching", "Product Development", "Product Development", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "WIP", "Product Development", "Stitching", "Cutting", "Stitching", "Quality", "Quality", "Stitching", "Cutting", "GWP", "Quality", "Mechanical", "Quality", "Stitching", "Stitching", "Stitching", "HR & Administration", "HR & Administration", "Stitching", "Stitching", "Finishing & Packing", "Quality", "GWP", "Stitching", "Cutting", "Cutting", "WIP", "WIP", "WIP", "Mechanical", "Finishing & Packing", "GWP", "GWP", "Quality", "GWP", "GWP", "GWP", "GWP", "GWP", "Mechanical", "Electrical", "GWP", "Quality", "Mechanical", "Cutting", "Product Development", "Stitching", "Quality", "Quality", "Mechanical", "Product Development", "Product Development", "Finishing & Packing", "Cutting", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Quality", "Quality", "Finishing & Packing", "Product Development", "Stitching", "Stitching", "GWP", "Stitching", "Quality", "Finishing & Packing", "GWP", "GWP", "GWP", "Stitching", "Finishing & Packing", "GWP", "GWP", "GWP", "Stitching", "Finishing & Packing", "Finishing & Packing", "Mechanical", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Product Development", "WIP", "WIP", "Stitching", "MMC", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "GWP", "Stitching", "Cutting", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Cutting", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Finishing & Packing", "Stitching", "Mechanical", "Stitching", "Product Development", "GWP", "Finishing & Packing", "GWP", "GWP", "Finishing & Packing", "Product Development", "Mechanical", "Product Development", "Cutting", "Product Development", "Product Development", "Product Development", "Stitching", "Stitching", "Product Development", "Stitching", "Product Development", "Finishing & Packing", "Quality", "Quality", "Quality", "P.P.C", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "Quality Meyer", "P.P.C", "WIP", "Stitching", "Stitching", "Finishing & Packing", "GWP", "Finishing & Packing", "Cutting", "Stitching", "MMC", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Cutting", "Stitching", "Product Development", "Product Development", "Stitching", "Product Development", "Product Development", "WIP", "Finishing & Packing", "Cutting", "Finishing & Packing", "Cutting", "Stitching", "Quality", "Quality", "Stitching", "Product Development", "Product Development", "Cutting", "Finishing & Packing", "Quality", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Product Development", "GWP", "Stitching", "Quality Meyer", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Quality", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Quality", "Product Development", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "Cutting", "Quality", "MMC", "Finishing & Packing", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Quality Meyer", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "GWP", "Stitching", "Finishing & Packing", "Product Development", "Quality", "GWP", "Finishing & Packing", "Finishing & Packing", "Product Development", "Stitching", "Product Development", "Product Development", "Industrial Engineering", "Finishing & Packing", "Product Development", "Product Development", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Cutting", "Stitching", "Finishing & Packing", "Stitching", "Mechanical", "Product Development", "Product Development", "GWP", "GWP", "Finishing & Packing", "Quality", "Stitching", "Cutting", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Accounts", "Stitching", "Stitching", "Cutting", "Finishing & Packing", "GWP", "Finishing & Packing", "Finishing & Packing", "Cutting", "Cutting", "Quality", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "GWP", "HR & Administration", "Finishing & Packing", "Finishing & Packing", "Quality", "Stitching", "Stitching", "Stitching", "GWP", "Cutting", "Stitching", "GWP", "Product Development", "MMC", "GWP", "MMC", "GWP", "WIP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "Product Development", "Stitching", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Product Development", "Product Development", "GWP", "Mechanical", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Finishing & Packing", "WIP", "WIP", "Cutting", "GWP", "Finishing & Packing", "Finishing & Packing", "GWP", "Quality", "Quality", "GWP", "Stitching", "Electrical", "Product Development", "Quality", "Stitching", "WIP", "GWP", "GWP", "GWP", "GWP", "Quality", "Product Development", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "GWP", "GWP", "P.P.C", "P.P.C", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Product Development", "HR & Administration", "Stitching", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "Cutting", "Stitching Meyer", "GWP", "GWP", "GWP", "Industrial Engineering", "Mechanical", "P.P.C", "Cutting", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "Stitching", "Stitching", "Stitching", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Cutting", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "Finishing & Packing", "P.P.C", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "Cutting", "Product Development", "Finishing & Packing", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Cutting", "Cutting", "Cutting", "Finishing & Packing", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "GWP", "WIP", "Quality", "Industrial Engineering", "Cutting", "WIP", "GWP", "GWP", "WIP", "WIP", "GWP", "GWP", "GWP", "GWP", "GWP", "Industrial Engineering", "Stitching", "Stitching Meyer", "Stitching", "Cutting", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "WIP", "WIP", "Cutting", "Cutting", "Quality", "Finishing & Packing", "Finishing & Packing", "Cutting", "GWP", "GWP", "GWP", "GWP", "Quality", "Quality Meyer", "Quality", "Quality", "WIP", "WIP", "Cutting", "WIP", "GWP", "Quality", "Quality", "Mechanical", "GWP", "Quality", "Quality", "WIP", "WIP", "WIP", "WIP", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Cutting", "Quality", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Quality", "Stitching", "Cutting", "Cutting", "Finishing & Packing", "Stitching", "WIP", "WIP", "WIP", "WIP", "WIP", "HR & Administration", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "HR & Administration", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Industrial Engineering", "Cutting", "Quality", "Mechanical", "Cutting", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Quality Meyer", "Quality", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Quality", "Cutting", "WIP", "WIP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "WIP Meyer", "WIP", "WIP", "WIP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Mechanical", "WIP", "WIP", "WIP", "WIP Meyer", "WIP", "WIP", "HR & Administration", "Product Development", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching Meyer", "Stitching", "HR & Administration", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "Quality", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "HR & Administration", "HR & Administration", "Cutting", "Cutting", "P.P.C", "GWP", "GWP", "Product Development", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "Quality", "Quality", "Cutting", "HR & Administration", "WIP", "WIP", "GWP", "Cutting", "Finishing & Packing", "GWP", "GWP", "GWP", "Quality", "Quality", "GWP", "Stitching", "Stitching", "Stitching", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Quality", "WIP", "WIP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "WIP", "Electrical", "Mechanical", "Mechanical", "Mechnical Meyer", "GWP", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "Stitching", "Stitching", "Finishing & Packing", "Product Development", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "GWP", "Stitching Meyer", "HR & Administration", "Industrial Engineering", "Finishing & Packing", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching Meyer", "Stitching Meyer", "Finishing & Packing", "Finishing & Packing", "Cutting", "Stitching Meyer", "GWP", "Stitching Meyer", "Finishing & Packing", "Stitching", "Stitching", "Industrial Engineering", "Stitching", "HR & Administration", "Finishing & Packing", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching Meyer", "Stitching", "Stitching", "Stitching", "Stitching", "Cutting", "Industrial Engineering", "MMC", "MMC", "Stitching", "Stitching", "Stitching", "Stitching Meyer", "Finishing & Packing", "Cutting", "Stitching Meyer", "Finishing & Packing", "Finishing & Packing", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "Industrial Engineering", "Cutting", "Mechanical", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "Mechanical", "Stitching Meyer", "Finishing & Packing", "Stitching", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Quality", "GWP", "Product Development", "GWP", "GWP", "Stitching Meyer", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching Meyer", "Stitching Meyer", "Stitching", "Stitching", "Quality", "Quality", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "Quality", "Quality", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "HR & Administration", "HR & Administration", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Product Development", "Cutting", "Finishing & Packing", "Mechanical", "Quality", "Stitching", "Stitching", "Stitching", "Product Development", "Stitching", "Finishing & Packing", "Finishing & Packing", "HR & Administration", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "HR & Administration", "Stitching Meyer", "Stitching Meyer", "Stitching Meyer", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Mechanical", "Finishing & Packing"]
		department_list.each do |single_item|
			Department.create(:name => single_item, :code => single_item, :is_active => true, :company_id => 1)
		end

		Department.all.each do |department|
			SubDepartment.create(:name => department.name, :code => department.code, :is_active => true, :company_id => 1, :department_id => department.id)
		end
	end

	# DataEntry.add_srl_job_title
	def self.add_srl_job_title
		job_titles = ["Receptionist", "Senior Manager R&D", "Executive Accounts & Finance", "DGM Planning & Merchandising", "Executive Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Deputy Manager Timelines Reporting - Stitched & Unstitched", "Rider", "Senior Executive Supply Chain & Warehouse", "Sr. Executive Raw Material - Fabric Procurement", "Worker Supply Chain & Warehouse", "Assistant Manager Print/Dyeing Sampling", "AM Inventory & Product Controller", "Executive Garment Engineering", "Officer Master Data", "Worker Supply Chain & Warehouse", "Sr. Executive Project & Expansion", "Planner - Kids Eastern & Western", "Senior Executive Allocation & Replenishment - Stitched Tops", "Deputy Manager Raw Material - Fabric Procurement", "Officer Supply Chain & Warehouse", "Supervisor Supply Chain & Warehouse", "Assistant Manager Supply Chain & Warehouse", "Chief Financial Officer", "Supervisor Supply Chain & Warehouse", "Sr. Executive Raw Material - Fabric Procurement", "Driver", "Executive Accounts & Finance", "Executive Repair & Maintenance - North", "Senior Officer Supply Chain & Warehouse", "Senior Officer Supply Chain & Warehouse", "Officer ERP Data Entry", "Executive ERP Functional", "Manager Budgeting", "Executive Procurement - Non Textile", "HR Officer", "Driver", "Senior Manager Retail Operations ", "Manager Expansion & Projects", "Office Attendant", "Deputy Manager Bank/Import & Insurance", "Office Attendant", "Driver", "Assistant Manager Sampling Requisition & Control", "Assistant Planner - Stitched", "HRIS Officer", "Assistant Manager ERP Development", "Assistant Manager Embroidery Sampling", "Chief MIS Officer", "Manager Taxation & Legal Affairs", "Content Uploader", "Deputy Manager Accounts & Finance", "Officer ERP Data Entry", "Manager IT Integration", "Senior Executive Administration", "Deputy Manager ERP DBA", "Assistant Worker Supply Chain & Warehouse", "Assistant Merchandiser - Stitched", "Sr. Executive Raw Material - Fabric Procurement", "Assistant Worker Supply Chain & Warehouse", "Assistant Manager Accounts & Finance", "Executive Supply Chain & Warehouse", "Planner - Women's Western", "Officer Supply Chain & Warehouse", "Senior Manager HR & OD", "Manager Accounts & Finance", "Deputy Manager Rewards, Policies & Analytics", "Assistant Manager Marketing", "Supervisor Supply Chain & Warehouse", "Web Developer", "Designer & Merchandiser - Men's Wear Eastern", "Senior Officer Visual Merchandise", "Executive Accounts & Finance", "Embroidery Puncher", "Embroidery Puncher", "Embroidery Puncher", "Embroidery Puncher", "Embroidery Puncher", "Sketcher", "Embroidery Puncher", "Embroidery Puncher", "Embroidery Designer", "Textile Designer", "Textile Designer", "Textile Designer", "Team Lead - Stitched A", "Textile Designer", "Textile Designer", "Senior Fashion Designer", "Embroidery Designer", "Senior Embroidery Designer", "Sketcher - Kids Eastern & Western", "Embroidery Designer", "Sketcher", "Sketcher", "Sketcher", "Sketcher", "Sketcher", "Embroidery Designer", "Textile Designer", "Tracer - Stitched", "Tracer - Stitched", "Tracer - Unstitched", "Tracer - Stitched", "Tracer - Unstitched", "Embroidery Puncher", "Tracer - Unstitched", "Assistant Planner - Stitched", "Sketcher", "Office Attendant", "Senior Executive Retail Audit", "Textile Designer", "Driver", "Designer- Bags", "Designer- Women's Shoes", "Assistant Manager Payments", "Embroidery Puncher", "Embroidery Puncher", "Tracer - Unstitched", "Tracer - Unstitched", "Tracer - Unstitched", "Stylist", "Designer- Men's Shoes", "Embroidery Puncher", "Textile Designer", "Textile Designer", "Textile Designer", "Textile Designer", "Tracer - Unstitched", "Embroidery Puncher", "Embroidery Puncher", "Assistant Manager Audit - Others & Logistics", "Embroidery Puncher", "Embroidery Puncher", "Creative Marketing Executive", "Tracer - Stitched", "Graphic Designer Lead", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Embroidery Puncher", "Embroidery Puncher", "Head of Technical Embroidery", "Supervisor Supply Chain & Warehouse", "Driver", "Worker Supply Chain & Warehouse", "Embroidery Puncher", "Fashion Designer - Kids Western", "Textile Designer", "Purchase Officer", "Fashion Designer - Women's Western", "Embroidery Puncher", "Fashion Designer", "Embroidery Designer", "Embroidery Puncher", "Tracer - Unstitched", "Tracer - Unstitched", "Embroidery Puncher", "Assistant Manager Supply Chain", "IT Support - Warehouse", "Tracer - Unstitched", "Fashion Designer", "Fashion Designer", "Fashion Designer", "Embroidery Puncher", "Graphic Designer", "IT Support", "Assistant Manager Godown", "Manager Digital Marketing", "Manager Marketing", "Senior Executive Inventory Control", "Embroidery Designer", "Supervisor Supply Chain & Warehouse", "Sketcher", "Textile Designer", "Textile Designer", "Image Retoucher", "Image Retoucher - Ecommerce", "Creative Marketing Assistant", "Embroidery Designer", "Image Retoucher", "Senior Officer Embroidery Sampling", "Fashion Designer", "Textile Designer", "Creative Group Head - Stitched", "Fashion Designer", "Team Lead - Unstitched A", "Merchandiser - Cosmetics & Perfumes", "Senior Executive Repair & Maintenance", "Category Head / Planner - UnStitched", "Embroidery Designer", "Supervisor Supply Chain & Warehouse", "Executive Taxation", "Fashion Designer", "Assistant Planner - UnStitched", "Sketcher", "Business Development Executive", "Manager - Allocation & Replenishment", "Planner & Buyer - Kids Eastern & Western", "Assistant Manager Accounts & Finance", "Embroidery Designer", "Fashion Designer", "Tracer - Unstitched", "Senior Textile Designer", "Sketcher", "Assistant Manager Accounts & Finance", "Senior Embroidery Designer", "Quality Checker", "Quality Checker", "Senior Executive Audit - Factory & Sourcing", "Worker Supply Chain & Warehouse", "Tracer - Unstitched", "HR Officer", "Embroidery Designer", "Officer Quality - Imports", "Deputy General Manager Manufacturing", "Quality Checker", "Supervisor Supply Chain & Warehouse", "Supervisor Supply Chain & Warehouse", "Talent Acquisition Specialist", "Officer Supply Chain & Warehouse", "Chief Commercial Officer", "Data Entry Officer - ERP", "Graphic Designer - Kids Western", "Textile Designer", "Quality Checker", "DGM Audit", "Assistant Worker Supply Chain & Warehouse", "Graphic Designer", "Textile Designer", "Graphic Designer", "Quality Checker", "Tracer - Unstitched", "Tracer - Unstitched", "E-Commerce Data Analyst", "Assistant Worker Supply Chain & Warehouse", "Tracer - Stitched", "Quality Checker", "Image Retoucher - Ecommerce", "Sr. Manager E-Commerce", "Quality Checker", "Senior Officer Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Supervisor Supply Chain & Warehouse", "Creative Group Head - Unstitched", "Textile Designer", "Embroidery Puncher", "Embroidery Puncher", "Embroidery Puncher", "Embroidery Puncher", "Officer Supply Chain & Warehouse", "Manager Supply Chain & Warehouse", "Senior Officer Supply Chain & Warehouse", "Photographer (E-Commerce)", "Sketcher", "Sketcher", "Executive Sourcing - Women Western Wear", "Senior Textile Designer", "Admin Executive", "Embroidery Puncher", "Assistant Manager E-Store Warehouse", "E-Commerce Shoots Support Staff", "Audit Officer - Warehouse", "Stock Assurance Officer", "Stock Assurance Officer", "Stock Assurance Officer", "Stock Assurance Officer", "Creative Group Head - Tunics & Solids", "Stock Assurance Officer", "Textile Designer", "Officer Replenishment - Stitched", "Assistant Worker Supply Chain & Warehouse", "Senior Worker Admin", "Creative Group Head – Kids Eastern & Western", "Art Director", "AM Visual Merchandising", "Assistant Worker Supply Chain & Warehouse", "Manager Creative Marketing", "Category Merchandiser – Unstitched", "ERP Officer", "Assistant Manager Purchase", "Quality Checker", "Senior Textile Designer", "ERP Coordinator", "IT Support", "Audit Officer", "Team Lead - Unstitched B", "Quality Checker", "Quality Checker", "Quality Checker", "Sr. Manager Men's Eastern Sourcing", "Deputy Manager Purchase", "Stock Assurance Officer", "Officer Supply Chain & Warehouse", "Assistant Manager Allocation & Replenishment - Home, Kids, Men, Shoes Bags, Cosmetics", "Executive Allocation & Replenishment - Stock Movement & STR", "DGM IT & ERP", "Photographer", "Assistant Worker Packing", "Assistant Worker Hard Tag Remover", "Assistant Worker Packing", "Assistant Worker Shoes/Bags/Home", "Officer Dispatch", "Digital Marketing Executive", "Stock Assurance Officer", "AM Analytics", "Manager Contact Center", "Sketcher", "Team Lead Punching", "Assistant Worker Bulk Dispatch & Receiving", "Team Lead Packing", "Assistant Worker Stitched", "Officer Dispatch", "Assistant Worker Stitched", "Assistant Worker Punching", "Assistant Worker Packing", "Assistant Worker Punching", "Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Worker Supply Chain & Warehouse", "Tracing Lead - Stitched", "Tracer - Stitched", "Deputy Manager Merchandising", "Officer Quality", "Tracer - Unstitched", "Management Trainee", "Officer Sourcing", "Tracing Lead - Unstitched", "Tracer - Stitched", "CC/Social Media Moderator", "CC/Social Media Moderator", "CC/Social Media Moderator", "Team Lead Customer Care", "CC/Social Media Moderator", "CC/Social Media Moderator", "CC/Social Media Moderator", "Creative Coordinator - E-Commerce", "Worker Supply Chain & Warehouse", "Tracer - Unstitched", "Senior Worker Home/Bag/Shoes", "Supervisor Stitched", "Inventory Controller", "Senior Textile Designer", "Sketcher", "Senior Textile Designer", "Quality Checker", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Brand Management Trainee", "Brand Management Trainee", "Senior Fashion Designer", "AM Visual Merchandise", "Team Lead - Zareen Project", "Designer- Women's Shoes", "CC/Social Media Moderator", "Designer- Men's Shoes", "Assistant Manager Visual Merchandise", "Image Retoucher", "Assistant Worker Bulk Dispatch & Receiving", "Senior Worker Un-Stitched", "Senior Worker Un-Stitched", "Supervisor Un-Stitched", "Senior Worker Stitched", "Officer Order Management", "Supervisor Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Driver", "Senior Architect", "Senior Textile Designer", "Senior Executive Sourcing", "Purchase Officer", "General Manager Design & Product Development", "IT Support", "CC/Social Media Moderator", "QA/Training & CX", "Tracer - Stitched", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Supervisor Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Supervisor Home Category", "Manager Sourcing", "Senior Officer E-Commerce Operations", "Image Retoucher - Ecommerce", "Software Engineer", "Tracer - Unstitched", "Team Lead Customer Care", "CC/Social Media Moderator", "Tracer - Unstitched", "Quality Checker", "Quality Checker", "Videographer", "Packer", "Packer", "Packer", "Packer", "Management Trainee Officer", "Tracer - Unstitched", "Godown Officer", "Management Trainee Officer - Men's Wear", "Deputy Manager E-Commerce", "General Manager Supply Chain & Warehouse", "General Manager Marketing", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Stitched", "Assistant Worker Unstitched", "Assistant Worker Packing", "Worker Supply Chain & Warehouse", "Area Sales Manager", "Area Sales Manager", "Assistant Area Sales Manager", "Graphic Designer", "Trainee CAD", "Creative Group Head - Stitched & Unstitched", "Executive E-Commerce", "Textile Designer", "CC/Social Media Moderator", "CC/Social Media Moderator", "Team Lead - Unstitched", "Tracer - Stitched", "Supervisor Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Graphic Designer", "Team Lead - Stitched", "Textile Designer", "Quality Checker", "Tracer - Zareen", "Tracer - Zareen", "Quality Checker", "Quality Checker", "Tracer - Stitched", "Graphic Designer", "Senior Textile Designer", "Sketcher", "Textile Designer", "Fashion Designer - Kids Western", "Assistant Planner - Women's Western", "Graphic Designer - Kids Western", "Embroidery Designer", "Fashion Designer - Kids Eastern", "Tracer - Stitched", "Quality Checker", "Tracer - Unstitched", "Officer Merchandising - Stitched", "Embroidery Puncher", "Tracer - Unstitched", "Assistant Worker Supply Chain & Warehouse", "Senior Executive IT Integration", "CAD Designer", "Senior Textile Designer - UnStitched", "Sketcher", "Senior Officer Digital Marketing", "Stock Assurance Officer", "Assistant Merchandise Planner", "Assistant Manager Supply Chain", "Tracer - Stitched", "Content Writer", "Textile Designer - Kid's", "Manager Quality", "Assistant Manager IT & ERP", "Category Head - Men's Western", "Rider", "Assistant Worker Supply Chain & Warehouse", "Assistant Worker Supply Chain & Warehouse", "Tracer - Stitched", "Tracer - Stitched", "IT Support - South", "Assistant Manager Kid's Sourcing", "Senior Executive Categories & Merchandising ", "Officer Categories & Merchandising - Unstitched"]
		job_titles.each do |single_item|
			JobTitle.create(:name => single_item, :is_active => true, :company_id => 1)
		end
	end

	# DataEntry.add_srl_grade
	def self.add_srl_grade
		grade_list = ["G-2", "G-3 A", "G-3 B", "G-4", "G-4 C", "G-5", "G-6", "G-7", "G-8", "G-9", "G-10", "G-11", "G-13", "G-12", "G-14", "G-15"]
		index = 0
		grade_list.each do |single_item|
			index = index + 1
			Grade.create(:name => single_item, :code => single_item, :is_active => true, :company_id => 1, :currency_title => "PKR - Pakistani Rupee", :sort_order => index)
		end
	end

	# DataEntry.srl_employee_import
	def self.srl_employee_import
		count = 0
		employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/active_employee_list1.csv")
		employee_data.each do |single_item|
			if single_item[:branch].titleize == "Karachi Office"
				branch = Branch.find_by_name("Head Office")
			elsif single_item[:branch].titleize == "Wtc"
				branch = Branch.find_by_name("WTC")
			else
				branch = Branch.find_by_name(single_item[:branch].titleize)
			end

			if single_item[:designation].titleize == "Asst. Worker"
				designation = Designation.find_by_name("Assistant Worker")
			else
				designation = Designation.find_by_name(single_item[:designation].titleize)	
			end
			location = Location.find_by_name(single_item[:location].titleize)
			department = Department.find_by_name(single_item[:department])
			sub_department = SubDepartment.find_by_name(single_item[:department])
			employee_type = EmployeeType.find_by_name(single_item[:employee_type].titleize)

			if single_item[:grade] == "G 4- C"
				grade = Grade.find_by_name("G-4 C")			
			else
				grade = Grade.find_by_name(single_item[:grade])			
			end

			company_id = 1
			grade_id = grade.id
			gender = single_item[:gender]
			salutation = single_item[:salutation]
			designation_id = designation.id
			department_id = department.id
			employee_type_id = employee_type.id
			cnic_number = single_item[:cnic]
			if single_item[:official_email].nil?
				official_email = ""
				create_login = false
				user_account_email = official_email
				user_account_password = "abcd@1234-#{single_item[:employee_code]}"
				role_id = nil
				is_admin = false
				custom_right = false
				is_company_head = false
				is_location_head = false
				is_branch_head = false
				is_department_head = false
			else
				official_email = single_item[:official_email].downcase
				user_account_email = official_email
				user_account_password = "abcd@1234-#{single_item[:employee_code]}"
				role_id = 2
				is_admin = false
				custom_right = false
				is_company_head = false
				is_location_head = false
				is_branch_head = false
				is_department_head = false
				create_login = true
			end

			date_of_birth = single_item[:dob].to_date
			joining_date = single_item[:doj].to_date
			if single_item[:doc].nil?
				confirmation_date = nil
				on_probation = true
			else
				confirmation_date = single_item[:doc].to_date	
				on_probation = false
			end

			gross_salary = single_item[:gross_salary]
			personal_number = single_item[:personal_number]
			blood_group = single_item[:blood_group]
			current_address = single_item[:present_address]
			permanent_address = single_item[:permanent_address]
			location_id = location.id
			branch_id = branch.id

			if single_item[:contract_start_date].nil?
				is_contractual = false
				contract_start_date = nil
				contract_end_date = nil
			else
				is_contractual = true
				contract_start_date = single_item[:contract_start_date].to_date
				contract_end_date = single_item[:contract_end_date].to_date
			end
			if single_item[:marital_status].nil?
				marital_status = ""
			else
				marital_status = single_item[:marital_status].titleize
			end

			puts "\n company_id => #{company_id} \n"
			puts "\n grade_id => #{grade_id} \n"
			puts "\n designation_id => #{designation_id} \n"
			puts "\n department_id => #{department_id} \n"
			puts "\n employee_type_id => #{employee_type_id} \n"
			puts "\n cnic_number => #{cnic_number} \n"
			puts "\n official_email => #{official_email} \n"
			puts "\n date_of_birth => #{date_of_birth} \n"
			puts "\n joining_date => #{joining_date} \n"
			puts "\n confirmation_date => #{confirmation_date} \n"
			puts "\n on_probation => #{on_probation} \n"
			puts "\n gross_salary => #{gross_salary} \n"
			puts "\n personal_number => #{personal_number} \n"
			puts "\n blood_group => #{blood_group} \n"
			puts "\n current_address => #{current_address} \n"
			puts "\n permanent_address => #{permanent_address} \n"
			puts "\n location => #{location} \n"
			puts "\n branch => #{branch} \n"
			# Employee.create(:gender => gender, :salutation => salutation, :employee_code => single_item[:employee_code], :first_name => single_item[:name].titleize, :company_id => company_id, :grade_id => grade_id, :designation_id => designation_id, :department_id => department_id, :employee_type_id => employee_type_id, :cnic_number => cnic_number, :official_email => official_email, :date_of_birth => date_of_birth, :joining_date => joining_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :gross_salary => gross_salary, :personal_number => personal_number, :blood_group => blood_group, :current_address => current_address, :permanent_address => permanent_address, :location_id => location_id, :branch_id => branch_id, :is_contractual => is_contractual, :contract_start_date => contract_start_date, :contract_end_date => contract_end_date, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :create_login => create_login, :martial_status => marital_status)
			count = count + 1
		end
	end
	
	def self.upload_srl_employee_extra_data
		employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/employee_extra_data.csv", :key_mapping => {:employee_code => :employee_code, :father_name => :father_name, :personal_mobile_number => :personal_mobile_number, :emergency_person_contact_number => :emergency_person_contact_number, :offical_mobile_number => :offical_mobile_number})
		employee_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code])
			if not employee.nil?
				if not single_item[:offical_mobile_number].nil?
					official_mobile_number = single_item[:offical_mobile_number].to_s.gsub('-', '')
					if official_mobile_number.length == 10
						official_mobile_number = "0#{official_mobile_number}"
					end
					official_mobile_number.insert(4, '-')
				else
					official_mobile_number = ""
				end

				if not single_item[:personal_mobile_number].nil?
					personal_number = single_item[:personal_mobile_number].to_s.gsub('-', '')
					if personal_number.length == 10
						personal_number = "0#{personal_number}"
					end
					personal_number.insert(4, '-')
				else
					personal_number = ""
				end
						
				employee.official_mobile_number = official_mobile_number
				employee.personal_number = personal_number
				employee.emergency_contact_phone = single_item[:emergency_person_contact_number]
				employee.father_name = single_item[:father_name]
				employee.save
			end
		end
	end

	def self.srl_line_manager_import
		employee_data = SmarterCSV.process("#{Rails.public_path}/line_manager_data_1546080665.csv")
		employee_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code])
			if not employee.nil?
				if single_item[:line_manager_employee_code] != "-"
					line_manager = Employee.find_by_employee_code(single_item[:line_manager_employee_code])
					employee.line_manager_id = line_manager.id
					employee.save
				end
			end
		end
	end

	def self.srl_employee_picture_import
		employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/employee_picture_data.csv")
		employee_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code])
			if not employee.nil?
				employee.avatar = URI.parse("#{single_item[:pic_url]}")
				employee.save
			end
		end
	end

	# DataEntry.auto_fetch_attendance_log
  def self.auto_fetch_attendance_log
  	fetch_start_date = (Time.now - 3.day).to_date
  	AttendanceDevice.all.order('id ASC').each do |attendance_device|
  		AttendanceMachineLog.fetch_attendance_machine_data(attendance_device, fetch_start_date)
  	end
  end

  # DataEntry.first_login_attemp
  def self.first_login_attemp
  	User.all.each do |user|
  		user.first_login = true
  		user.save
  	end
  end

  # DataEntry.design_studio_structure
  def self.design_studio_structure
  	AttendanceStructure.where(:location_id => 1).order('id ASC').each do |single_item|
			new_single_item = AttendanceStructure.new
			new_single_item.name = single_item.name.gsub("HO", "Design Studio")
			new_single_item.code = single_item.code.gsub("HO", "Design Studio")
			new_single_item.company_id = single_item.company_id
			new_single_item.is_active = single_item.is_active
			new_single_item.location_id = single_item.location_id
			new_single_item.branch_id = single_item.branch_id
			new_single_item.department_id = single_item.department_id
			new_single_item.grade_id = single_item.grade_id
			new_single_item.start_date = single_item.start_date
			new_single_item.end_date = single_item.end_date
			new_single_item.absent_policy_id = single_item.absent_policy_id
			new_single_item.attendance_overtime_id = single_item.attendance_overtime_id
			new_single_item.attendance_relaxation_id = single_item.attendance_relaxation_id
			new_single_item.early_left_id = single_item.early_left_id
			new_single_item.missing_punch_id = single_item.missing_punch_id
			new_single_item.description = single_item.description.gsub("HO", "Design Studio")
			new_single_item.department_ids = "7"
			new_single_item.special_rule = true
			new_single_item.is_flexi = true
			new_single_item.serve_minutes = 90
			new_single_item.save
		end

		AttendanceStructure.where(:department_ids => "7").order('id ASC').each do |single_item|
			single_item.early_left_id = 1
			single_item.missing_punch_id = 1
			single_item.total_working_minutes = 480
			single_item.save
		end

		AttendanceStructure.where(:department_ids => "7").order('id ASC').each do |single_item|
			single_item.addional_minutes = 120
			single_item.save
		end
  end

  def self.import_attendance
  	attendance_data = SmarterCSV.process("#{Rails.public_path}/srl_data/device_transaction_log1.csv")
    attendance_data.each_with_index do |attendance_detail,index|
      employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
      if not employee.nil?
      	company = employee.company
      	if not company.nil?
      		attendance_data = AttendanceMachineLog.new
		      attendance_data.employee_code 					= employee.employee_code
					attendance_data.machine_name 						= "Manual"
					attendance_data.attendance_datetime 		= attendance_detail[:attendance_date].to_datetime
					attendance_data.attendance_date 				= attendance_detail[:attendance_date].to_date
					attendance_data.actual_attendance_date 	= attendance_detail[:attendance_date]
					attendance_data.formatted_hour 					= attendance_detail[:attendance_date].to_datetime.hour
					attendance_data.formatted_minute 				= attendance_detail[:attendance_date].to_datetime.minute
					attendance_data.formatted_second 				= attendance_detail[:attendance_date].to_datetime.second
					attendance_data.log_id 									= "9999999999"
					attendance_data.employee_full_name 			= employee.full_name
					attendance_data.employee_id 						= employee.id
					attendance_data.company_id 							= employee.company_id
		    	attendance_data.save
      	end
      end
    end
  end

  # DataEntry.idl_attendance_data
  def self.idl_attendance_data
  	attendance_data_set = SmarterCSV.process("#{Rails.public_path}/idl_data/idl_attendance/idl_attendance8.csv")
		attendance_data_set.each_with_index do |attendance_detail,index|
			employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					attendance_data = AttendanceMachineLog.new
					attendance_data.employee_code = employee.employee_code
					attendance_data.machine_name = "Manual"
					attendance_data.attendance_datetime = attendance_detail[:actual_attendance_date11].to_datetime
					attendance_data.attendance_date = attendance_detail[:actual_attendance_date11].to_date
					attendance_data.actual_attendance_date = attendance_detail[:actual_attendance_date11]
					attendance_data.formatted_hour = attendance_detail[:actual_attendance_date11].to_datetime.hour
					attendance_data.formatted_minute = attendance_detail[:actual_attendance_date11].to_datetime.minute
					attendance_data.formatted_second = attendance_detail[:actual_attendance_date11].to_datetime.second
					attendance_data.log_id = "9999999999"
					attendance_data.employee_full_name = employee.full_name
					attendance_data.employee_id = employee.id
					attendance_data.company_id = employee.company_id
					attendance_data.save
					if attendance_detail[:actual_attendance_date12].present?
						attendance_data = AttendanceMachineLog.new
						attendance_data.employee_code = employee.employee_code
						attendance_data.machine_name = "Manual"
						attendance_data.attendance_datetime = attendance_detail[:actual_attendance_date12].to_datetime
						attendance_data.attendance_date = attendance_detail[:actual_attendance_date12].to_date
						attendance_data.actual_attendance_date = attendance_detail[:actual_attendance_date12]
						attendance_data.formatted_hour = attendance_detail[:actual_attendance_date12].to_datetime.hour
						attendance_data.formatted_minute = attendance_detail[:actual_attendance_date12].to_datetime.minute
						attendance_data.formatted_second = attendance_detail[:actual_attendance_date12].to_datetime.second
						attendance_data.log_id = "9999999999"
						attendance_data.employee_full_name = employee.full_name
						attendance_data.employee_id = employee.id
						attendance_data.company_id = employee.company_id
						attendance_data.save
					end
				end
			end
		end
  end

  # DataEntry.stml4_master_data
  def self.stml4_master_data
  	department_list = ["Administration", "Accounts", "Security", "Laboratory", "Air Condition", "Work Shop", "Electric", "Blow Room", "Drawing Simplex", "Roller Covering", "Ring", "Technical Staff", "Power Plant", "Comber", "Auto Cone", "Carding", "Packing", "Production", "Mixing"]

		department_list.each do |single_item|
			Department.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true)
		end

		Department.all.each do |department|
			SubDepartment.create(:name => department.name, :code => department.code, :is_active => true, :company_id => 1, :department_id => department.id)
		end

		job_title_list = ["Driver", "Sweeper", "Assistant Cotton Incharge", "Sr. Cotton Clerk", "Assistant Cotton Incharge", "Gate Incharge", "Mali", "Mali", "Time Keeper", "Record Incharge", "Fair Price Clerk", "Office Boy", "Courier", "Excise Clerk", "Erp Incharge", "Cook", "Sweeper", "Senior Manager Administration", "Sr. L & W Officer", "Driver", "Excise Officer", "Store Officer", "Imam Masjad", "Cook", "Driver", "Baildar", "Driver", "Sweeper", "Sweeper", "Sr.Cashir", "Assistant Accounts Manager", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Fire Man", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Security Incharge", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Assistant Laboratory Incharge", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Clerk", "High Volume Instrument Operator", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Uster Operator", "Wrapping Boy", "Wrapping Boy", "Uster Operator", "Wrapping Clerk", "Wrapping Boy", "Advance Fiber Instrument System Operator", "Wrapping Boy", "Wrapping Clerk", "Wrapping Boy", "Assistant Fitter", "Operator", "Pipe Fitter", "Head Fitter", "Fitter", "Forman", "Operator", "Helper", "Helper", "Helper", "Head Fitter", "Senior Fitter", "Fitter", "Electrician", "Assistant Forman", "Electrician", "Electrician", "Electrician", "Moter Winder", "Electrician", "Head Electrician", "Electrician", "Electrician", "Forman", "Electrician", "Electronic Supervisor", "Apprentice", "Helper", "Helper", "Apprentice", "Helper", "Helper", "Fitter", "Forman", "Senior Fitter", "Card Tenter", "Floor Cleaner", "Card Tenter", "Cotton Feeder", "Cotton Feeder", "Floor Cleaner", "Cotton Feeder", "Card Tenter", "Cotton Feeder", "Cotton Feeder", "Card Tenter", "Cotton Feeder", "Card Tenter", "Cotton Feeder", "Card Tenter", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Card Tenter", "Cotton Feeder", "Cotton Feeder", "Floor Cleaner", "Floor Cleaner", "Cotton Feeder", "Cotton Feeder", "Floor Cleaner", "Floor Cleaner", "Card Tenter", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Fitter", "Assistant Forman", "Fitter", "Head Fitter", "Senior Fitter", "Fitter", "Forman", "Assistant Forman", "Fitter", "Fitter", "Doffer", "Double Drawing Tenter", "Double Simplex Tenter", "Doffer", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Double Simplex Tenter", "Doffer", "Double Simplex Tenter", "Double Drawing Tenter", "Doffer", "Doffer", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Double Drawing Tenter", "Doffer", "Double Simplex Tenter", "Double Simplex Tenter", "Doffer", "Bobbin Boy", "Bobbin Boy", "Bobbin Boy", "Double Simplex Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Doffer", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Double Simplex Tenter", "Double Simplex Tenter", "Doffer", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Doffer", "Bobbin Boy", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Bobbin Boy", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Doffer", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Bobbin Boy", "Double Simplex Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Doffer", "Doffer", "Double Drawing Tenter", "Double Simplex Tenter", "Doffer", "Doffer", "Double Drawing Tenter", "Double Simplex Tenter", "Doffer", "Forman", "Fitter", "Head Fitter", "Assistant Fitter", "Helper", "Fitter", "Assistant Forman", "Assistant Fitter", "Head Fitter", "Fitter", "Assistant Forman", "Fitter", "Head Fitter", "Fitter", "Fitter", "Assistant Fitter", "Forman", "Assistant Forman", "Fitter", "Assistant Fitter", "Head Fitter", "Fitter", "Assistant Fitter", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Machine Cleaner", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Doffer", "Machine Cleaner", "4/Sider", "Doffer", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Machine Cleaner", "4/Sider", "4/Sider", "4/Sider", "Machine Cleaner", "4/Sider", "4/Sider", "4/Sider", "Machine Cleaner", "Helper", "4/Sider", "Doffer", "Doffer", "Floor Cleaner", "Machine Cleaner", "Doffer", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Doffer", "Machine Cleaner", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Helper", "4/Sider", "4/Sider", "Machine Cleaner", "Doffer", "Trolley Man", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "Trolley Man", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Floor Cleaner", "Floor Cleaner", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Doffer", "Doffer", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Helper", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Doffer", "Doffer", "Doffer", "Doffer", "4/Sider", "Doffer", "4/Sider", "Doffer", "4/Sider", "Floor Cleaner", "4/Sider", "Helper", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Oil Man", "4/Sider", "Doffer", "Doffer", "Doffer", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Helper", "Machine Cleaner", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Machine Cleaner", "Helper", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Floor Cleaner", "Helper", "Doffer", "4/Sider", "Floor Cleaner", "Doffer", "4/Sider", "Machine Cleaner", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "Doffer", "Floor Cleaner", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Doffer", "Doffer", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "Trolley Man", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Machine Cleaner", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Floor Cleaner", "4/Sider", "4/Sider", "Doffer", "Trolley Man", "4/Sider", "4/Sider", "Floor Cleaner", "4/Sider", "Floor Cleaner", "Doffer", "4/Sider", "4/Sider", "Floor Cleaner", "Doffer", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Trolley Man", "4/Sider", "Floor Cleaner", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Floor Cleaner", "Trolley Man", "4/Sider", "4/Sider", "Trolley Man", "Doffer", "Doffer", "4/Sider", "4/Sider", "Doffer", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Doffer", "4/Sider", "Doffer", "4/Sider", "Machine Cleaner", "4/Sider", "Doffer", "4/Sider", "4/Sider", "Floor Cleaner", "Floor Cleaner", "4/Sider", "4/Sider", "Trolley Man", "Doffer", "4/Sider", "Doffer", "Floor Cleaner", "4/Sider", "Trolley Man", "Trolley Man", "Doffer", "Trolley Man", "Floor Cleaner", "Doffer", "Sr.Supervisor", "Sr.Supervisor", "Assistant Spining Master", "Sr.Supervisor", "Assistant Spining Master", "Sr.Supervisor", "Senior Technical Manager", "Assistant Spining Master", "Assistant Spining Master", "Supervisor", "Sr.Supervisor", "Sr.Supervisor", "Senior Assistant Spinning Master", "Executive Director", "Deputy General Manager", "Sr.Deputy Spining Master", "Quality Officer", "Sr.Supervisor", "Assistant Spining Master", "Electrical Supervisor", "Shift Incharge", "Engine Operator", "Shift Incharge", "Operator", "Operator", "General Manager", "Assistant Manager", "Shift Engineer", "Shift Engineer", "Helper", "Helper", "Helper", "Helper", "Head Fitter", "Forman", "Assistant Fitter", "Comber Tenter", "Comber Tenter", "Lap Former Tentor", "Lap Former Tentor", "Comber Tenter", "Lap Former Tentor", "Comber Tenter", "Lap Former Tentor", "Fitter", "Assistant Fitter", "Fitter", "Head Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Assistant Forman", "Senior Fitter", "Fitter", "Fitter", "Head Fitter", "Senior Fitter", "Senior Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Cone Cooly", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Floor Cleaner", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Cone Cooly", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Floor Cleaner", "Floor Cleaner", "Operator Auto Cone", "Cone Cooly", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Floor Cleaner", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Cone Cooly", "Bobbin Carrier", "Cone Cooly", "Floor Cleaner", "Cone Cooly", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Cone Cooly", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Cone Cooly", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Cone Cooly", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Floor Cleaner", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Cone Cooly", "Operator Auto Cone", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Operator Auto Cone", "Bobbin Carrier", "Bobbin Carrier", "Bobbin Carrier", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Head Fitter", "Fitter", "Assistant Fitter", "Assistant Fitter", "Senior Fitter", "Forman", "Assistant Forman", "Assistant Fitter", "Senior Fitter", "Assistant Forman", "Fitter", "Fitter", "Packing Assistant", "Packing Assistant", "Packing Incharge", "Winder", "Xorella Machine Operator", "Xorella Machine Operator", "Xorella Machine Operator", "Lycra Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Lycra Helper", "Assistant Jobber", "Production Incharge", "Jobber", "Supervisor", "Assistant Jobber", "Cone Checker", "Lycra Checker", "Assistant Jobber", "Cone Checker", "Jobber", "Jobber", "Assistant Jobber", "Supervisor", "Lycra Checker", "Assistant Jobber", "Supervisor", "Assistant Jobber", "Assistant Jobber", "Jobber", "Jobber", "Lycra Boy", "Supervisor", "Jobber", "Jobber", "Cone Checker", "Jobber", "Lycra Boy", "Jobber", "Mixing Incharge", "Assistant Mixing Incharge", "Mixing Operator", "Mixing Operator", "Helper", "Mixing Operator", "Helper", "Helper", "Mixing Operator", "Helper", "Helper", "Mixing Operator", "Helper", "Mixing Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper"]

		job_title_list = job_title_list.uniq

		job_title_list.each do |single_item|
			JobTitle.create(:company_id => 1, :name => single_item, :description => single_item, :is_active => true)
		end

		grade_list = ["3", "1", "4", "3A", "4", "4C", "2", "2", "3A", "4C", "3", "2", "3", "3", "4C", "3", "1", "12", "8", "3", "7", "7", "A", "3", "3", "1", "3", "1", "1", "4C", "9", "2", "2", "2", "2", "2", "2", "3", "2", "2", "2", "2", "2", "2", "2", "2", "4C", "2", "2", "2", "2", "2", "2", "2", "2", "4", "2", "2", "2", "2", "2", "2", "3", "3A", "2", "2", "2", "3A", "2", "2", "3A", "3", "2", "3A", "2", "3", "2", "3", "3", "3A", "4C", "3A", "7", "3", "1", "1", "1", "4C", "4", "3A", "3A", "5", "3A", "3A", "3A", "3A", "3A", "4C", "3A", "3A", "7", "3A", "4B", "1", "1", "1", "1", "1", "1", "3A", "7", "4", "3", "1", "3", "2", "2", "1", "2", "3", "2", "2", "3", "2", "3", "2", "3", "2", "2", "2", "3", "2", "2", "1", "1", "2", "2", "1", "1", "3", "2", "2", "2", "3A", "5", "3A", "4C", "4", "3A", "7", "5", "3A", "3A", "2", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3", "2", "3", "2", "3", "3", "2", "2", "3", "3", "2", "3", "2", "3", "3", "2", "1", "1", "1", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "2", "3", "3", "2", "3", "3", "2", "2", "1", "3", "3", "3", "3", "1", "3", "3", "3", "3", "3", "3", "2", "2", "3", "3", "3", "1", "3", "3", "3", "3", "3", "2", "2", "3", "3", "2", "2", "3", "3", "2", "7", "3A", "4C", "3", "1", "3A", "5", "3", "4C", "3A", "5", "3A", "4C", "3A", "3A", "3", "7", "5", "3A", "3", "4C", "3A", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3", "3", "3", "3", "2", "3", "2", "2", "2", "2", "2", "2", "3", "2", "3", "2", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3", "2", "1", "3", "2", "2", "1", "2", "2", "3", "3", "2", "3", "3", "2", "2", "3", "3", "3", "3", "1", "3", "3", "2", "2", "1", "3", "3", "2", "3", "3", "3", "3", "2", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "2", "1", "3", "2", "3", "3", "1", "1", "3", "3", "3", "2", "3", "2", "3", "3", "2", "2", "3", "2", "3", "3", "1", "3", "3", "3", "3", "3", "2", "3", "3", "2", "2", "2", "2", "3", "2", "3", "2", "3", "1", "3", "1", "3", "3", "2", "3", "3", "1", "3", "2", "2", "2", "3", "2", "3", "3", "3", "1", "2", "3", "3", "2", "3", "3", "3", "2", "3", "3", "2", "1", "3", "3", "3", "3", "3", "1", "1", "2", "3", "1", "2", "3", "2", "3", "3", "3", "3", "2", "3", "3", "3", "3", "2", "3", "2", "1", "2", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3", "3", "2", "3", "3", "3", "2", "2", "3", "3", "3", "2", "3", "1", "2", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "1", "3", "3", "2", "1", "3", "3", "1", "3", "1", "2", "3", "3", "1", "2", "3", "2", "3", "3", "3", "3", "3", "3", "1", "3", "1", "3", "3", "3", "3", "3", "3", "1", "1", "3", "3", "1", "2", "2", "3", "3", "2", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "2", "3", "2", "3", "2", "3", "2", "3", "3", "1", "1", "3", "3", "1", "2", "3", "2", "1", "3", "1", "1", "2", "1", "1", "2", "4C", "4C", "8", "4C", "8", "4C", "11", "8", "8", "4C", "4C", "4C", "8", "15", "13", "9", "7", "4C", "8", "4B", "4C", "3A", "4C", "3", "3", "14", "9", "7", "7", "1", "1", "1", "1", "4C", "7", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3A", "3", "3A", "4C", "3A", "3A", "3A", "3A", "5", "4", "3A", "3A", "4C", "4", "4", "3A", "3A", "3A", "3A", "3A", "1", "3", "3", "3", "3", "3", "3", "1", "3", "3", "3", "3", "3", "1", "3", "1", "3", "1", "3", "3", "3", "1", "3", "3", "1", "3", "1", "3", "1", "3", "1", "1", "3", "3", "1", "3", "3", "1", "1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "1", "3", "3", "3", "1", "3", "3", "1", "3", "3", "3", "1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "1", "3", "3", "3", "3", "3", "3", "3", "3", "1", "3", "1", "1", "3", "1", "1", "3", "3", "1", "1", "3", "3", "3", "1", "1", "1", "1", "1", "3", "1", "3", "1", "1", "1", "1", "1", "3", "3", "1", "1", "1", "1", "1", "1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "1", "1", "3", "3", "1", "3", "1", "3", "3", "1", "3", "3", "1", "3", "1", "1", "1", "3", "3", "1", "1", "1", "1", "1", "1", "3", "1", "3", "3", "1", "1", "3", "1", "1", "1", "3", "3", "3", "4C", "3A", "3", "3", "4", "7", "5", "3", "4", "5", "3A", "3A", "4", "4", "5", "3", "3", "3", "3", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "3", "7", "3A", "4B", "3", "3", "3", "3", "3", "3A", "3A", "3", "4B", "3", "3", "4B", "3", "3", "3A", "3A", "2", "4B", "3A", "3A", "3", "3A", "2", "3A", "4C", "4", "3", "3", "1", "3", "1", "1", "3", "1", "1", "3", "1", "3", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"]

		grade_list = grade_list.uniq

		grade_list.each do |single_item|
			Grade.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true)
		end

		grade = Grade.find_by_name("G-1")
		designation_list = ["Deputy Manager", "Manager", "Operator", "Supervisor", "Textile Engineer", "Auditor", "Sr. Operator", "Operator", "Operator", "Asst. Supervisor", "Auditor", "Incharge", "Floor Cleaner", "Asst. Electrician", "Asst. Manager", "Asst. Operator", "Supervisor", "Supervisor", "Clerk", "Asst. Operator", "Incharge", "Measurement Checker", "Trimmer", "Asst. Operator", "Loop Cutter", "Clerk", "Asst. Supervisor", "Packer", "Incharge", "Sr. HR Assistant", "Incharge", "Engineer", "Stain Remover", "Darner", "Asst. Operator", "Asst. Clerk", "Supervisor", "Quality Checker", "Operator", "Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Operator", "Asst. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Quality Checker", "Darner", "Supervisor", "Carton Maker", "Operator", "Packer", "Auditor", "Operator", "Operator", "Incharge", "Supervisor", "Section Head", "Incharge", "Sr. Supervisor", "Trimmer", "Packer", "Operator", "Mender", "Electrician", "Sr. Operator", "Sr. Operator", "Asst. Supervisor", "Operator", "Operator", "Operator", "Auditor", "Incharge", "Foreman", "Operator", "Operator", "Operator", "Associate", "Auditor", "Operator", "Associate", "Operator", "Asst. Operator", "Supervisor", "Auditor", "Auditor", "Auditor", "Asst. Manager", "Incharge", "Auditor", "Operator", "Auditor", "Operator", "Trainee Pattern Master", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Supervisor", "Asst. Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Operator", "Asst. Operator", "Supervisor", "Operator", "Operator", "Associate", "Operator", "Supervisor", "Auditor", "Operator", "Asst. Operator", "Operator", "Auditor", "Technician", "Auditor", "Asst. Operator", "Operator", "Asst. Operator", "Watchman", "Watchman", "Asst. Operator", "Asst. Operator", "Associate", "Auditor", "Operator", "Asst. Operator", "Asst. Supervisor", "Asst. Manager", "Associate", "Associate", "Helper", "Asst. Technician", "Asst. Manager", "Asst. Operator", "Coordinator", "Auditor", "Operator", "Operator", "Associate", "Asst. Operator", "Associate", "Fitter", "Sr. Electrician", "Associate", "Quality Checker", "Fitter", "Supervisor", "Operator", "Operator", "Coordinator", "Auditor", "Technician", "Operator", "Operator", "Supervisor", "Numbering Man", "Operator", "Operator", "Operator", "Operator", "Auditor", "Incharge", "Operator", "Technician", "Operator", "Asst. Operator", "Operator", "Asst. Operator", "Auditor", "Trimmer", "Operator", "Operator", "Associate", "Asst. Operator", "Darner", "Associate", "Associate", "Associate", "Operator", "Operator", "Packer", "Helper", "Associate", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Supervisor", "Sr. Operator", "Operator", "Associate", "Operator", "Associate", "Associate", "Asst. Operator", "Supervisor", "Packer", "Asst. Operator", "Operator", "Operator", "Associate", "Operator", "Associate", "Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Pattern Master", "Operator", "Operator", "Operator", "Operator", "Supervisor", "Section Head", "Card Man", "Asst. Operator", "Fitter", "Asst. Operator", "Operator", "Sr. Operator", "Trimmer", "Associate", "Associate", "Packer", "Measurement Checker", "Technician", "Presser", "Technical Officer", "Quality Checker", "Measurement Checker", "Alter Man", "Asst. Operator", "Asst. Operator", "Operator", "Computer Operator", "Operator", "Associate", "Auditor", "Auditor", "Quality Checker", "Associate", "Operator", "Operator", "Operator", "Operator", "Associate", "Associate", "Asst. Operator", "Quality Checker", "Clerk", "Associate", "Operator", "Operator", "Measurement Checker", "Associate", "Final Checker", "Asst. Operator", "Asst. Operator", "Clerk", "Asst. Operator", "Operator", "Asst. Operator", "Associate", "Operator", "Asst. Operator", "Associate", "Operator", "Asst. Operator", "Operator", "Asst. Manager", "Associate", "Final Checker", "Asst. Operator", "Associate", "Numbering Man", "Asst. Operator", "Auditor", "Auditor", "Operator", "Asst. Officer", "Auditor", "Technical Officer", "Card Man", "Clerk", "Associate", "Associate", "Touching Man", "Mender", "Mender", "Asst. Operator", "Asst. Operator", "Associate", "Associate", "Asst. Operator", "Auditor", "Darner", "Associate", "Measurement Checker", "Final Checker", "Mender", "Final Checker", "Mender", "Trimmer", "Associate", "Packer", "Supervisor", "Auditor", "Auditor", "Stain Remover", "Packer", "Associate", "Measurement Checker", "Asst. Operator", "Asst. Operator", "Auditor", "Officer", "Asst. Operator", "Final Checker", "Packer", "Measurement Checker", "Operator", "Supervisor", "Final Checker", "Asst. Operator", "Asst. Operator", "Auditor", "Clerk", "Associate", "Asst. Operator", "Operator", "Asst. Operator", "Asst. Operator", "Darner", "Measurement Checker", "Presser", "Touching Man", "Associate", "Supervisor", "Trimmer", "Incharge", "Incharge", "Supervisor", "Mender", "Mender", "Operator", "Trimmer", "Associate", "Measurement Checker", "Packer", "Operator", "Operator", "Packer", "Associate", "Associate", "Operator", "Sr. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Mender", "Associate", "Asst. Operator", "Operator", "Operator", "Auditor", "Manager", "Trimmer", "Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Asst. Manager", "Mender", "Operator", "Operator", "Packer", "Asst. Operator", "Packer", "Carton Maker", "Asst. Operator", "Asst. Operator", "Carton Maker", "Operator", "Associate", "Operator", "Trainee Operator", "Incharge", "Operator", "Operator", "Quality Checker", "Asst. Operator", "Marker Maker", "Operator", "Associate", "Packer", "Operator", "Final Checker", "Operator", "Cashier", "Asst. Operator", "Associate", "Asst. Operator", "Associate", "Associate", "Associate", "Asst. Operator", "Technical Officer", "Associate", "Quality Checker", "Operator", "Measurement Checker", "Final Checker", "Packer", "Marker Maker", "Operator", "HR Assistant", "Asst. Operator", "Associate", "Quality Checker", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Associate", "Operator", "Sr. Operator", "Operator", "Clerk", "Associate", "Clerk", "Head", "Associate", "Associate", "Operator", "Associate", "Operator", "Associate", "Associate", "Supervisor", "Quality Checker", "Operator", "Associate", "Store Assistant", "Associate", "Associate", "Associate", "Associate", "Operator", "Operator", "Incharge", "Technician", "Packer", "Operator", "Associate", "Associate", "Asst. Operator", "Touching Man", "Operator", "Associate", "Operator", "Operator", "Associate", "Helper", "Associate", "Operator", "Supervisor", "Operator", "Asst. Operator", "Associate", "Packer", "Supervisor", "Packer", "Associate", "Operator", "Trimmer", "Trimmer", "Packer", "Associate", "Associate", "Associate", "Operator", "Packer", "Trimmer", "Associate", "Quality Checker", "Quality Checker", "Operator", "Associate", "Electrician", "Operator", "Auditor", "Operator", "Helper", "Associate", "Associate", "MTO", "MTO", "Quality Checker", "Operator", "Associate", "Associate", "Operator", "Operator", "Associate", "Operator", "Final Checker", "Incharge", "Incharge", "Manager", "Sr. Asst. Manager", "Asst. Manager", "Final Checker", "Final Checker", "Operator", "Operator", "Shade Master", "Associate", "Associate", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Trim Card Operator", "Asst. Officer", "Operator", "Operator", "Helper", "Associate", "Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Incharge", "Operator", "Operator", "Helper", "Operator", "Operator", "Operator", "Incharge", "Operator", "Operator", "Operator", "Operator", "Associate", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Associate", "MTO", "Head", "Supervisor", "Operator", "Officer", "Technician", "Computer Operator", "Associate", "Final Checker", "Asst. Supervisor", "Operator", "Associate", "Associate", "Associate", "Associate", "Associate", "Asst. Operator", "Operator", "Supervisor", "Associate", "Associate", "Incharge", "Packer", "Associate", "Associate", "Operator", "Operator", "Operator", "Operator", "Asst. Supervisor", "Operator", "Incharge", "Associate", "Associate", "Operator", "Associate", "Associate", "Operator", "Operator", "Touching Man", "Associate", "Associate", "Associate", "Associate", "Operator", "Operator", "Operator", "Operator", "Operator", "Sr. Operator", "Associate", "Clerk", "Operator", "Sr. Operator", "Associate", "Operator", "Sr. Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Section Head", "Associate", "Operator", "Supervisor", "Auditor", "Asst. Operator", "Operator", "Sr. Supervisor", "Operator", "Associate", "Associate", "Officer", "Asst. Operator", "Quality Checker", "Quality Checker", "Quality Checker", "Auditor", "Quality Checker", "Auditor", "MTO", "Incharge", "Section Head", "Section Head", "Associate", "Clerk", "Sr. Operator", "Operator", "Clerk", "Associate", "Operator", "Associate", "Operator", "Incharge", "Associate", "Incharge", "Incharge", "Incharge", "Section Head", "Associate", "Operator", "Operator", "Final Checker", "Final Checker", "Final Checker", "Supervisor", "Associate", "Asst. Operator", "Associate", "Operator", "Operator", "Supervisor", "Associate", "Supervisor", "Associate", "Associate", "Quality Checker", "Final Checker", "Asst. Supervisor", "Supervisor", "Operator", "Operator", "Operator", "Incharge", "Auditor", "Auditor", "Auditor", "Auditor", "Associate", "Associate", "Incharge", "Incharge", "Operator", "Auditor", "Quality Checker", "Technician", "Associate", "Quality Checker", "Auditor", "Computer Operator", "Clerk", "Supervisor", "Associate", "Quality Checker", "Loop Cutter", "Mender", "Mender", "Incharge", "Operator", "Operator", "Operator", "Computer Operator", "Final Checker", "Deputy Manager", "Auditor", "Auditor", "Associate", "Trimmer", "Trimmer", "Trimmer", "Quality Checker", "Asst. Operator", "Cutter Man", "Asst. Operator", "Computer Operator", "Associate", "Helper", "Helper", "Helper", "Helper", "Clerk", "Associate", "Associate", "Asst. Operator", "Associate", "Associate", "Associate", "Operator", "Associate", "Associate", "Sr. Operator", "Operator", "Floor Cleaner", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Officer", "Cutter Man", "Auditor", "Section Head", "Section Head", "Supervisor", "Associate", "Operator", "Associate", "Operator", "Associate", "Operator", "Supervisor", "Shade Checker", "Operator", "Auditor", "Auditor", "Associate", "Operator", "Associate", "Associate", "Associate", "Associate", "MTO", "Auditor", "Operator", "Associate", "Clerk", "Final Checker", "Asst. Operator", "Associate", "Trimmer", "Touching Man", "Final Checker", "Trimmer", "Clerk", "Clerk", "Clerk", "Clerk", "Associate", "Packer", "Computer Operator", "Supervisor", "Manager", "Technician", "Associate", "Clerk", "Associate", "Clerk", "Associate", "Sr. Supervisor", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Associate", "Associate", "Operator", "Operator", "Operator", "Asst. Manager", "Operator", "Floor Cleaner", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Auditor", "Auditor", "Associate", "Associate", "Associate", "Asst. Operator", "Shade Checker", "MTO", "Associate", "Sr. Operator", "Asst. Manager", "Final Checker", "Packer", "Operator", "Floor Cleaner", "Floor Cleaner", "Supervisor", "Pattern Maker", "Sr. Asst. Manager", "Associate", "Associate", "Section Head", "Operator", "Associate", "Asst. Operator", "Supervisor", "Operator", "Asst. Operator", "Operator", "Operator", "Auditor", "Auditor", "Supervisor", "Cutter Man", "Floor Cleaner", "Associate", "Sr. Supervisor", "Asst. Supervisor", "Operator", "Operator", "Associate", "Operator", "Operator", "Auditor", "Auditor", "Sr. Operator", "Operator", "Operator", "Operator", "Incharge", "Supervisor", "Supervisor", "Supervisor", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Supervisor", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Incharge", "Press Man", "Trimmer", "Incharge", "Mender", "Mender", "Supervisor", "Foreman", "Foreman", "Sr. Asst. Manager", "Technician", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Sr. Asst. Manager", "Asst. Manager", "Operator", "Operator", "Operator", "Supervisor", "Operator", "Asst. Manager", "Operator", "Floor Cleaner", "Asst. Manager", "Deputy Manager", "Auditor", "Supervisor", "Supervisor", "Supervisor", "Asst. Manager", "Operator", "Operator", "Associate", "Computer Operator", "Cutter Man", "Operator", "Sr. Manager", "Operator", "Final Checker", "Operator", "Operator", "Training Instrucitor", "Incharge", "Watchman", "Final Checker", "Auditor", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Incharge", "Operator", "Asst. Operator", "Sr. Officer", "Helper", "Helper", "Operator", "Associate", "Operator", "Operator", "Trimmer", "Asst. Manager", "Operator", "Loop Cutter", "Final Checker", "Sr. Asst. Manager", "Trimmer", "Asst. Operator", "Packer", "Operator", "Supervisor", "Pattern Maker", "Operator", "Technician", "Supervisor", "Supervisor", "Supervisor", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Associate", "Associate", "Associate", "Operator", "Operator", "Operator", "Operator", "Auditor", "Supervisor", "Coordinator", "Asst. Operator", "Asst. Manager", "Technician", "Helper", "Operator", "Associate", "Helper", "Associate", "Associate", "Operator", "Associate", "Associate", "Operator", "Operator", "Operator", "Asst. Manager", "Supervisor", "Asst. Manager", "Incharge", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Helper", "Associate", "Operator", "Operator", "Trimmer", "Trimmer", "Trimmer", "Measurement Checker", "Measurement Checker", "Measurement Checker", "Final Checker", "Final Checker", "Packer", "Packer", "Packer", "Packer", "Packer", "Packer", "Packer", "Carton Maker", "Packer", "Packer", "Supervisor", "Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Supervisor", "Asst. Operator", "Asst. Operator", "Auditor", "Auditor", "Associate", "Operator", "Packer", "Associate", "Card Man", "Packer", "Operator", "Operator", "Associate", "Packer", "Packer", "Packer", "Associate", "Trimmer", "Associate", "Associate", "Touching Man", "Operator", "Trimmer", "Mender", "Measurement Checker", "Associate", "Associate", "Associate", "Operator", "Auditor", "Auditor", "Quality Checker", "Supervisor", "Associate", "Asst. Operator", "Associate", "Operator", "Associate", "Associate", "Associate", "Associate", "Associate", "Mender", "Quality Checker", "Cutter Man", "Mender", "Welder", "Auditor", "Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Loop Cutter", "Supervisor", "Floor Cleaner", "Associate", "Final Checker", "Touching Man", "Trimmer", "Asst. Operator", "Watchman", "Operator", "Operator", "Operator", "Sr. Operator", "Sr. Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Associate", "Associate", "Asst. Operator", "Asst. Operator", "Incharge", "Operator", "Operator", "Operator", "Operator", "Operator", "Supervisor", "Fitter", "Section Head"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-2")
		designation_list = ["Mali", "Mali", "Office Boy", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Wrapping Boy", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Cotton Feeder", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Doffer", "Machine Cleaner", "Machine Cleaner", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Machine Cleaner", "Doffer", "Doffer", "Doffer", "Doffer", "Doffer", "Lycra Boy", "Lycra Boy"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-3")
		designation_list = ["Driver", "Fair Price Clerk", "Courier", "Excise Clerk", "Cook", "Driver", "Cook", "Driver", "Driver", "Fire Man", "Wrapping Clerk", "Wrapping Clerk", "Wrapping Clerk", "Assistant Fitter", "Operator", "Operator", "Card Tenter", "Card Tenter", "Card Tenter", "Card Tenter", "Card Tenter", "Card Tenter", "Card Tenter", "Card Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Double Drawing Tenter", "Double Simplex Tenter", "Assistant Fitter", "Assistant Fitter", "Assistant Fitter", "Assistant Fitter", "Assistant Fitter", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "4/Sider", "Operator", "Operator", "Assistant Fitter", "Comber Tenter", "Comber Tenter", "Lap Former Tentor", "Lap Former Tentor", "Comber Tenter", "Lap Former Tentor", "Comber Tenter", "Lap Former Tentor", "Assistant Fitter", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Operator Auto Cone", "Assistant Fitter", "Assistant Fitter", "Assistant Fitter", "Winder", "Xorella Machine Operator", "Xorella Machine Operator", "Xorella Machine Operator", "Assistant Jobber", "Assistant Jobber", "Cone Checker", "Lycra Checker", "Assistant Jobber", "Cone Checker", "Assistant Jobber", "Lycra Checker", "Assistant Jobber", "Assistant Jobber", "Assistant Jobber", "Cone Checker", "Mixing Operator", "Mixing Operator", "Mixing Operator", "Mixing Operator", "Mixing Operator", "Mixing Operator"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-4")
		designation_list = ["Assistant Cotton Incharge", "Assistant Cotton Incharge", "Assistant Laboratory Incharge", "Senior Fitter", "Senior Fitter", "Senior Fitter", "Senior Fitter", "Senior Fitter", "Senior Fitter", "Senior Fitter", "Senior Fitter", "Packing Assistant", "Packing Assistant", "Assistant Mixing Incharge"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-5")
		designation_list = ["Assistant Forman", "Assistant Forman", "Assistant Forman", "Assistant Forman", "Assistant Forman", "Assistant Forman", "Assistant Forman", "Assistant Forman", "Assistant Forman", "Packing Incharge"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-7")
		designation_list = ["Excise Officer", "Store Officer", "Forman", "Forman", "Forman", "Forman", "Forman", "Forman", "Quality Officer", "Shift Engineer", "Shift Engineer", "Forman", "Forman", "Production Incharge"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-8")
		designation_list = ["Sr. L & W Officer", "Assistant Spining Master", "Assistant Spining Master", "Assistant Spining Master", "Assistant Spining Master", "Senior Assistant Spinning Master", "Assistant Spining Master"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-9")
		designation_list = ["Assistant Accounts Manager", "Sr.Deputy Spining Master", "Assistant Manager"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-11")
		designation_list = ["Senior Technical Manager"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-12")
		designation_list = ["Senior Manager Administration"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-13")
		designation_list = ["Deputy General Manager"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-14")
		designation_list = ["General Manager"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-15")
		designation_list = ["Executive Director"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-3A")
		designation_list = ["Sr. Cotton Clerk", "Time Keeper", "High Volume Instrument Operator", "Uster Operator", "Uster Operator", "Advance Fiber Instrument System Operator", "Pipe Fitter", "Fitter", "Fitter", "Electrician", "Electrician", "Electrician", "Electrician", "Moter Winder", "Electrician", "Electrician", "Electrician", "Electrician", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Engine Operator", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Fitter", "Jobber", "Jobber", "Jobber", "Jobber", "Jobber", "Jobber", "Jobber", "Jobber", "Jobber"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-A")
		designation_list = ["Imam Masjad"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-4C")
		designation_list = ["Gate Incharge", "Record Incharge", "Erp Incharge", "Sr.Cashir", "Security Incharge", "Head Fitter", "Head Fitter", "Head Electrician", "Head Fitter", "Head Fitter", "Head Fitter", "Head Fitter", "Head Fitter", "Sr.Supervisor", "Sr.Supervisor", "Sr.Supervisor", "Sr.Supervisor", "Supervisor", "Sr.Supervisor", "Sr.Supervisor", "Sr.Supervisor", "Shift Incharge", "Shift Incharge", "Head Fitter", "Head Fitter", "Head Fitter", "Head Fitter", "Mixing Incharge"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end

		grade = Grade.find_by_name("G-4B")
		designation_list = ["Electronic Supervisor", "Electrical Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor"]

		designation_list = designation_list.uniq

		designation_list.each do |single_item|
			Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
		end
  end

  # DataEntry.stml4_employee_data
  def self.stml4_employee_data
  	employee_data = SmarterCSV.process("#{Rails.public_path}/stml4_data/stml4_emp_data.csv")
		count = 0
		employee_data.each do |single_item|

			grade_name = "G-#{single_item[:grade_name]}"
			grade = Grade.find_by_name(grade_name)
			job_title = JobTitle.find_by_name(single_item[:job_title_name])

			if single_item[:designation_name] != "`"
				designation = Designation.find_by(:name => single_item[:designation_name], :grade_id => grade.id)
				designation_id = designation.id
			else
				designation_id = nil
			end
			department = Department.find_by_name(single_item[:sub_department_name])
			sub_department = SubDepartment.find_by_name(single_item[:sub_department_name])
			if single_item[:employee_type_name].present?
				employee_type = EmployeeType.find_by_name(single_item[:employee_type_name])
				employee_type_id = employee_type.id
			else
				employee_type_id = nil
			end

			religion = Religion.find_by_name(single_item[:religion_name])

			branch_id = 3
			location_id = 2
			company_id = 1
			salary_unit_id = 2
			cost_center_id = 2
			grade_id = grade.id
			job_title_id = job_title.id
			department_id = department.id
			sub_department_id = sub_department.id

			religion_id = religion.id

			salutation = single_item[:salutation]
			first_name = single_item[:first_name]
			last_name = single_item[:last_name]
			father_name = single_item[:father_name]
			official_email = single_item[:official_email]
			official_mobile_number = single_item[:official_mobile_number]
			personal_email = single_item[:personal_email]
			personal_number = single_item[:personal_number]

			gender = single_item[:gender]
			cnic_number = single_item[:cnic_number]
			blood_group = single_item[:blood_group]
			martial_status = single_item[:martial_status]

			create_login = false
			user_account_email = official_email
			user_account_password = "abcd@1234-#{single_item[:employee_code]}"
			role_id = nil
			is_admin = false
			custom_right = false
			is_company_head = false
			is_location_head = false
			is_branch_head = false
			is_department_head = false

			date_of_birth = single_item[:date_of_birth].to_date
			joining_date = single_item[:joining_date].to_date
			confimration_due_date = single_item[:confimration_due_date].to_date

			if single_item[:confirmation_date].present?
				confirmation_date = single_item[:confirmation_date].to_date
				on_probation = false
			else
				confirmation_date = nil
				on_probation = true
			end

			employee_code = single_item[:employee_code]
			emergency_contact_name = single_item[:emergency_contact_name]
			payment_method = single_item[:payment_method]
			bank_name = single_item[:bank_name]
			bank_branch_name = single_item[:bank_branch_name]
			bank_branch_code = single_item[:bank_branch_code]
			bank_account_title = single_item[:bank_account_title]
			bank_account_number = single_item[:bank_account_number]
			gross_salary = single_item[:gross_salary]
			emergency_contact_phone = single_item[:emergency_contact_phone]
			permanent_address = single_item[:permanent_address]
			religion_name = single_item[:religion_name]

			puts "\n branch_id => #{branch_id} \n"
			puts "\n location_id => #{location_id} \n"
			puts "\n company_id => #{company_id} \n"
			puts "\n salary_unit_id => #{salary_unit_id} \n"
			puts "\n cost_center_id => #{cost_center_id} \n"
			puts "\n grade_id => #{grade_id} \n"
			puts "\n job_title_id => #{job_title_id} \n"
			puts "\n designation_id => #{designation_id} \n"
			puts "\n department_id => #{department_id} \n"
			puts "\n sub_department_id => #{sub_department_id} \n"
			puts "\n employee_type_id => #{employee_type_id} \n"
			puts "\n company_id => #{company_id} \n"
			puts "\n salutation => #{salutation} \n"
			puts "\n first_name => #{first_name} \n"
			puts "\n last_name => #{last_name} \n"
			puts "\n father_name => #{father_name} \n"
			puts "\n official_email => #{official_email} \n"
			puts "\n official_mobile_number => #{official_mobile_number} \n"
			puts "\n personal_email => #{personal_email} \n"
			puts "\n personal_number => #{personal_number} \n"
			puts "\n gender => #{gender} \n"
			puts "\n cnic_number => #{cnic_number} \n"
			puts "\n blood_group => #{blood_group} \n"
			puts "\n martial_status => #{martial_status} \n"
			puts "\n create_login => #{create_login} \n"
			puts "\n user_account_email => #{user_account_email} \n"
			puts "\n user_account_password => #{user_account_password} \n"
			puts "\n role_id => #{role_id} \n"
			puts "\n is_admin => #{is_admin} \n"
			puts "\n custom_right => #{custom_right} \n"
			puts "\n is_company_head => #{is_company_head} \n"
			puts "\n is_location_head => #{is_location_head} \n"
			puts "\n is_branch_head => #{is_branch_head} \n"
			puts "\n is_department_head => #{is_department_head} \n"
			puts "\n date_of_birth => #{date_of_birth} \n"
			puts "\n joining_date => #{joining_date} \n"
			puts "\n confimration_due_date => #{confimration_due_date} \n"
			puts "\n confirmation_date => #{confirmation_date} \n"
			puts "\n on_probation => #{on_probation} \n"
			puts "\n employee_code => #{employee_code} \n"
			puts "\n emergency_contact_name => #{emergency_contact_name} \n"
			puts "\n payment_method => #{payment_method} \n"
			puts "\n bank_name => #{bank_name} \n"
			puts "\n bank_branch_name => #{bank_branch_name} \n"
			puts "\n bank_branch_code => #{bank_branch_code} \n"
			puts "\n bank_account_title => #{bank_account_title} \n"
			puts "\n bank_account_number => #{bank_account_number} \n"
			puts "\n gross_salary => #{gross_salary} \n"
			puts "\n emergency_contact_phone => #{emergency_contact_phone} \n"
			puts "\n permanent_address => #{permanent_address} \n"
			puts "\n religion_id => #{religion_id} \n"

			count = count + 1
			Employee.create(:branch_id => branch_id, :location_id => location_id, :company_id => company_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :grade_id => grade_id, :job_title_id => job_title_id, :designation_id => designation_id, :department_id => department_id, :sub_department_id => sub_department_id, :employee_type_id => employee_type_id, :salutation => salutation, :first_name => first_name, :last_name => last_name, :father_name => father_name, :official_email => official_email, :official_mobile_number => official_mobile_number, :personal_email => personal_email, :personal_number => personal_number, :gender => gender, :cnic_number => cnic_number, :blood_group => blood_group, :martial_status => martial_status, :create_login => create_login, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :date_of_birth => date_of_birth, :joining_date => joining_date, :confimration_due_date => confimration_due_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :employee_code => employee_code, :emergency_contact_name => emergency_contact_name, :payment_method => payment_method, :bank_name => bank_name, :bank_branch_name => bank_branch_name, :bank_branch_code => bank_branch_code, :bank_account_title => bank_account_title, :bank_account_number => bank_account_number, :gross_salary => gross_salary, :emergency_contact_phone => emergency_contact_phone, :permanent_address => permanent_address, :religion_id => religion_id)
		end
  end

  # DataEntry.deactive_all_email_setting
  def self.deactive_all_email_setting
  	EmailTemplate.all.each do |single_item|
			single_item.is_active = false
			single_item.save
		end
		EmailConfigration.all.each do |single_item|
			single_item.is_active = false
			single_item.save
		end
  end

  # DataEntry.export_annual_leave_balance
  def self.export_annual_leave_balance
  	leave_types = LeaveType.where(:name => "Annual Leave")
		time = Time.now
		book = Axlsx::Package.new
		check_directory("#{Rails.public_path}/excel")
		wb = book.workbook
		sheet = wb.add_worksheet(name: 'Leave Balance')
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
		sheet.add_row ["Sr #", "Emp Code", "Name", "Leave Type", "Allocated Balance", "Used Balance", "Remaining Balance"], :style => header_style
		old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
		even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
		count = 0


		Employee.active.order('id ASC').each do |employee|
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

			leave_allocations = LeaveAllocation.where(:leave_type_id => leave_types.collect(&:id), :location_id => employee.location_id, :is_active => true, :employee_id => employee.id)

			if leave_allocations.count == 1
				leave_allocation = leave_allocations.first
				current_row_value << leave_allocation.leave_type_name
				current_row_style << row_format
				current_row_type << :string

				current_row_value << leave_allocation.allocated_quota
				current_row_style << row_format
				current_row_type << :float

				current_row_value << leave_allocation.used_quota
				current_row_style << row_format
				current_row_type << :float

				current_row_value << leave_allocation.remaining_quota
				current_row_style << row_format
				current_row_type << :float
			end

			sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
		end
		file_name = "leave_balance"
		url_path = save_excel_file(book, file_name)
  end

  # DataEntry.srl_new_job_title
  def self.srl_new_job_title
  	job_titles = SmarterCSV.process("#{Rails.public_path}/srl_data/job_title.csv")
		job_titles.each do |single_item|
			JobTitle.create(:company_id => 1, :is_active => true, :name => single_item[:job_title].titleize)
		end

		job_titles.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code])
			if not employee.nil?
				job_title = JobTitle.find_by(:name => single_item[:job_title].titleize)
				employee.job_title_id = job_title.id
				employee.save
			end
		end
  end

  # DataEntry.idl_tax
  def self.idl_tax
  	employee = Employee.find_by_employee_code("100001")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (791600 + 791600 + 791600 + 791600 + 791600 + 791600 + 641600 + 641600 +  500000)
			employee_taxable_income.monthly_tax_amount = (53500 + 53500 + 53500 + 80000 + 80000 + 80000 + 50000 + 50000)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100002")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (810000 + 810000 + 810000 + 810000 + 810000 + 810000 + 860000 + 860000 +  405000)
			employee_taxable_income.monthly_tax_amount = ( 86500 + 86500 + 86500 + 140056 + 140056 + 140056 + 140056 + 155055)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100005")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (425000 + 425000 + 425000 + 425000 + 425000 + 425000 + 468000 + 468000 +  212500 )
			employee_taxable_income.monthly_tax_amount = (28750 + 28750 + 28750 + 47083 + 47083 + 47083 + 47083 + 57404)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100015")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (240000 + 258462 + 240000 + 258462 + 240000 + 240000 + 277000 + 277000 +  120000)
			employee_taxable_income.monthly_tax_amount = (9000 + 9168 + 9168 + 11134 + 11134 + 11134 + 11134 + 17793)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100006")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (106000 + 106000 + 106000 + 114154 + 106000 + 106000 + 117000 + 117000 +  53000) 
			employee_taxable_income.monthly_tax_amount = (300 + 300 + 300 + 568 + 317 + 317 + 317 + 978)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100008")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (92000 + 99077 + 92000 + 92000 + 92000 + 92000 + 110000 + 110000 +  46000)
			employee_taxable_income.monthly_tax_amount = (167 + 167 + 167 + 167 + 167 + 167 + 167 + 166)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100024")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (115000 + 115000 + 115000 + 123846 + 115000 + 115000 + 133000 + 133000 +  57500)
			employee_taxable_income.monthly_tax_amount = (750 + 750 + 750 + 1021 + 771 + 771 + 771 + 1852)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100004")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (100000 + 100000 + 100000 + 100000 + 100000 + 100000 + 113500 + 113500 +  50000)
			employee_taxable_income.monthly_tax_amount = (167 + 167 + 167 + 167 + 167 + 167 + 167 + 576)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100003")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (60000 + 60000 + 60000 + 60000 + 60000 + 60000 + 68000 + 68000 +  30000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end


		employee = Employee.find_by_employee_code("100011")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (50000 + 50000 + 50000 + 50000 + 50000 + 50000 + 54500 + 54500 +  25000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end


		employee = Employee.find_by_employee_code("100082")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (51000 + 51000 + 51000 + 51000 + 51000 + 51000 + 66000 + 66000 +  25500)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84) 
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100126")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (58000 + 60231 + 58000 + 58000 + 58000 + 58000 + 75000 + 75000 +  29000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 284)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100009")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (50000 + 50000 + 50000 + 53846 + 50000 + 50000 + 59000 + 59000 +  25000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100021")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (42000 + 45231 + 42000 + 42000 + 42000 + 42000 + 46500 + 46500 +  21000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100269")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (106000 + 106000 + 106000 + 114154 + 106000 + 106000 + 112000 + 112000 +  53000)
			employee_taxable_income.monthly_tax_amount = (300 + 300 + 300 + 568 + 317 + 317 + 317 + 678)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100029")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (38000 + 40923 + 38000 + 40923 + 38000 + 38000 + 42500 + 42500 +  19000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100262")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (36000 + 36000 + 36000 + 38769 + 36000 + 36000 + 46500 + 46500 +  18000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100290")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (34000 + 34000 + 34000 + 36615 + 34000 + 34000 + 44000 + 44000 +  17000)
			employee_taxable_income.monthly_tax_amount = (83 + 83 + 83 + 83 + 83 + 83 + 83 + 84)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100289")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (33000 + 33000 + 33000 + 33000 + 33000 + 33000 + 37000 + 37000 +  16500)
			employee_taxable_income.monthly_tax_amount = (200)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end

		employee = Employee.find_by_employee_code("100395")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (32000 + 32000 + 32000 + 32000 + 32000 + 32000 + 35500 + 35500 +  16000)	 
			employee_taxable_income.monthly_tax_amount = (200)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end


		employee = Employee.find_by_employee_code("100418")
		if not employee.nil?
			employee_taxable_income = EmployeeTaxableIncome.new
			employee_taxable_income.employee_id = employee.id
			employee_taxable_income.company_id = employee.company_id
			employee_taxable_income.fiscal_year_id = 1
			employee_taxable_income.pay_invoice_id = nil
			employee_taxable_income.pay_execution_id = nil
			employee_taxable_income.taxable_amount_to_date = (30000 + 30000 + 30000 + 30000 + 30000 + 30000 + 36000 + 36000 +  15000)
			employee_taxable_income.status = true
			employee_taxable_income.save
		end
  end

  def self.idl_bank_info
  	bank_info = SmarterCSV.process("#{Rails.public_path}/idl_data/new_data/bank_info.csv")
		bank_info.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
			if not employee.nil?
				employee.bank_name = single_item[:bank_name]
		    employee.bank_branch_name = "-"
		    employee.bank_branch_code = single_item[:branch_code]
		    employee.bank_account_title = employee.full_name
		    employee.bank_account_number = single_item[:account_number]
		    employee.gross_salary = single_item[:gross_salary].to_f
		    employee.save
			end
		end
  end

  def self.picture_export
  	time = Time.now
		book = Axlsx::Package.new
		wb = book.workbook
		sheet = wb.add_worksheet(name: 'Employee PIC Data')
		book.use_autowidth = false
		sheet.sheet_view do |view|
		view.show_outline_symbols = true
		end
		book.use_autowidth = true
		bold_column_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
		sheet.add_row ["Employee Code", "PIC URL"], :style => bold_column_format
		line_item_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "641E16", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, b: true)

		Employee.active.order('id ASC').each do |employee|
		if not employee.avatar.nil?
		sheet.add_row [employee.employee_code, employee.avatar.url], :style => line_item_format
		end
		end

		file_name = "employee_picture"
		url_path = save_excel_file(book, file_name)

		picture_details = SmarterCSV.process("#{Rails.public_path}/srl_data/Book2.csv")
		picture_details.each do |single_item|
			open("#{single_item[:picture_url]}") do |image|
				file_name = "#{single_item[:employee_code]}.png"
				save_path = "#{Rails.public_path}/excel/image/#{file_name}"
			  File.open(save_path, "wb") do |file|
			    file.write(image.read)
			  end
			end
		end
  end

  def self.dfl_mill_master_data
  	department_list = ["Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Utility & Services", "Junior Staff", "Sizing", "Weaving", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Drawing In", "Weaving", "Junior Staff", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Warping", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Sizing", "Warping", "Weaving", "Sizing", "Winding", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Winding", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Warping", "Folding & Packing", "Sizing", "Weaving", "Weaving", "Knotting", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Folding & Packing", "Sizing", "Folding & Packing", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Warping", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Drawing In", "Folding & Packing", "Weaving", "Warping", "Drawing In", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Sizing", "Workshop", "Weaving", "Weaving", "Warping", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Sizing", "Warping", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Winding", "Winding", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Winding", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Knotting", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Electrical", "Warping", "Weaving", "Sizing", "Weaving", "Warping", "Weaving", "Warping", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Sizing", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Sizing", "Warping", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Utility & Services", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Warping", "Weaving", "Weaving", "Weaving", "Electrical", "Sizing", "Weaving", "Weaving", "Weaving", "Winding", "Winding", "Winding", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Winding", "Winding", "Winding", "Sizing", "Weaving", "Weaving", "Winding", "Winding", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Winding", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Drawing In", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Sizing", "Sizing", "Folding & Packing", "Weaving", "Sizing", "Warping", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Warping", "Weaving", "Weaving", "Folding & Packing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Drawing In", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Winding", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Accounts", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Utility & Services", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Knotting", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Folding & Packing", "Folding & Packing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Warping", "Folding & Packing", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Knotting", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Knotting", "Weaving", "Sizing", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Knotting", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Utility & Services", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Utility & Services", "Knotting", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Weaving", "Folding & Packing", "Folding & Packing", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Technical", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Warping", "Sizing", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Admin. Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "Other Staff", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Warping", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Knotting", "Sizing", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Warping", "Sizing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Warping", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Warping", "Sizing", "Drawing & Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Knotting", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Drawing & Knotting", "Weaving", "Folding & Packing", "Warping", "Warping", "Warping", "Weaving", "Sizing", "Warping", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Folding & Packing", "Sizing", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Drawing & Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Air Condition", "Sizing", "Sizing", "Weaving", "Warping", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Knotting", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Winding", "Weaving", "Weaving", "Winding", "Winding", "Weaving", "Winding", "Winding", "Weaving", "Winding", "Winding", "Weaving", "Weaving", "Weaving", "Winding", "Weaving", "Weaving", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Warping", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Warping", "Sizing", "Warping", "Weaving", "Weaving", "Utility & Services", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Winding", "Weaving", "Sizing", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Sizing", "Folding & Packing", "Warping", "Weaving", "Weaving", "Sizing", "Weaving", "Sizing", "Weaving", "Warping", "Warping", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Drawing In", "Weaving", "Weaving", "Warping", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Sizing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Warping", "Folding & Packing", "Winding", "Weaving", "Winding", "Folding & Packing", "Weaving", "Warping", "Warping", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Sizing", "Weaving", "Weaving", "Weaving", "Warping", "Folding & Packing", "Winding", "Folding & Packing", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Knotting", "Weaving", "Weaving", "Weaving", "Warping", "Knotting", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Sizing", "Sizing", "Weaving", "Knotting", "Weaving", "Sizing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Utility & Services", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Weaving", "Warping", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Power Plant", "Utility", "Finishing", "Dyeing", "Electrical", "Electrical", "Electrical", "Dyeing", "Dyeing", "Finishing", "Finishing", "Other Staff", "Other Staff", "Electrical", "Electrical", "HR & Administration", "Utility", "HR & Administration", "HR & Administration", "Dyeing", "Rebeaming", "Finishing", "Dyeing", "Mechanical", "Mechanical", "Mechanical", "Mechanical", "Utility", "Dyeing", "Dyeing", "Dyeing", "Finishing", "Finishing", "Dyeing", "Finishing", "Finishing", "Rebeaming", "Denim", "Rebeaming", "Ball Warping", "Ball Warping", "Air Condition", "Finishing", "Air Condition", "Denim", "Q.A Lab", "Finishing", "Mechanical", "HR & Administration", "Folding & Packing", "Folding & Packing", "Denim", "HR & Administration", "HR & Administration", "Q.A Lab", "Q.A Lab", "Denim", "Sizing", "Denim", "Electrical", "Electrical", "Electrical", "HR & Administration", "Denim", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Admin. Staff", "Folding & Packing", "Product Development", "Utility", "Rebeaming", "Ball Warping", "HR & Administration", "Q.A Lab", "Sizing", "Admin. Staff", "Ball Warping", "Rebeaming", "Finishing", "Air Condition", "Q.A Lab", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Sizing", "Dyeing", "Q.A Lab", "Ball Warping", "Ball Warping", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Finishing", "Finishing", "Finishing", "Finishing", "Dyeing", "Denim", "Dyeing", "Rebeaming", "Finishing", "Dyeing", "Sizing", "Sizing", "Rebeaming", "Finishing", "Finishing", "Finishing", "Dyeing", "HR & Administration", "Rebeaming", "Rebeaming", "Ball Warping", "Ball Warping", "Finishing", "Utility", "Finishing", "Utility", "Utility", "Finishing", "Finishing", "Finishing", "Folding & Packing", "Dyeing", "Dyeing", "Sizing", "Finishing", "Finishing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Q.A Lab", "Ball Warping", "Finishing", "Rebeaming", "Ball Warping", "Finishing", "Finishing", "Admin. Staff", "Ball Warping", "Sizing", "Sizing", "Sizing", "Other Staff", "Sizing", "Dyeing", "Dyeing", "Dyeing", "Rebeaming", "Ball Warping", "Dyeing", "Folding & Packing", "Rebeaming", "Folding & Packing", "Ball Warping", "Folding & Packing", "Q.A Lab", "Ball Warping", "Sizing", "Ball Warping", "Sizing", "Ball Warping", "Dyeing", "Folding & Packing", "Folding & Packing", "Q.A Lab", "Sizing", "Dyeing", "Folding & Packing", "Ball Warping", "Q.A Lab", "Q.A Lab", "Q.A Lab", "Folding & Packing", "Folding & Packing", "Electrical", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Rebeaming", "Finishing", "Finishing", "Rebeaming", "Mechanical", "Finishing", "Finishing", "Dyeing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Finishing", "Folding & Packing", "Sizing", "Finishing", "Dyeing", "Folding & Packing", "Finishing", "Dyeing", "Finishing", "Finishing", "Dyeing", "Sizing", "Finishing", "Product Development", "Folding & Packing", "Folding & Packing", "Ball Warping", "Q.A Lab", "Folding & Packing", "Rebeaming", "Folding & Packing", "Folding & Packing", "Product Development", "Product Development", "Folding & Packing", "Folding & Packing", "Product Development", "Product Development", "Dyeing", "Dyeing", "Dyeing", "Product Development", "Finishing", "Folding & Packing", "Folding & Packing", "Finishing", "Dyeing", "Rebeaming", "Dyeing", "Dyeing", "Folding & Packing", "Folding & Packing", "Rebeaming", "Product Development", "Mechanical", "Q.A Lab", "Folding & Packing", "Finishing", "Ball Warping", "Finishing", "Rebeaming", "Finishing", "Folding & Packing", "Finishing", "Finishing", "Finishing", "Q.A Lab", "Folding & Packing", "Rebeaming", "Folding & Packing", "Ball Warping", "Folding & Packing", "Finishing", "Dyeing", "Finishing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Dyeing", "Sizing", "Finishing", "Folding & Packing", "Finishing", "Ball Warping", "Rebeaming", "Rebeaming", "Ball Warping", "Ball Warping", "Dyeing", "Ball Warping", "Rebeaming", "Sizing", "Product Development", "Dyeing", "Mechanical", "Finishing", "Finishing", "Rebeaming", "Finishing", "Finishing", "Finishing", "Folding & Packing", "Sizing", "Finishing", "Finishing", "Finishing", "Finishing", "Folding & Packing", "Folding & Packing", "Sizing", "Finishing", "Q.A Lab", "Finishing", "Dyeing", "Finishing", "Q.A Lab", "Dyeing", "Finishing", "Ball Warping", "Dyeing", "Finishing", "Folding & Packing", "Electrical", "Q.A Lab", "Electrical", "Air Condition", "Finishing", "Chemical Store", "Finishing", "Finishing", "Finishing", "Product Development", "Product Development", "Finishing", "Folding & Packing", "Finishing", "Finishing", "Utility", "Finishing", "Utility", "Product Development", "Ball Warping", "Electrical", "Sizing", "Sizing", "Finishing", "Dyeing", "Folding & Packing", "Q.A Lab", "Q.A Lab", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Product Development", "Mechanical", "Dyeing", "Folding & Packing", "Folding & Packing", "Finishing", "Finishing", "Folding & Packing", "Finishing", "HR & Administration", "Product Development", "Product Development", "P.P.C", "Admin. Staff", "Finishing", "Q.A Lab", "Dyeing", "Rebeaming", "Rebeaming", "Finishing", "Ball Warping", "Finishing", "Finishing", "Folding & Packing", "Finishing", "Product Development", "Ball Warping", "Folding & Packing", "Other Staff", "Finishing", "Mechanical", "Mechanical", "Dyeing", "Finishing", "Electrical", "Electrical", "Dyeing", "Sizing", "Dyeing", "Folding & Packing", "Ball Warping", "Rebeaming", "Rebeaming", "Q.A Lab", "Folding & Packing", "Q.A Lab", "Sizing", "Folding & Packing", "Finishing", "Folding & Packing", "Ball Warping", "Dyeing", "Electrical", "Sizing", "Dyeing", "Ball Warping", "Dyeing", "Electrical", "Dyeing", "HR & Administration", "HR & Administration", "HR & Administration", "Finishing", "Product Development", "Other Staff", "Product Development", "Finishing", "Finishing", "Folding & Packing", "Ball Warping", "Utility", "Utility", "Utility", "Utility", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Utility", "Utility", "Utility", "Utility", "GWP", "Other Staff", "Electrical", "Sizing", "Electrical", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Stitching", "Sizing", "Rebeaming", "Finishing", "Finishing", "Finishing", "Folding & Packing", "Folding & Packing", "Q.A Lab", "Q.A Lab", "Electrical", "Folding & Packing", "Ball Warping", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Q.A Lab", "Utility", "Folding & Packing", "Dyeing", "Mechanical", "Product Development", "Rebeaming", "Ball Warping", "Folding & Packing", "Utility", "Ball Warping", "Rebeaming", "Sizing", "Sizing", "Mechanical", "Ball Warping", "Folding & Packing", "Dyeing", "Sizing", "Ball Warping", "Finishing", "Folding & Packing", "Folding & Packing", "Rebeaming", "Electrical", "Sizing", "Sizing", "Finishing", "Sizing", "Sizing", "Garments", "Garments", "Sizing", "Ball Warping", "Garments", "Rebeaming", "Electrical", "Folding & Packing", "Stitching", "Stitching", "Stitching", "Electrical", "GWP", "Stitching", "Finishing & Packing", "Mechanical", "Stitching", "Electrical", "Garments", "HR & Administration", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "MMC", "Cutting", "Cutting", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "Electrical", "GWP", "GWP", "GWP", "Cutting", "Product Development", "Product Development", "Stitching", "Cutting", "Quality", "Quality", "Product Development", "Quality", "Cutting", "Cutting", "Electrical", "GWP", "HR & Administration", "Marketing", "Stitching", "P.P.C", "Mechanical", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "Quality", "Marketing", "P.P.C", "P.P.C", "P.P.C", "Stitching", "Marketing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Marketing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "HR & Administration", "Finishing & Packing", "P.P.C", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Finishing & Packing", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Quality", "Cutting", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GDP", "GWP", "GWP", "GWP", "GWP", "GWP", "GDP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Cutting", "Cutting", "Cutting", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Product Development", "Product Development", "Finishing & Packing", "Product Development", "Product Development", "P.P.C", "Finishing & Packing", "GWP", "Quality", "Finishing & Packing", "MMC", "Finishing & Packing", "Stitching", "Mechanical", "GWP", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "Finishing & Packing", "Finishing & Packing", "Quality", "Quality", "Finishing & Packing", "Stitching", "Product Development", "Product Development", "Product Development", "MMC", "Finishing & Packing", "Finishing & Packing", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Quality", "GWP", "Quality", "P.P.C", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Product Development", "Product Development", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Electrical", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GDP", "GWP", "Finishing & Packing", "GWP", "Product Development", "Product Development", "Stitching", "Finishing & Packing", "Stitching", "GWP", "Stitching", "Product Development", "Product Development", "P.D Sampling", "Product Development", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "Mechanical", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Product Development", "Quality", "Product Development", "GWP", "Quality", "GWP", "GWP", "GWP", "Product Development", "GDP", "GDP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "Product Development", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "Quality", "Cutting", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Quality", "Quality", "Stitching", "GWP", "Stitching", "GWP", "Stitching", "Stitching", "Stitching", "Quality", "Cutting", "Stitching", "Product Development", "Quality", "Product Development", "Product Development", "Product Development", "Product Development", "GWP", "GWP", "GWP", "GWP", "Quality", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "P.P.C", "P.P.C", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "P.P.C", "Product Development", "Stitching", "Cutting", "Stitching", "Quality", "Quality", "P.P.C", "Stitching", "Stitching", "Stitching", "Cutting", "Cutting", "Stitching", "Stitching", "GWP", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "Finishing & Packing", "Stitching", "GWP", "GWP", "Quality", "MMC", "Cutting", "Mechanical", "Quality", "Cutting", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Stitching", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Product Development", "Product Development", "Product Development", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Quality", "HR & Administration", "Stitching", "Stitching", "Stitching", "Cutting", "GWP", "GWP", "GWP", "Cutting", "Finishing & Packing", "Cutting", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Cutting", "Cutting", "Cutting", "Product Development", "Product Development", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "P.P.C", "P.P.C", "Stitching", "Product Development", "Finishing & Packing", "Mechanical", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "Marketing", "Stitching", "Stitching", "Stitching", "Quality", "Quality", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "GWP", "Stitching", "GWP", "GWP", "Finishing & Packing", "Stitching", "GWP", "GWP", "Product Development", "GWP", "GWP", "GWP", "Mechanical", "Finishing & Packing", "Finishing & Packing", "Product Development", "Electrical", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "P.P.C", "GWP", "Cutting", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "Cutting", "Mechanical", "GWP", "Cutting", "Product Development", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Quality", "Quality", "Quality", "GWP", "Cutting", "GWP", "Stitching", "Quality", "GWP", "Product Development", "GWP", "Stitching", "Stitching", "Stitching", "Product Development", "GWP", "GWP", "Finishing & Packing", "GWP", "GWP", "Finishing & Packing", "GWP", "Finishing & Packing", "Cutting", "Cutting", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Mechanical", "GWP", "Quality", "Finishing & Packing", "Quality", "Finishing & Packing", "Product Development", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "GWP", "GWP", "GWP", "GWP", "Stitching", "Cutting", "Stitching", "GWP", "Product Development", "Stitching", "Stitching", "Stitching", "GWP", "GWP", "Cutting", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "Product Development", "Cutting", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Quality", "GWP", "GWP", "GWP", "Finishing & Packing", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Quality", "Finishing & Packing", "GWP", "GWP", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "GWP", "GWP", "GWP", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "Product Development", "Finishing & Packing", "Finishing & Packing", "Mechanical", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Cutting", "Cutting", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Cutting", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Product Development", "P.P.C", "P.P.C", "Stitching", "Stitching", "Stitching", "Cutting", "Product Development", "MMC", "Stitching", "Finishing & Packing", "Stitching", "GWP", "GWP", "GWP", "Marketing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "Stitching", "GWP", "Stitching", "GWP", "Stitching", "Stitching", "GWP", "GWP", "Finishing & Packing", "GWP", "Finishing & Packing", "GWP", "Cutting", "Stitching", "GWP", "Stitching", "Stitching", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "P.P.C", "Product Development", "Cutting", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Stitching", "Industrial Engineering", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Mechanical", "Stitching", "Stitching", "Mechanical", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "MMC", "Finishing & Packing", "Cutting", "Product Development", "Finishing & Packing", "GWP", "Finishing & Packing", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "GWP", "Finishing & Packing", "Finishing & Packing", "Product Development", "Product Development", "Product Development", "Mechanical", "Finishing & Packing", "Cutting", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Product Development", "Product Development", "Cutting", "Stitching", "Product Development", "Product Development", "Product Development", "Stitching", "Stitching", "Stitching", "Electrical", "Product Development", "Stitching", "Product Development", "Product Development", "Finishing & Packing", "GWP", "Product Development", "Quality", "Quality", "Finishing & Packing", "Quality", "Quality", "Cutting", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "P.P.C", "Stitching", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Quality", "Stitching", "Stitching", "P.P.C", "P.P.C", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "P.P.C", "GWP", "Finishing & Packing", "Stitching", "Finishing & Packing", "Cutting", "Stitching", "MMC", "Stitching", "Stitching", "GWP", "Stitching", "Stitching", "Finishing & Packing", "Stitching", "Finishing & Packing", "Cutting", "Stitching", "Stitching", "Stitching", "Product Development", "Stitching", "Quality", "Product Development", "Stitching", "Stitching", "Stitching", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "GWP", "Product Development", "Stitching", "Cutting", "Finishing & Packing", "Stitching", "Product Development", "Finishing & Packing", "GWP", "GWP", "GWP", "Finishing & Packing", "P.P.C", "Finishing & Packing", "Finishing & Packing", "Cutting", "Stitching", "Finishing & Packing", "Cutting", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "GWP", "GWP", "Cutting", "Stitching", "Stitching", "Stitching", "Quality", "Stitching", "Quality", "Stitching", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Product Development", "Product Development", "GWP", "Cutting", "Cutting", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "HR & Administration", "Quality", "Finishing & Packing", "GWP", "GWP", "Stitching", "Finishing & Packing", "Finishing & Packing", "Quality", "Product Development", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "Stitching", "Finishing & Packing", "Stitching", "Stitching", "Mechanical", "Product Development", "GWP", "GWP", "Stitching", "GWP", "Stitching", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Quality", "Stitching", "Stitching", "Quality", "Quality", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Quality", "Product Development", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Cutting", "Quality", "MMC", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "GWP", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Quality", "Quality", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "Stitching", "GWP", "Finishing & Packing", "Cutting", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "GWP", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "GWP", "GWP", "Finishing & Packing", "Stitching", "Finishing & Packing", "Product Development", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "GWP", "Product Development", "Finishing & Packing", "Quality", "GWP", "Finishing & Packing", "Finishing & Packing", "Product Development", "Stitching", "Stitching", "Stitching", "Product Development", "Product Development", "Industrial Engineering", "Product Development", "Finishing & Packing", "Stitching", "Stitching", "Product Development", "Product Development", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Stitching", "Stitching", "Stitching", "Stitching", "Stitching", "Industrial Engineering", "Finishing & Packing", "Finishing & Packing", "Product Development", "GWP", "MMC", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "Stitching", "Stitching", "Stitching", "Finishing & Packing", "Stitching", "Cutting", "Stitching", "Finishing & Packing", "Mechanical", "Product Development", "Finishing & Packing", "Stitching", "Product Development", "GWP", "Finishing & Packing", "Finishing & Packing", "GWP", "Finishing & Packing", "Cutting", "Quality", "Stitching", "Stitching", "Cutting", "GWP", "GWP", "GWP", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Accounts", "Stitching", "Stitching", "Stitching", "Stitching", "Cutting", "GWP", "GWP", "GWP", "GWP", "GWP", "Stitching", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Electrical", "GWP", "Finishing & Packing", "Finishing & Packing", "Finishing & Packing", "Cutting", "Cutting", "GWP", "Finishing & Packing", "Cutting", "HR & Administration", "Cutting", "Cutting", "GWP", "Stitching", "Finishing & Packing", "Finishing & Packing", "Utility & Services", "Finishing", "Dyeing", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Dyeing", "Utility & Services", "Product Development", "Dyeing", "Dyeing", "Finishing", "Utility & Services", "HR & Administration", "Utility & Services", "Electrical", "Finishing", "Finishing", "Finishing", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Dyeing", "Back Process", "Finishing", "Quality", "Back Process", "Back Process", "Back Process", "Back Process", "Dyeing", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Back Process", "Finishing", "Finishing", "Finishing", "Quality", "Quality", "Back Process", "Back Process", "Utility & Services", "Finishing", "Utility & Services", "Utility & Services", "Back Process", "HR & Administration", "Finishing", "Back Process", "Quality", "Finishing", "Utility & Services", "Finishing", "Finishing", "Quality", "HR & Administration", "Finishing", "Quality", "Quality", "Quality", "Back Process", "Back Process", "HR & Administration", "Utility & Services", "Finishing", "Utility & Services", "Utility & Services", "Quality", "Quality", "Quality", "Quality", "Stitching", "Quality", "Product Development", "Finishing", "Product Development", "Utility & Services", "Utility & Services", "Back Process", "Back Process", "Dyeing", "P.P.C", "HR & Administration", "Finishing", "Back Process", "Back Process", "Finishing", "Product Development", "Back Process", "Product Development", "GWP", "Finishing", "Dyeing", "Finishing", "Quality", "Finishing", "P.P.C", "Q.A Lab", "Folding & Packing", "Quality", "Quality", "Quality", "Finishing", "Dyeing", "Quality", "Back Process", "Back Process", "Back Process", "Finishing", "Finishing", "Back Process", "Back Process", "Quality", "Back Process", "Back Process", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Utility & Services", "Back Process", "Finishing", "Back Process", "Back Process", "Finishing", "Dyeing", "Finishing", "Back Process", "Back Process", "Back Process", "Back Process", "Back Process", "Finishing", "Finishing", "Finishing", "Finishing", "Utility & Services", "Finishing", "Finishing", "Finishing", "Utility & Services", "Utility & Services", "Utility & Services", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Quality", "Finishing", "Finishing", "Quality", "Folding & Packing", "Quality", "Back Process", "Back Process", "Finishing", "HR & Administration", "Back Process", "HR & Administration", "Utility & Services", "Back Process", "Utility & Services", "Quality", "Back Process", "Quality", "Back Process", "Back Process", "Dyeing", "Quality", "Back Process", "Quality", "Quality", "Dyeing", "Quality", "Quality", "P.P.C", "Quality", "Quality", "Quality", "Finishing", "Finishing", "Electrical", "Quality", "Quality", "Finishing", "Product Development", "Quality", "Mechanical", "Finishing", "Finishing", "Quality", "Quality", "Finishing", "Back Process", "Finishing", "Quality", "Finishing", "Dyeing", "Dyeing", "Finishing", "Dyeing", "Finishing", "Product Development", "HR & Administration", "Utility & Services", "Back Process", "Quality", "Quality", "Back Process", "Finishing", "Dyeing", "Quality", "Product Development", "Product Development", "Quality", "Finishing", "GWP", "GWP", "Product Development", "Stitching", "Finishing", "Finishing", "Product Development", "Finishing", "Finishing", "Back Process", "Product Development", "Dyeing", "Product Development", "Utility & Services", "Quality", "Quality", "Quality", "Finishing", "Product Development", "Product Development", "Quality", "Finishing", "Finishing", "Finishing", "Q.A Lab", "Quality", "Rebeaming", "Quality", "Finishing", "Finishing", "Quality", "Quality", "Quality", "Quality", "Sizing", "Finishing", "Quality", "Finishing", "Finishing", "Ball Warping", "Ball Warping", "Utility & Services", "Back Process", "Stitching", "Dyeing", "Utility & Services", "Finishing", "Dyeing", "Finishing", "Back Process", "Finishing", "Finishing", "Quality", "Quality", "Quality", "Finishing", "Utility & Services", "Dyeing", "Back Process", "Dyeing", "Finishing", "Stitching", "Stitching", "Quality", "Finishing", "Product Development", "HR & Administration", "Utility & Services", "Quality", "Product Development", "Utility & Services", "Finishing", "Finishing", "GWP", "Quality", "Finishing", "Finishing", "Utility & Services", "Utility & Services", "Ball Warping", "Utility & Services", "Back Process", "Finishing", "Dyeing", "Quality", "Quality", "Finishing", "Finishing", "Utility & Services", "Utility & Services", "Quality", "Finishing", "Finishing", "Dyeing", "Finishing", "Quality", "Quality", "Finishing", "Finishing", "Quality", "Dyeing", "Folding & Packing", "Product Development", "Finishing", "P.P.C", "Accounts", "Quality", "Quality", "Utility & Services", "Back Process", "Back Process", "Back Process", "Finishing", "Finishing", "Finishing", "Finishing", "Stitching", "Back Process", "Quality", "Ball Warping", "HR & Administration", "Utility & Services", "Mechanical", "Utility & Services", "Finishing", "Utility & Services", "Utility & Services", "Back Process", "Dyeing", "Finishing", "Quality", "GWP", "Back Process", "Back Process", "HR & Administration", "Quality", "Quality", "Utility & Services", "Quality", "Quality", "Back Process", "Folding & Packing", "Finishing", "Quality", "Utility & Services", "Back Process", "Ball Warping", "Utility & Services", "Dyeing", "Product Development", "HR & Administration", "HR & Administration", "HR & Administration", "Finishing", "Product Development", "Other Staff", "GWP", "GWP", "Utility & Services", "Back Process", "Finishing", "Ball Warping", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Finishing", "Finishing", "Back Process", "Back Process", "Finishing", "Finishing", "Utility", "Utility", "Utility & Services", "Utility & Services", "HR & Administration", "Utility & Services", "Back Process", "Utility & Services", "HR & Administration", "Quality", "HR & Administration", "Dyeing", "Back Process", "Sizing", "Finishing", "Finishing", "Finishing", "Quality", "Q.A Lab", "Quality", "Finishing", "Electrical", "Folding & Packing", "HR & Administration", "Back Process", "Ball Warping", "Quality", "Folding & Packing", "Quality", "Quality", "Utility & Services", "Quality", "Quality", "Dyeing", "Quality", "Product Development", "Utility & Services", "Back Process", "Back Process", "Back Process", "Rebeaming", "Ball Warping", "Quality", "Quality", "Quality", "Back Process", "Utility & Services", "Ball Warping", "Back Process", "Back Process", "Back Process", "Back Process", "Utility & Services", "Back Process", "Folding & Packing", "Quality", "Dyeing", "Back Process", "Back Process", "Finishing", "Folding & Packing", "Quality", "Rebeaming", "Utility & Services", "Quality", "Back Process", "Sizing", "Finishing", "Back Process", "Back Process", "Back Process", "Back Process", "Quality", "Back Process", "Ball Warping", "Back Process", "Quality", "Dyeing", "Quality", "Quality", "Quality", "Quality", "Quality", "Finishing", "Finishing", "Dyeing", "Finishing", "Sizing", "Quality", "Quality", "Quality", "Back Process", "Back Process", "Back Process", "Back Process", "Rebeaming", "Utility & Services", "Quality", "Folding & Packing", "Quality", "Quality", "Rebeaming", "Rebeaming", "Dyeing", "Utility & Services", "Rebeaming", "Back Process", "Back Process", "Ball Warping", "Product Development", "Stitching", "Stitching", "Product Development", "Product Development", "Product Development", "Stitching", "Rebeaming", "HR & Administration", "Rebeaming", "Rebeaming", "Utility & Services", "Accounts", "Accounts", "Ball Warping", "Back Process", "Finishing", "Finishing", "Back Process", "Back Process", "Quality", "Utility & Services", "Utility & Services", "HR & Administration", "Finishing", "Utility & Services", "Ball Warping", "Ball Warping", "Back Process", "Other Staff", "Ball Warping", "Back Process", "Dyeing", "Folding & Packing", "Folding & Packing", "Quality", "Rebeaming", "Dyeing", "Quality", "Quality", "Folding & Packing", "Utility & Services", "Folding & Packing", "Finishing", "Dyeing", "Back Process", "Back Process", "Sizing", "Quality", "Quality", "Finishing", "Dyeing", "Finishing", "P.P.C", "Finishing", "Dyeing", "Finishing", "Quality", "Finishing", "Q.A Lab", "Utility & Services", "Back Process", "Finishing", "Finishing", "Utility & Services", "Dyeing", "Finishing", "Finishing", "Finishing", "Finishing", "Q.A Lab", "Finishing", "Back Process", "Quality", "Q.A Lab", "Ball Warping", "Quality", "Folding & Packing", "Quality", "Ball Warping", "Back Process", "Back Process", "Quality", "Quality", "Quality", "Quality", "Back Process", "P.D Sampling", "Dyeing", "Finishing", "Dyeing", "Quality", "Quality", "Ball Warping", "Quality", "Sizing", "Accounts", "Finishing", "Quality", "Quality", "Folding & Packing", "Quality", "Folding & Packing", "Quality", "Quality", "Quality", "Product Development", "HR & Administration", "Quality", "Quality", "Back Process", "Quality", "Quality", "HR & Administration", "Back Process", "Quality", "Back Process", "Utility & Services", "Back Process", "Utility & Services", "Quality", "Quality", "Finishing", "Finishing", "Back Process", "Back Process", "Finishing", "Back Process", "Finishing", "Back Process", "Back Process", "Finishing", "Finishing", "Back Process", "Quality", "Back Process", "Back Process", "Back Process", "Product Development", "Quality", "Back Process", "Back Process", "Quality", "Finishing", "Back Process", "Quality", "HR & Administration", "Finishing", "Back Process", "Quality", "HR & Administration", "Utility & Services", "Utility & Services", "Back Process", "Back Process", "Back Process", "HR & Administration", "Stitching", "Quality", "Quality", "Back Process", "Quality", "Finishing", "Quality", "Finishing", "Quality", "Quality", "Back Process", "Back Process", "Quality", "Quality", "Back Process", "Back Process", "Finishing", "HR & Administration", "Finishing", "Back Process", "Finishing", "Finishing", "Finishing", "Quality", "Finishing", "Quality", "Dyeing", "Back Process", "Back Process", "Back Process", "Quality", "Dyeing", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Back Process", "Back Process", "HR & Administration", "Finishing", "Finishing", "Finishing", "Finishing", "Back Process", "Utility & Services", "Dyeing", "Quality", "Utility & Services", "Dyeing", "Finishing", "Back Process", "HR & Administration", "Quality", "Finishing", "Finishing", "Finishing", "Product Development", "Quality", "Product Development", "HR & Administration", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Product Development", "Quality", "Finishing", "Finishing", "Dyeing", "HR & Administration", "Finishing", "HR & Administration", "Back Process", "Quality", "Quality", "Product Development", "Product Development", "Back Process", "Finishing", "Utility & Services", "Utility & Services", "Finishing", "Dyeing", "Quality", "Quality", "Back Process", "Back Process", "Back Process", "Utility & Services", "Utility & Services", "Finishing", "Finishing", "Quality", "Quality", "Utility & Services", "Back Process", "Finishing", "Dyeing", "Utility & Services", "Utility & Services", "Utility & Services", "Quality", "Quality", "Quality", "Dyeing", "Finishing", "Finishing", "Finishing", "Product Development", "Quality", "Back Process", "Utility & Services", "Dyeing", "Finishing", "Quality", "Quality", "Finishing", "Product Development", "Back Process", "Dyeing", "HR & Administration", "Quality", "Quality", "Back Process", "Finishing", "Finishing", "Utility & Services", "Back Process", "Quality", "Finishing", "Finishing", "Back Process", "Utility & Services", "Finishing", "Finishing", "Finishing", "Finishing", "Finishing", "Utility & Services", "Quality", "HR & Administration", "Finishing", "Utility & Services", "Quality", "Finishing", "Dyeing", "Quality", "Quality", "Back Process", "Finishing", "Back Process", "Quality", "Finishing", "Finishing", "Finishing", "Back Process", "Back Process", "Back Process", "Back Process", "Utility & Services", "Finishing", "Quality", "Quality", "Quality", "Dyeing", "Quality", "Back Process", "Finishing", "Finishing", "Utility & Services", "Quality", "Quality", "Quality", "Product Development", "Dyeing", "Quality", "Quality", "Quality", "Back Process", "Quality", "Utility & Services", "Quality", "Quality", "Back Process", "Finishing", "Back Process", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Quality", "Quality", "Finishing", "Back Process", "Utility & Services", "Finishing", "Accounts", "Utility & Services", "Back Process", "Quality", "Dyeing", "Finishing", "Quality", "Quality", "Quality", "Product Development", "Finishing", "Product Development", "Quality", "Accounts", "Finishing", "Utility & Services", "Quality", "Quality", "Quality", "Quality", "Back Process", "Quality", "Accounts", "Dyeing", "Utility & Services", "Dyeing", "Quality", "Back Process", "Quality", "HR & Administration", "Finishing", "Quality", "Back Process", "Back Process", "Utility & Services", "Finishing", "Quality", "Quality", "Quality", "Quality", "Finishing", "Utility & Services", "HR & Administration", "Finishing", "Finishing", "Back Process", "Utility & Services", "Back Process", "Quality", "Finishing", "Quality", "HR & Administration", "Finishing", "Back Process", "HR & Administration", "Finishing", "Finishing", "Back Process", "Back Process", "Quality", "Utility & Services", "Finishing", "Finishing", "Finishing", "Quality", "Utility & Services", "Dyeing", "Back Process", "Dyeing", "Accounts", "Quality", "Quality", "Back Process", "Finishing", "Finishing", "Finishing", "Dyeing", "HR & Administration", "Quality", "Quality", "Quality", "Quality", "Finishing", "Quality", "Back Process", "Finishing", "Back Process", "Dyeing", "Dyeing", "Back Process", "Back Process", "Finishing", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Other Staff", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Production Store", "Production Store", "Production Store", "Production Store", "Production Store", "Production Store", "Production Store", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Knotting", "Sizing", "Sizing", "Junior Staff", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Drawing In", "Drawing In", "Drawing In", "Drawing In", "Drawing In", "Drawing In", "Drawing In", "Winding", "Winding", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Weaving", "Weaving", "HR & Administration", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Technical", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Laboratory", "Laboratory", "Laboratory", "Laboratory", "Laboratory", "Laboratory", "Laboratory", "Weaving", "Laboratory", "Laboratory", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Junior Staff", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Junior Staff", "Junior Staff", "Folding & Packing", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Junior Staff", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Junior Staff", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Junior Staff", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Junior Staff", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "HR & Administration", "Weaving", "HR & Administration", "Weaving", "Folding & Packing", "Folding & Packing", "Utility & Services", "HR & Administration", "Knotting", "Weaving", "Weaving", "Junior Staff", "Junior Staff", "HR & Administration", "HR & Administration", "Weaving", "HR & Administration", "Folding & Packing", "Junior Staff", "Folding & Packing", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Junior Staff", "Weaving", "Weaving", "Junior Staff", "HR & Administration", "Folding & Packing", "Folding & Packing", "Knotting", "Folding & Packing", "Weaving", "HR & Administration", "Utility & Services", "Folding & Packing", "Folding & Packing", "Weaving", "Folding & Packing", "HR & Administration", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Utility & Services", "Utility & Services", "Folding & Packing", "Weaving", "Folding & Packing", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Production Technical", "Weaving", "HR & Administration", "HR & Administration", "Weaving", "Utility & Services", "HR & Administration", "Folding & Packing", "Folding & Packing", "Folding & Packing", "HR & Administration", "Knotting", "Utility & Services", "Weaving", "Weaving", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Folding & Packing", "HR & Administration", "HR & Administration", "HR & Administration", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Sizing", "Sizing", "Weaving", "Weaving", "HR & Administration", "Knotting", "Weaving", "HR & Administration", "Utility & Services", "Utility & Services", "Folding & Packing", "Weaving", "HR & Administration", "HR & Administration", "Weaving", "Weaving", "Knotting", "HR & Administration", "Utility & Services", "Utility & Services", "Knotting", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Weaving", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Weaving", "Knotting", "Folding & Packing", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Weaving", "Folding & Packing", "HR & Administration", "Weaving", "Accounts", "HR & Administration", "Weaving", "Weaving", "HR & Administration", "Folding & Packing", "HR & Administration", "Weaving", "Weaving", "Warping", "HR & Administration", "Folding & Packing", "HR & Administration", "Weaving", "Weaving", "Weaving", "Weaving", "HR & Administration", "Utility & Services", "Weaving", "HR & Administration", "HR & Administration", "Folding & Packing", "Drawing In", "Weaving", "Folding & Packing", "Sizing", "Weaving", "Knotting", "HR & Administration", "HR & Administration", "Weaving", "Junior Staff", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "Production Technical", "HR & Administration", "Accounts", "Accounts", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Other Staff", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Accounts", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "Production Store", "Production Store", "Production Store", "Production Store", "Production Store", "Production Store", "Production Store", "Laboratory", "Laboratory", "Laboratory", "Drawing In", "Drawing In", "Drawing In", "Drawing In", "Drawing In", "Winding", "Sizing", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Warping", "Junior Staff", "Sizing", "Sizing", "Sizing", "Winding", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Sizing", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Knotting", "Weaving", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Junior Staff", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Utility & Services", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Technical", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Technical", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Junior Staff", "Junior Staff", "Folding & Packing", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Junior Staff", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Junior Staff", "Junior Staff", "Folding & Packing", "Folding & Packing", "Junior Staff", "Folding & Packing", "Utility & Services", "Technical", "Junior Staff", "HR & Administration", "HR & Administration", "Warping", "Technical", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Knotting", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Weaving", "Junior Staff", "Folding & Packing", "Folding & Packing", "Other Staff", "Utility & Services", "Weaving", "Weaving", "Utility & Services", "HR & Administration", "HR & Administration", "Knotting", "Weaving", "Weaving", "Junior Staff", "HR & Administration", "HR & Administration", "Weaving", "Sizing", "Weaving", "Weaving", "Utility & Services", "HR & Administration", "Knotting", "Sizing", "Folding & Packing", "Weaving", "Weaving", "Warping", "Junior Staff", "Weaving", "Weaving", "Weaving", "Junior Staff", "Weaving", "Weaving", "Utility & Services", "Weaving", "Weaving", "Folding & Packing", "Folding & Packing", "Weaving", "Weaving", "Sizing", "Folding & Packing", "Weaving", "Folding & Packing", "Weaving", "Weaving", "Folding & Packing", "Weaving", "Weaving", "HR & Administration", "Weaving", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Folding & Packing", "Knotting", "Weaving", "Weaving", "Weaving", "Knotting", "Weaving", "Weaving", "Utility & Services", "Weaving", "HR & Administration", "Folding & Packing", "Utility & Services", "Folding & Packing", "Drawing In", "HR & Administration", "Weaving", "Weaving", "HR & Administration", "Electrical", "Technical", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "HR & Administration", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "Air Condition", "HR & Administration", "Blow Room & Card", "D.Simplex & Comber", "HR & Administration", "HR & Administration", "HR & Administration", "Blow Room & Card", "Electrical", "Blow Room & Card", "Blow Room & Card", "Ring Maintenance", "Electrical", "Air Condition", "Air Condition", "Autocone", "Ring", "Ring", "Air Condition", "Ring", "Autocone", "Ring", "Ring", "Ring", "HR & Administration", "Ring", "Autocone", "Autocone", "Autocone", "Electrical", "HR & Administration", "Air Condition", "Production Store", "Production Store", "D.Simplex & Comber", "Technical", "Electrical", "Air Condition", "Technical", "Autocone", "Electrical", "Electrical", "Electrical", "HR & Administration", "Air Condition", "Laboratory", "Ring", "Blow Room & Card", "Blow Room & Card", "Blow Room & Card", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Laboratory", "Laboratory", "Laboratory", "Blow Room & Card", "Air Condition", "Ring", "Laboratory", "HR & Administration", "Air Condition", "HR & Administration", "Air Condition", "HR & Administration", "Ring", "Laboratory", "Autocone", "Autocone", "Autocone", "Ring", "Ring", "Autocone", "Ring", "Ring Autocone", "Laboratory", "HR & Administration", "Autocone", "HR & Administration", "Air Condition", "HR & Administration", "Laboratory", "Blow Room & Card", "Laboratory", "Ring", "HR & Administration", "Ring", "Technical", "HR & Administration", "HR & Administration", "Air Condition", "Ring", "Laboratory", "Ring", "D.Simplex & Comber", "Laboratory", "Marketing", "D.Simplex & Comber", "Blow Room & Card", "Ring Maintenance", "Ring Maintenance", "Ring Maintenance", "Air Condition", "Ring", "Ring", "Ring", "Ring", "Blow Room & Card", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Blow Room & Card", "D.Simplex & Comber", "Blow Room & Card", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "Blow Room & Card", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Blow Room & Card", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "Blow Room & Card", "Blow Room & Card", "D.Simplex & Comber", "Ring", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "Laboratory", "Ring", "D.Simplex & Comber", "Blow Room & Card", "D.Simplex & Comber", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Autocone", "Autocone", "Ring", "Ring", "D.Simplex & Comber", "Ring", "D.Simplex & Comber", "Autocone", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "Autocone", "Ring", "Blow Room & Card", "Ring", "Blow Room & Card", "Blow Room & Card", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "D.Simplex & Comber", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Autocone", "Ring", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Ring", "D.Simplex & Comber", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Blow Room & Card", "Autocone", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Autocone", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Autocone", "D.Simplex & Comber", "Blow Room & Card", "Ring", "Ring", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "Blow Room & Card", "D.Simplex & Comber", "Ring", "Autocone", "D.Simplex & Comber", "Autocone", "Autocone", "D.Simplex & Comber", "Ring", "Autocone", "Autocone", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Ring Maintenance", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "D.Simplex & Comber", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Autocone", "Ring", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Autocone", "Ring", "Autocone", "Ring", "Ring", "Autocone", "D.Simplex & Comber", "Autocone", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "Blow Room & Card", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "Autocone", "D.Simplex & Comber", "D.Simplex & Comber", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Autocone", "Ring", "Autocone", "Blow Room & Card", "Autocone", "Autocone", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Autocone", "Autocone", "Ring", "Autocone", "Blow Room & Card", "Ring", "Autocone", "Autocone", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Autocone", "Ring", "Autocone", "Blow Room & Card", "Ring", "Ring", "D.Simplex & Comber", "Autocone", "Ring", "Ring", "Ring", "Autocone", "Ring", "Blow Room & Card", "Blow Room & Card", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Ring", "Autocone", "Autocone", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Ring", "D.Simplex & Comber", "Blow Room & Card", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Blow Room & Card", "Blow Room & Card", "Autocone", "Ring Maintenance", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Ring", "D.Simplex & Comber", "Ring", "Ring Maintenance", "Autocone", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "D.Simplex & Comber", "Autocone", "Autocone", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Autocone", "Ring", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "Ring", "Ring", "Autocone", "Blow Room & Card", "D.Simplex & Comber", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Autocone", "Ring", "Ring", "Ring", "Ring", "Ring", "Ring", "Utility & Services", "Blow Room & Card", "Ring", "Autocone", "D.Simplex & Comber", "Ring", "Ring", "Ring", "Ring", "Ring"]
  	department_list = department_list.uniq
		department_list.each do |single_item|
			Department.create(:name => single_item, :code => single_item, :is_active => true, :company_id => 1)
		end

		Department.all.each do |department|
			SubDepartment.create(:name => department.name, :code => department.code, :is_active => true, :company_id => 1, :department_id => department.id)
		end

		designation_list = ["Deputy Incharge", "Sr. Foreman", "Mills Manager", "Executive Director", "Sr. Foreman", "Sr. Foreman", "Asst. Foreman", "Sr. Foreman", "Sr. Foreman", "Sr. Mills Manager", "Foreman", "Foreman", "Foreman", "Sr. Technical Manager", "Sr. Foreman", "Asst. Foreman", "Technical Manager", "Asst. Foreman", "Asst. Foreman", "Sr. Foreman", "Deputy Incharge", "Sr. Foreman", "Foreman", "Asst. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. General Manager", "DGM", "Asst. Foreman", "Sr. Asst. Manager", "Sr. Asst. Manager", "Asst. Foreman", "Foreman", "Asst. Foreman", "Asst. Manager", "Asst. Manager", "Asst. Manager", "Sr. Mills Manager", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Foreman", "Sr. Foreman", "Foreman", "Floor Cleaner", "Asst. Fitter", "Floor Cleaner", "Floor Cleaner", "Officer", "Incharge", "Asst. Officer", "Store Keeper", "Accountant", "Asst. Accountant", "Asst. Accountant", "Baledar", "Baledar", "Sweeper", "Courier", "Sweeper", "Head Driver", "Head Mali", "Cook", "Cook", "Baledar", "Waste Sorter", "Baledar", "Sweeper", "Sweeper", "Baledar", "Driver", "Helper", "Driver", "Driver", "Driver", "Cook", "Driver", "Driver", "Driver", "Driver", "Plumber", "Supervisor", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Sr. Electrician", "Drawer", "Head Checker", "Head Checker", "Sr. Technician", "Quality Controller", "Sr. Operator", "Sr. Checker", "Sr. Technician", "Head Checker", "Head Checker", "Quality Planner", "Sizer", "Asst. Controller", "Sr. Checker", "Sr. Checker", "Sizer", "Sr. Technician", "Back Sizer", "Warper", "Sr. Checker", "Article Beam Gaiter", "Asst. Controller", "Head Checker", "Sizer", "Warper", "Sr. Technician", "Cloth Checker", "Sr. Checker", "Sizer", "Quality Controller", "Sr. Technician", "Cloth Checker", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Cloth Checker", "Sr. Technician", "Sr. Checker", "Warper", "Sr. Checker", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Back Sizer", "Warper", "Cloth Checker", "Sizer", "Cloth Checker", "Sr. Beam Gaiter", "Sr. Technician", "Technician", "Warper", "Sr. Technician", "Sr. Checker", "Sr. Technician", "Sr. Incharge", "Cloth Checker", "Cloth Checker", "Sr. Checker", "Article Beam Gaiter", "Sr. Checker", "Back Sizer", "Cloth Checker", "Back Sizer", "Sizer", "Sr. Checker", "Operator", "Cloth Checker", "Sizer", "Sizer", "Sr. Beam Gaiter", "Beam Gaiter", "Sr. Technician", "Sr. Beam Gaiter", "Asst. Controller", "Drawer", "Sr. Technician", "Cloth Checker", "Technician", "Sizer", "Sr. Electrician", "Sizer", "Sr. Checker", "Cloth Checker", "Sr. Technician", "Cloth Checker", "Beam Gaiter", "Warper", "Sr. Electrician", "Cloth Checker", "Beam Gaiter", "Sr. Technician", "Cloth Checker", "Warper", "Article Beam Gaiter", "Sr. Welder", "Asst. Controller", "Carpenter", "Beam Gaiter", "Cloth Checker", "Head Electrician", "Cloth Checker", "Article Beam Gaiter", "Cloth Checker", "Sr. Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Sr. Beam Gaiter", "Sizer", "Cloth Checker", "Article Beam Gaiter", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Operator", "Electrician", "Sr. Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Warper", "Sr. Technician", "Warper", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Beam Gaiter", "Sizer", "Beam Gaiter", "Beam Gaiter", "Warper", "Sr. Checker", "Warper", "Sr. Technician", "Sr. Beam Gaiter", "Sr. Welder", "Beam Gaiter", "Sr. Beam Gaiter", "Asst. Fitter", "Warper", "Asst. Electrician", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Head Checker", "Article Beam Gaiter", "Cloth Checker", "Cloth Checker", "Sr. Beam Gaiter", "Cloth Checker", "Cloth Checker", "Article Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Warper", "Back Sizer", "Back Sizer", "Beam Gaiter", "Beam Gaiter", "Warper", "Sr. Technician", "Warper", "Drawer", "Cloth Checker", "Cloth Checker", "Electrician", "Article Beam Gaiter", "Sr. Electrician", "Sr. Technician", "Beam Gaiter", "Sr. Beam Gaiter", "Sr. Technician", "Cloth Checker", "Sr. Technician", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Beam Gaiter", "Sr. Beam Gaiter", "Sr. Technician", "Sr. Technician", "Cloth Checker", "Sr. Beam Gaiter", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Asst. Fitter", "Electrician", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Warper", "Cloth Checker", "Asst. Fitter", "Sr. Checker", "Sr. Technician", "Warper", "Asst. Fitter", "Article Beam Gaiter", "Apprenntice", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Warper", "Asst. Fitter", "Drawer", "Electrician", "Cloth Checker", "Quality Planner", "Sr. Technician", "Asst. Fitter", "Sr. Beam Gaiter", "Cloth Checker", "Article Beam Gaiter", "Electrician", "Sr. Technician", "Asst. Fitter", "Article Beam Gaiter", "Sr. Technician", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Asst. Fitter", "Sr. Welder", "Article Beam Gaiter", "Article Beam Gaiter", "Asst. Fitter", "Beam Gaiter", "Electrician", "Asst. Fitter", "Asst. Fitter", "Back Sizer", "Back Sizer", "Asst. Fitter", "Article Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Sr. Technician", "Sr. Technician", "Asst. Fitter", "Cloth Checker", "Article Beam Gaiter", "Asst. Fitter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Drawer", "Drawer", "Beam Gaiter", "Beam Gaiter", "Supervisor", "Cloth Checker", "Beam Gaiter", "Warper", "Article Beam Gaiter", "Warper", "Warper", "Warper", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Article Beam Gaiter", "Beam Gaiter", "Article Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Warper", "Cloth Checker", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Back Sizer", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Back Sizer", "Beam Gaiter", "Cloth Checker", "Sr. Technician", "Beam Gaiter", "Asst. Fitter", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Warper", "Beam Gaiter", "Sr. Technician", "Article Beam Gaiter", "Cloth Checker", "Article Beam Gaiter", "Head Checker", "Beam Gaiter", "Asst. Fitter", "Sr. Technician", "Warper", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Cloth Checker", "Cloth Checker", "Sizer", "Beam Gaiter", "Beam Gaiter", "Sr. Technician", "Article Beam Gaiter", "Sr. Technician", "Asst. Fitter", "Supervisor", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Sr. Technician", "Back Sizer", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Beam Gaiter", "Warper", "Asst. Fitter", "Beam Gaiter", "Sr. Technician", "Beam Gaiter", "Sr. Beam Gaiter", "Asst. Fitter", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Floor Cleaner", "Weaver", "Packer", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Reacher", "Floor Cleaner", "Beam Gaiter", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Warping Boy", "Weaver", "Floor Cleaner", "Floor Cleaner", "Floor Cleaner", "Beam Cooli", "Weaver", "Weaver", "Packer", "Weaver", "Packer", "Weaver", "Weaver", "Mixing Man", "Warping Boy", "Floor Cleaner", "Weaver", "Packer", "Weaver", "Mixing Man", "Packer", "Cone Boy", "Floor Cleaner", "Weaver", "Weaver", "Floor Cleaner", "Mixing Man", "Warping Boy", "Weaver", "Beam Carrier", "Winder", "Packer", "Weaver", "Weaver", "Helper", "Winder", "Weaver", "Mixing Man", "Weaver", "Weaver", "Floor Cleaner", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Asst. Operator", "Weaver", "Helper", "Asst. Warper", "Helper", "Mixing Man", "Floor Cleaner", "Weaver", "Asst. Operator", "Weaver", "Mixing Man", "Floor Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Mixing Man", "Packer", "Packer", "Asst. Operator", "Packer", "Weaver", "Mixing Man", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Beam Carrier", "Weaver", "Winder", "Weaver", "Packer", "Warping Boy", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Packer", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Packer", "Weaver", "Weaver", "Beam Cooli", "Reacher", "Helper", "Weaver", "Warping Boy", "Reacher", "Weaver", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Beam Cooli", "Helper", "Cone Boy", "Weaver", "Warping Boy", "Floor Cleaner", "Packer", "Helper", "Asst. Operator", "Weaver", "Weaver", "Weaver", "Weaver", "Asst. Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Asst. Warper", "Weaver", "Asst. Operator", "Mixing Man", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Cooli", "Mixing Man", "Mixing Man", "Weaver", "Asst. Operator", "Asst. Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Asst. Operator", "Packer", "Weaver", "Helper", "Weaver", "Asst. Warper", "Cone Boy", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Mixing Man", "Weaver", "Beam Cooli", "Asst. Warper", "Asst. Operator", "Asst. Weaver", "Weaver", "Warping Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Asst. Operator", "Warping Boy", "Weaver", "Weaver", "Floor Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Helper", "Weaver", "Weaver", "Warping Boy", "Weaver", "Asst. Operator", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Mixing Man", "Cone Boy", "Helper", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Packer", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Packer", "Weaver", "Weaver", "Helper", "Cone Boy", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Cooli", "Weaver", "Weaver", "Warping Boy", "Asst. Operator", "Machine Cleaner", "Weaver", "Packer", "Weaver", "Weaver", "Warping Boy", "Weaver", "Cone Boy", "Weaver", "Asst. Operator", "Asst. Operator", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Warping Boy", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Warping Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Floor Cleaner", "Beam Cooli", "Weaver", "Weaver", "Beam Cooli", "Cone Boy", "Cone Boy", "Weaver", "Helper", "Helper", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Machine Cleaner", "Winder", "Winder", "Cone Boy", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Winder", "Cone Boy", "Machine Cleaner", "Weaver", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Asst. Weaver", "Warping Boy", "Packer", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Mixing Man", "Warping Boy", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Cone Boy", "Asst. Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Warping Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Weaver", "Asst. Operator", "Cone Boy", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Cloth Carrier", "Weaver", "Beam Carrier", "Cone Boy", "Weaver", "Beam Cooli", "Weaver", "Weaver", "Helper", "Weaver", "Cloth Carrier", "Weaver", "Machine Cleaner", "Cone Boy", "Weaver", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Cone Boy", "Cone Boy", "Weaver", "Cloth Carrier", "Weaver", "Beam Carrier", "Machine Cleaner", "Weaver", "Beam Cooli", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Cloth Carrier", "Cloth Carrier", "Weaver", "Asst. Weaver", "Helper", "Machine Cleaner", "Weaver", "Cloth Carrier", "Weaver", "Cone Boy", "Warping Boy", "Weaver", "Helper", "Weaver", "Asst. Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Helper", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Asst. Warper", "Weaver", "Machine Cleaner", "Beam Cooli", "Machine Cleaner", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Floor Cleaner", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Helper", "Machine Cleaner", "Helper", "Asst. Warper", "Machine Cleaner", "Mixing Man", "Weaver", "Warping Boy", "Weaver", "Warping Boy", "Weaver", "Weaver", "Warping Boy", "Cone Boy", "Cloth Carrier", "Beam Cooli", "Beam Cooli", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Beam Cooli", "Cloth Carrier", "Weaver", "Cone Boy", "Cloth Carrier", "Weaver", "Weaver", "Beam Cooli", "Beam Cooli", "Beam Cooli", "Floor Cleaner", "Asst. Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Cone Boy", "Beam Cooli", "Cone Boy", "Weaver", "Machine Cleaner", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Beam Cooli", "Packer", "Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Warping Boy", "Warping Boy", "Cone Boy", "Weaver", "Cone Boy", "Helper", "Beam Cooli", "Weaver", "Cone Boy", "Weaver", "Winder", "Winder", "Winder", "Machine Cleaner", "Machine Cleaner", "Mixing Man", "Helper", "Weaver", "Weaver", "Weaver", "Winder", "Winder", "Winder", "Mixing Man", "Weaver", "Weaver", "Winder", "Winder", "Cone Boy", "Cone Boy", "Packer", "Machine Cleaner", "Winder", "Weaver", "Weaver", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Cone Boy", "Asst. Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Weaver", "Asst. Weaver", "Weaver", "Cloth Carrier", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Machine Cleaner", "Beam Cooli", "Weaver", "Weaver", "Beam Cooli", "Weaver", "Weaver", "Beam Cooli", "Weaver", "Weaver", "Reacher", "Weaver", "Cloth Carrier", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Machine Cleaner", "Packer", "Weaver", "Machine Cleaner", "Cone Boy", "Weaver", "Machine Cleaner", "Cone Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Packer", "Beam Carrier", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Asst. Weaver", "Weaver", "Machine Cleaner", "Helper", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Beam Cooli", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Machine Cleaner", "Machine Cleaner", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Asst. Operator", "Weaver", "Asst. Operator", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Packer", "Beam Carrier", "Weaver", "Machine Cleaner", "Cone Boy", "Beam Carrier", "Weaver", "Weaver", "Cone Boy", "Weaver", "Helper", "Asst. Weaver", "Cone Boy", "Warping Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Beam Carrier", "Weaver", "Packer", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Asst. Operator", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Machine Cleaner", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Helper", "Weaver", "Machine Cleaner", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Helper", "Cone Boy", "Beam Cooli", "Beam Cooli", "Weaver", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Beam Cooli", "Asst. Weaver", "Beam Cooli", "Beam Cooli", "Weaver", "Machine Cleaner", "Beam Carrier", "Beam Cooli", "Packer", "Machine Cleaner", "Beam Carrier", "Warping Boy", "Weaver", "Beam Cooli", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Asst. Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Asst. Weaver", "Weaver", "Weaver", "Cone Boy", "Machine Cleaner", "Machine Cleaner", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Beam Cooli", "Beam Cooli", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Warping Boy", "Weaver", "Weaver", "Beam Cooli", "Weaver", "Helper", "Weaver", "Warping Boy", "Weaver", "Weaver", "Helper", "Beam Cooli", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Cloth Carrier", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Packer", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Packer", "Weaver", "Weaver", "Machine Cleaner", "Helper", "Machine Cleaner", "Machine Cleaner", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Machine Cleaner", "Cone Boy", "Beam Carrier", "Weaver", "Cone Boy", "Packer", "Weaver", "Beam Carrier", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Reacher", "Weaver", "Packer", "Weaver", "Weaver", "Winder", "Weaver", "Cone Boy", "Machine Cleaner", "Weaver", "Machine Cleaner", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Packer", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Machine Cleaner", "Cone Boy", "Weaver", "Packer", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Cone Boy", "Helper", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Accountant", "Machine Cleaner", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Packer", "Machine Cleaner", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Packer", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Cone Boy", "Beam Carrier", "Weaver", "Packer", "Weaver", "Packer", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Machine Cleaner", "Weaver", "Packer", "Weaver", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Packer", "Cone Boy", "Packer", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Beam Carrier", "Weaver", "Asst. Weaver", "Weaver", "Machine Cleaner", "Weaver", "Cone Boy", "Machine Cleaner", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Floor Cleaner", "Cone Boy", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Machine Cleaner", "Beam Carrier", "Cone Boy", "Asst. Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Packer", "Weaver", "Beam Carrier", "Cone Boy", "Weaver", "Beam Carrier", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Packer", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Cone Boy", "Cone Boy", "Warping Boy", "Packer", "Packer", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Weaver", "Packer", "Cone Boy", "Warping Boy", "Packer", "Weaver", "Cone Boy", "Beam Carrier", "Weaver", "Asst. Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Packer", "Weaver", "Beam Carrier", "Weaver", "Packer", "Weaver", "Weaver", "Packer", "Packer", "Cone Boy", "Cone Boy", "Beam Carrier", "Asst. Weaver", "Beam Carrier", "Weaver", "Cone Boy", "Beam Cooli", "Machine Cleaner", "Weaver", "Weaver", "Cone Boy", "Beam Carrier", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Weaver", "Cloth Carrier", "Cone Boy", "Asst. Weaver", "Beam Carrier", "Cone Boy", "Weaver", "Weaver", "Weaver", "Asst. Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Packer", "Beam Carrier", "Cone Boy", "Weaver", "Beam Carrier", "Cone Boy", "Weaver", "Weaver", "Apprenntice", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Packer", "Weaver", "Weaver", "Weaver", "Cone Boy", "Packer", "Weaver", "Cone Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Beam Carrier", "Beam Carrier", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Packer", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Asst. Weaver", "Packer", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Mixing Man", "Beam Carrier", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Cone Boy", "Packer", "Weaver", "Cone Boy", "Weaver", "Packer", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Apprenntice", "Beam Carrier", "Weaver", "Cone Boy", "Cone Boy", "Packer", "Cone Boy", "Packer", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Packer", "Weaver", "Beam Carrier", "Cone Boy", "Packer", "Helper", "Sr. Foreman", "DGM", "Sr. Foreman", "Quality Planner", "Sr. Foreman", "Sr. Foreman", "Deputy Incharge", "Foreman", "Sr. Foreman", "DGM", "Sr. Foreman", "Sr. Technical Manager", "Foreman", "Foreman", "Foreman", "Foreman", "Asst. Foreman", "Deputy Incharge", "Foreman", "Sr. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Inspection", "Foreman", "Foreman", "Sr. General Manager", "Asst. Foreman", "Sr. Asst. Manager", "Foreman", "Asst. Foreman", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. Foreman", "Fireman", "Asst. Inspection", "DGM", "Asst. Foreman", "Sr. Foreman", "Floor Cleaner", "Floor Cleaner", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Packer", "Floor Cleaner", "Mixing Man", "Asst. Manager", "Asst. Officer", "Sr. Officer", "Accountant", "Sr. Officer", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Store Keeper", "Asst. Accountant", "Accountant", "Baledar", "Sweeper", "Imam Masjid", "Baledar", "Head Mason", "Sweeper", "Cook", "Sr. Driver", "Cook", "Driver", "Driver", "Baledar", "Driver", "Sweeper", "Driver", "Waste Sorter", "Driver", "Cook", "Office Boy", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Care Taker", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Sizer", "Head Checker", "Sr. Technician", "Quality Controller", "Head Electrician", "Sr. Technician", "Sr. Checker", "Head Checker", "Sizer", "Sizer", "Back Sizer", "Sizer", "Warper", "Sr. Technician", "Sr. Beam Gaiter", "Cloth Checker", "Sr. Technician", "Article Beam Gaiter", "Sr. Checker", "Sr. Technician", "Sr. Technician", "Head Electrician", "Warper", "Back Sizer", "Sr. Technician", "Sr. Beam Gaiter", "Warper", "Article Beam Gaiter", "Article Beam Gaiter", "Sr. Checker", "Beam Gaiter", "Sr. Checker", "Article Beam Gaiter", "Sr. Checker", "Sr. Checker", "Sr. Beam Gaiter", "Asst. Controller", "Sr. Checker", "Sr. Checker", "Sr. Technician", "Sr. Technician", "Sr. Checker", "Sr. Technician", "Article Beam Gaiter", "Warper", "Sr. Cutter Man", "Beam Gaiter", "Sizer", "Head Checker", "Asst. Fitter", "Sr. Technician", "Sizer", "Sr. Technician", "Sr. Beam Gaiter", "Back Sizer", "Sr. Technician", "Sr. Beam Gaiter", "Head Checker", "Sr. Technician", "Sr. Checker", "Warper", "Sr. Technician", "Sr. Checker", "Sr. Checker", "Warper", "Sr. Technician", "Sr. Checker", "Sr. Technician", "Drawer", "Cloth Checker", "Sr. Beam Gaiter", "Cloth Checker", "Sr. Checker", "Sr. Operator", "Electrician", "Cloth Checker", "Warper", "Apprenntice", "Sr. Checker", "Back Sizer", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Head Checker", "Sr. Technician", "Back Sizer", "Beam Gaiter", "Sr. Checker", "Cloth Checker", "Beam Gaiter", "Asst. Electrician", "Sizer", "Sr. Technician", "Warper", "Warper", "Sr. Technician", "Sr. Technician", "Sr. Beam Gaiter", "Beam Gaiter", "Asst. Fitter", "Warper", "Sr. Technician", "Sr. Technician", "Cloth Checker", "Drawer", "Drawer", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Back Sizer", "Back Sizer", "Article Beam Gaiter", "Cloth Checker", "Sr. Technician", "Article Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Asst. Electrician", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Sr. Technician", "Cloth Checker", "Asst. Fitter", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Beam Gaiter", "Asst. Fitter", "Asst. Fitter", "Beam Gaiter", "Beam Gaiter", "Asst. Fitter", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Warper", "Sr. Technician", "Warper", "Warper", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Warper", "Warper", "Warper", "Cloth Checker", "Apprenntice", "Asst. Fitter", "Cloth Checker", "Warper", "Warper", "Asst. Fitter", "Back Sizer", "Beam Gaiter", "Beam Gaiter", "Sizer", "Asst. Controller", "Sr. Technician", "Beam Gaiter", "Cloth Checker", "Article Beam Gaiter", "Cloth Checker", "Cloth Checker", "Head Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Sr. Technician", "Cloth Checker", "Sr. Technician", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Asst. Fitter", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Beam Gaiter", "Sr. Technician", "Head Checker", "Cloth Checker", "Back Sizer", "Sr. Technician", "Asst. Fitter", "Sr. Technician", "Sr. Technician", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Drawer", "Cloth Checker", "Sr. Technician", "Drawer", "Cloth Checker", "Cloth Checker", "Sr. Technician", "Drawer", "Cloth Checker", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Weaver", "Weaver", "Weaver", "Weaver", "Mixing Man", "Floor Cleaner", "Warping Boy", "Helper", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Packer", "Weaver", "Floor Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Asst. Warper", "Weaver", "Asst. Warper", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Mixing Man", "Cone Boy", "Cone Boy", "Mixing Man", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Floor Cleaner", "Warping Boy", "Weaver", "Weaver", "Asst. Warper", "Beam Cooli", "Weaver", "Weaver", "Helper", "Weaver", "Mixing Man", "Asst. Warper", "Weaver", "Mixing Man", "Packer", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Mixing Man", "Asst. Warper", "Beam Cooli", "Reacher", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Beam Carrier", "Cone Boy", "Asst. Warper", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Packer", "Helper", "Weaver", "Weaver", "Cone Boy", "Weaver", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Floor Cleaner", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Floor Cleaner", "Floor Cleaner", "Weaver", "Weaver", "Helper", "Weaver", "Packer", "Weaver", "Asst. Operator", "Weaver", "Floor Cleaner", "Reacher", "Weaver", "Helper", "Warping Boy", "Warping Boy", "Asst. Warper", "Weaver", "Mixing Man", "Warping Boy", "Weaver", "Packer", "Weaver", "Beam Carrier", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Floor Cleaner", "Weaver", "Weaver", "Packer", "Beam Cooli", "Warping Boy", "Asst. Operator", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Cone Boy", "Beam Carrier", "Reacher", "Weaver", "Weaver", "Weaver", "Cone Boy", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Helper", "Weaver", "Helper", "Weaver", "Weaver", "Helper", "Weaver", "Packer", "Machine Cleaner", "Machine Cleaner", "Mixing Man", "Beam Carrier", "Weaver", "Warping Boy", "Beam Cooli", "Cone Boy", "Packer", "Weaver", "Helper", "Weaver", "Weaver", "Cloth Carrier", "Cloth Carrier", "Cloth Carrier", "Machine Cleaner", "Weaver", "Beam Cooli", "Weaver", "Cone Boy", "Helper", "Weaver", "Helper", "Asst. Operator", "Weaver", "Helper", "Weaver", "Helper", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Cloth Carrier", "Weaver", "Helper", "Cone Boy", "Beam Carrier", "Weaver", "Weaver", "Cone Boy", "Weaver", "Beam Cooli", "Helper", "Cone Boy", "Weaver", "Cloth Carrier", "Weaver", "Helper", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Cone Boy", "Cone Boy", "Cloth Carrier", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Helper", "Weaver", "Helper", "Weaver", "Packer", "Weaver", "Cloth Carrier", "Cloth Carrier", "Weaver", "Cone Boy", "Cone Boy", "Machine Cleaner", "Weaver", "Asst. Operator", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Asst. Operator", "Helper", "Helper", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Packer", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Mixing Man", "Weaver", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Helper", "Beam Cooli", "Helper", "Weaver", "Weaver", "Helper", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Warping Boy", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Beam Cooli", "Beam Cooli", "Weaver", "Weaver", "Winder", "Weaver", "Cone Boy", "Winder", "Winder", "Weaver", "Winder", "Winder", "Weaver", "Winder", "Winder", "Weaver", "Weaver", "Weaver", "Winder", "Weaver", "Machine Cleaner", "Beam Cooli", "Weaver", "Helper", "Cone Boy", "Helper", "Beam Cooli", "Weaver", "Packer", "Floor Cleaner", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Asst. Operator", "Weaver", "Weaver", "Weaver", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Packer", "Packer", "Weaver", "Weaver", "Helper", "Warping Boy", "Machine Cleaner", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Warping Boy", "Mixing Man", "Weaver", "Helper", "Weaver", "Warping Boy", "Mixing Man", "Warping Boy", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Packer", "Weaver", "Weaver", "Weaver", "Weaver", "Warping Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Asst. Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Machine Cleaner", "Weaver", "Cone Boy", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Helper", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Helper", "Helper", "Weaver", "Machine Cleaner", "Packer", "Weaver", "Helper", "Weaver", "Helper", "Weaver", "Helper", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Weaver", "Machine Cleaner", "Machine Cleaner", "Helper", "Packer", "Packer", "Weaver", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Beam Cooli", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Helper", "Weaver", "Weaver", "Machine Cleaner", "Winder", "Machine Cleaner", "Beam Cooli", "Machine Cleaner", "Warping Boy", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Helper", "Helper", "Cone Boy", "Packer", "Weaver", "Machine Cleaner", "Cone Boy", "Machine Cleaner", "Beam Carrier", "Weaver", "Machine Cleaner", "Helper", "Warping Boy", "Cone Boy", "Weaver", "Beam Cooli", "Weaver", "Beam Cooli", "Weaver", "Warping Boy", "Warping Boy", "Helper", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Beam Cooli", "Cone Boy", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Cloth Carrier", "Mixing Man", "Weaver", "Packer", "Weaver", "Cone Boy", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Warping Boy", "Beam Carrier", "Packer", "Cone Boy", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Cone Boy", "Weaver", "Warping Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Reacher", "Cone Boy", "Weaver", "Warping Boy", "Weaver", "Packer", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Weaver", "Warping Boy", "Mixing Man", "Weaver", "Asst. Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Warping Boy", "Beam Cooli", "Weaver", "Weaver", "Weaver", "Packer", "Cone Boy", "Weaver", "Beam Cooli", "Warping Boy", "Helper", "Winder", "Cone Boy", "Winder", "Packer", "Cone Boy", "Warping Boy", "Warping Boy", "Warping Boy", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Packer", "Weaver", "Cone Boy", "Packer", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Beam Carrier", "Weaver", "Packer", "Weaver", "Cone Boy", "Packer", "Beam Carrier", "Weaver", "Weaver", "Asst. Weaver", "Warping Boy", "Packer", "Winder", "Packer", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Cone Boy", "Weaver", "Weaver", "Cone Boy", "Machine Cleaner", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Beam Carrier", "Weaver", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Mixing Man", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cloth Carrier", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Warping Boy", "Weaver", "Machine Cleaner", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Mixing Man", "Weaver", "Beam Carrier", "Weaver", "Weaver", "Weaver", "Warping Boy", "Beam Carrier", "Cone Boy", "Weaver", "Weaver", "Machine Cleaner", "Beam Carrier", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Mixing Man", "Mixing Man", "Weaver", "Beam Carrier", "Weaver", "Beam Carrier", "Weaver", "Packer", "Cone Boy", "Weaver", "Mixing Man", "Packer", "Packer", "Weaver", "Weaver", "Weaver", "Cone Boy", "Packer", "Weaver", "Weaver", "Warping Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Cone Boy", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Apprenntice", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Machine Cleaner", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Cone Boy", "Weaver", "Weaver", "Weaver", "Weaver", "Weaver", "Packer", "Weaver", "Cone Boy", "Weaver", "Weaver", "Warping Boy", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Cone Boy", "Cone Boy", "Weaver", "Cone Boy", "Weaver", "Weaver", "General Manager", "Shift Engineer", "Shift Engineer", "Asst. Electrician", "Cook", "Cook", "Shift Engineer", "General Manager", "Engineer", "Engineer", "Shift Engineer", "Shift Engineer", "Shift Engineer", "Engineer", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Cook", "Floor Cleaner", "Floor Cleaner", "Cleaner", "Cleaner", "Operator", "Manager", "Manager Processing", "Manager Processing", "Section Head", "Supervisor", "Electrician", "Shift Engineer", "Shift Engineer", "Shift Engineer", "Deputy Manager", "Supervisor", "Chef", "Electrician", "Electrician", "Watchman", "Supervisor", "Watchman", "Watchman", "Asst. Operator", "Sr. Supervisor", "Asst. Operator", "Supervisor", "Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Helper", "Helper", "Asst. Operator", "Warping Boy", "Foreman", "Associate", "Sr. Technician", "Helper", "Supervisor", "Asst. Operator", "Fitter", "Watchman", "Supervisor", "Cloth Inspector", "Helper", "Watchman", "Watchman", "Lab Head", "Sr. Supervisor", "Section Head", "Mixing Man", "Helper", "Sr. Electrician", "Asst. Electrician", "Electrician", "Watchman", "Asst. Operator", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Asst. Accountant", "Computer Operator", "Deputy Manager", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Watchman", "Computer Operator", "Helper", "Clerk", "Floor Cleaner", "Floor Cleaner", "Asst. Operator", "Helper", "Supervisor", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Helper", "Helper", "Stitcher", "Helper", "Helper", "Helper", "Helper", "Cloth Inspector", "Cloth Inspector", "Asst. Operator", "Trainee", "Sr. Checker", "Asst. Operator", "Asst. Operator", "Helper", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Mixing Man", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Helper", "Watchman", "Asst. Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Asst. Operator", "Trainee", "Asst. Operator", "Trainee", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Asst. Operator", "Cloth Inspector", "Cloth Inspector", "Computer Operator", "Asst. Technician", "Helper", "Shift Engineer", "Helper", "Helper", "Asst. Operator", "Helper", "Asst. Officer", "Helper", "Asst. Operator", "Helper", "Helper", "Office Boy", "Helper", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Cloth Inspector", "Asst. Operator", "Supervisor", "Helper", "Helper", "Stitcher", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Cloth Inspector", "Cloth Inspector", "Stitcher", "Helper", "Helper", "Supervisor", "Helper", "Data Color Operator", "Supervisor", "Supervisor", "Cloth Inspector", "Cloth Inspector", "Helper", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Asst. Operator", "Helper", "Asst. Fitter", "Asst. Operator", "Asst. Operator", "Helper", "Helper", "Helper", "Helper", "Cloth Inspector", "Asst. Operator", "Cloth Inspector", "Helper", "Asst. Operator", "Helper", "Cloth Inspector", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Associate", "Helper", "Asst. Operator", "Stitcher", "Cloth Inspector", "Computer Operator", "Helper", "Data Entry Operator", "Cloth Inspector", "Floor Cleaner", "Helper", "Helper", "Stitcher", "Washing Sup", "Helper", "Helper", "Trainee Operator", "Pattern Master", "Helper", "Helper", "Helper", "Stitcher", "Asst. Operator", "Cloth Inspector", "Helper", "Asst. Operator", "Helper", "Helper", "Associate", "Helper", "Cloth Inspector", "Sample Man", "Helper", "Stitcher", "Asst. Fitter", "Technologist", "Helper", "Shift Engineer", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Lab Technologist", "Cloth Inspector", "Helper", "Cloth Inspector", "Helper", "Helper", "Asst. Operator", "Helper", "Trainee", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Helper", "Mixing Man", "Trainee", "Helper", "Supervisor", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Stitcher", "Associate", "Fitter", "Shift Engineer", "Helper", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Cloth Inspector", "Helper", "Trainee", "Trainee", "Trainee", "Trainee", "Cloth Inspector", "Cloth Inspector", "Helper", "Helper", "Garment Washer", "Helper", "Helper", "Asst. Operator", "Technologist", "Associate", "Asst. Operator", "Helper", "Associate", "Helper", "Computer Operator", "Asst. Electrician", "Computer Operator", "Electrician", "Helper", "Trainee", "Helper", "Helper", "Supervisor", "Supervisor", "Helper", "Helper", "Helper", "Cloth Inspector", "Deputy Manager", "Helper", "Helper", "Trainee", "Helper", "Sample Man", "Helper", "Asst. Electrician", "Helper", "Mixing Man", "Asst. Operator", "Associate", "Helper", "Supervisor", "Garment Washer", "Asst. Operator", "Trainee", "Trainee", "Asst. Operator", "Trainee Operator", "Trainee", "Helper", "Sample Man", "Fitter", "Shift Engineer", "Cloth Inspector", "Helper", "Trainee", "Supervisor", "Cloth Inspector", "Trainee", "Fireman", "Helper", "MTO", "MTO", "Asst. Accountant", "Trainee", "Technologist", "Helper", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Helper", "Helper", "Warping Boy", "Helper", "Chef", "Helper", "Asst. Fitter", "Fitter", "Helper", "Helper", "Electrician", "Asst. Electrician", "Helper", "Helper", "Associate", "Cloth Inspector", "Helper", "Helper", "Helper", "Asst. Technician", "Sample Man", "Asst. Technician", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Helper", "Asst. Electrician", "Asst. Operator", "Helper", "Helper", "Helper", "Electrician", "Associate", "Watchman", "Watchman", "Watchman", "Asst. Operator", "Associate", "Office Boy", "Helper", "Asst. Operator", "Asst. Operator", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Asst. Operator", "Helper", "Asst. Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Manager", "Sweeper", "Electrician", "Helper", "Electrician", "Helper", "Cloth Inspector", "Helper", "Section Head", "Helper", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Helper", "Cloth Inspector", "Asst. Technician", "Asst. Technician", "Sr. Electrician", "Helper", "Helper", "Computer Operator", "Computer Operator", "Cloth Inspector", "Technologist", "Helper", "Helper", "Associate", "Fitter", "Associate", "Helper", "Helper", "Cloth Inspector", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Fitter", "Helper", "Helper", "Associate", "Helper", "Helper", "Helper", "Helper", "Supervisor", "Helper", "Technician", "Helper", "Helper", "Trainee Operator", "Helper", "Asst. Operator", "Merchandiser", "Supervisor", "Helper", "Helper", "Asst. Electrician", "Helper", "Electrician", "Helper", "Supervisor", "Floor Cleaner", "Supervisor", "Electrician", "Manager", "Asst. Manager", "Section Head", "Asst. Technician", "Supervisor", "Asst. Electrician", "Merchandiser", "Section Head", "Operator", "Supervisor", "Operator", "Floor Cleaner", "Asst. Supervisor", "Asst. Supervisor", "Supervisor", "Asst. Manager", "Asst. Manager", "Textile Engineer", "Marker Maker", "Quality Checker", "Quality Checker", "Operator", "Operator", "Supervisor", "Operator", "Incharge", "Sr. Electrician", "Operator", "Operator", "Head", "Pattern Maker", "Operator", "Operator", "Operator", "Spread Man", "Auditor", "Quality Checker", "Associate", "Quality Checker", "Supervisor", "Floor Cleaner", "Asst. Electrician", "Asst. Supervisor", "Asst. Manager", "Operator", "Operator", "Section Head", "Asst. Fitter", "Operator", "Operator", "Asst. Supervisor", "Operator", "Quality Checker", "Supervisor", "MTO", "Clerk", "Clerk", "Clerk", "Operator", "Asst. Manager", "Supervisor", "Helper", "Supervisor", "Supervisor", "Packer", "Final Checker", "Final Checker", "Helper", "Helper", "Final Checker", "Supervisor", "Helper", "Trimmer", "Trimmer", "Supervisor", "Packer", "Packer", "Measurement Checker", "Packer", "Trimmer", "Packer", "MTO", "Helper", "Final Checker", "Final Checker", "Packer", "Measurement Checker", "Presser", "Touching Man", "Loop Cutter", "Alter Man", "Trimmer", "Supervisor", "Loop Cutter", "Operator", "Packer", "Packer", "Clerk", "Presser", "Measurement Checker", "Final Checker", "Packer", "Packer", "Packer", "Packer", "Packer", "Packer", "Packer", "Supervisor", "Alter Man", "Sr. HR Assistant", "Operator", "Incharge", "Engineer", "Alter Man", "Darner", "Final Checker", "Final Checker", "Measurement Checker", "Operator", "Supervisor", "Asst. Operator", "Touching Man", "Asst. Operator", "Operator", "Operator", "Helper", "Operator", "Presser", "Asst. Clerk", "Presser", "Supervisor", "Operator", "Measurement Checker", "Presser", "Trimmer", "Final Checker", "Asst. Supervisor", "Quality Checker", "Associate", "Incharge", "Operator", "Operator", "Operator", "Asst. Supervisor", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Helper", "Operator", "Operator", "Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Numbering Man", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Computer Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Packer", "Helper", "Operator", "Clerk", "Helper", "Asst. Supervisor", "Quality Checker", "Darner", "Clerk", "Final Checker", "Operator", "Technician", "Operator", "Supervisor", "Carton Maker", "Touching Man", "Final Checker", "Operator", "Operator", "Packer", "Quality Checker", "Quality Checker", "Final Checker", "Operator", "Operator", "Operator", "Operator", "Incharge", "Operator", "Darner", "Helper", "Operator", "Operator", "Supervisor", "Operator", "Section Head", "Incharge", "Sr. Supervisor", "Manager", "Asst. Supervisor", "Incharge", "Trimmer", "Operator", "Trimmer", "Packer", "Packer", "Operator", "Touching Man", "Operator", "Operator", "Stain Remover", "Alter Man", "Alter Man", "Touching Man", "Electrician", "Operator", "Operator", "Operator", "Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Operator", "Asst. Supervisor", "Helper", "Operator", "Gate Keeper", "Helper", "Operator", "Operator", "Operator", "Card Man", "Operator", "Incharge", "Operator", "Helper", "Helper", "Helper", "Operator", "Auditor", "Auditor", "Auditor", "Auditor", "Auditor", "Auditor", "Foreman", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Auditor", "Operator", "Helper", "Auditor", "Operator", "Operator", "Incharge", "Section Head", "Helper", "Helper", "Helper", "Carton Maker", "Shade Master", "Operator", "Operator", "Supervisor", "Auditor", "Auditor", "Auditor", "Auditor", "Incharge", "Incharge", "Auditor", "Auditor", "Auditor", "Numbering Man", "Operator", "Presser", "Sr. Operator", "Operator", "Auditor", "Auditor", "Operator", "Operator", "Operator", "Incharge", "Operator", "Operator", "Operator", "Auditor", "Section Head", "Operator", "Operator", "Auditor", "Operator", "Operator", "Operator", "Trim Card Maker", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Supervisor", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Clerk", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Clerk", "Operator", "Operator", "Helper", "Operator", "Supervisor", "Auditor", "Clerk", "Operator", "Operator", "Operator", "Helper", "Operator", "Helper", "Operator", "Operator", "Final Checker", "Final Checker", "Operator", "Operator", "Operator", "Helper", "Operator", "Asst. Operator", "Auditor", "Helper", "Helper", "Technician", "Auditor", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Presser", "Helper", "Presser", "Touching Man", "Operator", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Supervisor", "Operator", "Helper", "Darner", "Helper", "Auditor", "Driver", "Operator", "Operator", "Operator", "Helper", "Asst. Supervisor", "Operator", "Helper", "Numbering Man", "Alter Man", "Numbering Man", "Helper", "Presser", "Trimmer", "Operator", "Operator", "Numbering Man", "Numbering Man", "Pattern Maker", "Operator", "Asst. Manager", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Operator", "Operator", "Operator", "Helper", "Clerk", "Operator", "Operator", "Presser", "Asst. Technician", "Operator", "Operator", "Asst. Manager", "Operator", "Coordinator", "Merchandiser", "Operator", "Operator", "Operator", "Auditor", "Auditor", "Operator", "Operator", "Operator", "Operator", "Helper", "Loader", "Helper", "Operator", "Helper", "Operator", "Touching Man", "Operator", "Operator", "Operator", "Technician", "Operator", "Helper", "Helper", "Fitter", "Operator", "Helper", "Operator", "Sr. Electrician", "Helper", "Helper", "Helper", "Helper", "Operator", "Operator", "Helper", "Operator", "Checker", "Trimmer", "Helper", "Operator", "Helper", "Operator", "Operator", "Touching Man", "Final Checker", "Final Checker", "Measurement Checker", "Operator", "Helper", "Fitter", "Sr. Operator", "Supervisor", "Operator", "Operator", "Operator", "Final Checker", "Measurement Checker", "Auditor", "Coordinator", "Auditor", "Helper", "Helper", "Operator", "Operator", "Auditor", "Operator", "Operator", "Helper", "Supervisor", "Supervisor", "Operator", "Operator", "Helper", "Operator", "Operator", "Helper", "Helper", "Supervisor", "Operator", "Operator", "Numbering Man", "Numbering Man", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Fitter", "Incharge", "Auditor", "Presser", "Auditor", "Operator", "Technician", "Carton Maker", "Packer", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Helper", "Operator", "Checker", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Operator", "Computer Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Computer Operator", "Trimmer", "Operator", "Presser", "Helper", "Computer Operator", "Helper", "Operator", "Helper", "Final Checker", "Operator", "Helper", "Operator", "Helper", "Helper", "Helper", "Helper", "Auditor", "Touching Man", "Operator", "Operator", "Operator", "Operator", "Touching Man", "Presser", "Helper", "Helper", "Helper", "Helper", "Helper", "Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Operator", "Helper", "Helper", "Operator", "Packer", "Operator", "Operator", "Operator", "Helper", "Operator", "MTO", "Operator", "Presser", "Computer Operator", "Final Checker", "Loop Cutter", "Packer", "Operator", "Operator", "Helper", "Touching Man", "Fitter", "Touching Man", "Alter Man", "Operator", "Packer", "Operator", "Operator", "Helper", "Helper", "Helper", "Helper", "Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Operator", "Supervisor", "Operator", "Helper", "Operator", "Operator", "Sr. Operator", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Helper", "Operator", "Helper", "Helper", "Operator", "Operator", "Operator", "Helper", "Operator", "Asst. Supervisor", "Helper", "Packer", "Helper", "Helper", "Helper", "Operator", "MTO", "Packer", "Packer", "Final Checker", "Operator", "Operator", "Operator", "Operator", "Presser", "Operator", "Operator", "Helper", "Operator", "Helper", "Helper", "Operator", "Operator", "Helper", "Operator", "Helper", "Computer Operator", "Helper", "Helper", "Helper", "Helper", "Operator", "Helper", "Operator", "Asst. Supervisor", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Darner", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Supervisor", "Pattern Master", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Section Head", "Helper", "Operator", "Asst. Manager", "Packer", "Packer", "Packer", "Technician", "Operator", "Operator", "Fitter", "Supervisor", "Operator", "Operator", "Operator", "Clerk", "Helper", "Helper", "Operator", "Final Checker", "Operator", "Operator", "Computer Operator", "Operator", "Helper", "Helper", "Operator", "Helper", "Helper", "Helper", "Operator", "Operator", "Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Operator", "Helper", "Helper", "Final Checker", "Alter Man", "Measurement Checker", "Auditor", "Technician", "Computer Operator", "Operator", "Carton Maker", "Operator", "Helper", "Helper", "Auditor", "Presser", "Technical Officer", "Operator", "Quality Checker", "Measurement Checker", "Alter Man", "Operator", "Operator", "Operator", "MTO", "Operator", "Computer Operator", "Operator", "Operator", "Helper", "Incharge", "Helper", "Auditor", "Auditor", "Presser", "Quality Checker", "Quality Checker", "Operator", "Operator", "Measurement Checker", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Presser", "Measurement Checker", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Incharge", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Helper", "Operator", "Operator", "Operator", "Quality Checker", "Operator", "Helper", "Clerk", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Supervisor", "Operator", "Measurement Checker", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Computer Operator", "Clerk", "Helper", "Touching Man", "Operator", "Packer", "Operator", "Operator", "Clerk", "Operator", "Operator", "Operator", "Operator", "Operator", "Packer", "Operator", "Helper", "Operator", "Helper", "Operator", "Operator", "Helper", "Operator", "Quality Checker", "Operator", "Operator", "Operator", "Operator", "Helper", "Helper", "Operator", "Operator", "Asst. Supervisor", "Helper", "Helper", "Operator", "Helper", "Marker Maker", "Packer", "Operator", "Asst. Manager", "Trimmer", "Helper", "Operator", "Operator", "Final Checker", "Helper", "Presser", "Final Checker", "Operator", "Operator", "Helper", "Technical Officer", "Helper", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Auditor", "Operator", "Auditor", "Operator", "Packer", "Helper", "Operator", "Operator", "Helper", "Helper", "Helper", "Operator", "Helper", "Operator", "Operator", "Operator", "Packer", "Operator", "Auditor", "Trainee", "Technical Officer", "Operator", "Card Man", "Helper", "Carton Maker", "Watchman", "Computer Operator", "Packer", "Trainee Operator", "Trainee Operator", "Helper", "Helper", "Presser", "Quality Checker", "Alter Man", "Darner", "Operator", "Operator", "Loop Cutter", "Alter Man", "Alter Man", "Trainee Operator", "Operator", "Presser", "Operator", "Operator", "Fitter", "Helper", "Operator", "Trainee Operator", "Operator", "Trainee Operator", "Operator", "Auditor", "Darner", "Helper", "Measurement Checker", "Touching Man", "Final Checker", "Measurement Checker", "Final Checker", "Alter Man", "Packer", "Packer", "Operator", "Packer", "Final Checker", "Alter Man", "Packer", "Helper", "Operator", "Trimmer", "Helper", "Helper", "Presser", "Trimmer", "Loop Cutter", "Packer", "Packer", "Shade Master", "Helper", "Trimmer", "Packer", "Packer", "Supervisor", "Supervisor", "Auditor", "Operator", "Operator", "Auditor", "Auditor", "Operator", "Stain Remover", "Packer", "Helper", "Measurement Checker", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Auditor", "Helper", "Presser", "Final Checker", "Presser", "Packer", "Packer", "Trimmer", "Measurement Checker", "Packer", "Packer", "Measurement Checker", "Operator", "Supervisor", "Touching Man", "Presser", "Trimmer", "Final Checker", "Final Checker", "Operator", "Final Checker", "Operator", "Operator", "Auditor", "Clerk", "Final Checker", "Final Checker", "Helper", "Operator", "Operator", "Operator", "Trainee Operator", "Operator", "Trimmer", "Presser", "Presser", "Darner", "Measurement Checker", "Final Checker", "Touching Man", "Darner", "Operator", "Packer", "Helper", "Supervisor", "Operator", "Operator", "Operator", "Helper", "Trimmer", "Incharge", "Incharge", "Supervisor", "Final Checker", "Alter Man", "Alter Man", "Operator", "Operator", "Operator", "Operator", "Trimmer", "Helper", "Operator", "Trainee Operator", "Trainee Operator", "Operator", "Operator", "Helper", "Helper", "Operator", "Measurement Checker", "Presser", "Operator", "Final Checker", "Final Checker", "Packer", "Packer", "Operator", "Operator", "Operator", "Helper", "Trimmer", "Packer", "Helper", "Trainee Operator", "Trainee Operator", "Operator", "Trainee Operator", "Operator", "Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Alter Man", "Helper", "Operator", "Operator", "Final Checker", "Operator", "Alter Man", "Trainee Operator", "Trainee Operator", "Card Man", "Operator", "Final Checker", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Auditor", "Manager", "Trimmer", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Manager", "Operator", "Alter Man", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Final Checker", "Packer", "Packer", "Operator", "Floor Cleaner", "Operator", "Operator", "Operator", "Officer", "Packer", "Presser", "Helper", "Asst. Supervisor", "Store Keeper", "Supervisor", "Store Assistant", "Packer", "Carton Maker", "Packer", "Helper", "Operator", "Operator", "Operator", "Operator", "Carton Maker", "Operator", "Operator", "Operator", "Touching Man", "Tehnical Associate", "Operator", "Presser", "Operator", "Trainee Operator", "Supervisor", "Final Checker", "Packer", "Operator", "Operator", "Operator", "Checker", "Operator", "Operator", "Marker Maker", "Operator", "Trainee Operator", "Trainee Operator", "Operator", "Packer", "Helper", "Operator", "Helper", "Computer Operator", "Presser", "Operator", "Cashier", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Helper", "Helper", "Helper", "Helper", "Operator", "Trainee Operator", "Loop Cutter", "Helper", "Helper", "Electrician", "Helper", "Helper", "Presser", "Presser", "Marker Maker", "Technical Officer", "Operator", "Trimmer", "Helper", "Sweeper", "Operator", "Checker", "Helper", "Operator", "Measurement Checker", "Packer", "Manager", "Sr. Manager", "Manager", "Section Head", "Foreman", "Fitter", "Fitter", "Section Head", "Engineer", "Supervisor", "Asst. Manager", "Engineer", "Engineer", "Manager", "Foreman", "Helper", "Sr. Electrician", "Electrician", "Incharge", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Supervisor", "Sr. Operator", "Asst. Supervisor", "Asst. Operator", "Sr. Supervisor", "Technician", "Sr. Manager", "Asst. Supervisor", "Asst. Supervisor", "Asst. Supervisor", "Sr. Operator", "Incharge", "Fitter", "Fitter", "Fitter", "Fitter", "Asst. Supervisor", "Asst. Operator", "Asst. Operator", "Operator", "Auditor", "Technician", "Operator", "Creal Boy", "Foreman", "Associate", "Technician", "Sr. Technician", "Asst. Supervisor", "Sr. HR Assistant", "Sr. Operator", "Asst. Supervisor", "Supervisor", "Asst. Operator", "Asst. Supervisor", "Operator", "Operator", "Cloth Inspector", "Watchman", "Operator", "Auditor", "Head", "Incharge", "Sr. Operator", "Asst. Operator", "Clerk", "Sr. Electrician", "Operator", "Operator", "Operator", "Asst. Manager", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Supervisor", "Supervisor", "Deputy Manager", "Sr. Operator", "Dispatcher", "Operator", "Operator", "Operator", "Operator", "Operator", "Manager", "Clerk", "Incharge", "Helper", "Floor Cleaner", "Operator", "Supervisor", "Sr. Operator", "Incharge", "Supervisor", "Operator", "Asst. Operator", "Operator", "Incharge", "Sr. Operator", "Asst. Manager", "Supervisor", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Operator", "Asst. Manager", "Operator", "Operator", "Asst. Supervisor", "Operator", "Operator", "Sr. Operator", "Sr. Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Sr. Operator", "Asst. Operator", "Sr. Operator", "Asst. Operator", "Technician", "Operator", "Asst. Operator", "Mixing Man", "Sr. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Operator", "Sr. Operator", "Deputy Manager", "Incharge", "Asst. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Asst. Operator", "Operator", "Trainee", "Deputy Manager", "Operator", "Supervisor", "Asst. Operator", "Operator", "Cloth Inspector", "Computer Operator", "Technician", "Operator", "Asst. Operator", "Deputy Manager", "Asst. Officer", "Asst. Operator", "Office Boy", "Sr. Operator", "Operator", "Sr. Supervisor", "Cloth Inspector", "Operator", "Supervisor", "Helper", "Operator", "Asst. Technician", "Operator", "Mixing Man", "Cloth Inspector", "Operator", "Incharge", "Auditor", "Sr. Supervisor", "Executive", "Auditor", "Supervisor", "Sr. Supervisor", "Operator", "Operator", "Helper", "Operator", "Operator", "Asst. Operator", "Associate", "Supervisor", "Asst. Fitter", "Asst. Operator", "Incharge", "Operator", "Cloth Inspector", "Asst. Operator", "Mixing Man", "Operator", "Cloth Inspector", "Asst. Operator", "Operator", "Asst. Operator", "Asst. Operator", "Associate", "Asst. Operator", "Operator", "Incharge", "Sr. Electrician", "Asst. Operator", "Sr. Operator", "Supervisor", "Floor Cleaner", "Supervisor", "Asst. Manager", "Incharge", "Operator", "Washing Sup", "Cloth Inspector", "Sr. Operator", "Operator", "Operator", "Asst. Manager", "Pattern Master", "Operator", "Operator", "Operator", "Asst. Operator", "Asst. Operator", "Operator", "Technician", "Asst. Colour Mixer", "Stitcher", "Asst. Fitter", "Record Keeper", "Technologist", "Cloth Inspector", "Engineer", "Operator", "Operator", "Supervisor", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Lab Technologist", "Cloth Inspector", "Helper", "Cloth Inspector", "Asst. Operator", "Operator", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Cloth Inspector", "Mixing Man", "Checker", "Cloth Inspector", "Incharge", "Supervisor", "Helper", "Helper", "Technician", "Helper", "Operator", "Asst. Colour Mixer", "Fitter", "Engineer", "Operator", "Asst. Operator", "Operator", "Checker", "Trainee", "Cloth Inspector", "Cloth Inspector", "Operator", "Helper", "Engineer", "Associate", "Asst. Operator", "Colour Mixer", "Helper", "Operator", "Operator", "Operator", "Incharge", "Operator", "Fireman", "Electrician", "Operator", "Supervisor", "Helper", "Helper", "Engineer", "Trainee", "Cloth Inspector", "Deputy Manager", "Helper", "Helper", "Helper", "Helper", "Asst. Electrician", "Mixing Man", "Asst. Operator", "Asst. Operator", "Helper", "Supervisor", "Checker", "Asst. Operator", "Operator", "Operator", "Incharge", "Colour Man", "Helper", "Engineer", "Operator", "Asst. Cloth Inspector", "Clerk", "Trainee", "Supervisor", "Incharge", "Technician", "Cloth Inspector", "Helper", "Colour Man", "MTO", "Asst. Accountant", "Technician", "Auditor", "Engineer", "Asst. Operator", "Operator", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Helper", "Operator", "Technician", "Creal Boy", "Chef", "Asst. Fitter", "Fitter", "Technician", "Helper", "Electrician", "Asst. Electrician", "Helper", "Associate", "Technician", "Cloth Inspector", "Supervisor", "Helper", "Helper", "Clerk", "Asst. Technician", "Supervisor", "Operator", "Sample Man", "Technician", "Helper", "Helper", "Asst. Operator", "Asst. Cloth Inspector", "Electrician", "Asst. Operator", "Helper", "Sr. Electrician", "Associate", "Associate", "Watchman", "Watchman", "Watchman", "Operator", "Associate", "Office Boy", "Helper", "Operator", "Electrician", "Operator", "Asst. Operator", "Helper", "Asst. Operator", "Sr. Operator", "Asst. Operator", "Asst. Operator", "Operator", "Asst. Operator", "Asst. Operator", "Operator", "Operator", "Helper", "Helper", "Helper", "Helper", "Helper", "Asst. Operator", "Sweeper", "Electrician", "Helper", "Electrician", "Supervisor", "Cloth Inspector", "HR Assistant", "Supervisor", "Operator", "Helper", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Asst. Cloth Inspector", "Asst. Technician", "Technician", "Operator", "Sr. Electrician", "Helper", "Dispatcher", "Operator", "Helper", "Operator", "Computer Operator", "Cloth Inspector", "Technologist", "Helper", "Operator", "Helper", "Associate", "Clerk", "Coordinator", "Associate", "Operator", "Operator", "Operator", "Helper", "Helper", "Operator", "Clerk", "Cloth Inspector", "Operator", "Asst. Operator", "Helper", "Asst. Operator", "Helper", "Operator", "Operator", "Fitter", "Helper", "Helper", "Clerk", "Associate", "Helper", "Helper", "Helper", "Helper", "Supervisor", "Helper", "Technician", "Clerk", "Helper", "Helper", "Asst. Operator", "Operator", "Operator", "Helper", "Asst. Operator", "Clerk", "Operator", "Helper", "Asst. Operator", "Asst. Cloth Inspector", "Associate", "Auditor", "Technician", "Asst. Cloth Inspector", "Sample Man", "Helper", "Helper", "Asst. Operator", "Operator", "Operator", "Helper", "Asst. Technician", "Supervisor", "Auditor", "Sr. General Manager", "Technical Manager", "Sr. Asst. Manager", "Incharge", "Helper", "Fitter", "Clerk", "Helper", "Helper", "Cloth Inspector", "Helper", "Helper", "Associate", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Quality Checker", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Helper", "HR Assistant", "Helper", "Helper", "Fitter", "Incharge", "Clerk", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Helper", "Operator", "Fitter", "Asst. Fitter", "Fireman", "Incharge", "Electrician", "Helper", "Creal Boy", "Helper", "Office Boy", "Creal Boy", "Creal Boy", "Associate", "Cloth Inspector", "Helper", "Clerk", "Helper", "Colour Mixer", "Helper", "Helper", "Cloth Inspector", "Helper", "Helper", "Asst. Operator", "Lab. Assistant", "Creal Boy", "Creal Boy", "Helper", "Cloth Inspector", "Cloth Inspector", "Helper", "Colour Mixer", "Operator", "Clerk", "Helper", "Associate", "Helper", "Technician", "Asst. Operator", "Asst. Technician", "Asst. Supervisor", "Mixing Man", "Helper", "Asst. Operator", "Sr. Engineer", "Associate", "Sr. Operator", "Asst. Operator", "Asst. Operator", "Asst. Operator", "Helper", "Trainee", "Helper", "Cloth Inspector", "Asst. Technician", "Helper", "Helper", "Helper", "Sample Man", "Helper", "Creal Boy", "Helper", "Cloth Inspector", "Clerk", "Cloth Inspector", "Cloth Inspector", "Helper", "Helper", "Helper", "MTO", "Operator", "Helper", "Helper", "Creal Boy", "Helper", "Helper", "Clerk", "Asst. Operator", "Clerk", "Operator", "Helper", "Helper", "Helper", "Helper", "Cloth Inspector", "Helper", "Associate", "Dispatcher", "Cloth Inspector", "Supervisor", "Helper", "Operator", "Operator", "Office Boy", "Helper", "Technician", "Helper", "Electrician", "Creal Boy", "Operator", "Clerk", "Helper", "Asst. Operator", "Helper", "Helper", "Creal Boy", "Asst. Operator", "Helper", "Trainee", "Creal Boy", "Helper", "Helper", "Asst. Operator", "Creal Boy", "Helper", "Creal Boy", "Creal Boy", "Creal Boy", "Helper", "Helper", "Helper", "Creal Boy", "Cloth Inspector", "Operator", "Helper", "Asst. Technician", "Driver", "Colour Man", "Helper", "Helper", "Asst. Cook", "Asst. Operator", "Operator", "Creal Boy", "Asst. Operator", "Creal Boy", "Care Taker", "Operator", "Operator", "Helper", "Operator", "Helper", "Helper", "Helper", "Asst. Operator", "Helper", "Helper", "Creal Boy", "Creal Boy", "Cloth Inspector", "Helper", "Helper", "Creal Boy", "Asst. Operator", "Dispatcher", "Asst. Operator", "Helper", "Asst. Operator", "Operator", "Helper", "Helper", "Operator", "Helper", "Associate", "Creal Boy", "Helper", "Floor Cleaner", "Helper", "Associate", "Asst. Operator", "Helper", "Asst. Operator", "Asst. Operator", "Operator", "Helper", "Helper", "HR Assistant", "Helper", "Helper", "Operator", "Operator", "Asst. Supervisor", "Helper", "Associate", "Computer Operator", "Electrician", "Associate", "Helper", "Creal Boy", "Dispatcher", "Helper", "Colour Man", "Helper", "Asst. Operator", "Manager", "Asst. Technician", "Operator", "Dispatcher", "Operator", "Operator", "Operator", "Helper", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Helper", "Helper", "Operator", "Helper", "Associate", "Dispatcher", "Helper", "Driver", "Creal Boy", "Helper", "Helper", "Operator", "Operator", "Floor Cleaner", "Helper", "Asst. Electrician", "Asst. Fitter", "Operator", "Associate", "Technician", "Helper", "Creal Boy", "Operator", "Creal Boy", "Helper", "Helper", "Asst. Operator", "Operator", "Clerk", "Operator", "Fitter", "Creal Boy", "Helper", "Quality Checker", "Electrician", "Electrician", "Asst. Electrician", "Clerk", "Clerk", "Clerk", "MTO", "Asst. Operator", "Helper", "Asst. Operator", "Operator", "Helper", "Creal Boy", "Helper", "Associate", "Helper", "Supervisor", "Helper", "Asst. Operator", "Floor Cleaner", "Creal Boy", "Associate", "Sr. Fireman", "Cloth Inspector", "Cloth Inspector", "Creal Boy", "Asst. Manager", "Trainee", "Fitter", "Helper", "Helper", "Incharge", "Helper", "Helper", "Electrician", "Trainee", "Operator", "Trainee", "Asst. Operator", "Incharge", "Fitter", "Cloth Inspector", "Watchman", "Asst. Operator", "Electrician", "Computer Operator", "Helper", "Helper", "Computer Operator", "Helper", "Creal Boy", "Colour Man", "Creal Boy", "Computer Operator", "Helper", "Asst. Operator", "Asst. Operator", "Helper", "Helper", "Creal Boy", "Creal Boy", "Technician", "Helper", "Cloth Inspector", "Clerk", "Asst. Technician", "Associate", "Cloth Inspector", "Computer Operator", "Asst. Operator", "Helper", "Helper", "Technician", "Technician", "Asst. Technician", "Operator", "Associate", "Cloth Inspector", "Helper", "Helper", "Creal Boy", "Helper", "Operator", "Computer Operator", "Asst. Technician", "Helper", "Operator", "Helper", "Supervisor", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Helper", "Helper", "Helper", "Helper", "Electrician", "Asst. Operator", "Clerk", "Trainee Operator", "Helper", "Asst. Supervisor", "Engineer", "Asst. Operator", "Clerk", "Cloth Inspector", "Cloth Inspector", "Associate", "Asst. Operator", "Operator", "Operator", "Clerk", "Helper", "Helper", "Cloth Inspector", "Cloth Inspector", "Helper", "Cloth Inspector", "Sr. Asst. Manager", "Cloth Inspector", "Accountant", "Associate", "Trainee Operator", "Associate", "Cloth Inspector", "Helper", "Cloth Inspector", "HR Assistant", "Asst. Operator", "Helper", "Helper", "Helper", "Asst. Fitter", "Incharge", "Helper", "Helper", "Helper", "Helper", "Operator", "Helper", "Dispenser", "MTO", "MTO", "Operator", "Fitter", "Sr. Operator", "Cloth Inspector", "Incharge", "Clerk", "Asst. Manager", "Asst. Operator", "Helper", "Sr. HR Assistant", "Trainee", "Asst. Operator", "Creal Boy", "Helper", "Cloth Inspector", "Fitter", "Helper", "Associate", "Helper", "Cloth Inspector", "Operator", "Operator", "Operator", "Associate", "Cashier", "Helper", "Helper", "Helper", "Associate", "Helper", "Helper", "Associate", "Dispatcher", "Helper", "Helper", "Technician", "Asst. Technician", "Associate", "Helper", "Creal Boy", "Helper", "Creal Boy", "Associate", "Associate", "Helper", "Asst. Operator", "Operator", "Executive Director", "Sr. Mills Manager", "Mills Manager", "Sr. Technical Manager", "Sr. Manager", "Sr. Asst. Manager", "Asst. Manager", "Asst. Manager", "Asst. Manager", "Asst. Officer", "Asst. Officer", "Asst. Officer", "Sr. HR Assistant", "Sr. HR Assistant", "Sr. Manager", "Sr. Accountant", "Accountant", "Asst. Accountant", "Officer", "Incharge", "Clerk", "Waste Sorter", "Engineer", "Sweeper", "Courier", "Sweeper", "Driver", "Cook", "Sweeper", "Driver", "Sr. Operator", "Cleaner", "Driver", "Cook", "Driver", "Plumber", "Supervisor", "Floor Cleaner", "Incharge", "Sr. Incharge", "Incharge", "Clerk", "Sr. Officer", "Supervisor", "Asst. Incharge", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Officer", "Head Mali", "Baledar", "Baledar", "Baledar", "Baledar", "Sr. Officer", "Asst. Incharge", "Incharge", "Store Keeper", "Sr. Incharge", "Incharge", "Clerk", "Sr. Incharge", "Asst. Incharge", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Sizer", "Sizer", "Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Sizer", "Operator", "Sizer", "Asst. Incharge", "Operator", "Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Sizer", "Back Sizer", "Sr. Foreman", "Foreman", "Technician", "Sr. Technician", "Technician", "Technician", "Sr. Foreman", "Foreman", "Drawer", "Drawer", "Drawer", "Drawer", "Drawer", "Asst. Foreman", "Supervisor", "Sr. Foreman", "Foreman", "Sr. Technician", "Technician", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Sr. Operator", "Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Incharge", "Asst. Incharge", "Incharge", "Incharge", "Incharge", "Incharge", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Incharge", "Sr. Beam Gaiter", "Incharge", "Incharge", "Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Incharge", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Incharge", "Beam Gaiter", "Incharge", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Sr. Beam Gaiter", "Incharge", "Incharge", "Incharge", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Sr. Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Sr. Foreman", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Technician", "Sr. Technician", "Article Beam Gaiter", "Sr. Technician", "Technician", "Sr. Technician", "Sr. Technician", "Technician", "Article Beam Gaiter", "Asst. Fitter", "Technician", "Sr. Technician", "Asst. Fitter", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. Technician", "Sr. Technician", "Article Beam Gaiter", "Sr. Technician", "Technician", "Technician", "Article Beam Gaiter", "Sr. Technician", "Technician", "Sr. Technician", "Sr. Technician", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Sr. Foreman", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. Technician", "Sr. Technician", "Article Beam Gaiter", "Sr. Technician", "Sr. Technician", "Article Beam Gaiter", "Technician", "Asst. Fitter", "Sr. Technician", "Asst. Fitter", "Sr. Technician", "Technician", "Technician", "Sr. Technician", "Technician", "Sr. Technician", "Article Beam Gaiter", "Article Beam Gaiter", "Sr. Technician", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Foreman", "Sr. Foreman", "Foreman", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Technician", "Technician", "Technician", "Article Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Technician", "Asst. Fitter", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Article Beam Gaiter", "Technician", "Quality Controller", "Quality Controller", "Quality Planner", "Asst. Controller", "Supervisor", "Supervisor", "Asst. Controller", "Supervisor", "Asst. Controller", "Asst. Controller", "Supervisor", "Asst. Controller", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Sr. Incharge", "Incharge", "Asst. Incharge", "Operator", "Sr. Incharge", "Incharge", "Asst. Incharge", "Clerk", "Sr. Incharge", "Incharge", "Sr. Incharge", "Incharge", "Clerk", "Clerk", "Deputy Incharge", "Deputy Incharge", "Foreman", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Head Checker", "Head Checker", "Sr. Operator", "Head Checker", "Operator", "Head Checker", "Sr. Checker", "Head Checker", "Sr. Operator", "Head Checker", "Cloth Checker", "Sr. Checker", "Operator", "Cutter Man", "Cloth Cutter", "Cloth Checker", "Cloth Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Operator", "Cloth Checker", "Operator", "Cloth Checker", "Sr. Checker", "Operator", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Cloth Checker", "Operator", "Sr. Checker", "Sr. Checker", "Operator", "Sr. Checker", "Asst. Incharge", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Operator", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Asst. Incharge", "Cloth Checker", "Cutter Man", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Engineer", "Foreman", "Asst. Foreman", "Sr. Technician", "Technician", "Technician", "Technician", "Sr. Foreman", "Asst. Foreman", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Engineer", "Sr. Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. Electrician", "Sr. Electrician", "Head Electrician", "Sr. Electrician", "Sr. Electrician", "Electrician", "Sr. Electrician", "Electrician", "Sr. Electrician", "Electrician", "Apprenntice", "Sr. Foreman", "Foreman", "Foreman", "Asst. Foreman", "Sr. Technician", "Sr. Technician", "Carpenter", "Sr. Technician", "Sr. Welder", "Sr. Welder", "Technician", "Asst. Foreman", "Technician", "Sr. Technician", "Operator", "Sr. Technician", "Technician", "Warper", "Cloth Cutter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Watchman", "Asst. Fitter", "Driver", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Technician", "Watchman", "Operator", "Beam Gaiter", "Technician", "Cloth Checker", "Cloth Checker", "Incharge", "Driver", "Sr. Technician", "Sr. Manager", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Beam Gaiter", "Cloth Checker", "Asst. Fitter", "Cloth Checker", "Beam Gaiter", "Beam Gaiter", "Cloth Checker", "Asst. Incharge", "Cloth Checker", "Cloth Checker", "Operator", "Cloth Checker", "Beam Gaiter", "Watchman", "Electrician", "Cloth Checker", "Cloth Checker", "Supervisor", "Cloth Checker", "Watchman", "Beam Gaiter", "Sr. Technician", "Clerk", "Cloth Checker", "Operator", "Beam Gaiter", "Cloth Checker", "Asst. Fitter", "Asst. Fitter", "Electrician", "Electrician", "Cloth Checker", "Asst. Fitter", "Cloth Checker", "Asst. Manager", "Engineer", "Officer", "Sr. Officer", "Manager", "Asst. Fitter", "Watchman", "Watchman", "Asst. Fitter", "Sr. Supervisor", "Operator", "Cloth Checker", "Operator", "Cloth Checker", "Supervisor", "Operator", "Asst. Fitter", "Foreman", "Asst. Fitter", "Supervisor", "Care Taker", "Asst. Fireman", "Baledar", "Imam Masjid", "Office Boy", "Cook", "Head Mason", "Cloth Checker", "Watchman", "Driver", "Driver", "Asst. Fitter", "Asst. Fitter", "Beam Gaiter", "Sr. Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Operator", "Asst. Fitter", "Asst. Fitter", "Beam Gaiter", "Watchman", "Operator", "Asst. Fitter", "Watchman", "Foreman", "Technician", "Clerk", "Technician", "Sr. Officer", "Incharge", "Asst. Fitter", "Asst. Fitter", "Operator", "Watchman", "Asst. Engineer", "Apprenntice", "Operator", "Watchman", "Watchman", "Watchman", "Watchman", "Incharge", "Watchman", "Beam Gaiter", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Beam Gaiter", "Operator", "Clerk", "Beam Gaiter", "Clerk", "Cloth Checker", "Asst. Fitter", "Technician", "Asst. Fitter", "Cloth Checker", "Supervisor", "Asst. Fitter", "Waste Sorter", "Watchman", "Beam Gaiter", "Asst. Fitter", "Watchman", "Cloth Checker", "Watchman", "Technician", "Beam Gaiter", "Warper", "Dispenser", "Clerk", "Watchman", "Asst. Fitter", "Beam Gaiter", "Technician", "Asst. Fitter", "HR Assistant", "Technician", "Asst. Fitter", "Plumber", "Watchman", "Clerk", "Drawer", "Sr. Technician", "Checker", "Sr. Incharge", "Sr. Technician", "Operator", "Watchman", "Watchman", "Technician", "Article Beam Gaiter", "Sr. General Manager", "DGM", "Sr. Technical Manager", "Manager", "Manager", "Deputy Manager", "Asst. Manager", "Accountant", "Accountant", "Asst. Officer", "Officer", "Incharge", "Sr. HR Assistant", "Engineer", "Officer", "Operator", "Sr. Officer", "Sr. Officer", "Sr. Incharge", "Incharge", "Clerk", "Baledar", "Baledar", "Baledar", "Cook", "Cook", "Sr. Driver", "Driver", "Driver", "Driver", "Head Mason", "Imam Masjid", "Office Boy", "Sweeper", "Waste Sorter", "Care Taker", "Helper", "Incharge", "Supervisor", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Watchman", "Sr. Officer", "Incharge", "Store Keeper", "Sr. Incharge", "Incharge", "Clerk", "Clerk", "Sr. Incharge", "Incharge", "Asst. Incharge", "Foreman", "Sr. Incharge", "Drawer", "Drawer", "Drawer", "Supervisor", "Sr. Incharge", "Sr. Incharge", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Warper", "Sr. Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Technician", "Technician", "Sr. Incharge", "Sizer", "Sizer", "Sizer", "Sizer", "Sizer", "Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Back Sizer", "Sr. Foreman", "Foreman", "Sr. Technician", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Operator", "Incharge", "Asst. Manager", "Sr. Foreman", "Foreman", "Asst. Foreman", "Head Electrician", "Head Electrician", "Sr. Electrician", "Sr. Electrician", "Sr. Electrician", "Sr. Electrician", "Sr. Electrician", "Apprenntice", "Electrician", "Engineer", "Foreman", "Asst. Foreman", "Sr. Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Sr. Foreman", "Foreman", "Asst. Foreman", "Sr. Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Asst. Engineer", "Foreman", "Engineer", "Foreman", "Sr. Supervisor", "Technician", "Incharge", "Incharge", "Sr. Foreman", "Sr. Foreman", "Sr. Foreman", "Foreman", "Foreman", "Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Asst. Foreman", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Sr. Technician", "Technician", "Sr. Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Technician", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Asst. Fitter", "Operator", "Incharge", "Incharge", "Incharge", "Incharge", "Incharge", "Incharge", "Incharge", "Incharge", "Article Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Sr. Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Article Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Beam Gaiter", "Quality Planner", "Quality Controller", "Supervisor", "Asst. Controller", "Supervisor", "Supervisor", "Supervisor", "Asst. Controller", "Asst. Controller", "Asst. Controller", "Supervisor", "Supervisor", "Sr. Incharge", "Incharge", "Clerk", "Sr. Incharge", "Deputy Incharge", "Deputy Incharge", "Deputy Incharge", "Asst. Inspection", "Asst. Foreman", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Clerk", "Head Checker", "Head Checker", "Head Checker", "Head Checker", "Head Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Sr. Checker", "Cloth Checker", "Sr. Checker", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Operator", "Sr. Cutter Man", "Cutter Man", "Cutter Man", "Operator", "Operator", "Operator", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Sr. Electrician", "Foreman", "Beam Gaiter", "Watchman", "Driver", "Warper", "Foreman", "Clerk", "Foreman", "Sr. Technician", "Cloth Checker", "Cloth Checker", "Cloth Checker", "Operator", "Asst. Foreman", "Cloth Checker", "Operator", "Cloth Checker", "Article Beam Gaiter", "Cloth Checker", "Cloth Checker", "Clerk", "Driver", "Technician", "Beam Gaiter", "Supervisor", "Technician", "Watchman", "Watchman", "Operator", "Supervisor", "Article Beam Gaiter", "Cloth Checker", "Watchman", "Watchman", "Sr. Technician", "Technician", "Sr. Technician", "Supervisor", "Technician", "Watchman", "Operator", "Technician", "Cloth Checker", "Asst. Fitter", "Sr. Foreman", "Warper", "Sr. Technician", "Sr. Technician", "Supervisor", "Beam Gaiter", "Operator", "Sr. Technician", "Asst. Fitter", "Electrician", "Supervisor", "Asst. Fitter", "Clerk", "Cloth Checker", "Asst. Fitter", "Beam Gaiter", "Technician", "Clerk", "Supervisor", "Clerk", "Sr. Technician", "Beam Gaiter", "Clerk", "Sr. Technician", "Technician", "Operator", "Beam Gaiter", "Clerk", "Cloth Checker", "Sr. Operator", "Sr. Operator", "Foreman", "Sr. Technician", "Sr. Technician", "Supervisor", "Sr. Technician", "Supervisor", "Supervisor", "Sr. Electrician", "Beam Gaiter", "Watchman", "Cloth Checker", "Technician", "Clerk", "Drawer", "Data Incharge", "Beam Gaiter", "Sr. Technician", "Watchman", "Head Electrician", "DGM", "Sr. Fireman", "Supervisor", "Watchman", "Watchman", "Watchman", "Operator", "Foreman", "Sr.Fitter", "Fitter", "Fitter", "Fitter", "Watchman", "Foreman", "Asst. Fitter", "Watchman", "Watchman", "Watchman", "Sr.Fitter", "Asst. Electrician", "Fitter", "Fitter", "Foreman", "Electrician", "Fitter", "Operator", "Fitter", "Fitter", "Asst. Fitter", "Operator", "Fitter", "Asst. Foreman", "Asst. Fitter", "Fitter", "Fitter", "Office Boy", "Asst. Fitter", "Fitter", "Fitter", "Asst. Fitter", "Motor Winder", "Excise Incharge", "Fitter", "Officer", "Store Assistant", "Fitter", "Sr.Spinning Manager", "Electrician", "Foreman", "Depty Spinning Manager", "Asst. Fitter", "Asst. Foreman", "Electrician", "Electrician", "Operator", "Fitter", "Clerk", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Supervisor", "Asst. Supervisor", "Asst. Supervisor", "Asst. Supervisor", "Asst. Supervisor", "Asst. Supervisor", "Operator", "Clerk", "Laboratory Clerk", "Fitter", "Clerk", "Fitter", "Warping Boy", "Incharge", "Clerk", "Clerk", "Clerk", "Excise Assistant", "Lycra Supervisor", "Warping Boy", "Cones Checker", "Cones Checker", "Cones Checker", "Lycra Supervisor", "Tap Man", "Asst. Supervisor", "Lycra Supervisor", "Asst. Supervisor", "Clerk", "HR Assistant", "Cones Checker", "HR Assistant", "Clerk", "HR Assistant", "Wrapping Boy", "Asst. Fitter", "Wrapping Boy", "Asst. Supervisor", "Asst. Incharge", "Asst. Fitter", "Spinning Manager", "Clerk", "Clerk", "Operator", "Asst. Supervisor", "Incharge", "Asst. Supervisor", "Fitter", "Clerk", "MTO", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Machine Cleaner", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "DDT", "Operator", "DST", "Cotton Feeder", "Doffer", "DDT", "DST", "DST", "DST", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Trolley Man", "Piecer", "Card Tenter", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "DDT", "DST", "Cotton Feeder", "Card Tenter", "DDT", "Piecer", "Piecer", "DST", "Doffer", "Lab. Helper", "Piecer", "Floor Cleaner", "Card Tenter", "DDT", "Card Tenter", "Doffer", "Doffer", "Floor Cleaner", "DST", "Doffer", "Piecer", "Piecer", "Piecer", "Operator", "Operator", "Piecer", "Piecer", "DDT", "Piecer", "Floor Cleaner", "Trolley Man", "Piecer", "DDT", "Doffer", "DST", "DST", "Operator", "Piecer", "Card Tenter", "Piecer", "Floor Cleaner", "Cotton Feeder", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Doffer", "DDT", "Doffer", "Cotton Feeder", "DDT", "DDT", "Card Tenter", "Doffer", "DDT", "Floor Cleaner", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Operator", "Piecer", "Piecer", "Floor Cleaner", "Doffer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Comber Tenter", "Piecer", "Card Tenter", "Operator", "Piecer", "Floor Cleaner", "Piecer", "Floor Cleaner", "Piecer", "Floor Cleaner", "Operator", "Piecer", "Operator", "Floor Cleaner", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Comber Tenter", "Operator", "DDT", "Cotton Feeder", "Piecer", "Piecer", "Cotton Feeder", "Doffer", "DDT", "Doffer", "DDT", "Piecer", "Trolley Man", "Floor Cleaner", "Operator", "Operator", "Doffer", "Piecer", "Operator", "Trolley Man", "Piecer", "Operator", "Piecer", "Floor Cleaner", "Floor Cleaner", "Piecer", "Piecer", "Piecer", "Doffer", "Machine Cleaner", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Floor Cleaner", "Operator", "DDT", "Piecer", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Floor Cleaner", "Piecer", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Doffer", "Piecer", "Piecer", "Piecer", "Trolley Man", "Operator", "Piecer", "DST", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Trolley Man", "Piecer", "Piecer", "Operator", "DST", "Trolley Man", "DST", "Piecer", "Piecer", "Piecer", "Floor Cleaner", "Card Tenter", "DDT", "Piecer", "Piecer", "Piecer", "Floor Cleaner", "Trolley Man", "Comber Tenter", "DST", "Floor Cleaner", "Piecer", "Piecer", "Comber Tenter", "Piecer", "Floor Cleaner", "Piecer", "Piecer", "Doffer", "Operator", "Piecer", "Trolley Man", "Card Tenter", "Operator", "Operator", "Piecer", "Piecer", "Piecer", "DDT", "Piecer", "Piecer", "Piecer", "Operator", "Operator", "Piecer", "Operator", "Cotton Feeder", "Piecer", "Operator", "Operator", "Floor Cleaner", "Operator", "Piecer", "Piecer", "Floor Cleaner", "Floor Cleaner", "Piecer", "Piecer", "DDT", "Operator", "Piecer", "Operator", "Comber Tenter", "Piecer", "Piecer", "DDT", "Operator", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Cotton Feeder", "Cotton Feeder", "Trolley Man", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Floor Cleaner", "Operator", "Operator", "Operator", "Piecer", "Floor Cleaner", "Floor Cleaner", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Floor Cleaner", "DST", "Machine Cleaner", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Cotton Feeder", "Floor Cleaner", "Operator", "Machine Cleaner", "Floor Cleaner", "Piecer", "Floor Cleaner", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Operator", "Piecer", "Piecer", "DST", "Piecer", "Machine Cleaner", "Operator", "Piecer", "Doffer", "DDT", "Operator", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "DDT", "Doffer", "Trolley Man", "Operator", "Piecer", "Operator", "Piecer", "Piecer", "Floor Cleaner", "Floor Cleaner", "DDT", "Piecer", "Piecer", "Floor Cleaner", "Operator", "Piecer", "Operator", "DST", "DST", "Floor Cleaner", "Piecer", "Operator", "Doffer", "DST", "DDT", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Trolley Man", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer", "Machine Cleaner", "Cotton Feeder", "Piecer", "Operator", "DDT", "Piecer", "Piecer", "Piecer", "Piecer", "Piecer"]
		designation_list = designation_list.uniq
			Grade.all.each do |grade|
			designation_list.each do |single_item|
				Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
			end
		end
  end

  # DataEntry.dfl_mill_may_attendance
  def self.dfl_mill_may_attendance
  	attendance_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/dfl_may_attendance.csv")
    attendance_data.each_with_index do |attendance_detail,index|
      employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
      if not employee.nil?
      	company = employee.company
      	if not company.nil?
      		if attendance_detail[:attendance_date].present?
      			if employee.joining_date.to_date <= attendance_detail[:attendance_date].to_date
		      		attendance_log = AttendanceMachineLog.new
				      attendance_log.employee_code = employee.employee_code
							attendance_log.machine_name = "Manual"
							attendance_log.attendance_datetime = attendance_detail[:attendance_date].to_datetime
							attendance_log.attendance_date = attendance_detail[:attendance_date].to_date
							attendance_log.actual_attendance_date = attendance_detail[:attendance_date]
							attendance_log.formatted_hour = attendance_detail[:attendance_date].to_datetime.hour
							attendance_log.formatted_minute = attendance_detail[:attendance_date].to_datetime.minute
							attendance_log.formatted_second = attendance_detail[:attendance_date].to_datetime.second
							attendance_log.log_id = "9999999999"
							attendance_log.employee_full_name = employee.full_name
							attendance_log.employee_id = employee.id
							attendance_log.company_id = employee.company_id
				    	attendance_log.save
				    end
			    end
      	end
      end
    end
  end

  # DataEntry.dfl_mill_denim_apparel_may_attendance
  def self.dfl_mill_denim_apparel_may_attendance
  	attendance_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/denim_apparel_may_attendance.csv")
    attendance_data.each_with_index do |attendance_detail,index|
      employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
      if not employee.nil?
      	company = employee.company
      	if not company.nil?
      		if attendance_detail[:attendance_date].present?
      			if employee.joining_date.to_date <= attendance_detail[:attendance_date].to_date
		      		attendance_log = AttendanceMachineLog.new
				      attendance_log.employee_code = employee.employee_code
							attendance_log.machine_name = "Manual"
							attendance_log.attendance_datetime = attendance_detail[:attendance_date].to_datetime
							attendance_log.attendance_date = attendance_detail[:attendance_date].to_date
							attendance_log.actual_attendance_date = attendance_detail[:attendance_date]
							attendance_log.formatted_hour = attendance_detail[:attendance_date].to_datetime.hour
							attendance_log.formatted_minute = attendance_detail[:attendance_date].to_datetime.minute
							attendance_log.formatted_second = attendance_detail[:attendance_date].to_datetime.second
							attendance_log.log_id = "9999999999"
							attendance_log.employee_full_name = employee.full_name
							attendance_log.employee_id = employee.id
							attendance_log.company_id = employee.company_id
				    	attendance_log.save
				    end
			    end
      	end
      end
    end
  end

  # DataEntry.dfl_employee_data
	def self.dfl_employee_data
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/dfl_employee_data.csv")
		count = 0
		employee_data.each do |single_item|

			grade_name = single_item[:grade]
			designation_name = single_item[:designation]
			department_name = single_item[:department]
			branch_name = single_item[:branch]
			location_name = single_item[:location]
			religion_name = single_item[:religion]
			
			grade = Grade.find_by_name(grade_name)
			designation = Designation.find_by(:name => designation_name, :grade_id => grade.id)
			department = Department.find_by_name(department_name)
			sub_department = SubDepartment.find_by_name(department_name)
			location = Location.find_by_name(location_name)
			branch = Branch.find_by_name(branch_name)
			religion = Religion.find_by_name(religion_name)

			company_id = 1
			location_id = location.id
			branch_id = branch.id
			department_id = department.id
			sub_department_id = sub_department.id
			grade_id = grade.id
			designation_id = designation.id
			salary_unit_id = 1
			cost_center_id = 1
			employee_type_id = 1

			salutation = "Mr."
			first_name = single_item[:employee_name]
			last_name = ""
			father_name = single_item[:father_name]
			
			gender = "Male"
			cnic_number = single_item[:cnic_number]
			if single_item[:blood_group] != "-"
				blood_group = single_item[:blood_group]	
			else
				blood_group = nil
			end
			gross_salary = single_item[:salary]

			create_login = false
			user_account_email = nil
			user_account_password = nil
			role_id = nil
			is_admin = false
			custom_right = false
			is_company_head = false
			is_location_head = false
			is_branch_head = false
			is_department_head = false

			date_of_birth = single_item[:date_of_birth].to_date
			joining_date = single_item[:date_of_joining].to_date
			confimration_due_date = joining_date + 3.month
			confirmation_date = confimration_due_date.to_date
			on_probation = false
			

			employee_code = single_item[:employee_code]
			current_address = single_item[:current_address]
			permanent_address = single_item[:current_address]

			count = count + 1
			puts "\n\n count => #{count} \n\n"
			Employee.create(:company_id => company_id, :location_id => location_id, :branch_id => branch_id, :department_id => department_id, :sub_department_id => sub_department_id, :grade_id => grade_id, :designation_id => designation_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :employee_type_id => employee_type_id, :salutation => salutation, :first_name => first_name, :last_name => last_name, :father_name => father_name, :gender => gender, :cnic_number => cnic_number, :blood_group => blood_group, :gross_salary => gross_salary, :create_login => create_login, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :date_of_birth => date_of_birth, :joining_date => joining_date, :confimration_due_date => confimration_due_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :employee_code => employee_code, :current_address => current_address, :permanent_address => permanent_address)
		end
	end

	# DataEntry.dfl_mill_may_roster
	def self.dfl_mill_may_roster
		attendance_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/dfl_may_attendance.csv")
		attendance_data.each_with_index do |attendance_detail,index|
			employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					worked_shift = attendance_detail[:worked_shift]
					if attendance_detail[:worked_shift] == "G"
						worked_shift = "G1"
					end
					time_slot = TimeSlot.find_by(:name => worked_shift, :location_id => employee.location_id, :branch_id => employee.branch_id)
					if not time_slot.nil?
						if attendance_detail[:attendance_date].present?
							if EmployeeRoster.where(:employee_id => employee.id, :roster_date => attendance_detail[:attendance_date].to_date).count == 0
								employee_roster = EmployeeRoster.new
								employee_roster.employee_id = employee.id
								employee_roster.company_id = employee.company_id
								employee_roster.location_id = employee.location_id
								employee_roster.branch_id = employee.branch_id
								employee_roster.department_id = employee.department_id
								employee_roster.grade_id = employee.grade_id
								employee_roster.joining_date = employee.joining_date.to_date
								employee_roster.roster_date = attendance_detail[:attendance_date].to_date
								employee_roster.employee_code = employee.employee_code
								employee_roster.employee_name = employee.full_name
								employee_roster.location_name = employee.location_name
								employee_roster.branch_name = employee.branch_name
								employee_roster.department_name = employee.department_name
								employee_roster.grade_name = employee.grade_name
								employee_roster.is_rest_day = true
								employee_roster.time_slot_id = time_slot.id
								employee_roster.is_flexi = time_slot.is_flexi
								employee_roster.start_time = time_slot.start_time
								employee_roster.end_time = time_slot.end_time
								employee_roster.formated_start_time = time_slot.actual_start_time
								employee_roster.formated_end_time = time_slot.actual_end_time
								employee_roster.start_buffer = time_slot.start_buffer
								employee_roster.end_buffer = time_slot.end_buffer
								employee_roster.save
							end
						end
					end
				end
			end
		end
		attendance_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/denim_apparel_may_attendance.csv")
		attendance_data.each_with_index do |attendance_detail,index|
			employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					worked_shift = attendance_detail[:worked_shift]
					if attendance_detail[:worked_shift] == "G"
						worked_shift = "G1"
					end
					time_slot = TimeSlot.find_by(:name => worked_shift, :location_id => employee.location_id, :branch_id => employee.branch_id)
					if not time_slot.nil?
						if attendance_detail[:attendance_date].present?
							if EmployeeRoster.where(:employee_id => employee.id, :roster_date => attendance_detail[:attendance_date].to_date).count == 0
								employee_roster = EmployeeRoster.new
								employee_roster.employee_id = employee.id
								employee_roster.company_id = employee.company_id
								employee_roster.location_id = employee.location_id
								employee_roster.branch_id = employee.branch_id
								employee_roster.department_id = employee.department_id
								employee_roster.grade_id = employee.grade_id
								employee_roster.joining_date = employee.joining_date.to_date
								employee_roster.roster_date = attendance_detail[:attendance_date].to_date
								employee_roster.employee_code = employee.employee_code
								employee_roster.employee_name = employee.full_name
								employee_roster.location_name = employee.location_name
								employee_roster.branch_name = employee.branch_name
								employee_roster.department_name = employee.department_name
								employee_roster.grade_name = employee.grade_name
								employee_roster.is_rest_day = true
								employee_roster.time_slot_id = time_slot.id
								employee_roster.is_flexi = time_slot.is_flexi
								employee_roster.start_time = time_slot.start_time
								employee_roster.end_time = time_slot.end_time
								employee_roster.formated_start_time = time_slot.actual_start_time
								employee_roster.formated_end_time = time_slot.actual_end_time
								employee_roster.start_buffer = time_slot.start_buffer
								employee_roster.end_buffer = time_slot.end_buffer
								employee_roster.save
							end
						end
					end
				end
			end
		end
	end

	# DataEntry.dfl_mill_denim_apparel_may_roster
	def self.dfl_mill_denim_apparel_may_roster
		attendance_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/denim_apparel_may_attendance.csv")
		attendance_data.each_with_index do |attendance_detail,index|
			employee = Employee.find_by_employee_code(attendance_detail[:employee_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					worked_shift = attendance_detail[:worked_shift]
					if attendance_detail[:worked_shift] == "G"
						worked_shift = "G1"
					end
					time_slot = TimeSlot.find_by(:name => worked_shift, :location_id => employee.location_id, :branch_id => employee.branch_id)
					if not time_slot.nil?
						if attendance_detail[:attendance_date].present?
							if EmployeeRoster.where(:employee_id => employee.id, :roster_date => attendance_detail[:attendance_date].to_date).count == 0
								employee_roster = EmployeeRoster.new
								employee_roster.employee_id = employee.id
								employee_roster.company_id = employee.company_id
								employee_roster.location_id = employee.location_id
								employee_roster.branch_id = employee.branch_id
								employee_roster.department_id = employee.department_id
								employee_roster.grade_id = employee.grade_id
								employee_roster.joining_date = employee.joining_date.to_date
								employee_roster.roster_date = attendance_detail[:attendance_date].to_date
								employee_roster.employee_code = employee.employee_code
								employee_roster.employee_name = employee.full_name
								employee_roster.location_name = employee.location_name
								employee_roster.branch_name = employee.branch_name
								employee_roster.department_name = employee.department_name
								employee_roster.grade_name = employee.grade_name
								employee_roster.is_rest_day = true
								employee_roster.time_slot_id = time_slot.id
								employee_roster.is_flexi = time_slot.is_flexi
								employee_roster.start_time = time_slot.start_time
								employee_roster.end_time = time_slot.end_time
								employee_roster.formated_start_time = time_slot.actual_start_time
								employee_roster.formated_end_time = time_slot.actual_end_time
								employee_roster.start_buffer = time_slot.start_buffer
								employee_roster.end_buffer = time_slot.end_buffer
								employee_roster.save
							end
						end
					end
				end
			end
		end
	end

	# DataEntry.dfl_ho_data_entry
	def self.dfl_ho_data_entry
		designation_list = ["Senior Manager", "Officer", "Record keeper", "Assistant Manager", "Deputy Manager", "Executive", "Deputy Manager", "Officer", "Officer", "Deputy Manager", "Officer", "Executive", "Executive", "General Manager", "Executive", "Assistant Officer", "Assistant Protocol", "Engineer", "Manager", "Courier", "Assistant Manager", "Officer", "Assistant Manager", "Officer", "Personal Assistant-Executive", "Assistant Manager", "Assistant Officer", "Chief Internal Auditor", "Assistant Manager", "Assistant Manager", "Assistant Manager", "Assistant Manager", "Assistant Manager", "Manager", "Courier", "Assistant Manager", "Senior Manager", "Manager", "Officer", "Officer", "Director", "Assistant Officer", "Officer", "Officer", "Officer", "Assistant Manager", "Officer", "Manager", "General Manager", "Sr. Assiatant Manager", "Deputy Manager", "Executive", "Executive", "MTO", "MTO", "MTO", "Assistant Manager", "Deputy Manager", "Officer", "Officer", "Officer", "Officer", "Officer", "Officer", "Assistant Manager", "Business Development Manager", "Officer", "Officer", "Assistant Manager", "Merchandising Manager", "Sr. Manager", "Sr. Assistant Manager", "MTO", "Computer Operator", "Assistant Manager", "MTO", "Assistant Manager", "Merchandisor", "Deputy Manager", "MTO", "Co-Ordinator", "Assistant Manager", "Courier", "Officer", "Manager", "Manager", "Officer", "Assistant Officer", "Business Application Manager", "Software Engineer", "Senior Software Engineer", "Software Engineer", "Executive", "Executive", "Executive", "Head", "Assistant Documentation", "Head", "Assistant Manager", "Officer", "Officer", "Tax Co-ordinator", "Project Director", "Assistant Manager", "Assistant Manager", "Officer", "General Manager", "Assistant Manager", "Executive", "Courier", "Commando Guard", "Commando Guard", "Commando Guard", "Commando Guard", "Cook", "Driver", "Driver", "Driver", "Driver", "Driver", "Driver", "Driver", "Driver", "Electrician", "Fax Operator", "Office Boy", "Office Boy", "Office Boy", "Office Boy", "Office Boy", "Security Guard", "Security Guard", "Security Guard", "Security Guard", "Security Guard", "Telephone Operator", "Assistant Accountant", "Executive", "Manager", "Office Boy", "Driver", "Assistant Manager", "Incharge", "Assistant Manager", "Head of Sales", "Manager", "Executive", "Assistant Manager", "HUB Executive"]
		designation_list = designation_list.uniq

		Grade.all.each do |grade|
			designation_list.each do |single_item|
				Designation.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true, :grade_id => grade.id)
			end
		end

		department_list = ["Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Accounts", "Import", "Accounts", "Accounts", "Administration", "Administration", "Administration", "Administration", "Civil", "Finance", "Finance", "Finance", "Insurance", "Human Resource", "Human Resource", "Administration", "Inernal Audit", "Internal Audit", "Internal Audit", "Accounts", "Internal Audit", "Internal Audit", "Marketing", "Marketing", "Marketing", "Export", "Marketing", "Marketing", "Marketing", "Marketing", "Export", "Marketing&Export", "Export", "Export", "Export", "Export", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Export", "Marketing", "Export", "Marketing", "Export", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "Export", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "PD & Design", "Marketing", "Marketing", "Marketing", "Marketing", "Marketing", "PD & Design", "Marketing", "Marekting", "Marketing", "Procurement", "MMC", "MMC", "MMC", "MMC", "MIS", "MIS", "MIS", "MIS", "MIS", "MIS", "MIS", "Purchase", "Purchase", "Purchase", "Purchase", "Sales Tax", "Sales Tax", "Sales Tax", "Sales Tax", "Technical", "Yarn Procurement", "Yarn Procurement", "Yarn Procurement", "Yarn Procurement", "Import", "Yarn Procurement", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Administration", "Accounts", "Accounts", "Accounts", "Administration", "Administration", "Farm", "Farm", "Sales", "Sales", "Operations", "Procurement", "R&D", "Sales"]
		department_list = department_list.uniq

		department_list.each do |single_item|
			Department.create(:company_id => 1, :name => single_item, :code => single_item, :description => single_item, :is_active => true)
		end

		Department.all.each do |department|
			SubDepartment.create(:name => department.name, :code => department.code, :is_active => true, :company_id => 1, :department_id => department.id)
		end

		job_title_list = ["Senior Manager", "Officer", "Record keeper", "Assistant Manager", "Deputy Manager", "Executive", "Deputy Manager", "Officer", "Officer", "Deputy Manager", "Officer", "Executive", "Executive", "General Manager", "Executive", "Assistant Officer", "Assistant Protocol", "Engineer", "Manager", "Courier", "Assistant Manager", "Officer", "Assistant Manager", "Officer", "Personal Assistant-Executive", "Assistant Manager", "Assistant Officer", "Chief Internal Auditor", "Assistant Manager", "Assistant Manager", "Assistant Manager", "Assistant Manager", "Assistant Manager", "Manager", "Courier", "Assistant Manager", "Senior Manager", "Manager", "Officer", "Officer", "Director", "Assistant Officer", "Officer", "Officer", "Officer", "Assistant Manager", "Officer", "Manager", "General Manager", "Sr. Assiatant Manager", "Deputy Manager", "Executive", "Executive", "MTO", "MTO", "MTO", "Assistant Manager", "Deputy Manager", "Officer", "Officer", "Officer", "Officer", "Officer", "Officer", "Assistant Manager", "Business Development Manager", "Officer", "Officer", "Assistant Manager", "Merchandising Manager", "Sr. Manager", "Sr. Assistant Manager", "MTO", "Computer Operator", "Assistant Manager", "MTO", "Assistant Manager", "Merchandisor", "Deputy Manager", "MTO", "Co-Ordinator", "Assistant Manager", "Courier", "Officer", "Manager", "Manager", "Officer", "Assistant Officer", "Business Application Manager", "Software Engineer", "Senior Software Engineer", "Software Engineer", "Executive", "Executive", "Executive", "Head", "Assistant Documentation", "Head", "Assistant Manager", "Officer", "Officer", "Tax Co-ordinator", "Project Director", "Assistant Manager", "Assistant Manager", "Officer", "General Manager", "Assistant Manager", "Executive", "Courier", "Commando Guard", "Commando Guard", "Commando Guard", "Commando Guard", "Cook", "Driver", "Driver", "Driver", "Driver", "Driver", "Driver", "Driver", "Driver", "Electrician", "Fax Operator", "Office Boy", "Office Boy", "Office Boy", "Office Boy", "Office Boy", "Security Guard", "Security Guard", "Security Guard", "Security Guard", "Security Guard", "Telephone Operator", "Assistant Accountant", "Executive", "Manager", "Office Boy", "Driver", "Assistant Manager", "Incharge", "Assistant Manager", "Head of Sales", "Manager", "Executive", "Assistant Manager", "HUB Executive"]
		job_title_list = job_title_list.uniq

		job_title_list.each do |single_item|
			JobTitle.create(:company_id => 1, :name => single_item, :description => single_item, :is_active => true)
		end

		program_list = ["CA Inter", "MBA", "Matric", "DAE", "Bcom+Diploma Accounting", "Bcom&PGD", "B.Com", "ACCA", "BBA(Hons)", "BA", "BTech", "Inter", "BCom", "MBA/MPhill", "Mcom/MPhill", "MPhill", "ACMA", "BSC", "CA Fianlist, CICA, FPFA,", "CA Finalist", "CA Finalist (5 papers left)", "Bcom", "Bs (Hons)", "Bcom IT,ACCA Pass 3 papers", "MCom", "BBA (Hons)", "BCS", "BSc Textile Eng.", "BS Textile Eng.", "BBA Agibusiness", "BCom (Hons)", "MBA+ACCA Finalist", "BBIT (Hons)", "B.Com+PGD", "BSc", "BSC(Hons)", "B.Com(Hons)", "BS", "MSC", "Bcom & PGD in MIS", "BSCS", "Bcom+SAP Certified", "B.A", "BCom      ", "M.Com", "Master in Chemical", "MCS & MBA", "BSc + ICMA Finalist", "Under Matric", "Middle", "Nill", "Primary", "ACCA -8 paper passed", "MSc (Hons)"]
		program_list = program_list.uniq

		program_list.each do |single_item|
			QualificationProgram.create(:name => single_item)
		end

		Branch.create(company_id: 1, location_id: 1, name: "Denim", code: "Denim", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 1, name: "Garments", code: "Garments", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 1, name: "Weaving", code: "Weaving", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 1, name: "Shared", code: "Shared", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 1, name: "Blank", code: "Blank", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)

		Branch.create(company_id: 1, location_id: 2, name: "Denim", code: "Denim", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 2, name: "Garments", code: "Garments", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 2, name: "Weaving", code: "Weaving", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 2, name: "Shared", code: "Shared", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 2, name: "Blank", code: "Blank", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)

		Branch.create(company_id: 1, location_id: 3, name: "Denim", code: "Denim", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 3, name: "Garments", code: "Garments", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 3, name: "Weaving", code: "Weaving", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 3, name: "Shared", code: "Shared", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 3, name: "Blank", code: "Blank", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)

		Branch.create(company_id: 1, location_id: 4, name: "Denim", code: "Denim", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 4, name: "Garments", code: "Garments", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 4, name: "Weaving", code: "Weaving", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 4, name: "Shared", code: "Shared", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
		Branch.create(company_id: 1, location_id: 4, name: "Blank", code: "Blank", description: nil, is_active: true, country_id: nil, state_id: nil, city_id: nil, employee_code_prefix: 0.0)
	end

	def self.dfl_ho_emaployee_data
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_ho_employee_data.csv")
		count = 0
		employee_data.each do |single_item|	
			grade_name = single_item[:grade_name]
			religion_name = single_item[:religion_name]
			designation_name = single_item[:designation_name]
			if single_item[:depatment_name] == "Inernal Audit"
			depatment_name = "Internal Audit"
			else
			department_name = single_item[:depatment_name]
			end
			location_name = single_item[:location_name]
			branch_name = single_item[:branch_name].capitalize
			employee_type_name = single_item[:employee_type_name]
			salary_unit_name = single_item[:salary_unit_name]
			cost_center_name = single_item[:cost_center_name].upcase

			grade = Grade.find_by_name(grade_name)
			religion = Religion.find_by_name(religion_name)
			designation = Designation.find_by(:name => designation_name, :grade_id => grade.id)
			job_title = JobTitle.find_by(:name => designation_name)
			department = Department.find_by_name(department_name)
			sub_department = SubDepartment.find_by_name(department_name)
			location = Location.find_by_name(location_name)
			branch = Branch.find_by(:name => branch_name, :location => location.id)
			employee_type = EmployeeType.find_by_name(employee_type_name)
			salary_unit = SalaryUnit.find_by_name(salary_unit_name)
			cost_center = CostCenter.find_by_name(cost_center_name)

			company_id = 1
			location_id = location.id
			branch_id = branch.id
			job_title_id = job_title.id

			if department.nil?
			department_id = nil
			else
			department_id = department.id	
			end

			if sub_department.nil?
			sub_department_id = nil
			else
			sub_department_id = sub_department.id
			end

			grade_id = grade.id
			designation_id = designation.id
			salary_unit_id = salary_unit.id
			cost_center_id = cost_center.id
			employee_type_id = employee_type.id
			if religion.nil?
			religion_id = nil
			else
			religion_id = religion.id	
			end


			employee_code = single_item[:employee_code]
			salutation = single_item[:salutation]
			first_name = single_item[:first_name]
			last_name = single_item[:last_name]
			father_name = single_item[:father_name]

			if not single_item[:cnic_number].nil?
			cnic_number = single_item[:cnic_number]	
			else
			cnic_number = "00000-0000000-0"
			end
			if single_item[:blood_group] != "-"
			blood_group = single_item[:blood_group]	
			else
			blood_group = nil
			end
			if single_item[:martial_status] != "-"
			martial_status = single_item[:martial_status]	
			else
			martial_status = nil
			end
			if single_item[:gender] != "-"
			gender = single_item[:gender]	
			else
			gender = nil
			end

			if single_item[:official_email] != "-"
			official_email = single_item[:official_email]	
			else
			official_email = nil
			end

			if single_item[:personal_email] != "-"
			personal_email = single_item[:personal_email]	
			else
			personal_email = nil
			end

			attendance_exempted = false
			if single_item[:attendance_exempted] == "Yes"
			attendance_exempted = true
			else
			attendance_exempted = false
			end

			create_login = false
			user_account_email = nil
			user_account_password = nil
			role_id = nil
			is_admin = false
			custom_right = false
			is_company_head = false
			is_location_head = false
			is_branch_head = false
			is_department_head = false

			date_of_birth = single_item[:date_of_birth].to_date
			joining_date = single_item[:joining_date].to_date
			if single_item[:confimration_due_date].nil?
			confimration_due_date = joining_date + 3.month
			confirmation_date = joining_date + 3.month
			on_probation = false
			else	
			confimration_due_date = single_item[:confimration_due_date].to_date
			confirmation_date = single_item[:confimration_due_date].to_date
			on_probation = false
			end

			if single_item[:employee_type_name] == "Contractual"
			confimration_due_date = joining_date + 3.month
			confirmation_date = joining_date + 3.month
			on_probation = false
			end

			current_country_id = 166
			current_address = single_item[:current_address]
			permanent_address = single_item[:permanent_address]
			emergency_contact_phone = single_item[:emergency_contact_name]
			personal_number = single_item[:personal_number]
			official_mobile_number = single_item[:official_mobile_number]

			count = count + 1
			puts "\n\n count => #{count} \n\n"

			Employee.create(:company_id => company_id, :location_id => location_id, :branch_id => branch_id, :department_id => department_id, :sub_department_id => sub_department_id, :grade_id => grade_id, :designation_id => designation_id, :job_title_id => job_title_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :employee_type_id => employee_type_id, :religion_id => religion_id, :employee_code => employee_code, :salutation => salutation, :first_name => first_name, :last_name => last_name, :father_name => father_name, :cnic_number => cnic_number, :blood_group => blood_group, :martial_status => martial_status, :gender => gender, :official_email => official_email, :personal_email => personal_email, :attendance_exempted => attendance_exempted, :create_login => create_login, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :date_of_birth => date_of_birth, :joining_date => joining_date, :confimration_due_date => confimration_due_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :current_country_id => current_country_id, :current_address => current_address, :permanent_address => permanent_address, :emergency_contact_phone => emergency_contact_phone, :personal_number => personal_number, :official_mobile_number => official_mobile_number)

		end
	end

	# DataEntry.dfl_ho_leave_balance
	def self.dfl_ho_leave_balance
		leave_year = LeaveYear.find 1
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_leave_balance.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s, :is_active => true)
			if not employee.nil?
				leave_type = LeaveType.find_by(:name => "Casual Leave", :location_id => employee.location_id)
				if not leave_type.nil?
					leave_allocation = LeaveAllocation.new    
					leave_allocation.company_id = 1
					leave_allocation.employee_id = employee.id
					leave_allocation.leave_type_id = leave_type.id
					leave_allocation.location_id = 2
					leave_allocation.leave_year_id = leave_year.id
					leave_allocation.leave_year_start_date = leave_year.start_date
					leave_allocation.leave_year_end_date = leave_year.end_date
					leave_allocation.is_active = true
					leave_allocation.allocated_quota = single_item[:cl_quota].to_f + single_item[:cl_used].to_f
					leave_allocation.used_quota = single_item[:cl_used]
					leave_allocation.remaining_quota = leave_allocation.allocated_quota - leave_allocation.used_quota
					if leave_allocation.save(:validate => false)
					  leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
					  if not leave_transaction.nil?
					    leave_transaction.leave_allocation_id = leave_allocation.id
					    leave_transaction.save
					  else
					  	LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Earned", "Allocated By System", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
					  end
					end
				end
			end
		end
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s, :is_active => true)
			if not employee.nil?
				leave_type = LeaveType.find_by(:name => "Sick Leave", :location_id => employee.location_id)
				if not leave_type.nil?
					leave_allocation = LeaveAllocation.new    
					leave_allocation.company_id = 1
					leave_allocation.employee_id = employee.id
					leave_allocation.leave_type_id = leave_type.id
					leave_allocation.location_id = 2
					leave_allocation.leave_year_id = leave_year.id
					leave_allocation.leave_year_start_date = leave_year.start_date
					leave_allocation.leave_year_end_date = leave_year.end_date
					leave_allocation.is_active = true
					leave_allocation.allocated_quota = single_item[:sl_quota]
					leave_allocation.remaining_quota = single_item[:sl_quota]
					leave_allocation.used_quota = 0.0
					if leave_allocation.save(:validate => false)
					  leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
					  if not leave_transaction.nil?
					    leave_transaction.leave_allocation_id = leave_allocation.id
					    leave_transaction.save
					  else
					  	LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Earned", "Allocated By System", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
					  end
					end
				end
			end
		end
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s, :is_active => true)
			if not employee.nil?
				leave_type = LeaveType.find_by(:name => "Compensatory Leave", :location_id => employee.location_id)
				if not leave_type.nil?
					leave_allocation = LeaveAllocation.new    
					leave_allocation.company_id = 1
					leave_allocation.employee_id = employee.id
					leave_allocation.leave_type_id = leave_type.id
					leave_allocation.location_id = 2
					leave_allocation.leave_year_id = leave_year.id
					leave_allocation.leave_year_start_date = leave_year.start_date
					leave_allocation.leave_year_end_date = leave_year.end_date
					leave_allocation.is_active = true
					leave_allocation.allocated_quota = single_item[:cpl_quota]
					leave_allocation.remaining_quota = single_item[:cpl_balance]
					leave_allocation.used_quota = single_item[:cpl_used]
					if leave_allocation.save(:validate => false)
					  leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
					  if not leave_transaction.nil?
					    leave_transaction.leave_allocation_id = leave_allocation.id
					    leave_transaction.save
					  else
					  	LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Earned", "Allocated By System", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
					  end
					end
				end
			end
		end
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s, :is_active => true)
			if not employee.nil?
				leave_type = LeaveType.find_by(:name => "Annual Leave", :location_id => employee.location_id)
				if not leave_type.nil?
					leave_allocation = LeaveAllocation.new    
					leave_allocation.company_id = 1
					leave_allocation.employee_id = employee.id
					leave_allocation.leave_type_id = leave_type.id
					leave_allocation.location_id = 2
					leave_allocation.leave_year_id = leave_year.id
					leave_allocation.leave_year_start_date = leave_year.start_date
					leave_allocation.leave_year_end_date = leave_year.end_date
					leave_allocation.is_active = true
					leave_allocation.allocated_quota = single_item[:al_quota]
					leave_allocation.remaining_quota = single_item[:al_quota]
					leave_allocation.used_quota = 0.0
					if leave_allocation.save(:validate => false)
					  leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
					  if not leave_transaction.nil?
					    leave_transaction.leave_allocation_id = leave_allocation.id
					    leave_transaction.save
					  else
					  	LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Earned", "Allocated By System", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
					  end
					end
				end
			end
		end
	end

	def self.dfl_employee_dependent
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_employee_dependent.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s)
			if not employee.nil?
				count = count + 1
				relationship_id = Relationship.find_by_name(single_item[:relation].titleize).id
				gender = "Male"
				relative_age = 0
				is_dependent = true

				if ["Wife", "Daughter"].include?(single_item[:relation].titleize) == true
				gender = "Female"
				else
				gender = "Male"
				end

				if single_item[:relation] = "Self"
				gender = employee.gender
				end

				if single_item[:date_of_birth].present?
				date_of_birth = single_item[:date_of_birth].to_date
				relative_age = Time.now.year - date_of_birth.year	
				else
				relative_age = 0
				date_of_birth = nil
				end

				employee_relative = EmployeeRelative.new
				employee_relative.employee_id = employee.id
				employee_relative.relative_name = single_item[:relative_name]
				employee_relative.relationship_id = relationship_id
				employee_relative.email = ""
				employee_relative.contact_number = ""
				employee_relative.gender = gender
				employee_relative.date_of_birth = date_of_birth
				employee_relative.date_of_enrollment = nil
				employee_relative.cnic_number = ""
				employee_relative.is_dependent = true
				employee_relative.address = ""
				employee_relative.insurance_allowed = true
				employee_relative.same_as_employee_address = false
				employee_relative.same_as_employee_permanent_address = false
				employee_relative.save

				puts "\n\n employee_id => #{employee_relative.employee_id} \n\n"
				puts "\n\n relative_name => #{employee_relative.relative_name} \n\n"
				puts "\n\n relationship_id => #{employee_relative.relationship_id} \n\n"
				puts "\n\n email => #{employee_relative.email} \n\n"
				puts "\n\n contact_number => #{employee_relative.contact_number} \n\n"
				puts "\n\n gender => #{employee_relative.gender} \n\n"
				puts "\n\n date_of_birth => #{employee_relative.date_of_birth} \n\n"
				puts "\n\n date_of_enrollment => #{employee_relative.date_of_enrollment} \n\n"
				puts "\n\n cnic_number => #{employee_relative.cnic_number} \n\n"
				puts "\n\n is_dependent => #{employee_relative.is_dependent} \n\n"
				puts "\n\n address => #{employee_relative.address} \n\n"
				puts "\n\n same_as_employee_address => #{employee_relative.same_as_employee_address} \n\n"
				puts "\n\n same_as_employee_permanent_address => #{employee_relative.same_as_employee_permanent_address} \n\n"

				next_of_kin = EmployeeNextOfKin.new
				next_of_kin.employee_id = employee.id
				next_of_kin.employee_relative_id = employee_relative.id
				next_of_kin.relationship_id = relationship_id
				next_of_kin.relative_age = relative_age
				next_of_kin.percentage = single_item[:percentage]
				next_of_kin.save

				puts "\n\n employee_id => #{next_of_kin.employee_id} \n\n"
				puts "\n\n employee_relative_id => #{next_of_kin.employee_relative_id} \n\n"
				puts "\n\n relationship_id => #{next_of_kin.relationship_id} \n\n"
				puts "\n\n relative_age => #{next_of_kin.relative_age} \n\n"
				puts "\n\n percentage => #{next_of_kin.percentage} \n\n"
			end
		end
	end

	def self.new_dfl_mill_employee_data
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_dfl_employee_data.csv")
		count = 0
		employee_data.each do |single_item|

			grade_name = single_item[:grade]
			designation_name = single_item[:designation]
			department_name = single_item[:department]
			branch_name = single_item[:branch]
			location_name = single_item[:location]
			religion_name = single_item[:religion]
			eobi_number = single_item[:eobi_number]

			is_active = true
			if single_item[:status].nil?
			is_active = true
			else
			is_active = false
			end

			grade = Grade.find_by_name(grade_name)
			designation = Designation.find_by(:name => designation_name, :grade_id => grade.id)
			department = Department.find_by_name(department_name)
			sub_department = SubDepartment.find_by_name(department_name)
			location = Location.find_by_name(location_name)
			branch = Branch.find_by(:name => branch_name, :location_id => location.id)
			religion = Religion.find_by_name(religion_name)

			company_id = 1
			location_id = location.id
			branch_id = branch.id
			department_id = department.id
			sub_department_id = sub_department.id
			grade_id = grade.id
			designation_id = designation.id
			salary_unit_id = 1
			cost_center_id = 1
			employee_type_id = 1
			religion_id = religion.id

			salutation = "Mr."
			first_name = single_item[:employee_name]
			last_name = ""
			father_name = single_item[:father_name]

			gender = "Male"
			cnic_number = single_item[:cnic_number]
			if single_item[:blood_group] != "-"
			blood_group = single_item[:blood_group]	
			else
			blood_group = nil
			end
			gross_salary = single_item[:salary]

			create_login = false
			user_account_email = nil
			user_account_password = nil
			role_id = nil
			is_admin = false
			custom_right = false
			is_company_head = false
			is_location_head = false
			is_branch_head = false
			is_department_head = false
			if single_item[:eobi_number] != "-"
			eobi_number = single_item[:eobi_number]	
			else
			eobi_number = "-"
			end

			date_of_birth = single_item[:date_of_birth].to_date
			joining_date = single_item[:date_of_joining].to_date
			confimration_due_date = joining_date + 3.month
			confirmation_date = confimration_due_date.to_date
			on_probation = false

			employee_code = single_item[:employee_code]
			current_address = single_item[:current_address]
			permanent_address = single_item[:current_address]

			count = count + 1
			puts "\n\n count => #{count} \n\n"

			puts "\n\n company_id => #{company_id} \n\n"
			puts "\n\n location_id => #{location_id} \n\n"
			puts "\n\n branch_id => #{branch_id} \n\n"
			puts "\n\n department_id => #{department_id} \n\n"
			puts "\n\n sub_department_id => #{sub_department_id} \n\n"
			puts "\n\n grade_id => #{grade_id} \n\n"
			puts "\n\n designation_id => #{designation_id} \n\n"
			puts "\n\n salary_unit_id => #{salary_unit_id} \n\n"
			puts "\n\n cost_center_id => #{cost_center_id} \n\n"
			puts "\n\n employee_type_id => #{employee_type_id} \n\n"
			puts "\n\n salutation => #{salutation} \n\n"
			puts "\n\n first_name => #{first_name} \n\n"
			puts "\n\n last_name => #{last_name} \n\n"
			puts "\n\n father_name => #{father_name} \n\n"
			puts "\n\n gender => #{gender} \n\n"
			puts "\n\n cnic_number => #{cnic_number} \n\n"
			puts "\n\n blood_group => #{blood_group} \n\n"
			puts "\n\n gross_salary => #{gross_salary} \n\n"
			puts "\n\n create_login => #{create_login} \n\n"
			puts "\n\n user_account_email => #{user_account_email} \n\n"
			puts "\n\n user_account_password => #{user_account_password} \n\n"
			puts "\n\n role_id => #{role_id} \n\n"
			puts "\n\n is_admin => #{is_admin} \n\n"
			puts "\n\n custom_right => #{custom_right} \n\n"
			puts "\n\n is_company_head => #{is_company_head} \n\n"
			puts "\n\n is_location_head => #{is_location_head} \n\n"
			puts "\n\n is_branch_head => #{is_branch_head} \n\n"
			puts "\n\n is_department_head => #{is_department_head} \n\n"
			puts "\n\n eobi_number => #{eobi_number} \n\n"
			puts "\n\n date_of_birth => #{date_of_birth} \n\n"
			puts "\n\n joining_date => #{joining_date} \n\n"
			puts "\n\n confimration_due_date => #{confimration_due_date} \n\n"
			puts "\n\n confirmation_date => #{confirmation_date} \n\n"
			puts "\n\n on_probation => #{on_probation} \n\n"
			puts "\n\n employee_code => #{employee_code} \n\n"
			puts "\n\n current_address => #{current_address} \n\n"
			puts "\n\n permanent_address => #{permanent_address} \n\n"
			puts "\n\n is_active => #{is_active} \n\n"
			puts "\n\n religion_id => #{religion_id} \n\n"

			Employee.create(:company_id => company_id, :location_id => location_id, :branch_id => branch_id, :department_id => department_id, :sub_department_id => sub_department_id, :grade_id => grade_id, :designation_id => designation_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :employee_type_id => employee_type_id, :salutation => salutation, :first_name => first_name, :last_name => last_name, :father_name => father_name, :gender => gender, :cnic_number => cnic_number, :blood_group => blood_group, :gross_salary => gross_salary, :create_login => create_login, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :eobi_number => eobi_number, :date_of_birth => date_of_birth, :joining_date => joining_date, :confimration_due_date => confimration_due_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :employee_code => employee_code, :current_address => current_address, :permanent_address => permanent_address, :is_active => is_active, :religion_id => religion_id)
		end
	end

	def self.new_dfl_mill_shift_data
		shift_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_dfl_mill_shift_data.csv")
		shift_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					worked_shift = single_item[:shift]
					time_slot = TimeSlot.find_by(:name => worked_shift, :location_id => employee.location_id, :branch_id => employee.branch_id)
					if not time_slot.nil?
						start_date = Time.now.beginning_of_month.to_date
						end_date = (Time.now. + 1.month).end_of_month.to_date
						date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
						date_range.each do |single_date|
							if EmployeeRoster.where(:employee_id => employee.id, :roster_date => single_date.to_date).count == 0
								employee_roster = EmployeeRoster.new
								employee_roster.employee_id = employee.id
								employee_roster.company_id = employee.company_id
								employee_roster.location_id = employee.location_id
								employee_roster.branch_id = employee.branch_id
								employee_roster.department_id = employee.department_id
								employee_roster.grade_id = employee.grade_id
								employee_roster.joining_date = employee.joining_date.to_date
								employee_roster.roster_date = single_date.to_date
								employee_roster.employee_code = employee.employee_code
								employee_roster.employee_name = employee.full_name
								employee_roster.location_name = employee.location_name
								employee_roster.branch_name = employee.branch_name
								employee_roster.department_name = employee.department_name
								employee_roster.grade_name = employee.grade_name
								if single_item.to_date.strftime("%A").upcase == single_item[:rest_day].upcase
									employee_roster.is_rest_day = true
								else
									employee_roster.is_rest_day = false				
								end
								employee_roster.time_slot_id = time_slot.id
								employee_roster.is_flexi = time_slot.is_flexi
								employee_roster.start_time = time_slot.start_time
								employee_roster.end_time = time_slot.end_time
								employee_roster.formated_start_time = time_slot.actual_start_time
								employee_roster.formated_end_time = time_slot.actual_end_time
								employee_roster.start_buffer = time_slot.start_buffer
								employee_roster.end_buffer = time_slot.end_buffer
								employee_roster.save
							end
						end
					end
				end
			end
		end
	end

	def self.updated_dfl_mill_shift_data
		shift_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/updated_nov_roster.csv")
		shift_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					worked_shift = single_item[:shift]
					time_slot = TimeSlot.find_by(:name => worked_shift, :location_id => employee.location_id, :branch_id => employee.branch_id)
					if not time_slot.nil?
						roster = EmployeeRoster.find_by(:employee_id => employee.id, :roster_date => single_item[:roster_date].to_date)
						if roster.nil?
							employee_roster = EmployeeRoster.new
							employee_roster.employee_id = employee.id
							employee_roster.company_id = employee.company_id
							employee_roster.location_id = employee.location_id
							employee_roster.branch_id = employee.branch_id
							employee_roster.department_id = employee.department_id
							employee_roster.grade_id = employee.grade_id
							employee_roster.joining_date = employee.joining_date.to_date
							employee_roster.roster_date = single_item[:roster_date].to_date
							employee_roster.employee_code = employee.employee_code
							employee_roster.employee_name = employee.full_name
							employee_roster.location_name = employee.location_name
							employee_roster.branch_name = employee.branch_name
							employee_roster.department_name = employee.department_name
							employee_roster.grade_name = employee.grade_name
							if single_item[:roster_date].to_date.strftime("%A").upcase == single_item[:rest_day].upcase
								employee_roster.is_rest_day = true
							else
								employee_roster.is_rest_day = false				
							end
							employee_roster.time_slot_id = time_slot.id
							employee_roster.is_flexi = time_slot.is_flexi
							employee_roster.start_time = time_slot.start_time
							employee_roster.end_time = time_slot.end_time
							employee_roster.formated_start_time = time_slot.actual_start_time
							employee_roster.formated_end_time = time_slot.actual_end_time
							employee_roster.start_buffer = time_slot.start_buffer
							employee_roster.end_buffer = time_slot.end_buffer
							employee_roster.save
						else
							employee_roster = roster
							employee_roster.employee_id = employee.id
							employee_roster.company_id = employee.company_id
							employee_roster.location_id = employee.location_id
							employee_roster.branch_id = employee.branch_id
							employee_roster.department_id = employee.department_id
							employee_roster.grade_id = employee.grade_id
							employee_roster.joining_date = employee.joining_date.to_date
							employee_roster.roster_date = single_item[:roster_date].to_date
							employee_roster.employee_code = employee.employee_code
							employee_roster.employee_name = employee.full_name
							employee_roster.location_name = employee.location_name
							employee_roster.branch_name = employee.branch_name
							employee_roster.department_name = employee.department_name
							employee_roster.grade_name = employee.grade_name
							if single_item[:roster_date].to_date.strftime("%A").upcase == single_item[:rest_day].upcase
								employee_roster.is_rest_day = true
							else
								employee_roster.is_rest_day = false				
							end
							employee_roster.time_slot_id = time_slot.id
							employee_roster.is_flexi = time_slot.is_flexi
							employee_roster.start_time = time_slot.start_time
							employee_roster.end_time = time_slot.end_time
							employee_roster.formated_start_time = time_slot.actual_start_time
							employee_roster.formated_end_time = time_slot.actual_end_time
							employee_roster.start_buffer = time_slot.start_buffer
							employee_roster.end_buffer = time_slot.end_buffer
							employee_roster.save
						end
					end
				end
			end
		end
	end

	def self.srl_ho_employee_relative_data
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/old_data/srl_relatives.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employe_code])
			if not employee.nil?
				count = count + 1
				relationship_id = Relationship.find_by_name(single_item[:relation].titleize).id
				gender = "Male"
				relative_age = 0
				is_dependent = false
				
				if ["Spouse", "Mother-In-Law", "Sister", "Daughter", "Mother"].include?(single_item[:relation].titleize) == true
					gender = "Female"
				else
					gender = "Male"
				end

				if single_item[:date_of_birth].present?
					date_of_birth = single_item[:date_of_birth].to_date
					relative_age = Time.now.year - date_of_birth.year	
				else
					relative_age = 0
					date_of_birth = nil
				end

				employee_relative = EmployeeRelative.new
				employee_relative.employee_id = employee.id
				employee_relative.relative_name = single_item[:relative_name]
				employee_relative.relationship_id = relationship_id
				employee_relative.email = ""
				employee_relative.contact_number = ""
				employee_relative.gender = gender
				employee_relative.date_of_birth = date_of_birth
				employee_relative.date_of_enrollment = nil
				employee_relative.cnic_number = single_item[:relative_cnic_number]
				employee_relative.is_dependent = is_dependent
				employee_relative.address = ""
				employee_relative.same_as_employee_address = false
				employee_relative.same_as_employee_permanent_address = single_item[:relative_address]
				employee_relative.save

				puts "\n\n employee_id => #{employee_relative.employee_id} \n\n"
				puts "\n\n relative_name => #{employee_relative.relative_name} \n\n"
				puts "\n\n relationship_id => #{employee_relative.relationship_id} \n\n"
				puts "\n\n email => #{employee_relative.email} \n\n"
				puts "\n\n contact_number => #{employee_relative.contact_number} \n\n"
				puts "\n\n gender => #{employee_relative.gender} \n\n"
				puts "\n\n date_of_birth => #{employee_relative.date_of_birth} \n\n"
				puts "\n\n date_of_enrollment => #{employee_relative.date_of_enrollment} \n\n"
				puts "\n\n cnic_number => #{employee_relative.cnic_number} \n\n"
				puts "\n\n is_dependent => #{employee_relative.is_dependent} \n\n"
				puts "\n\n address => #{employee_relative.address} \n\n"
				puts "\n\n same_as_employee_address => #{employee_relative.same_as_employee_address} \n\n"
				puts "\n\n same_as_employee_permanent_address => #{employee_relative.same_as_employee_permanent_address} \n\n"

			end
		end
  end

	def self.srl_ho_employee_certification
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/old_data/srl_employee_certification.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code])
			if not employee.nil?
				count = count + 1
				certification = EmployeeCertification.new
				certification.certification_authority = single_item[:certification_authority]
				certification.name = single_item[:certificate_name]
				certification.certification_type = single_item[:certification_type_id]
				certification.employee_id = employee.id
				if single_item[:certification_start_date].present?
					start_date = single_item[:certification_start_date].to_s.to_date
				else
					start_date = nil
				end

				if single_item[:certification_end_date].present?
					end_date = single_item[:certification_end_date].to_s.to_date
				else
					end_date = nil
				end
				certification.start_date = start_date
				certification.end_date = end_date
				certification.save
			end
		end
  end

  def self.srl_ho_employee_traning
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/old_data/srl_employee_traning.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code])
			if not employee.nil?
				count = count + 1
				training = EmployeeTraining.new
				training.organization = single_item[:training_organization_name]
				training.name = single_item[:training_name]
				training.training_type = single_item[:training_type_id]
				training.employee_id = employee.id
				if single_item[:training_start_date].present?
					start_date = single_item[:training_start_date].to_s.to_date
				else
					start_date = nil
				end

				if single_item[:training_end_date].present?
					end_date = single_item[:training_end_date].to_s.to_date
				else
					end_date = nil
				end
				training.start_date = start_date
				training.end_date = end_date
				training.save
			end
		end
  end

  def self.srl_ho_employee_previous
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/old_data/srl_employee_previous.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code])
			if not employee.nil?
				count = count + 1
				experience = EmployeeExperience.new
				experience.organization = single_item[:previous_history_organization_name]
				experience.job_title = single_item[:previous_history_job_title]
				experience.left_reason = single_item[:previous_history_left_reason_id]
				experience.salary = single_item[:previous_history_salary]
				experience.employee_id = employee.id
				if single_item[:previous_history_start_date].present?
					start_date = single_item[:previous_history_start_date].to_s.to_date
				else
					start_date = nil
				end

				if single_item[:previous_history_end_date].present?
					end_date = single_item[:previous_history_end_date].to_s.to_date
				else
					end_date = nil
				end
				experience.start_date = start_date
				experience.end_date = end_date
				experience.save
			end
		end
  end

  def self.srl_ho_employee_education
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/old_data/srl_education.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code])
			if not employee.nil?
				count = count + 1
				qualification = EmployeeQualification.new
				qualification.institute_name = single_item[:education_institute_name]
				qualification.program_name = single_item[:education_program_id]
				qualification.status = single_item[:education_status]
				if single_item[:education_status] == 'Grade' or single_item[:education_status] == 'Pass/Fail' or single_item[:education_status] == 'Division'
					qualification.status_text	= single_item[:education_gpa_or_percentage]
				else
					qualification.gpa_or_percentage =	single_item[:education_gpa_or_percentage]	
				end
				qualification.employee_id = employee.id
				if single_item[:education_program_id].present?
					qualification_program_id = QualificationProgram.find_by_name(single_item[:education_program_id]).id
				else
					qualification_program_id = nil
				end
				specialization_id = nil
				qualification.qualification_program_id = qualification_program_id
				qualification.specialization_id = specialization_id
				if single_item[:education_start_year].present?
					if single_item[:education_start_year].to_s.length == 4
						start_date = "01-JAN-#{single_item[:education_start_year].to_s}".to_date
					else
						start_date = single_item[:education_start_year].to_s.to_date
					end
				else
					start_date = nil
				end

				if single_item[:education_end_year].present?
					if single_item[:education_end_year].to_s.length == 4
						end_date = "31-DEC-#{single_item[:education_end_year].to_s}".to_date
					else
						end_date = single_item[:education_end_year].to_s.to_date
					end
				else
					end_date = nil
				end
				qualification.start_date = start_date
				qualification.end_date = end_date
				qualification.save
			end
		end
  end

  def self.srl_ho_employee_reference
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/old_data/srl_employee_reference.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code])
			if not employee.nil?
				count = count + 1
				reference = EmployeeReference.new
				reference.employee_id = employee.id
				reference.reference_type = single_item[:reference_type]
				reference.name = single_item[:reference_name]
				reference.email = single_item[:reference_email]
				reference.contact_number = single_item[:reference_contact_no]
				reference.organization = single_item[:reference_occupation]
				reference.designation = single_item[:reference_designation]
				reference.address = single_item[:reference_address]
				reference.save
			end
		end
  end

  def self.srl_archive_employee_list
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/archive_employee_list.csv")
		count = 0
		employee_data.each do |single_item|
			puts "\n employee_code => #{single_item[:employee_code]} \n"
			branch = Branch.find_by_name(single_item[:branch].titleize)
			if single_item[:branch].titleize == "Wtc"
			branch = Branch.find_by_name("WTC")
			else
			branch = Branch.find_by_name(single_item[:branch].titleize)
			end
			designation = Designation.find_by_name(single_item[:designation].titleize)
			location = Location.find_by_name(single_item[:location].titleize)
			department = Department.find_by_name(single_item[:department])	
			employee_type = EmployeeType.find_by_name(single_item[:employee_type].titleize)

			grade = Grade.find_by_name(single_item[:grade])

			company_id = 1

			if grade.nil?
				grade_id = nil
			else
				grade_id = grade.id
			end

			salutation = single_item[:salutation]
			if designation.nil?
				designation_id = nil
			else
				designation_id = designation.id
			end

			department_id = department.id
			employee_type_id = employee_type.id
			cnic_number = single_item[:cnic]
			if single_item[:official_email].nil?
				official_email = ""
				create_login = false
				user_account_email = official_email
				user_account_password = "abcd@1234-#{single_item[:employee_code]}"
				role_id = nil
				is_admin = false
				custom_right = false
				is_company_head = false
				is_location_head = false
				is_branch_head = false
				is_department_head = false
			else
				official_email = single_item[:official_email].downcase
				user_account_email = official_email
				user_account_password = "abcd@1234-#{single_item[:employee_code]}"
				role_id = 2
				is_admin = false
				custom_right = false
				is_company_head = false
				is_location_head = false
				is_branch_head = false
				is_department_head = false
				create_login = false
			end

			if single_item[:dob].nil?
				date_of_birth = nil
			else
				date_of_birth = single_item[:dob].to_date	
			end

			joining_date = single_item[:doj].to_date
			if single_item[:doc].nil?
				confirmation_date = nil
				on_probation = true
			else
				confirmation_date = single_item[:doc].to_date	
				on_probation = false
			end

			gross_salary = single_item[:gross_salary]
			if single_item[:personal_number].nil?
				personal_number = ""
			else
				if single_item[:personal_number].to_s.length == 10
					personal_number = "0#{single_item[:personal_number]}"
					personal_number = ReportFormat.phone_format(personal_number)
				else
					personal_number = ReportFormat.phone_format(single_item[:personal_number])
				end
			end

			blood_group = single_item[:blood_group]
			current_address = single_item[:present_address]
			permanent_address = single_item[:permanent_address]
			location_id = location.id
			branch_id = branch.id

			if single_item[:contract_start_date].nil?
				is_contractual = false
				contract_start_date = nil
				contract_end_date = nil
			else
				is_contractual = true
				contract_start_date = single_item[:contract_start_date].to_date
				contract_end_date = single_item[:contract_end_date].to_date
			end
			if single_item[:marital_status].nil?
				marital_status = ""
			else
				marital_status = single_item[:marital_status].titleize
			end

			puts "\n company_id => #{company_id} \n"
			puts "\n grade_id => #{grade_id} \n"
			puts "\n designation_id => #{designation_id} \n"
			puts "\n department_id => #{department_id} \n"
			puts "\n employee_type_id => #{employee_type_id} \n"
			puts "\n cnic_number => #{cnic_number} \n"
			puts "\n official_email => #{official_email} \n"
			puts "\n date_of_birth => #{date_of_birth} \n"
			puts "\n joining_date => #{joining_date} \n"
			puts "\n confirmation_date => #{confirmation_date} \n"
			puts "\n on_probation => #{on_probation} \n"
			puts "\n gross_salary => #{gross_salary} \n"
			puts "\n personal_number => #{personal_number} \n"
			puts "\n blood_group => #{blood_group} \n"
			puts "\n current_address => #{current_address} \n"
			puts "\n permanent_address => #{permanent_address} \n"
			puts "\n location_id => #{location_id} \n"
			puts "\n branch_id => #{branch_id} \n"
			Employee.create(:salutation => salutation, :employee_code => single_item[:employee_code], :first_name => single_item[:name].titleize, :company_id => company_id, :grade_id => grade_id, :designation_id => designation_id, :department_id => department_id, :employee_type_id => employee_type_id, :cnic_number => cnic_number, :official_email => official_email, :date_of_birth => date_of_birth, :joining_date => joining_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :gross_salary => gross_salary, :personal_number => personal_number, :blood_group => blood_group, :current_address => current_address, :permanent_address => permanent_address, :location_id => location_id, :branch_id => branch_id, :is_contractual => is_contractual, :contract_start_date => contract_start_date, :contract_end_date => contract_end_date, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :create_login => create_login, :martial_status => marital_status, :is_active => false)
			count = count + 1
		end

		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s, :is_active => false)
			if not employee.nil?
				if not single_item[:dol].nil?
					employee_transaction = EmployeeTransactionHistory.new
					employee_transaction.transaction_date = Time.now.to_date
					employee_transaction.hold_salary = true
					employee_transaction.left_type = "Resignation"
					employee_transaction.left_reason = "Better Opportunity"
					employee_transaction.transaction_date = single_item[:dol].to_date
					employee_transaction.transaction_type = "End of Employment"
					employee_transaction.employee_id = employee.id
					employee_transaction.save
				end
			end
		end
  end

  def self.leave_balance_adjustment
  	start_date = (Time.now - 29.day).to_date
		end_date = Time.now.to_date
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_balance1.csv")
		count = 0
		employee_data.each do |single_item|
			employee = Employee.find_by(:employee_code => single_item[:employee_code].to_s, :is_active => true)
			if not employee.nil?
				LeaveAllocation.where(:employee_id => employee.id).each do |leave_allocation|
					if leave_allocation.leave_type_name == "Casual Leave"
						request_count = LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_allocation.leave_type_id, :request_status => ["Waiting For Approval","Availed","System Deducted"]).where("Date(start_date) >= ? AND Date(end_date) <= ?", start_date.to_date, end_date.to_date).sum(:request_count)
						leave_allocation.allocated_quota = single_item[:cl_quota]
						leave_allocation.used_quota = single_item[:cl_used] + request_count
						leave_allocation.remaining_quota = leave_allocation.allocated_quota - leave_allocation.used_quota
						leave_allocation.save(:validate => false)
						LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Manual Adjustement", "Manual Adjustement By HR", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
					elsif leave_allocation.leave_type_name == "Sick Leave"
						request_count = LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_allocation.leave_type_id, :request_status => ["Waiting For Approval","Availed","System Deducted"]).where("Date(start_date) >= ? AND Date(end_date) <= ?", start_date.to_date, end_date.to_date).sum(:request_count)
						leave_allocation.allocated_quota = single_item[:sl_quota]
						leave_allocation.used_quota = single_item[:sl_used] + request_count
						leave_allocation.remaining_quota = leave_allocation.allocated_quota - leave_allocation.used_quota
						leave_allocation.save(:validate => false)
						LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Manual Adjustement", "Manual Adjustement By HR", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
					elsif leave_allocation.leave_type_name == "Compensatory Leave"
						request_count = LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_allocation.leave_type_id, :request_status => ["Waiting For Approval","Availed","System Deducted"]).where("Date(start_date) >= ? AND Date(end_date) <= ?", start_date.to_date, end_date.to_date).sum(:request_count)
						leave_allocation.allocated_quota = single_item[:cpl_quota]
						leave_allocation.used_quota = single_item[:cpl_used] + request_count
						leave_allocation.remaining_quota = leave_allocation.allocated_quota - leave_allocation.used_quota
						leave_allocation.save(:validate => false)
					elsif leave_allocation.leave_type_name == "Annual Leave"
						if single_item[:al_quota] != "-"
							LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Manual Adjustement", "Manual Adjustement By HR", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
							request_count = LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_allocation.leave_type_id, :request_status => ["Waiting For Approval","Availed","System Deducted"]).where("Date(start_date) >= ? AND Date(end_date) <= ?", start_date.to_date, end_date.to_date).sum(:request_count)
							leave_allocation.allocated_quota = single_item[:al_quota]
							leave_allocation.used_quota = single_item[:al_used] + request_count
							leave_allocation.remaining_quota = leave_allocation.allocated_quota - leave_allocation.used_quota
							leave_allocation.save(:validate => false)
							LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Manual Adjustement", "Manual Adjustement By HR", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
						end
					end
				end
			end
		end
  end

  def self.incremented_salary
  	incremented_detail = SmarterCSV.process("#{Rails.public_path}/idl_data/incremented_salary.csv")
		incremented_detail.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
			if not employee.nil?
				employee_transaction = EmployeeTransactionHistory.new
				employee_transaction.transaction_date = (Time.now - 1.month).beginning_of_month.to_date
				employee_transaction.old_gross_salary = employee.gross_salary
				employee_transaction.new_gross_salary = single_item[:new_salary].to_f
				employee_transaction.transaction_type ="Gross Salary"
				employee_transaction.employee_id = employee.id
				employee_transaction.action_performed = "HR"
				employee_transaction.save
			end
		end
  end

  def self.revision_of_earned_cpl
  	employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_removed_cpl.csv")
		employee_data.each do |single_item|
			attendance_date = single_item[:attendance_date].split('(')[0].gsub('-19 ', '-2019').to_date
			employee_code = single_item[:employee_code]
			employee_attendance = EmployeeAttendance.where(:employee_code => employee_code, :attendance_date => attendance_date.to_date).last
			leave_type = LeaveType.find_by(:company_id => employee_attendance.employee.company_id, :location_id => employee_attendance.employee.location_id, :is_active => true, :auto_allocation => true, :earned_quota => true)
			employee = employee_attendance.employee
			if not leave_type.nil?	
				leave_allocation = LeaveAllocation.find_by(:employee_id => employee_attendance.employee_id, :is_active => true, :leave_type_id => leave_type.id)
				if not leave_allocation.nil?
					deducted_quota = single_item[:no_of_cpl]
					if leave_allocation.allocated_quota > 0
						leave_allocation.allocated_quota = leave_allocation.allocated_quota - deducted_quota.to_f
						leave_allocation.remaining_quota = leave_allocation.remaining_quota - deducted_quota.to_f
						LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, deducted_quota, "Reversion", "Reverted By HR", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
						leave_allocation.save(:validate => false)
					else
						puts "\n\n employee_code => #{employee_code} \n\n"
					end
					employee_attendance.no_of_cpl = 0
					employee_attendance.quota_earned = false
					employee_attendance.remarks = ""
					employee_attendance.save
				end
			end
		end
  end

  def self.srl_new_org_structure
  	employee_data = SmarterCSV.process("#{Rails.public_path}/srl_data/srl_org_chart.csv")
		employee_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
			if not employee.nil?
				department_name = single_item[:department]
				sub_department_name = single_item[:sub_department]
				position_title_name = single_item[:position_title]

				department = Department.find_by_name(department_name)	
				if not department.nil?
					sub_department = SubDepartment.find_by(:department_id => department.id, :name => sub_department_name)
					if sub_department.nil?
						sub_department = SubDepartment.create(:name => sub_department_name, :code => sub_department_name, :is_active => true, :company_id => 1, :department_id => department.id)	
					end
				else
					department = Department.create(:company_id => 1, :name => department_name, :code => department_name, :description => department_name, :is_active => true)
					sub_department = SubDepartment.create(:name => sub_department_name, :code => sub_department_name, :is_active => true, :company_id => 1, :department_id => department.id)				
				end
				
				job_title = JobTitle.find_by_name(position_title_name)
				
				if job_title.nil?
					job_title = JobTitle.create(:name => position_title_name, :is_active => true, :company_id => 1)
				end

				employee.department_id = department.id
				employee.sub_department_id = sub_department.id
				employee.job_title_id = job_title.id

				line_manager = Employee.find_by_employee_code(single_item[:line_manager_code].to_s)
				if not line_manager.nil?
					employee.line_manager_id = line_manager.id
				end
				employee.save
			end
		end
  end

  def self.dfl_salary_updation
  	payroll_info = SmarterCSV.process("#{Rails.public_path}/dfl_ho/aug_dfl_sheet.csv")
		payroll_info.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
			if not employee.nil?
				pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
				if not pay_invoice.nil?
					pay_invoice.pay_invoice_details.each do |a|
						a.amount = 0.0
						a.taxable_amount = 0.0
						a.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Basic Salary")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:basic_salary].to_f
						pay_invoice_detail.taxable_amount = single_item[:basic_salary].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "House Rent")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:house_rent].to_f
						pay_invoice_detail.taxable_amount = single_item[:house_rent].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Utility Allowance")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:utility_allowance].to_f
						pay_invoice_detail.taxable_amount = single_item[:utility_allowance].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Medical Allowance (OPD)")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:medical_allowance].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Other Allowance")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:other_allowance].to_f
						pay_invoice_detail.taxable_amount = single_item[:other_allowance].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Arrears")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:arrear].to_f
						pay_invoice_detail.taxable_amount = single_item[:arrear].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Increment Arrears")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:increment_arrear].to_f
						pay_invoice_detail.taxable_amount = single_item[:increment_arrear].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Mess Deduction")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:mess_deduction].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Bike Loan")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:mobile_loan].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Attendance Deduction")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:lwp].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Provident Fund")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:provident_fund].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "EOBI")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:eobi].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice.monthly_tax = single_item[:income_tax].to_f
					total_deduction = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction").sum(:amount)
					total_earning = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Earning").sum(:amount)
					pay_invoice.total_deduction = total_deduction - PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_name => "Attendance Deduction").sum(:amount)
					pay_invoice.total_earning = total_earning
					pay_invoice.save
					employee_taxable_income = EmployeeTaxableIncome.where(:employee_id => employee.id, :status => true).last
					employee_taxable_income.prev_taxable_amount = (single_item[:basic_salary].to_f + single_item[:house_rent].to_f + single_item[:utility_allowance].to_f + single_item[:other_allowance].to_f + single_item[:arrear].to_f)
					employee_taxable_income.monthly_tax_amount = single_item[:income_tax].to_f
					employee_taxable_income.total_paid_tax = 0
					employee_taxable_income.remaing_tax_to_be_paid = 0
					employee_taxable_income.employeer_pf_value = single_item[:provident_fund].to_f
					employee_taxable_income.save
				end
			end
		end
  end

  def self.dfl_aug_salary_data
  	payroll_info = SmarterCSV.process("#{Rails.public_path}/dfl_ho/aug_demin_sheet.csv")
		payroll_info.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
			if not employee.nil?
				pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
				if not pay_invoice.nil?
					pay_invoice.pay_invoice_details.each do |a|
					a.amount = 0.0
					a.taxable_amount = 0.0
					a.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Basic Salary")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:basic_salary].to_f
						pay_invoice_detail.taxable_amount = single_item[:basic_salary].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "House Rent")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:house_rent].to_f
						pay_invoice_detail.taxable_amount = single_item[:house_rent].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Utility Allowance")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:utility_allowance].to_f
						pay_invoice_detail.taxable_amount = single_item[:utility_allowance].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Medical Allowance (OPD)")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:medical_allowance].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Advance")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:advance].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Other Allowance")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:other_allowance].to_f
						pay_invoice_detail.taxable_amount = single_item[:other_allowance].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Arrears")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:arrear].to_f
						pay_invoice_detail.taxable_amount = single_item[:arrear].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Increment Arrears")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:increment_arrear].to_f
						pay_invoice_detail.taxable_amount = single_item[:increment_arrear].to_f
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Mess Deduction")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:mess_deduction].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Bike Loan")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:mobile_loan].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Attendance Deduction")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:lwp].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Provident Fund")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:provident_fund].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "EOBI")
					if not pay_invoice_detail.nil?
						pay_invoice_detail.amount = single_item[:eobi].to_f
						pay_invoice_detail.taxable_amount = 0.0
						pay_invoice_detail.save
					end
					pay_invoice.monthly_tax = single_item[:income_tax].to_f
					total_deduction = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction").sum(:amount)
					total_earning = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Earning").sum(:amount)
					pay_invoice.total_deduction = total_deduction - PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_name => "Attendance Deduction").sum(:amount)
					pay_invoice.total_earning = total_earning
					pay_invoice.save
					employee_taxable_income = EmployeeTaxableIncome.where(:employee_id => employee.id, :status => true).last
					employee_taxable_income.prev_taxable_amount = (single_item[:basic_salary].to_f + single_item[:house_rent].to_f + single_item[:utility_allowance].to_f + single_item[:other_allowance].to_f + single_item[:arrear].to_f + single_item[:increment_arrear].to_f)
					employee_taxable_income.monthly_tax_amount = single_item[:income_tax].to_f
					employee_taxable_income.total_paid_tax = 0
					employee_taxable_income.remaing_tax_to_be_paid = 0
					employee_taxable_income.employeer_pf_value = single_item[:provident_fund].to_f
					employee_taxable_income.employer_yearly_contribution = single_item[:income_tax_employyer_contribution	]
					employee_taxable_income.employer_contribution_before_tax_on_tax = single_item[:income_tax_employyer_contribution	]
					employee_taxable_income.tax_on_tax = single_item[:tax_on_tax].to_f
					employee_taxable_income.total_tax_on_tax = single_item[:tax_on_tax].to_f
					employee_taxable_income.save
				end
			end
		end
  end

  # DataEntry.dfl_tax_adjustment
  def self.dfl_tax_adjustment
  	Employee.active.each do |employee|
			if not employee.nil?
				old_pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
				old_pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_execution_id => old_pay_execution_ids).last
				pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
				pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_execution_id => pay_execution_ids).last
				if not old_pay_invoice.nil?
					if not pay_invoice.nil?
						old_employee_taxable_income = old_pay_invoice.employee_taxable_income
						old_employee_taxable_income.taxable_amount_to_date = old_employee_taxable_income.prev_taxable_amount
						old_employee_taxable_income.save
						pay_invoice_detail_taxable_amount = 0
						# pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Increment Arrears")
						# if not pay_invoice_detail.nil?
						# 	pay_invoice_detail_taxable_amount = pay_invoice_detail.taxable_amount
						# end

						pay_invoice_detail_lwp_taxable_amount = 0
						pay_invoice_detail = old_pay_invoice.pay_invoice_details.find_by(:item_name => "Attendance Deduction")
						if not pay_invoice_detail.nil?
							pay_invoice_detail_lwp_taxable_amount = pay_invoice_detail_lwp_taxable_amount + pay_invoice_detail.amount
						end

						pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Attendance Deduction")
						if not pay_invoice_detail.nil?
							pay_invoice_detail_lwp_taxable_amount = pay_invoice_detail_lwp_taxable_amount + pay_invoice_detail.amount
						end

						current_taxable_amount = pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance", "Other Allowance", "Arrears", "Increment Arrears"]).sum(:taxable_amount)

						medical_amount = 0
						medical_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/medical_value.csv")
						medical_data.each do |single_item|
							if employee.employee_code.to_s == single_item[:employee_code].to_s
								medical_amount = single_item[:medical_value].to_f
							end
						end

						bouns_arrear_amount = 0
						bouns_arrear_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/bouns_arrears.csv")
						bouns_arrear_data.each do |single_item|
							if employee.employee_code.to_s == single_item[:employee_code].to_s
								bouns_arrear_amount = single_item[:bouns_arrears].to_f
							end
						end

						pf_diff_amount = 0
						e_cont_amount = 0
						pf_diff_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/Book6.csv")
						pf_diff_data.each do |single_item|
							if employee.employee_code.to_s == single_item[:employee_code].to_s
								pf_diff_amount = single_item[:pf_diff].to_f
								e_cont_amount = single_item[:e_cont].to_f
							end
						end

						pay_invoice_detail_pf_amount = 0
						pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => "Provident Fund")
						if not pay_invoice_detail.nil?
							pay_invoice_detail_pf_amount = pay_invoice_detail.amount
						end

						medical_exempted = ((((employee.gross_salary/100.0)*67.0)/100.0)*8.0).round
						medical_exempted = medical_exempted * 2
						employee_taxable_income = pay_invoice.employee_taxable_income
						employee_taxable_income.employeer_pf_value = pay_invoice_detail_pf_amount + pf_diff_amount
						employee_taxable_income.taxable_amount_to_date = (old_employee_taxable_income.prev_taxable_amount + current_taxable_amount + pay_invoice_detail_taxable_amount + e_cont_amount) - (medical_amount + bouns_arrear_amount + medical_exempted + pay_invoice_detail_lwp_taxable_amount)
						employee_taxable_income.monthly_tax_amount = pay_invoice.monthly_tax + e_cont_amount
						employee_taxable_income.save
					end
				end
			end
		end
  end

  # DataEntry.employee_taxable_income
  def self.employee_taxable_income
  	employees = Employee.active
		time = Time.now
		book = Axlsx::Package.new
		wb = book.workbook
		sheet = wb.add_worksheet(name: 'Tax Working')
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
		table_header = ["Sr #", "Emp Code", "Name", "current_taxable_amount", "prev_taxable_amount", "predicated_taxable_amount", "taxable_amount_to_date", "prev_incentive_amount", "current_incentive_amount", "loan_interest_amount", "gross_salary", "total_taxable_amount", "yearly_total_tax", "monthly_tax_amount", "total_paid_tax", "remaing_tax_to_be_paid", "encashable_quota", "predition_amount", "predition_item_amounts", "predition_item_ids", "predition_item_names", "current_month_vehicle_tax", "predicted_vehicle_tax", "employeer_pf_value", "predicted_pf_value", "pf_tax_value", "employeer_eobi_value", "prev_vehicle_tax", "annualize_predicated_taxable_amount"]

		sheet.add_row table_header, :style => header_style
		old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
		even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
		count = 0
		employees.each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			if not pay_invoice.nil?
				employee_taxable_income = pay_invoice.employee_taxable_income

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

				current_row_value << employee_taxable_income.current_taxable_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.prev_taxable_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.predicated_taxable_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.taxable_amount_to_date.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.prev_incentive_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.current_incentive_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.loan_interest_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.gross_salary.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.total_taxable_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.yearly_total_tax.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.monthly_tax_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.total_paid_tax.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.remaing_tax_to_be_paid.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.encashable_quota.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.predition_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.predition_item_amounts
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee_taxable_income.predition_item_ids
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee_taxable_income.predition_item_names
				current_row_style << row_format
				current_row_type << :string

				current_row_value << employee_taxable_income.current_month_vehicle_tax.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.predicted_vehicle_tax.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.employeer_pf_value.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.predicted_pf_value.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.pf_tax_value.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.employeer_eobi_value.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.prev_vehicle_tax.to_f
				current_row_style << row_format
				current_row_type << :float

				current_row_value << employee_taxable_income.annualize_predicated_taxable_amount.to_f
				current_row_style << row_format
				current_row_type << :float

				sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
			end
		end
		file_name = "employee_taxable_income"
		url_path = save_excel_file(book, file_name)
		puts "url_path => #{url_path}"
  end

  def self.od_request
  	od_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/od_data.csv")
		od_data.each do |single_item|
		  employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
		  if not employee.nil?
		    official_duty = OfficialDuty.new
		    official_duty.company_id 				= employee.company_id
		    official_duty.employee_id 			= employee.id
		    official_duty.request_count 		= 1
		    official_duty.start_date 				= single_item[:od_date].to_date
		    official_duty.end_date 					= single_item[:od_date].to_date
		    official_duty.request_sender_name = "-"
		    official_duty.reason            = "Request By HR"
		    official_duty.is_full_day       = true
		    official_duty.request_status    = "Waiting For Approval"  
		    official_duty.apply_status      = "HR User"
		    official_duty.is_cancelled     	= false
		    official_duty.start_time        = Time.new(single_item[:od_date].to_date.year, single_item[:od_date].to_date.month, single_item[:od_date].to_date.day, 9, 0, 0)
		    official_duty.end_time          = Time.new(single_item[:od_date].to_date.year, single_item[:od_date].to_date.month, single_item[:od_date].to_date.day, 21, 0, 0)
		    official_duty.save
		  end
		end
  end

  def self.reg_data
  	reg_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/reg_data.csv")
		reg_data.each do |single_item|
		  employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
		  if not employee.nil?
				employee_transaction = EmployeeTransactionHistory.new
				employee_id = employee.id
				employee_transaction.hold_salary 			= true
				employee_transaction.left_type 				= "Resignation"
				employee_transaction.left_reason 			= "Better Opportunity"
				employee_transaction.transaction_date = single_item[:r_date].to_date
				employee_transaction.transaction_type = "End of Employment"
				employee_transaction.employee_id 			= employee_id
				employee_transaction.action_performed = "HR User"
				employee_transaction.save
			end
		end
  end

  def self.leave_data
  	leave_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/leave_data.csv")
		leave_data.each do |single_item|
		  employee = Employee.find_by_employee_code(single_item[:employee_code].to_s)
		  if not employee.nil?
		    leave_type    = LeaveType.find_by(:name => "", :location_id => employee.location_id)
		    if not leave_type.nil?
		      leave_allocation = LeaveAllocation.find_by(:leave_type_id => leave_type.id, :employee_id => employee.id, :is_active => true)
		      if not leave_allocation.nil?
		        leave_request = LeaveRequest.new
		        leave_request.company_id          = employee.company_id
		        leave_request.employee_id         = employee.id
		        leave_request.leave_type_id       = leave_type.id
		        leave_request.allocated_quota     = leave_allocation.allocated_quota.to_f
		        leave_request.used_quota          = leave_allocation.used_quota.to_f
		        leave_request.remaining_quota     = leave_allocation.remaining_quota.to_f
		        leave_request.request_count       = 1.0
		        leave_request.sandwich_count      = 0.0
		        leave_request.min_apply_date      = (single_item[:leave_date].to_date - 1.month).to_date
		        leave_request.start_date          = single_item[:leave_date].to_date
		        leave_request.end_date            = single_item[:leave_date].to_date
		        leave_request.reason              = "On Request of HR Dept"
		        leave_request.leave_category      = "Full Day"
		        leave_request.request_sender_name = "-"
		        leave_request.request_status      = "Availed"  
		        leave_request.is_composite        = false
		        leave_request.apply_status        = "HR User"
		        leave_request.is_cancelled        = false
		        leave_request.save
		      end        
		    end
		  end
		end
  end

  def self.sdl_employee_upload
		employee_data = SmarterCSV.process("#{Rails.public_path}/sdl_farm/emnployee_list1.csv")
		count = 0
		employee_data.each do |single_item|
			puts "\n employee_code => #{single_item[:emp_code]} \n"
			if single_item[:emp_code].present?
				if single_item[:cnic].present?
					designation = Designation.find_by_name(single_item[:designation])
					department 	= Department.find_by_name(single_item[:department])	
					sub_department = SubDepartment.find_by_name(single_item[:department])	
					
					company_id = 1
					employee_type_id = 1
					grade_id = 1
					branch_id = 1
					location_id = 1
					job_title_id = 1
					
					if designation.nil?
						designation_id = nil
					else
						designation_id = designation.id
					end

					if department.nil?
						department_id = nil
					else
						department_id = department.id
					end

					if sub_department.nil?
						sub_department_id = nil
					else
						sub_department_id = sub_department.id
					end

					salary_unit_id = 1
					cost_center_id = 1
					salutation = single_item[:salutation]
					cnic_number = single_item[:cnic]
					father_name = single_item[:father_name]
					first_name = single_item[:name]
					official_email = ""
					create_login = false
					user_account_email = official_email
					user_account_password = "abcd@1234-#{single_item[:emp_code]}"
					role_id = nil
					is_admin = false
					custom_right = false
					is_company_head = false
					is_location_head = false
					is_branch_head = false
					is_department_head = false

					date_of_birth = single_item[:dob].to_date

					joining_date = single_item[:doj].to_date
					confirmation_date = (single_item[:doj].to_date + 3.month).to_date
					on_probation = false

					gross_salary = single_item[:gross_salary].to_f
					personal_number = ""

					blood_group = "B+"
					martial_status = "Single"

					puts "\n designation_id => #{designation_id} \n"
					puts "\n department_id => #{department_id} \n"
					puts "\n sub_department_id => #{sub_department_id} \n"
					puts "\n company_id => #{company_id} \n"
					puts "\n employee_type_id => #{employee_type_id} \n"
					puts "\n grade_id => #{grade_id} \n"
					puts "\n branch_id => #{branch_id} \n"
					puts "\n location_id => #{location_id} \n"
					puts "\n job_title_id => #{job_title_id} \n"
					puts "\n salary_unit_id => #{salary_unit_id} \n"
					puts "\n cost_center_id => #{cost_center_id} \n"
					puts "\n salutation => #{salutation} \n"
					puts "\n cnic_number => #{cnic_number} \n"
					puts "\n father_name => #{father_name} \n"
					puts "\n first_name => #{first_name} \n"
					puts "\n official_email => #{official_email} \n"
					puts "\n create_login => #{create_login} \n"
					puts "\n user_account_email => #{user_account_email} \n"
					puts "\n user_account_password => #{user_account_password} \n"
					puts "\n role_id => #{role_id} \n"
					puts "\n is_admin => #{is_admin} \n"
					puts "\n custom_right => #{custom_right} \n"
					puts "\n is_company_head => #{is_company_head} \n"
					puts "\n is_location_head => #{is_location_head} \n"
					puts "\n is_branch_head => #{is_branch_head} \n"
					puts "\n is_department_head => #{is_department_head} \n"
					puts "\n date_of_birth => #{date_of_birth} \n"
					puts "\n joining_date => #{joining_date} \n"
					puts "\n confirmation_date => #{confirmation_date} \n"
					puts "\n on_probation => #{on_probation} \n"
					puts "\n gross_salary => #{gross_salary} \n"
					puts "\n blood_group => #{blood_group} \n"
					puts "\n martial_status => #{martial_status} \n"

					# Employee.create(:employee_code => single_item[:emp_code], :designation_id => designation_id, :department_id => department_id, :sub_department_id => sub_department_id, :company_id => company_id, :employee_type_id => employee_type_id, :grade_id => grade_id, :branch_id => branch_id, :location_id => location_id, :job_title_id => job_title_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :salutation => salutation, :cnic_number => cnic_number, :father_name => father_name, :first_name => first_name, :official_email => official_email, :create_login => create_login, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :date_of_birth => date_of_birth, :joining_date => joining_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :gross_salary => gross_salary, :blood_group => blood_group, :martial_status => martial_status, :is_active => true)
					count = count + 1
				end
			end
		end  	
  end

  # DataEntry.insert_initial_data
  def self.insert_initial_data
  	Company.create(:name => "Syscon", :code => "Syscon", :short_name => "Syscon", :address => "7 A/K, Gulberg 2, Lahore, Pakistan", :description => "")

		DataEntry.add_geographical_data
		DataEntry.add_role_permission
		DataEntry.insert_religion_sect
		DataEntry.insert_religion
		DataEntry.add_qualification_program
		DataEntry.add_relationship

		User.create(:email => "khawaja.tayyab@admin.com", :password => "11223344", :first_name => "Khawaja", :last_name => "Tayyab", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
		User.create(:email => "ahsan.ali@admin.com", :password => "11223344", :first_name => "Ahsan", :last_name => "Ali", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
		User.create(:email => "syed.talal@admin.com", :password => "11223344", :first_name => "Syed", :last_name => "Talal", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
		User.create(:email => "anna.sahar@admin.com", :password => "11223344", :first_name => "Anna", :last_name => "Sahar", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
		User.create(:email => "fahad.rasool@admin.com", :password => "11223344", :first_name => "Fahad", :last_name => "Rasool", :is_confirmed => true, :is_admin => true, :company_id => 1, :role_id => 1)
  end

  def self.sdl_farm_rest_day
  	numbers = []
		Array.new(31).each_index do |index|
			numbers << (index + 1).to_s
		end

		start_date = Time.now.beginning_of_month.to_date
		end_date = (Time.now. + 1.month).end_of_month.to_date
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}

		shift_data = SmarterCSV.process("#{Rails.public_path}/sdl_farm/rest_day_data.csv")
		shift_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code])
			if not employee.nil?
				numbers.each_with_index do |single_number, index|
					if single_item[:"#{single_number}"].present?
						roster_date = date_range[index]
						employee_roster = EmployeeRoster.find_by(:employee_id => employee.id, :roster_date => roster_date.to_date)
						if not employee_roster.nil?
							if single_item[:"#{single_number}"].upcase == "R"
								employee_roster.is_rest_day = true
								employee_roster.save
							end
						end
					end
				end
			end
		end
  end

  # DataEntry.dfl_ho_pay_item_july
  def self.dfl_ho_pay_item_july
  	pay_item = PayItem.find_by(:name => "Basic Salary")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_basic_salary.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		pay_invoice.pay_invoice_details.destroy_all
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:july], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:july], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "House Rent")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_house_rent.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:july], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:july], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Utility Allowance")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_utility.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:july], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:july], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:july], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical Allowance (OPD)")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical_2.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:new_july], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
  end

  # DataEntry.dfl_ho_pay_item_aug
  def self.dfl_ho_pay_item_aug
  	pay_item = PayItem.find_by(:name => "Basic Salary")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_basic_salary.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		pay_invoice.pay_invoice_details.destroy_all
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:aug], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "House Rent")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_house_rent.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:aug], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Utility Allowance")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_utility.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:aug], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical Allowance (OPD)")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical_2.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
  end

	# DataEntry.dfl_ho_pay_item_sep
  def self.dfl_ho_pay_item_sep
  	pay_item = PayItem.find_by(:name => "Basic Salary")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_basic_salary.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		pay_invoice.pay_invoice_details.destroy_all
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:sep], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "House Rent")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_house_rent.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:sep], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Utility Allowance")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_utility.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:sep], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical Allowance (OPD)")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical_2.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
  end

  # DataEntry.dfl_ho_pay_item_oct
  def self.dfl_ho_pay_item_oct
  	pay_item = PayItem.find_by(:name => "Basic Salary")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_basic_salary.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		pay_invoice.pay_invoice_details.destroy_all
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:oct], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "House Rent")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_house_rent.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:oct], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Utility Allowance")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_utility.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:oct], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		pay_item = PayItem.find_by(:name => "Medical Allowance (OPD)")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_medical_2.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => 0.0, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
  end

  # DataEntry.dfl_ho_eid_reward2
  def self.dfl_ho_eid_reward2
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
  end

  # DataEntry.employee_loan_tax_amount
	def self.employee_loan_tax_amount
		ed = EmployeeLoanDetail.find(688)
		ed.loan_interest_amount = 36250
		ed.save

		ed = EmployeeLoanDetail.find(689)
		ed.loan_interest_amount = 36250
		ed.save

		ed = EmployeeLoanDetail.find(690)
		ed.loan_interest_amount = 35833
		ed.save

		ed = EmployeeLoanDetail.find(691)
		ed.loan_interest_amount = 35417
		ed.save

		ed = EmployeeLoanDetail.find(692)
		ed.loan_interest_amount = 35000
		ed.save

		ed = EmployeeLoanDetail.find(693)
		ed.loan_interest_amount = 34583
		ed.save

		ed = EmployeeLoanDetail.find(694)
		ed.loan_interest_amount = 34167
		ed.save

		ed = EmployeeLoanDetail.find(695)
		ed.loan_interest_amount = 33750
		ed.save

		ed = EmployeeLoanDetail.find(696)
		ed.loan_interest_amount = 33333
		ed.save

		ed = EmployeeLoanDetail.find(697)
		ed.loan_interest_amount = 32917
		ed.save

		ed = EmployeeLoanDetail.find(698)
		ed.loan_interest_amount = 32500
		ed.save

		ed = EmployeeLoanDetail.find(699)
		ed.loan_interest_amount = 32083
		ed.save

		employee = Employee.find_by(:employee_code => "771027")
		EmployeeTaxableIncome.where(:employee_id => employee.id).each do |employee_taxable_income|
			employee_taxable_income.loan_interest_amount = EmployeeLoan.employee_loan_tax_amount_yearly(employee, FiscalYear.first)
			employee_taxable_income.save
		end
	end

	# DataEntry.dfl_ho_pay_item_arrear
	def self.dfl_ho_pay_item_arrear
		pay_item = PayItem.find_by(:name => "Arrears")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_arrear.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:new_july], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:new_july], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:aug], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:sep], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:oct], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
	end

	# DataEntry.dfl_ho_pay_item_manual_arrear
	def self.dfl_ho_pay_item_manual_arrear
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_manual_arrear.csv")

		employee_data.each do |single_item|  
			employee = Employee.find_by_employee_code(single_item[:emp_code])
			if not employee.nil?
				pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
				pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
				if not pay_invoice.nil?
					taxable_amount = 0
					if single_item[:aug].to_f > 0
						taxable_amount = ((((single_item[:aug].to_f/100.0)*67)/100.0)*8)
						taxable_amount = taxable_amount.round
					end
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				end
			end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		taxable_amount = 0
		if single_item[:oct].to_f > 0
		taxable_amount = ((((single_item[:oct].to_f/100.0)*67)/100.0)*8)
		taxable_amount = taxable_amount.round
		end
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
	end

	# DataEntry.dfl_ho_pay_item_allowance
	def self.dfl_ho_pay_item_allowance
		pay_item = PayItem.find_by(:name => "Other Allowance")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dlf_allowance.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:new_july], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:new_july], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:aug], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:sep], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:oct], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
	end

	# DataEntry.dfl_ho_pay_item_lwp
	def self.dfl_ho_pay_item_lwp
		pay_item = PayItem.find_by(:name => "Attendance Deduction")
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/dfl_lwp.csv")
		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "July 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:new_july], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:new_july], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:aug], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:aug], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "September 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:sep], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:sep], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end

		employee_data.each do |single_item|  
		employee = Employee.find_by_employee_code(single_item[:emp_code])
		if not employee.nil?
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:status => true, :pay_execution_id => pay_execution_ids, :employee_id => employee.id).last
		if not pay_invoice.nil?
		PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => single_item[:oct], :pay_invoice_id => pay_invoice.id, :taxable_amount => single_item[:oct], :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
		end
		end
		end
	end

	# DataEntry.dfl_ho_vehicle_value
	def self.dfl_ho_vehicle_value
		employee_codes = ['771014', '771020', '771021', '771053', '771097', '771587', '771571']
		Employee.where(:employee_code => employee_codes).each do |employee|
			employee.velicle_allowed = false
			employee.save
		end

		employee_codes = ['771014', '771020', '771021', '771053', '771097', '771587', '771571', '771033', '771034', '771079', '771640', '771639']
		Employee.where(:employee_code => employee_codes).each do |employee|
			EmployeeTaxableIncome.where(:employee_id => employee.id).each do |employee_taxable_income|
				employee_taxable_income.prev_vehicle_tax = 0
				employee_taxable_income.predicted_vehicle_tax	 = 0
				employee_taxable_income.current_month_vehicle_tax = 0
				employee_taxable_income.save
			end
		end	

		employee_codes = ['771067']
		Employee.where(:employee_code => employee_codes).each do |employee|
			employee.velicle_allowed = false
			employee.save
		end

		employee_codes = ["771067"]
		Employee.where(:employee_code => employee_codes).each do |employee|
			EmployeeTaxableIncome.where(:employee_id => employee.id).each do |employee_taxable_income|
				employee_taxable_income.prev_vehicle_tax = 0
				employee_taxable_income.predicted_vehicle_tax	 = 0
				employee_taxable_income.current_month_vehicle_tax = 0
				employee_taxable_income.save
			end
		end	

		employee_codes = ['771033']
		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			employee_taxable_income = pay_invoice.employee_taxable_income
			employee_taxable_income.prev_vehicle_tax = 0
			employee_taxable_income.predicted_vehicle_tax	 = 30225
			employee_taxable_income.current_month_vehicle_tax = 30225
			employee_taxable_income.save
		end	

		employee_codes = ['771034']
		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			employee_taxable_income = pay_invoice.employee_taxable_income
			employee_taxable_income.prev_vehicle_tax = 0.0
			employee_taxable_income.predicted_vehicle_tax	 = 0.0
			employee_taxable_income.current_month_vehicle_tax = 49263
			employee_taxable_income.save
		end	

		employee_codes = ['771079']
		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			employee_taxable_income = pay_invoice.employee_taxable_income
			employee_taxable_income.prev_vehicle_tax = 0
			employee_taxable_income.predicted_vehicle_tax	 = 90000
			employee_taxable_income.current_month_vehicle_tax = 90000
			employee_taxable_income.save
		end	

		employee_codes = ['771640']
		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			employee_taxable_income = pay_invoice.employee_taxable_income
			employee_taxable_income.prev_vehicle_tax = 0
			employee_taxable_income.predicted_vehicle_tax	 = 31850
			employee_taxable_income.current_month_vehicle_tax = 31850
			employee_taxable_income.save
		end	

		employee_codes = ['771639']
		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			employee_taxable_income = pay_invoice.employee_taxable_income
			employee_taxable_income.prev_vehicle_tax = 0
			employee_taxable_income.predicted_vehicle_tax	 = 60150
			employee_taxable_income.current_month_vehicle_tax = 60150
			employee_taxable_income.save
		end
	end

	# DataEntry.eid_reward1_data
	def self.eid_reward1_data
		employee_codes = ['771627', '771034', '771087', '771600', '771704', '771668', '771670', '771671', '771673', '771674', '771677', '771676', '771678', '771679', '771680', '771682', '771681']

		Employee.where(:employee_code => employee_codes).each do |employee|
			employee.bonus1_allowed = false
			employee.bonus1_impact_allowed = true
			employee.save
		end

		employee_codes = ['771657', '771659', '771666', '771663', '771665', '771668', '771667']
		Employee.where(:employee_code => employee_codes).each do |employee|
			employee.bonus1_allowed = true
			employee.save
		end

		employee_codes = ['771627', '771034', '771087', '771600', '771704', '771668', '771670', '771671', '771673', '771674', '771677', '771676', '771678', '771679', '771680', '771682', '771681']

		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			pay_execution = pay_invoice.pay_execution
			employee_taxable_income = pay_invoice.employee_taxable_income
			predition_amount = 0
			predition_item_ids = []
			predition_item_names = []
			predition_item_amounts = []
			PayItem.where(:is_active => true, :prediction_tax_impact => true).order('id ASC').each do |single_item|
				if single_item.name == "Eid Reward 1" and pay_invoice.employee.bonus1_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Eid Reward 2" and pay_invoice.employee.bonus2_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Annual Bonus" and pay_invoice.employee.bonus3_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Leave Encahsment"
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
			end
			employee_taxable_income.predition_amount = predition_amount
			employee_taxable_income.predition_item_amounts	= predition_item_amounts.join(',')
			employee_taxable_income.predition_item_ids	= predition_item_ids.join(',')
			employee_taxable_income.predition_item_names	= predition_item_names.join(',')
			employee_taxable_income.save
		end

		employee_codes = ['771657', '771659', '771666', '771663', '771665', '771668', '771667']
		Employee.where(:employee_code => employee_codes).each do |employee|
			pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
			pay_execution = pay_invoice.pay_execution
			employee_taxable_income = pay_invoice.employee_taxable_income
			predition_amount 				= 0
			predition_item_ids 			= []
			predition_item_names 		= []
			predition_item_amounts 	= []
			PayItem.where(:is_active => true, :prediction_tax_impact => true).order('id ASC').each do |single_item|
				if single_item.name == "Eid Reward 1" and pay_invoice.employee.bonus1_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Eid Reward 2" and pay_invoice.employee.bonus2_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Annual Bonus" and pay_invoice.employee.bonus3_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Leave Encahsment"
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
			end
			employee_taxable_income.predition_amount 				= predition_amount
			employee_taxable_income.predition_item_amounts	= predition_item_amounts.join(',')
			employee_taxable_income.predition_item_ids			= predition_item_ids.join(',')
			employee_taxable_income.predition_item_names		= predition_item_names.join(',')
			employee_taxable_income.save
		end
	end

	# DataEntry.dfl_ho_pf_data
	def self.dfl_ho_pf_data
		employee = Employee.find_by_employee_code("775605")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		EmployeeTaxableIncome.where(:status => true, :fiscal_year_id => pay_invoice.fiscal_year_id, :employee_id => pay_invoice.employee_id).each do |employee_taxable_income|
		employee_taxable_income.employeer_pf_value = 29160.0
		employee_taxable_income.save
		end

		pay_execution = pay_invoice.pay_execution
		employee_taxable_income = pay_invoice.employee_taxable_income
		pf_tax_value = pay_invoice.calculate_predicted_employyer_provident_fund(pay_invoice, employee, pay_execution, "PF TAX")
		employee_taxable_income.pf_tax_value = pf_tax_value
		employee_taxable_income.pf_tax_value = employee_taxable_income.pf_tax_value - 29160.0
		employee_taxable_income.save
	end

	# DataEntry.dfl_ho_extra_working
	def self.dfl_ho_extra_working
		employee = Employee.find_by_employee_code("771676")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771681")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771679")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771678")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771677")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771675")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771664")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771646")
		pay_item = PayItem.find_by(:name => "Manual Arrear")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		pay_item = PayItem.find_by(:name => "Attendance Deduction")
		employee = Employee.find_by_employee_code("771675")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = pay_invoice_detail.amount + 3070
		pay_invoice_detail.taxable_amount = pay_invoice_detail.taxable_amount + 3070
		pay_invoice_detail.save

		pay_item = PayItem.find_by(:name => "Attendance Deduction")
		employee = Employee.find_by_employee_code("771682")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "December 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = 13492
		pay_invoice_detail.taxable_amount = 13492
		pay_invoice_detail.save

		pay_item = PayItem.find_by(:name => "Other Deduction")
		employee = Employee.find_by_employee_code("771682")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "December 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = 0
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save

		pay_item = PayItem.find_by(:name => "Arrears")
		employee = Employee.find_by_employee_code("771672")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "August 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = 6938
		pay_invoice_detail.taxable_amount = 6938
		pay_invoice_detail.save

		pay_item = PayItem.find_by(:name => "Arrears")
		employee = Employee.find_by_employee_code("771672")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = 2891
		pay_invoice_detail.taxable_amount = 2891
		pay_invoice_detail.save

		employee = Employee.find_by_employee_code("771582")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		employee_taxable_income = pay_invoice.employee_taxable_income
		employee_taxable_income.annualize_predicated_taxable_amount = 0
		employee_taxable_income.save
		

		pay_item = PayItem.find_by(:name => "Attendance Deduction")
		employee = Employee.find_by_employee_code("771586")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = 0
		pay_invoice_detail.taxable_amount = 0
		pay_invoice_detail.save


		pay_item = PayItem.find_by(:name => "Attendance Deduction")
		employee = Employee.find_by_employee_code("771582")
		pay_execution_ids = PayExecution.where(:formated_pay_month => "October 2019").collect(&:id)
		pay_invoice = PayInvoice.where(:pay_execution_id => pay_execution_ids, :employee_id => employee.id, :status => true).last
		pay_invoice_detail = pay_invoice.pay_invoice_details.find_by(:item_name => pay_item.name)
		pay_invoice_detail.amount = 614
		pay_invoice_detail.taxable_amount = 614
		pay_invoice_detail.save

		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_ho/Book2.csv")
		employee_data.each do |single_item|  
			employee = Employee.find_by_employee_code(single_item[:emp_code])
			if not employee.nil?
				pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
				if not pay_invoice.nil?
					pay_execution = pay_invoice.pay_execution
					employee_taxable_income = pay_invoice.employee_taxable_income
					employee_taxable_income.taxable_amount_to_date = single_item[:total_salary].to_f
					employee_taxable_income.save
				end
			end
		end

		employee = Employee.find_by_employee_code("771067")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_execution = pay_invoice.pay_execution
		employee_taxable_income = pay_invoice.employee_taxable_income
		employee_taxable_income.prev_vehicle_tax = 0.0
		employee_taxable_income.save

		employee = Employee.find_by_employee_code("771582")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_execution = pay_invoice.pay_execution
		employee_taxable_income = pay_invoice.employee_taxable_income
		employee_taxable_income.taxable_amount_to_date = 258074
		employee_taxable_income.save

		employee = Employee.find_by_employee_code("771586")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_execution = pay_invoice.pay_execution
		employee_taxable_income = pay_invoice.employee_taxable_income
		employee_taxable_income.taxable_amount_to_date = employee_taxable_income.taxable_amount_to_date + 614
		employee_taxable_income.save

		employee = Employee.find_by_employee_code("771672")
		pay_invoice = PayInvoice.where(:employee_id => employee.id, :status => true).last
		pay_execution = pay_invoice.pay_execution
		employee_taxable_income = pay_invoice.employee_taxable_income
		employee_taxable_income.taxable_amount_to_date = employee_taxable_income.taxable_amount_to_date - 1156
		employee_taxable_income.save
	end

	# DataEntry.bulk_update_salary_data
	def self.bulk_update_salary_data
		DataEntry.dfl_ho_pay_item_july
		DataEntry.dfl_ho_pay_item_aug
		DataEntry.dfl_ho_pay_item_sep
		DataEntry.dfl_ho_pay_item_oct
		DataEntry.dfl_ho_eid_reward2
		DataEntry.employee_loan_tax_amount
		DataEntry.dfl_ho_pay_item_arrear
		DataEntry.dfl_ho_pay_item_manual_arrear
		DataEntry.dfl_ho_pay_item_allowance
		DataEntry.dfl_ho_pay_item_lwp
		DataEntry.dfl_ho_pf_data
		DataEntry.dfl_ho_extra_working
		DataEntry.eid_reward1_data
		DataEntry.dfl_ho_vehicle_value
	end

	def self.dfl_mill_rest_day
		shift_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/final_rest_day.csv")
		shift_data.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code])
			if not employee.nil?
				company = employee.company
				if not company.nil?
					worked_shift = single_item[:shift]
					if worked_shift == "G-1"
						worked_shift = "G1"
					elsif worked_shift == "No Roster Assinged"
						worked_shift = "Z"
					end
					time_slot = TimeSlot.find_by(:name => worked_shift, :location_id => employee.location_id, :branch_id => employee.branch_id)
					if not time_slot.nil?
						roster = EmployeeRoster.find_by(:employee_id => employee.id, :roster_date => single_item[:roster_date].to_date)
						if roster.nil?
							employee_roster = EmployeeRoster.new
							employee_roster.employee_id = employee.id
							employee_roster.company_id = employee.company_id
							employee_roster.location_id = employee.location_id
							employee_roster.branch_id = employee.branch_id
							employee_roster.department_id = employee.department_id
							employee_roster.grade_id = employee.grade_id
							employee_roster.joining_date = employee.joining_date.to_date
							employee_roster.roster_date = single_item[:roster_date].to_date
							employee_roster.employee_code = employee.employee_code
							employee_roster.employee_name = employee.full_name
							employee_roster.location_name = employee.location_name
							employee_roster.branch_name = employee.branch_name
							employee_roster.department_name = employee.department_name
							employee_roster.grade_name = employee.grade_name
							if single_item[:roster_date].to_date.strftime("%A").upcase == single_item[:rest_day].upcase
								employee_roster.is_rest_day = true
							else
								employee_roster.is_rest_day = false				
							end
							employee_roster.time_slot_id = time_slot.id
							employee_roster.is_flexi = time_slot.is_flexi
							employee_roster.start_time = time_slot.start_time
							employee_roster.end_time = time_slot.end_time
							employee_roster.formated_start_time = time_slot.actual_start_time
							employee_roster.formated_end_time = time_slot.actual_end_time
							employee_roster.start_buffer = time_slot.start_buffer
							employee_roster.end_buffer = time_slot.end_buffer
							employee_roster.save
						else
							employee_roster = roster
							employee_roster.employee_id = employee.id
							employee_roster.company_id = employee.company_id
							employee_roster.location_id = employee.location_id
							employee_roster.branch_id = employee.branch_id
							employee_roster.department_id = employee.department_id
							employee_roster.grade_id = employee.grade_id
							employee_roster.joining_date = employee.joining_date.to_date
							employee_roster.roster_date = single_item[:roster_date].to_date
							employee_roster.employee_code = employee.employee_code
							employee_roster.employee_name = employee.full_name
							employee_roster.location_name = employee.location_name
							employee_roster.branch_name = employee.branch_name
							employee_roster.department_name = employee.department_name
							employee_roster.grade_name = employee.grade_name
							if single_item[:roster_date].to_date.strftime("%A").upcase == single_item[:rest_day].upcase
								employee_roster.is_rest_day = true
							else
								employee_roster.is_rest_day = false				
							end
							employee_roster.time_slot_id = time_slot.id
							employee_roster.is_flexi = time_slot.is_flexi
							employee_roster.start_time = time_slot.start_time
							employee_roster.end_time = time_slot.end_time
							employee_roster.formated_start_time = time_slot.actual_start_time
							employee_roster.formated_end_time = time_slot.actual_end_time
							employee_roster.start_buffer = time_slot.start_buffer
							employee_roster.end_buffer = time_slot.end_buffer
							employee_roster.save
						end
					end
				end
			end
		end
	end

	# DataEntry.hiring_shift_data
	def self.hiring_shift_data
		shift_data1 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/feb/DFL-Apparel.csv")
		shift_data1.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
			if not employee.nil?
				employee.hiring_shift = single_item[:hiring_shift]
				employee.save
			end
		end

		shift_data2 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/feb/DFL-Denim.csv")
		shift_data2.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
			if not employee.nil?
				employee.hiring_shift = single_item[:hiring_shift]
				employee.save
			end
		end

		shift_data3 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/feb/DFL-POWER.csv")
		shift_data3.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
			if not employee.nil?
				employee.hiring_shift = single_item[:hiring_shift]
				employee.save
			end
		end

		shift_data4 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/feb/DFL-SPINNING.csv")
		shift_data4.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
			if not employee.nil?
				employee.hiring_shift = single_item[:hiring_shift]
				employee.save
			end
		end

		shift_data5 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/feb/DFL-UNIT-1.csv")
		shift_data5.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
			if not employee.nil?
				employee.hiring_shift = single_item[:hiring_shift]
				employee.save
			end
		end

		shift_data6 = SmarterCSV.process("#{Rails.public_path}/dfl_mill/feb/DFL-UNIT-2.csv")
		shift_data6.each do |single_item|
			employee = Employee.find_by_employee_code(single_item[:emp_code].to_s)
			if not employee.nil?
				employee.hiring_shift = single_item[:hiring_shift]
				employee.save
			end
		end
	end

	def self.sdl_farm_attendance_data
		feb_attendance1 = SmarterCSV.process("#{Rails.public_path}/sdl_farm/feb_attendance1.csv")
		feb_attendance1.each do |single_item|
			employee_code = single_item[:emp_code].to_s
			employee = Employee.find_by_employee_code(employee_code)
			if not employee.nil?
				attendance_date = single_item[:date].to_date
				employee_attendance = EmployeeAttendance.where(:employee_code => employee_code, :attendance_date => attendance_date.to_date).last
				if not employee_attendance.nil?
					if single_item[:in_time].present?
						if not single_item[:in_time].nil?
							if not single_item[:in_time] == "-"
								employee_attendance.in_time	= Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, single_item[:in_time].split(':')[0], single_item[:in_time].split(':')[1], 00)
							end
						end
					end
					if single_item[:out_time].present?
						if not single_item[:out_time].nil?
							if not single_item[:out_time] == "-"
								if single_item[:out_time].split(' ')[1].downcase == 'am'
									new_out_time = single_item[:out_time].to_datetime + 12.hours
									employee_attendance.out_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, new_out_time.to_datetime.to_time.strftime('%H'), new_out_time.to_datetime.to_time.strftime('%M'), new_out_time.to_datetime.to_time.strftime('%S'))
								else
									new_out_time = single_item[:out_time].to_datetime
									employee_attendance.out_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, new_out_time.to_datetime.to_time.strftime('%H'), new_out_time.to_datetime.to_time.strftime('%M'), new_out_time.to_datetime.to_time.strftime('%S'))
								end
							end
						end
					end
					employee_attendance.mark_as_manual = true
					employee_attendance.save
				end
			end
		end

		feb_attendance2 = SmarterCSV.process("#{Rails.public_path}/sdl_farm/feb_attendance2.csv")
		feb_attendance2.each do |single_item|
			employee_code = single_item[:emp_code].to_s
			employee = Employee.find_by_employee_code(employee_code)
			if not employee.nil?
				attendance_date = single_item[:date].to_date
				employee_attendance = EmployeeAttendance.where(:employee_code => employee_code, :attendance_date => attendance_date.to_date).last
				if not employee_attendance.nil?
					if single_item[:in_time].present?
						if not single_item[:in_time].nil?
							if not single_item[:in_time] == "-"
								employee_attendance.in_time	= Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, single_item[:in_time].split(':')[0], single_item[:in_time].split(':')[1], 00)
							end
						end
					end
					if single_item[:out_time].present?
						if not single_item[:out_time].nil?
							if not single_item[:out_time] == "-"
								if single_item[:out_time].split(' ')[1].downcase == 'am'
									new_out_time = single_item[:out_time].to_datetime + 12.hours
									employee_attendance.out_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, new_out_time.to_datetime.to_time.strftime('%H'), new_out_time.to_datetime.to_time.strftime('%M'), new_out_time.to_datetime.to_time.strftime('%S'))
								else
									new_out_time = single_item[:out_time].to_datetime
									employee_attendance.out_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, new_out_time.to_datetime.to_time.strftime('%H'), new_out_time.to_datetime.to_time.strftime('%M'), new_out_time.to_datetime.to_time.strftime('%S'))
								end
							end
						end
					end
					employee_attendance.mark_as_manual = true
					employee_attendance.save
				end
			end
		end
	end

	def self.cresset_employee_list
		employee_data = SmarterCSV.process("#{Rails.public_path}/cresset_data/employee_list.csv")	
		count = 0
		employee_data.each do |single_item|
			if single_item[:employee_code].present?
				employee_code = single_item[:employee_code].split('E-')[1]
				puts "\n employee_code => #{employee_code} \n"

				designation = Designation.find_by(:name => single_item[:designation])

				department = Department.find_by_name(single_item[:department])
				sub_department = SubDepartment.find_by(:name => single_item[:department], :department_id => department.id)

				designation_id = designation.id
				employee_type_id = 1
				branch_id = 1
				location_id = 1
				company_id = 1
				salary_unit_id = 1
				cost_center_id = 1
				grade_id = 1
				job_title_id = 1
				department_id = department.id
				sub_department_id = sub_department.id

				first_name = single_item[:name]
				last_name = ""
				father_name = single_item[:"father's_name"]
				personal_number = ReportFormat.phone_format(single_item[:telephone].to_s.gsub(' ', ''))
				cnic_number = single_item[:cnic]
				blood_group = single_item[:blood_group]
				martial_status = single_item[:marital_status]

				create_login = false
				role_id = nil
				is_admin = false
				custom_right = false
				is_company_head = false
				is_location_head = false
				is_branch_head = false
				is_department_head = false

				if not single_item[:dob].nil?
				date_of_birth = single_item[:dob].to_date
				else
				date_of_birth = nil
				end

				if not single_item[:joining_date].nil?
				joining_date = single_item[:joining_date].to_date
				confimration_due_date = joining_date.to_date
				on_probation = false
				confirmation_date = joining_date.to_date
				else
				joining_date = nil
				confimration_due_date = nil
				on_probation = true
				confirmation_date = nil
				end

				payment_method = "Bank"
				bank_name = single_item[:bank_name]
				bank_branch_name = single_item[:branch_name]
				bank_branch_code = single_item[:branch_code]
				bank_account_title = single_item[:account_title]
				bank_account_number = single_item[:account_number]
				gross_salary = single_item[:current_salary]
				permanent_address = single_item[:address]
				current_address = single_item[:address]

				puts "\n designation_id => #{designation_id} \n"
				puts "\n employee_type_id => #{employee_type_id} \n"
				puts "\n branch_id => #{branch_id} \n"
				puts "\n location_id => #{location_id} \n"
				puts "\n company_id => #{company_id} \n"
				puts "\n salary_unit_id => #{salary_unit_id} \n"
				puts "\n cost_center_id => #{cost_center_id} \n"
				puts "\n grade_id => #{grade_id} \n"
				puts "\n job_title_id => #{job_title_id} \n"
				puts "\n department_id => #{department_id} \n"
				puts "\n sub_department_id => #{sub_department_id} \n"
				puts "\n first_name => #{first_name} \n"
				puts "\n last_name => #{last_name} \n"
				puts "\n father_name => #{father_name} \n"
				puts "\n personal_number => #{personal_number} \n"
				puts "\n cnic_number => #{cnic_number} \n"
				puts "\n blood_group => #{blood_group} \n"
				puts "\n martial_status => #{martial_status} \n"
				puts "\n create_login => #{create_login} \n"
				puts "\n role_id => #{role_id} \n"
				puts "\n is_admin => #{is_admin} \n"
				puts "\n custom_right => #{custom_right} \n"
				puts "\n is_company_head => #{is_company_head} \n"
				puts "\n is_location_head => #{is_location_head} \n"
				puts "\n is_branch_head => #{is_branch_head} \n"
				puts "\n is_department_head => #{is_department_head} \n"
				puts "\n date_of_birth => #{date_of_birth} \n"
				puts "\n joining_date => #{joining_date} \n"
				puts "\n confimration_due_date => #{confimration_due_date} \n"
				puts "\n on_probation => #{on_probation} \n"
				puts "\n confirmation_date => #{confirmation_date} \n"
				puts "\n payment_method => #{payment_method} \n"
				puts "\n bank_name => #{bank_name} \n"
				puts "\n bank_branch_name => #{bank_branch_name} \n"
				puts "\n bank_branch_code => #{bank_branch_code} \n"
				puts "\n bank_account_title => #{bank_account_title} \n"
				puts "\n bank_account_number => #{bank_account_number} \n"
				puts "\n gross_salary => #{gross_salary} \n"
				puts "\n permanent_address => #{permanent_address} \n"
				puts "\n current_address => #{current_address} \n"

				count = count + 1
				Employee.create(:employee_code => employee_code, :designation_id => designation_id, :employee_type_id => employee_type_id, :branch_id => branch_id, :location_id => location_id, :company_id => company_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :grade_id => grade_id, :job_title_id => job_title_id, :department_id => department_id, :sub_department_id => sub_department_id, :first_name => first_name, :last_name => last_name, :father_name => father_name, :personal_number => personal_number, :cnic_number => cnic_number, :blood_group => blood_group, :martial_status => martial_status, :create_login => create_login, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :date_of_birth => date_of_birth, :joining_date => joining_date, :confimration_due_date => confimration_due_date, :on_probation => on_probation, :confirmation_date => confirmation_date, :payment_method => payment_method, :bank_name => bank_name, :bank_branch_name => bank_branch_name, :bank_branch_code => bank_branch_code, :bank_account_title => bank_account_title, :bank_account_number => bank_account_number, :gross_salary => gross_salary, :permanent_address => permanent_address, :current_address => current_address)
			end
		end
	end

	def self.dfl_mill_new_enrollment
		employee_data = SmarterCSV.process("#{Rails.public_path}/dfl_mill/new_enrollment/spinning.csv")
		count = 0
		employee_data.each do |single_item|

			grade_name = single_item[:status]
			designation_name = single_item[:designation]
			department_name = single_item[:deptartment]
			branch_name = "None"
			location_name = "Spinning"

			grade = Grade.find_by_name(grade_name)
			designation = Designation.find_by(:name => designation_name, :grade_id => grade.id)
			if designation.nil?
			designation = Designation.create(:company_id => 1, :name => designation_name, :code => designation_name, :description => designation_name, :is_active => true, :grade_id => grade.id)
			end
			department = Department.find_by_name(department_name)
			if department.nil?
			department = Department.create(:company_id => 1, :name => department_name, :code => department_name, :description => department_name, :is_active => true)
			end
			location = Location.find_by_name(location_name)
			branch = Branch.find_by_name(branch_name)


			company_id = 1
			location_id = location.id
			branch_id = branch.id
			department_id = department.id
			sub_department_id = nil
			grade_id = grade.id
			designation_id = designation.id
			salary_unit_id = 1
			cost_center_id = 1
			employee_type_id = 1

			salutation = "Mr."
			first_name = single_item[:employeename]
			last_name = ""
			father_name = single_item[:fathername]

			gender = "Male"
			cnic_number = single_item[:cnic]
			blood_group = nil
			gross_salary = single_item[:gross_rate]

			create_login = false
			user_account_email = nil
			user_account_password = nil
			role_id = nil
			is_admin = false
			custom_right = false
			is_company_head = false
			is_location_head = false
			is_branch_head = false
			is_department_head = false

			date_of_birth = single_item[:dob].to_date
			joining_date = single_item[:doj].to_date
			confimration_due_date = joining_date + 3.month
			confirmation_date = confimration_due_date.to_date
			on_probation = false


			employee_code = single_item[:employeeid]
			current_address = "-"
			permanent_address = "-"

			count = count + 1
			puts "\n\n count => #{count} \n\n"
			Employee.create(:company_id => company_id, :location_id => location_id, :branch_id => branch_id, :department_id => department_id, :sub_department_id => sub_department_id, :grade_id => grade_id, :designation_id => designation_id, :salary_unit_id => salary_unit_id, :cost_center_id => cost_center_id, :employee_type_id => employee_type_id, :salutation => salutation, :first_name => first_name, :last_name => last_name, :father_name => father_name, :gender => gender, :cnic_number => cnic_number, :blood_group => blood_group, :gross_salary => gross_salary, :create_login => create_login, :user_account_email => user_account_email, :user_account_password => user_account_password, :role_id => role_id, :is_admin => is_admin, :custom_right => custom_right, :is_company_head => is_company_head, :is_location_head => is_location_head, :is_branch_head => is_branch_head, :is_department_head => is_department_head, :date_of_birth => date_of_birth, :joining_date => joining_date, :confimration_due_date => confimration_due_date, :confirmation_date => confirmation_date, :on_probation => on_probation, :employee_code => employee_code, :current_address => current_address, :permanent_address => permanent_address)
		end
	end

end