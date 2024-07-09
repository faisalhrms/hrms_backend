json.fuel_card_details @fuel_card_details.each do |fuel_card_detail|
	json.id 											fuel_card_detail.try(:id)
	json.employee_name 						fuel_card_detail.try(:employee_name)
	json.employee_code 						fuel_card_detail.try(:employee_code)
	json.card_no 									fuel_card_detail.try(:card_no)
	json.card_name 								fuel_card_detail.try(:card_name)
	json.registration  						fuel_card_detail.try(:registration)
end