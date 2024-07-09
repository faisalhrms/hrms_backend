class AttendanceOvertimeSlab < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:attendance_overtime
	belongs_to 	:attendance_earning

	def attendance_overtime_name
  	if self.attendance_overtime.nil?
  		return "-"
  	else
  		return self.attendance_overtime.name
  	end
  end

  def attendance_earning_name
  	if self.attendance_earning.nil?
  		return "-"
  	else
  		return self.attendance_earning.name
  	end
  end

end
