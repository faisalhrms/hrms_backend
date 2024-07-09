json.eobi do
  json.id												@eobi.try(:id)
	json.company_id								@eobi.try(:company_id)
	json.name											@eobi.try(:name)
	json.is_active								@eobi.try(:is_active)
	json.employer_is_taxable			@eobi.try(:employer_is_taxable)
	json.employee_is_taxable			@eobi.try(:employee_is_taxable)
	json.employer_wage_rate				@eobi.try(:employer_wage_rate)
	json.employer_percentage			@eobi.try(:employer_percentage)
	json.employee_wage_rate				@eobi.try(:employee_wage_rate)
	json.employee_percentage			@eobi.try(:employee_percentage)
end