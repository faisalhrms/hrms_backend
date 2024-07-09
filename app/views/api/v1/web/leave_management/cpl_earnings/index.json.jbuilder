json.cpl_earnings @cpl_earnings do |attendance|
  json.id                attendance.try(:id)
  json.employee_code         attendance.employee.employee_code
  json.employee_name         attendance.employee_name
  json.status            attendance.status.titleize
  json.in_time            attendance.employee_attendance.in_time.strftime('%I:%M %p')
  json.out_time            attendance.employee_attendance.out_time.strftime('%I:%M %p')
  json.attendance_date   attendance.employee_attendance.attendance_date.to_date.strftime("%B %d, %Y")
  json.apply_date   attendance.created_at.to_date.strftime("%B %d, %Y")
end