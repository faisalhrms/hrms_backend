json.employee_relatives @employee.employee_relatives.order('id ASC').each do |employee_relative|
	json.id 																employee_relative.try(:id)
	json.employee_relative_id 							employee_relative.try(:id)
	json.employee_id 												employee_relative.try(:employee_id)
	json.relative_name 											employee_relative.try(:relative_name)
	json.relationship_id 										employee_relative.try(:relationship_id)
	json.relationship_name 									employee_relative.relationship_name
	json.email 															employee_relative.try(:email)
	json.contact_number 										employee_relative.try(:contact_number)
	json.date_of_birth 											employee_relative.try(:date_of_birth)
	json.date_of_enrollment									employee_relative.try(:date_of_enrollment)
	json.gender 														employee_relative.try(:gender)
	json.cnic_number 												employee_relative.try(:cnic_number)
	json.is_dependent 											employee_relative.try(:is_dependent)
	json.insurance_allowed									employee_relative.try(:insurance_allowed)
	json.same_as_employee_address 					employee_relative.try(:same_as_employee_address)
	json.same_as_employee_permanent_address employee_relative.try(:same_as_employee_address)
	json.address 														employee_relative.try(:address)
  json.martial_status 										employee_relative.try(:martial_status)
  json.deceased 													employee_relative.try(:deceased)
  json.covid_vaccination		  						employee_relative.try(:covid_vaccination)

  if employee_relative.date_of_birth.nil?
		json.relative_age 										0
	else	
		json.relative_age 										Time.now.year - employee_relative.date_of_birth.year
	end
end

json.employee_next_of_kins @employee.employee_next_of_kins.order('id ASC').each do |employee_next_of_kin|
	json.id 																employee_next_of_kin.try(:id)
	json.employee_next_of_kin_id 						employee_next_of_kin.try(:id)
	json.employee_id 												employee_next_of_kin.try(:employee_id)
	json.employee_relative_id 							employee_next_of_kin.try(:employee_relative_id)
	json.relationship_id 										employee_next_of_kin.try(:relationship_id)
	json.guardian_id 												employee_next_of_kin.try(:guardian_id)
	json.relative_name 											employee_next_of_kin.employee_relative_name
	json.relationship_name 									employee_next_of_kin.relationship_name
	json.relative_age 											employee_next_of_kin.try(:relative_age)
	json.percentage 												employee_next_of_kin.try(:percentage)
end

json.employee_references @employee.employee_references.order('id ASC').each do |employee_reference|
	json.id 													employee_reference.try(:id)
	json.employee_reference_id 				employee_reference.try(:id)
	json.employee_id 									employee_reference.try(:employee_id)
	json.reference_type 							employee_reference.try(:reference_type)
	json.name 												employee_reference.try(:name)
	json.email 												employee_reference.try(:email)
	json.contact_number 							employee_reference.try(:contact_number)
	json.organization 								employee_reference.try(:organization)
	json.designation 									employee_reference.try(:designation)
	json.address 											employee_reference.try(:address)
end

json.employee_qualifications @employee.employee_qualifications.order('id ASC').each do |employee_qualification|
	json.id 																	employee_qualification.try(:id)
	json.employee_qualification_id 						employee_qualification.try(:id)
	json.employee_id 													employee_qualification.try(:employee_id)
	json.qualfication_type_id 								employee_qualification.try(:qualfication_type_id)
	json.qualification_program_id							employee_qualification.try(:qualification_program_id)
	json.specialization_id										employee_qualification.try(:specialization_id)
	json.institute_name 											employee_qualification.try(:institute_name)
	json.qualification_level 									employee_qualification.try(:qualification_level)
	json.program_name 												employee_qualification.program_name
	json.specialization_name 									employee_qualification.specialization_name
	json.status 															employee_qualification.try(:status)
	json.start_date 													employee_qualification.start_date
	json.end_date 														employee_qualification.end_date
	json.status_text 													employee_qualification.try(:status_text)
	json.gpa_or_percentage 										employee_qualification.try(:gpa_or_percentage)
	begin
		json.avatar employee_qualification.try(:avatar).url
	  json.avatar_file_name employee_qualification.try(:avatar_file_name)
		if employee_qualification.avatar_file_name.nil? or employee_qualification.avatar_file_name.blank?
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

