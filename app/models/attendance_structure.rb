class AttendanceStructure < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
	belongs_to 	:grade

	belongs_to 	:attendance_relaxation
	belongs_to 	:attendance_overtime
	belongs_to 	:absent_policy
	belongs_to 	:missing_punch
	belongs_to 	:early_left

  belongs_to  :regular_overtime,    foreign_key: :regular_overtime_id,   :class_name => "AttendanceOvertime"
  belongs_to  :holiday_overtime,    foreign_key: :holiday_overtime_id,   :class_name => "AttendanceOvertime"

  ########## Validation ############
  validate   :validate_struture_date

  ########## Validation of Attendance Structure ##########
  def validate_struture_date
    if self.id.present?
      AttendanceStructure.where.not(id:self.id).where(company_id: self.company_id, location_id: self.location_id, grade_id: self.grade_id, :branch_id => self.branch_id, :department_ids => self.department_ids, :is_active => true).each do |structure|
        if self.id != structure.id
          if structure.start_date.present? and structure.end_date.present?
            if (structure.start_date <= self.start_date and structure.end_date >= self.start_date) or (structure.end_date >= self.end_date and structure.start_date <= self.end_date)
              self.errors.add(:base, "Attendance Structure Already Exist! from #{structure.start_date.to_date.strftime("%d-%b-%Y")} to #{structure.end_date.to_date.strftime("%d-%b-%Y")}")
            end
          end
        end
      end
    else
      AttendanceStructure.where(company_id: self.company_id, location_id: self.location_id, grade_id: self.grade_id, :branch_id => self.branch_id, :department_ids => self.department_ids, :is_active => true).each do |structure|
        if self.id != structure.id
          if structure.start_date.present? and structure.end_date.present?
            if (structure.start_date <= self.start_date and structure.end_date >= self.start_date) or (structure.end_date >= self.end_date and structure.start_date <= self.end_date)
              self.errors.add(:base, "Attendance Structure Already Exist! from #{structure.start_date.to_date.strftime("%d-%b-%Y")} to #{structure.end_date.to_date.strftime("%d-%b-%Y")}")
            end
          end
        end
      end
    end
    logger.info "#{self.errors}"
  end

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def location_name
  	if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
  end

  	def branch_name
  	if self.branch.nil?
  		return "-"
  	else
  		return self.branch.name
  	end
  end

  def department_name
  	if self.department.nil?
  		return "-"
  	else
  		return self.department.name
  	end
  end

  def grade_name
  	if self.grade.nil?
  		return "-"
  	else
  		return self.grade.name
  	end
  end

  def attendance_relaxation_name
  	if self.attendance_relaxation.nil?
  		return "-"
  	else
  		return self.attendance_relaxation.name
  	end
  end

  def attendance_overtime_name
  	if self.attendance_overtime.nil?
  		return "-"
  	else
  		return self.attendance_overtime.name
  	end
  end

  def absent_policy_name
  	if self.absent_policy.nil?
  		return "-"
  	else
  		return self.absent_policy.name
  	end
  end

  def missing_punch_name
  	if self.missing_punch.nil?
  		return "-"
  	else
  		return self.missing_punch.name
  	end
  end

  def early_left_name
  	if self.early_left.nil?
  		return "-"
  	else
  		return self.early_left.name
  	end
  end

end
