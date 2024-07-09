class EarlyLeftSlab < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:early_left
	belongs_to 	:attendance_deduction
	belongs_to	:fallback, foreign_key: :fallback_id, :class_name => "AttendanceDeduction"

	def early_left_name
  	if self.early_left.nil?
  		return "-"
  	else
  		return self.early_left.name
  	end
  end

  def attendance_deduction_name
  	if self.attendance_deduction.nil?
  		return "-"
  	else
  		return self.attendance_deduction.name
  	end
  end

  def fallback_name
  	if self.fallback.nil?
  		return "-"
  	else
  		return self.fallback.name
  	end
  end

end
