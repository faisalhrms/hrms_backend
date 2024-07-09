json.time_slots @time_slots do |time_slot|
  json.id   						time_slot.try(:id)
  json.name 						time_slot.try(:name)
  json.code 						time_slot.try(:code)
  json.location_name 		time_slot.location_name
  json.branch_name 			time_slot.branch_name
  json.shift_timing 		"#{time_slot.actual_start_time} - #{time_slot.actual_end_time}"
  json.is_active 				time_slot.try(:is_active)
end