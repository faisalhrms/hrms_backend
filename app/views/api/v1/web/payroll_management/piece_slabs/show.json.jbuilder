json.piece_slab do
  json.id 								@piece_slab.try(:id)
  json.company_id 				@piece_slab.try(:company_id)
  json.name 							@piece_slab.try(:name)
  json.location_id 				@piece_slab.try(:location_id)
  json.is_active 					@piece_slab.try(:is_active)
  json.piece_slab_details 	@piece_slab.piece_slab_details.order('id ASC').each do |piece_slab_detail|
    json.piece_slab_detail_id						piece_slab_detail.try(:id)
    json.piece_slab_id									piece_slab_detail.try(:piece_slab_id)
    json.lower_limit									piece_slab_detail.try(:lower_limit)
    json.upper_limit									piece_slab_detail.try(:upper_limit)
    json.fixed_amount									piece_slab_detail.try(:fixed_amount)
  end
end