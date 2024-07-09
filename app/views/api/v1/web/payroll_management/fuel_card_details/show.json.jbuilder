json.fuel_card_detail do
	json.id 											@fuel_card_detail.try(:id)
	json.employee_id							@fuel_card_detail.try(:employee_id)
	json.company_id								@fuel_card_detail.try(:company_id)
	json.card_no									@fuel_card_detail.try(:card_no)
	json.card_name								@fuel_card_detail.try(:card_name)
	json.registration							@fuel_card_detail.try(:registration)
	json.fleet_division						@fuel_card_detail.try(:fleet_division)
	json.quantity_consumed				@fuel_card_detail.try(:quantity_consumed)
	json.amount_consumed					@fuel_card_detail.try(:amount_consumed)
	json.last_km									@fuel_card_detail.try(:last_km)
	json.consumption							@fuel_card_detail.try(:consumption)
end