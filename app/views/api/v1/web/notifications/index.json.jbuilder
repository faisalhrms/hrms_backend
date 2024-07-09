json.notifications @noti.each do |a_noti|
	json.id a_noti.try(:id)
	json.noti_date a_noti.notification.created_at.localtime.strftime("%B %d, %Y, %I:%M:%S %p")
	json.content a_noti.try(:content)
	json.did_read a_noti.try(:did_read)
	if a_noti.did_read == true
		json.noti_status "Read"
	else
		json.noti_status "Un-Read"
	end
end