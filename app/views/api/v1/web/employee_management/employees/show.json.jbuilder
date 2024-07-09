json.employee do
	json.id 																		@employee.id
  json.file_number														@employee.file_number
	json.family_number													@employee.family_number
	json.full_name															@employee.full_name
	json.location_name 													@employee.location_name
	json.branch_name 														@employee.branch_name
	json.department_name 												@employee.department_name
	json.job_title_name 												@employee.job_title_name
	json.grade_name 														@employee.grade_name
	json.designation_name 											@employee.designation_name
	json.display_joining_date 									ReportFormat.date_format(@employee.joining_date)
	json.display_probation_end_date 						ReportFormat.date_format(@employee.confimration_due_date)
	json.display_confirmation_date 							ReportFormat.date_format(@employee.confirmation_date)
	json.salutation															@employee.salutation
	json.first_name															@employee.first_name
	json.last_name															@employee.last_name
	json.father_name														@employee.father_name
	json.official_email													@employee.official_email
	json.official_mobile_number									@employee.official_mobile_number
	json.personal_email													@employee.personal_email
	json.personal_number												@employee.personal_number
	json.date_of_birth													@employee.date_of_birth
	json.cnic_expiry_date 											@employee.cnic_expiry_date
	json.gender																	@employee.gender
	json.cnic_number														@employee.cnic_number
	json.blood_group														@employee.blood_group
	json.martial_status													@employee.martial_status
	json.company_id															@employee.company_id
	json.location_id														@employee.location_id
	json.branch_id															@employee.branch_id
	json.department_id													@employee.department_id
	json.sub_department_id											@employee.sub_department_id
	json.designation_id													@employee.designation_id
	json.job_title_id														@employee.job_title_id
	json.grade_id																@employee.grade_id
	json.salary_unit_id													@employee.salary_unit_id
	json.cost_center_id													@employee.cost_center_id
	json.employee_type_id												@employee.employee_type_id
	json.joining_date														@employee.joining_date
	json.old_joining_date 											@employee.old_joining_date
	json.contract_start_date										@employee.contract_start_date
	json.contract_end_date 											@employee.contract_end_date
	json.employee_code													@employee.employee_code
	json.prev_employee_code											@employee.prev_employee_code
	json.on_probation														@employee.on_probation
	json.is_contractual													@employee.is_contractual
	json.is_line_manager												@employee.is_line_manager
	json.is_active															@employee.is_active
	json.create_login														@employee.create_login
	json.relationship_id												@employee.relationship_id
	json.payment_method													@employee.payment_method
	json.tax_exempted														@employee.tax_exempted
	json.salary_exempted												@employee.salary_exempted
	json.bank_name															@employee.bank_name
	json.bank_branch_name												@employee.bank_branch_name
	json.bank_branch_code												@employee.bank_branch_code
	json.bank_account_title											@employee.bank_account_title
	json.bank_account_number										@employee.bank_account_number
	json.customize_tax													@employee.customize_tax
	json.tax_criteria														@employee.tax_criteria
	json.fixed_tax_rate													@employee.fixed_tax_rate
	json.gross_salary														@employee.gross_salary
	json.ntn_number															@employee.ntn_number
	json.is_admin																@employee.is_admin
	json.custom_right														@employee.custom_right
	json.role_id																@employee.role_id
	json.is_company_head												@employee.is_company_head
	json.is_location_head												@employee.is_location_head
	json.is_branch_head													@employee.is_branch_head
	json.is_department_head											@employee.is_department_head
	json.is_sub_department_head									@employee.is_sub_department_head
	json.user_account_email											@employee.user_account_email
	json.user_account_password									@employee.user_account_password
	json.emergency_contact_name									@employee.emergency_contact_name
	json.emergency_contact_email								@employee.emergency_contact_email
	json.emergency_contact_phone								@employee.emergency_contact_phone
	json.current_address												@employee.current_address
	json.permanent_address											@employee.permanent_address
	json.current_country_id											@employee.current_country_id
	json.current_state_id												@employee.current_state_id
	json.current_city_id												@employee.current_city_id
	json.current_division_id										@employee.current_division_id
	json.current_district_id										@employee.current_district_id
	json.current_tehsil_id											@employee.current_tehsil_id
	json.line_manager_name											@employee.line_manager_name
  json.hod_name          											@employee.hod_name
  json.check_hod_name                         @employee.hod_name.present?
	json.country_name														@employee.country_name
	json.state_name															@employee.state_name
	json.city_name															@employee.city_name
	json.division_name													@employee.division_name
	json.district_name													@employee.district_name
	json.tehsil_name														@employee.tehsil_name
	json.religion_sect_id												@employee.religion_sect_id
	json.religion_sect_name											@employee.religion_sect_name
	json.religion_id														@employee.religion_id
	json.religion_name													@employee.religion_name
	json.hold_salary														@employee.hold_salary
	json.is_overtime														@employee.is_overtime
	json.is_off_day_working											@employee.is_off_day_working
	json.is_cpl																	@employee.is_cpl
	json.attendance_exempted										@employee.attendance_exempted
	json.late_exempted													@employee.late_exempted
	json.regular_quota_encashment								@employee.regular_quota_encashment
	json.holiday_quota_encashment								@employee.holiday_quota_encashment
	json.is_regular_cpl													@employee.is_regular_cpl
	json.is_holiday_overtime										@employee.is_holiday_overtime
	json.social_security_allowed								@employee.social_security_allowed
	json.social_security_eligibility						@employee.social_security_eligibility
	json.social_security_joining_salary					@employee.social_security_joining_salary
	json.life_insurance_allowed									@employee.life_insurance_allowed
	json.life_insurance_eligibility							@employee.life_insurance_eligibility
	json.life_insurance_value										@employee.life_insurance_value
	json.cell_phone_bill_allowed								@employee.cell_phone_bill_allowed
	json.cell_phone_bill_eligibility						@employee.cell_phone_bill_eligibility
	json.cell_phone_bill_limit									@employee.cell_phone_bill_limit
	json.cell_phone_bill_amount									@employee.cell_phone_bill_amount
	json.fuel_allowed														@employee.fuel_allowed
	json.fuel_eligibility												@employee.fuel_eligibility
	json.fuel_limit															@employee.fuel_limit
	json.fuel_value															@employee.fuel_value
	json.cell_phone_allowed											@employee.cell_phone_allowed
	json.cell_phone_eligibility									@employee.cell_phone_eligibility
	json.cell_phone_entitlement_upto						@employee.cell_phone_entitlement_upto
	json.laptop_allowed													@employee.laptop_allowed
	json.laptop_eligibility											@employee.laptop_eligibility
	json.laptop_entitlement_upto								@employee.laptop_entitlement_upto
	json.laptop_category												@employee.laptop_category
	json.actual_laptop_value										@employee.actual_laptop_value
	json.velicle_allowed												@employee.velicle_allowed
	json.velicle_eligibility										@employee.velicle_eligibility
	json.vehicle_assignment_date								@employee.vehicle_assignment_date
	json.vehicle_value													@employee.vehicle_value
	json.provident_fund_allowed									@employee.provident_fund_allowed
	json.provident_fund_eligibility							@employee.provident_fund_eligibility
	json.eobi_allowed														@employee.eobi_allowed
	json.eobi_eligibility												@employee.eobi_eligibility
	json.incentive_allowed											@employee.incentive_allowed
	json.incentive_eligibility									@employee.incentive_eligibility
	json.vehicle_allowance_allowed							@employee.vehicle_allowance_allowed
	json.vehicle_allowance_eligibility					@employee.vehicle_allowance_eligibility
	json.vehicle_allowance_entitlement_upto			@employee.vehicle_allowance_entitlement_upto
	json.maintenance_allowed										@employee.maintenance_allowed
	json.maintenance_eligibility								@employee.maintenance_eligibility
	json.maintenance_entitlement_upto						@employee.maintenance_entitlement_upto
	json.travel_allowance_allowed								@employee.travel_allowance_allowed
	json.travel_allowance_eligibility						@employee.travel_allowance_eligibility
	json.travel_allowance_entitlement_upto			@employee.travel_allowance_entitlement_upto
	json.social_security_impact_allowed					@employee.social_security_impact_allowed
	json.life_insurance_impact_allowed					@employee.life_insurance_impact_allowed
	json.cell_phone_bill_impact_allowed					@employee.cell_phone_bill_impact_allowed
	json.fuel_impact_allowed										@employee.fuel_impact_allowed
	json.cell_phone_impact_allowed							@employee.cell_phone_impact_allowed
	json.laptop_impact_allowed									@employee.laptop_impact_allowed
	json.velicle_impact_allowed									@employee.velicle_impact_allowed
	json.provident_fund_impact_allowed					@employee.provident_fund_impact_allowed
	json.eobi_impact_allowed										@employee.eobi_impact_allowed
	json.incentive_impact_allowed								@employee.incentive_impact_allowed
	json.vehicle_allowance_impact_allowed				@employee.vehicle_allowance_impact_allowed
	json.maintenance_impact_allowed							@employee.maintenance_impact_allowed
	json.travel_allowance_impact_allowed				@employee.travel_allowance_impact_allowed
	json.attendance_impact_allowed							@employee.attendance_impact_allowed
	json.bonus1_impact_allowed									@employee.bonus1_impact_allowed
	json.bonus1_allowed													@employee.bonus1_allowed
	json.bonus1_eligibility											@employee.bonus1_eligibility
	json.bonus2_impact_allowed									@employee.bonus2_impact_allowed
	json.bonus2_allowed													@employee.bonus2_allowed
	json.bonus2_eligibility											@employee.bonus2_eligibility
	json.bonus3_impact_allowed									@employee.bonus3_impact_allowed
	json.bonus3_allowed													@employee.bonus3_allowed
	json.bonus3_eligibility											@employee.bonus3_eligibility
	json.back_date_eobi_impact									@employee.back_date_eobi_impact
	json.back_date_pf_impact										@employee.back_date_pf_impact
	json.back_date_allowance_impact							@employee.back_date_allowance_impact
	json.security_number												@employee.security_number
	json.health_insurance_impact_allowed				@employee.health_insurance_impact_allowed
	json.health_insurance_allowed								@employee.health_insurance_allowed
	json.health_insurance_plan									@employee.health_insurance_plan
	json.health_insurance_eligibility						@employee.health_insurance_eligibility
	json.social_security_other_date							@employee.social_security_other_date
	json.life_insurance_other_date							@employee.life_insurance_other_date
	json.cell_phone_bill_other_date							@employee.cell_phone_bill_other_date
	json.fuel_other_date												@employee.fuel_other_date
	json.cell_phone_other_date									@employee.cell_phone_other_date
	json.laptop_other_date											@employee.laptop_other_date
	json.velicle_other_date											@employee.velicle_other_date
	json.provident_fund_other_date							@employee.provident_fund_other_date
	json.eobi_other_date												@employee.eobi_other_date
	json.incentive_other_date										@employee.incentive_other_date
	json.vehicle_allowance_other_date						@employee.vehicle_allowance_other_date
	json.maintenance_other_date									@employee.maintenance_other_date
	json.travel_allowance_other_date						@employee.travel_allowance_other_date
	json.bonus1_other_date											@employee.bonus1_other_date
	json.bonus2_other_date											@employee.bonus2_other_date
	json.bonus3_other_date											@employee.bonus3_other_date
	json.health_insurance_other_date						@employee.health_insurance_other_date
	json.gratuity_impact_allowed								@employee.gratuity_impact_allowed
	json.gratuity_allowed												@employee.gratuity_allowed
	json.gratuity_eligibility										@employee.gratuity_eligibility
	json.gratuity_other_date										@employee.gratuity_other_date
	json.lfa_impact_allowed											@employee.lfa_impact_allowed
	json.lfa_allowed														@employee.lfa_allowed
	json.lfa_eligibility												@employee.lfa_eligibility
	json.lfa_other_date													@employee.lfa_other_date
	json.house_allowance_impact_allowed					@employee.house_allowance_impact_allowed
	json.house_allowance_allowed								@employee.house_allowance_allowed
	json.house_allowance_eligibility						@employee.house_allowance_eligibility
	json.house_allowance_other_date							@employee.house_allowance_other_date
	json.eobi_number														@employee.eobi_number
	json.nationality														@employee.nationality
	json.vehicle_name 													@employee.vehicle_name
	json.vehicle_model 													@employee.vehicle_model
	json.laptop_name 														@employee.laptop_name
	json.laptop_model 													@employee.laptop_model
	json.cell_phone_name 												@employee.cell_phone_name
	json.cell_phone_model 											@employee.cell_phone_model
	json.laptop_assignment_date 								@employee.laptop_assignment_date
	json.cell_assignment_date 									@employee.cell_assignment_date
	json.excluded_from_reports 									@employee.excluded_from_reports
	json.approval_base_overtime									@employee.approval_base_overtime
	json.is_medical_allowance										@employee.is_medical_allowance
	json.hiring_shift														@employee.hiring_shift_id
	json.fuel_card_number												@employee.fuel_card_number
	json.fuel_company_name											@employee.fuel_company_name
	json.velicle_two_allowed										@employee.velicle_two_allowed
	json.velicle_two_eligibility								@employee.velicle_two_eligibility
	json.velicle_two_other_date									@employee.velicle_two_other_date
	json.vehicle_two_assignment_date						@employee.vehicle_two_assignment_date
	json.vehicle_two_name												@employee.vehicle_two_name
	json.vehicle_two_model											@employee.vehicle_two_model
	json.vehicle_two_value											@employee.vehicle_two_value
  json.vaccinated														  @employee.vaccinated
  json.spouse_name      											@employee.spouse_name
  json.whatsapp_number      									@employee.whatsapp_number
  json.marriage_date      							   		@employee.marriage_date
  json.linkedln_url      						  	   		@employee.linkedln_url
  json.disability      						    	   		@employee.disability
  json.disability_needs      						   		@employee.disability_needs
  json.passport_number      						   		@employee.passport_number
  json.passport_expiry      					 	   		@employee.passport_expiry
  json.license_number      					   	   		@employee.license_number
  json.license_expiry      				    	   		@employee.license_expiry
  json.permanent_country_id										@employee.permanent_country_id
  json.permanent_state_id											@employee.permanent_state_id
  json.permanent_city_id											@employee.permanent_city_id
  json.permanent_country_name                 @employee.permanent_country_name
  json.permanent_state_name                   @employee.permanent_state_name
  json.permanent_city_name                    @employee.permanent_city_name
  json.category                               @employee.category
  json.mother_name                            @employee.mother_name


  if @employee.languages.present?
    json.languages 							              @employee.languages
  end
  json.language_second      						   		@employee.language_second
  json.language_third      					   	   		@employee.language_third

  json.languages_level      						   		@employee.languages_level
  json.inter_level      					    	   		@employee.inter_level
  json.expert_level      						      		@employee.expert_level

  json.skills_software      					     		@employee.skills_software
  json.skills_second      					     	  	@employee.skills_second
  json.skills_third         					     		@employee.skills_third

  json.skills_level      						       		@employee.skills_level
  json.second_level      						       		@employee.second_level
  json.third_level      						       		@employee.third_level

  json.criminal_record      						  	  @employee.criminal_record

  if @employee.employee_type_id == 7
    json.floor_id                             @employee.floor_id
    if @employee.is_incharge == true and @employee.group_id.present?
      json.group_id                            @employee.group_id.split(',').map(&:to_i)
    else
      json.group_id                             @employee.group_id.to_i
    end
    json.category_id                          @employee.category_id
    json.incharge_id                          @employee.incharge_id
    json.line_id                              @employee.line_id
    json.is_incharge                          @employee.is_incharge
  end
  if @employee.is_incharge == true and @employee.group_id.present?
    json.group_id                             @employee.group_id.split(',').map(&:to_i)
    json.is_incharge                          @employee.is_incharge
  end
	if not @employee.tags.nil?
		json.tags																	@employee.tags.split(',')
	else
		json.tags																	[]
	end
	if @employee.create_login == true
		json.login_account_created true
	else
		json.login_account_created false
	end
	begin
		json.avatar @employee.try(:avatar).url
	  json.avatar_file_name @employee.try(:avatar_file_name)
		if @employee.avatar_file_name.nil? or @employee.avatar_file_name.blank?
	    json.avatar_present false
	  else
	    json.avatar_present true
	  end
	rescue Exception => e
		json.avatar ""
		json.avatar_file_name ""
		json.avatar_present false
  end

  begin
    json.vaccinee @employee.try(:vaccinee).url
    json.vaccinee_file_name @employee.try(:vaccinee_file_name)
    if @employee.vaccinee_file_name.nil? or @employee.vaccinee_file_name.blank?
      json.vaccinee_present false
    else
      json.vaccinee_present true
    end
  rescue Exception => e
    json.vaccinee ""
    json.vaccinee_file_name ""
    json.vaccinee_present false
  end

end