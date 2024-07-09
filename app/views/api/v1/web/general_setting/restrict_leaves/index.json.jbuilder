json.restrict_leaves @restrict_leaves do |asset_type|
  json.id   			      asset_type.try(:id)
  json.leave_days 			asset_type.try(:leave_days)
  json.approval_days 		asset_type.try(:approval_days)
  json.is_active 	      asset_type.try(:is_active)
  json.notification 	  asset_type.try(:notification)
  json.receiver_email 	asset_type.try(:receiver_email)
  json.user_id         	asset_type.try(:user_id)
  json.company_id      	asset_type.try(:company_id)

  next if asset_type.user_ids.blank?
  users = User.where(id: asset_type.try(:user_ids).parameterize.split('-'))

  json.users users.map{|user| "#{user.first_name}  #{user.last_name}" }.to_s
end