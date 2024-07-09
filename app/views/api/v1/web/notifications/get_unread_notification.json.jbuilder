count = 0
json.lastest_notifications @notis.each do |a_noti|
	json.id a_noti.try(:id)
	json.noti_date a_noti.notification.created_at.localtime.strftime("%B %d, %Y, %I:%M:%S %p")
	json.content a_noti.try(:content)
	json.did_read a_noti.try(:did_read)
	if a_noti.did_read == false
		count = count + 1
	end
end

json.un_read_noti_count count