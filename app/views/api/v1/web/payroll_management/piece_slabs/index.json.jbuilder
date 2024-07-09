json.piece_slabs @piece_slabs.each do |piece_slab|
  json.id 					piece_slab.try(:id)
  json.name 				piece_slab.try(:name)
  json.is_active 		piece_slab.try(:is_active)
end


