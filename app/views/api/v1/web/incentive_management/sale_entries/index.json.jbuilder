json.sale_entries @sale_entries.each do |sale_entry|
	json.id 						sale_entry.id
	json.location_name 	sale_entry.location_name
	json.branch_name 		sale_entry.branch_name
	json.name 					sale_entry.try(:name)
  if sale_entry.sale_month.present?
	json.sale_month 		sale_entry.try(:sale_month).to_date.strftime("%B %Y")
  end
	json.sale_value 		sale_entry.try(:sale_value)
  json.incentive_payable 		sale_entry.try(:incentive_payable)
  json.target_value 	sale_entry.try(:target_value)
end