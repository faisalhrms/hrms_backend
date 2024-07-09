json.time_slot do
  json.id           					@time_slot.try(:id)
	json.company_id 						@time_slot.try(:company_id)
	json.location_id 						@time_slot.try(:location_id)
	json.branch_id 							@time_slot.try(:branch_id)
	json.name 									@time_slot.try(:name)
	json.code 									@time_slot.try(:code)
	json.start_time 						@time_slot.try(:start_time)
	json.end_time 							@time_slot.try(:end_time)
	json.start_buffer 					@time_slot.try(:start_buffer)
	json.end_buffer 						@time_slot.try(:end_buffer)
	json.is_active 							@time_slot.try(:is_active)
	json.is_flexi 							@time_slot.try(:is_flexi)
	json.total_working_minutes 	@time_slot.try(:total_working_minutes)
	json.description 						@time_slot.try(:description)
	json.break_times @time_slot.break_times.order('id ASC').each do |break_time|
		json.break_time_id 		break_time.try(:id)
		json.name							break_time.try(:name)
		json.code							break_time.try(:code)
		json.start_time				break_time.try(:start_time)
		json.end_time					break_time.try(:end_time)
		json.excluded					break_time.try(:excluded)
	end
end