json.employee_experiences @employee.employee_experiences.order('id ASC').each do |employee_experience|
	json.id 														employee_experience.try(:id)
	json.employee_experience_id 				employee_experience.try(:id)
	json.employee_id 										employee_experience.try(:employee_id)
	json.organization 									employee_experience.try(:organization)
	json.job_title 											employee_experience.try(:job_title)
  json.department 										employee_experience.try(:department)
  json.other_benefits 								employee_experience.try(:other_benefits)
  json.left_reason 										employee_experience.try(:left_reason)
	json.salary 												employee_experience.try(:salary)
	json.start_date 										ReportFormat.date_format(employee_experience.try(:start_date))
	json.end_date 											ReportFormat.date_format(employee_experience.try(:end_date))
	begin
		json.avatar employee_experience.try(:avatar).url
	  json.avatar_file_name employee_experience.try(:avatar_file_name)
		if employee_experience.avatar_file_name.nil? or employee_experience.avatar_file_name.blank?
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

json.employee_memberships @employee.employee_memberships.order('id ASC').each do |employee_membership|
  json.id 														employee_membership.try(:id)
  json.employee_membership_id  				employee_membership.try(:id)
  json.employee_id 										employee_membership.try(:employee_id)
  json.position_title 								employee_membership.try(:position_title)
  json.institute_name 								employee_membership.try(:institute_name)
  json.remarks 												employee_membership.try(:remarks)
  json.start_date 										ReportFormat.date_format(employee_membership.try(:start_date))
  json.end_date 											ReportFormat.date_format(employee_membership.try(:end_date))
  begin
    json.avatar employee_membership.try(:avatar).url
    json.avatar_file_name employee_membership.try(:avatar_file_name)
    if employee_membership.avatar_file_name.nil? or employee_membership.avatar_file_name.blank?
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

json.employee_documents @employee.employee_documents.order('id ASC').each do |employee_documents|
  json.id 														employee_documents.try(:id)
  json.employee_document_id  	   			employee_documents.try(:id)
  json.employee_id 										employee_documents.try(:employee_id)
  json.document_name 						  		employee_documents.try(:document_name)
  json.document_remarks 							employee_documents.try(:document_remarks)
  begin
    json.avatar employee_documents.try(:avatar).url
    json.avatar_file_name employee_documents.try(:avatar_file_name)
    if employee_documents.avatar_file_name.nil? or employee_documents.avatar_file_name.blank?
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

json.employee_trainings @employee.employee_trainings.order('id ASC').each do |employee_training|
	json.id 													employee_training.try(:id)
	json.employee_training_id 				employee_training.try(:id)
	json.employee_id 									employee_training.try(:employee_id)
	json.organization 								employee_training.try(:organization)
	json.name 												employee_training.try(:name)
	json.training_type 								employee_training.try(:training_type)
	json.percentage 									employee_training.try(:percentage)
	json.start_date 									ReportFormat.date_format(employee_training.try(:start_date))
	json.end_date 										ReportFormat.date_format(employee_training.try(:end_date))
	begin
		json.avatar employee_training.try(:avatar).url
	  json.avatar_file_name employee_training.try(:avatar_file_name)
		if employee_training.avatar_file_name.nil? or employee_training.avatar_file_name.blank?
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

json.employee_certifications @employee.employee_certifications.order('id ASC').each do |employee_certification|
	json.id 													employee_certification.try(:id)
	json.employee_certification_id 		employee_certification.try(:id)
	json.employee_id 									employee_certification.try(:employee_id)
	json.certification_authority 			employee_certification.try(:certification_authority)
	json.name 												employee_certification.try(:name)
	json.certification_type 					employee_certification.try(:certification_type)
	json.percentage 									employee_certification.try(:percentage)
	json.start_date 									ReportFormat.date_format(employee_certification.try(:start_date))
	json.end_date 										ReportFormat.date_format(employee_certification.try(:end_date))
	begin
		json.avatar employee_certification.try(:avatar).url
	  json.avatar_file_name employee_certification.try(:avatar_file_name)
		if employee_certification.avatar_file_name.nil? or employee_certification.avatar_file_name.blank?
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

json.fixed_pay_items @employee.fixed_pay_items.order('id').each do |fixed_pay_item|
	json.id 											fixed_pay_item.try(:id)
	json.employee_name 						fixed_pay_item.employee_name
	json.employee_code 						fixed_pay_item.employee_code
	json.pay_item_name 						fixed_pay_item.pay_item_name
	json.item_amount 							fixed_pay_item.try(:item_amount)
	json.is_active 								fixed_pay_item.try(:is_active)
end