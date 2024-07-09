json.finalize_attendances @finalize_attendances.order('attendance_date ASC').each do |finalize_attendance|
	json.finalize_attendance_id 				finalize_attendance.try(:id)
	json.attendance_date 								ReportFormat.date_format1(finalize_attendance.try(:attendance_date))
	json.arrear_days 										finalize_attendance.try(:arrear_days)
	json.pay_deduction 									finalize_attendance.try(:pay_deduction)
	json.over_time_hours 								finalize_attendance.try(:over_time_hours)
	json.off_day_payment 								finalize_attendance.try(:off_day_payment)
	json.encashable_quota 							finalize_attendance.try(:encashable_quota)
end