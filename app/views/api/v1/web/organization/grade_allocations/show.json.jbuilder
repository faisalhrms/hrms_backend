grades = Grade.where(:company_id => @grade_allocation.company_id, :is_active => true).order('id ASC')
json.grade_allocation do 
	json.id 								@grade_allocation.id
	json.company_id					@grade_allocation.company_id
	json.location_id				@grade_allocation.location_id
	json.branch_id					@grade_allocation.branch_id
	json.name								@grade_allocation.name
	json.description				@grade_allocation.description
	json.grade_allocation_details grades.each do |grade|
		detail = @grade_allocation.grade_allocation_details.find_by(:grade_id => grade.id)
		if detail.nil?
			json.grade_id 							grade.id
			json.grade_name 						grade.name
			json.is_selected						false
		else
			json.detail_id 							detail.id
			json.grade_allocation_id 		detail.grade_allocation_id
			json.grade_id 							detail.grade_id
			json.grade_name 						grade.name
			json.is_selected						detail.is_selected	
		end			
	end
end