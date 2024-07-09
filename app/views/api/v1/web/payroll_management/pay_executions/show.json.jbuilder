pay_items 		= PayItem.where(:company_id => @pay_execution.company_id, :is_active => true, :is_static_item => false).order('id ASC')
pay_item_ids 	= @pay_execution.item_execution_details.collect(&:pay_item_id)
json.pay_execution do
	json.id 												@pay_execution.try(:id)
	json.name 											@pay_execution.try(:name)
	json.company_id 								@pay_execution.try(:company_id)
	json.location_id 								@pay_execution.try(:location_id)
	if @pay_execution.grade_ids.nil?
		json.grade_ids 								[]
	else
		json.grade_ids 								@pay_execution.try(:grade_ids).split(',').map(&:to_i)
	end
	if @pay_execution.attendance_cutoff_ids.nil?
		json.attendance_cutoff_ids 								[]
	else
		json.attendance_cutoff_ids 		@pay_execution.try(:attendance_cutoff_ids).split(',').map(&:to_i)
	end
	json.allowed_urdu								@pay_execution.try(:allowed_urdu)
	json.provident_fund_id 					@pay_execution.try(:provident_fund_id)
	json.eobi_id 										@pay_execution.try(:eobi_id)
	json.tax_slab_id 								@pay_execution.try(:tax_slab_id)
	json.fiscal_year_id 						@pay_execution.try(:fiscal_year_id)
	json.pay_month 									@pay_execution.try(:pay_month)
	json.formated_pay_month 				@pay_execution.try(:formated_pay_month)
	json.tax_applicable 						@pay_execution.try(:tax_applicable)
	json.no_of_pay_days 						@pay_execution.try(:no_of_pay_days)
	json.per_litre_rate 						@pay_execution.try(:per_litre_rate)
	json.start_date 								@pay_execution.try(:start_date)
	json.end_date 									@pay_execution.try(:end_date)
	json.incentive_impact_on_tax		@pay_execution.try(:incentive_impact_on_tax)
	json.incentive_month						@pay_execution.try(:incentive_month)
	json.prediction_tax_impact			@pay_execution.try(:prediction_tax_impact)
	json.opd_impact_on_arrear				@pay_execution.try(:opd_impact_on_arrear)
	json.vehicle_impact_on_tax			@pay_execution.try(:vehicle_impact_on_tax)
	json.vehicle_tax_percentage			@pay_execution.try(:vehicle_tax_percentage)
	json.vehicle_monthly_prorated		@pay_execution.try(:vehicle_monthly_prorated)
	json.exclude_sunday							@pay_execution.try(:exclude_sunday)
	json.joining_exception_pay_days							@pay_execution.try(:joining_exception_pay_days)
	json.joining_exception_formated_month				@pay_execution.try(:joining_exception_formated_month)
	json.joining_exception_month								@pay_execution.try(:joining_exception_month)
	json.joining_exception											@pay_execution.try(:joining_exception)
	json.allowed_extra_days											@pay_execution.try(:allowed_extra_days)
	json.item_details				pay_items.each do |pay_item|
		if pay_item_ids.include?(pay_item.id) == true
			item_execution_detail = @pay_execution.item_execution_details.find_by(:pay_item_id => pay_item.id, :pay_execution => @pay_execution.id)
	  	json.item_execution_detail_id 						item_execution_detail.id
			json.name 																item_execution_detail.pay_item_name
			json.id 																	item_execution_detail.pay_item_id
			json.status 															item_execution_detail.status
		else
			json.id   																pay_item.try(:id)
		  json.name 																pay_item.try(:name)
			json.status 															"Not Allowed"
	  end
	end
end