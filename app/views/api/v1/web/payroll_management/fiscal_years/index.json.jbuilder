json.fiscal_years @fiscal_years do |fiscal_year|
  json.id							fiscal_year.try(:id)
  json.name 					fiscal_year.try(:name)
  json.start_date 		fiscal_year.try(:start_date).strftime("%B %-d, %Y")
  json.end_date 			fiscal_year.try(:end_date).strftime("%B %-d, %Y")
  json.is_active 			fiscal_year.try(:is_active)
end