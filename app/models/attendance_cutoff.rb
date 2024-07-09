class AttendanceCutoff < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :branch_id }

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
  belongs_to  :salary_unit

  ########## Validation ############
  validate   :validate_cutoff_date

  ########## Validation of Attendance Cutoff ##########
  def validate_cutoff_date
    if self.id.present?
      AttendanceCutoff.where.not(id:self.id).where(company_id: self.company_id, location_id: self.location_id, branch_id: self.branch_id, salary_unit_id: self.salary_unit_id).each do |attendance_cutoff|
        if self.id != attendance_cutoff.id
          if attendance_cutoff.start_date.present? and attendance_cutoff.end_date.present?
            if (attendance_cutoff.start_date <= self.start_date and attendance_cutoff.end_date >= self.start_date) or (attendance_cutoff.end_date >= self.end_date and attendance_cutoff.start_date <= self.end_date)
              self.errors.add(:base, "Attendance Cutoff Already Exist! from #{attendance_cutoff.start_date.to_date.strftime("%d-%b-%Y")} to #{attendance_cutoff.end_date.to_date.strftime("%d-%b-%Y")}")
            end
          end
        end
      end
    else
      AttendanceCutoff.where(company_id: self.company_id, location_id: self.location_id, branch_id: self.branch_id, salary_unit_id: self.salary_unit_id).each do |attendance_cutoff|
        if self.id != attendance_cutoff.id
          if attendance_cutoff.start_date.present? and attendance_cutoff.end_date.present?
            if (attendance_cutoff.start_date <= self.start_date and attendance_cutoff.end_date >= self.start_date) or (attendance_cutoff.end_date >= self.end_date and attendance_cutoff.start_date <= self.end_date)
              self.errors.add(:base, "Attendance Cutoff Already Exist! from #{attendance_cutoff.start_date.to_date.strftime("%d-%b-%Y")} to #{attendance_cutoff.end_date.to_date.strftime("%d-%b-%Y")}")
            end
          end
        end
      end
    end
    logger.info "#{self.errors}"
  end

  has_many    :finalize_attendances

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

  def salary_unit_name
    if self.salary_unit.nil?
      return "-"
    else
      return self.salary_unit.name
    end
  end

  def self.get_attendance_cutoff_date_range(employee_attendance)
    cufoff_data = AttendanceCutoff.where(:company_id => employee_attendance.company_id, :salary_unit_id => employee_attendance.salary_unit_id, :salary_unit_wise => true).where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date)
    if cufoff_data.count == 0
      cufoff_data = AttendanceCutoff.where(:company_id => employee_attendance.company_id, :location_id => employee_attendance.location_id, :branch_id => employee_attendance.branch_id, :salary_unit_wise => false).where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date)  
    end
    if cufoff_data.count == 1
      return date_range = cufoff_data.first.start_date.to_date..cufoff_data.first.end_date.to_date 
    else
      return nil
    end
  end
	
end
