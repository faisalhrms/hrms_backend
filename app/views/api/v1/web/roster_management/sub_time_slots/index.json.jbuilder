json.sub_time_slots @sub_time_slots do |sub_time_slot|
  json.id   						sub_time_slot.try(:id)
  json.name 						sub_time_slot.try(:name)
  json.code 						sub_time_slot.try(:code)
  json.location_name 		sub_time_slot.location_name
  json.branch_name 			sub_time_slot.branch_name
  json.time_slot_name 	sub_time_slot.time_slot_name
  json.shift_timing 		"#{sub_time_slot.actual_start_time} - #{sub_time_slot.actual_end_time}"
  json.is_active 				sub_time_slot.try(:is_active)
end