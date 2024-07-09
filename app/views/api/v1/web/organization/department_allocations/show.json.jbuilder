departments = Department.where(:company_id => @department_allocation.company_id, :is_active => true).order('id ASC')
json.department_allocation do 
	json.id 								@department_allocation.id
	json.company_id					@department_allocation.company_id
	json.location_id				@department_allocation.location_id
	json.branch_id					@department_allocation.branch_id
	json.name								@department_allocation.name
	json.description				@department_allocation.description
	json.department_allocation_details departments.each do |department|
		detail = @department_allocation.department_allocation_details.find_by(:department_id => department.id)
		if detail.nil?
			json.department_id 								department.id
			json.department_name 							department.name
			json.is_selected									false
		else
			json.detail_id 										detail.id
			json.department_allocation_id 		detail.department_allocation_id
			json.department_id 								detail.department_id
			json.department_name 							department.name
			json.is_selected									detail.is_selected	
		end			
	end
end