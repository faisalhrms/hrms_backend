json.user_activities @user_activities.each do |user_activity|
	json.id 								user_activity.try(:id)
	json.full_name 					user_activity.try(:full_name)
	json.email 							user_activity.try(:email)
	json.action_performed 	user_activity.try(:action_performed)
	json.action_time 				user_activity.try(:created_at).localtime.strftime('%d-%b-%Y %I:%M:%S %p')
	json.ip_address 				user_activity.try(:ip_address)
	json.role_name 					user_activity.try(:role_name)
end