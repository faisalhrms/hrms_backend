class AttendanceRelaxationSlab < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:attendance_relaxation
	belongs_to 	:attendance_deduction
	belongs_to	:fallback, foreign_key: :fallback_id, :class_name => "AttendanceDeduction"

	def attendance_relaxation_name
  	if self.attendance_relaxation.nil?
  		return "-"
  	else
  		return self.attendance_relaxation.name
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
