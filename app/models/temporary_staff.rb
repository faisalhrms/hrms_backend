class TemporaryStaff < ApplicationRecord

	########## Validation ############
	validates :temporary_staff_code, 			:uniqueness => { scope: :company_id }
  validates :cnic_number, 							:uniqueness => true
  validates :official_email,      			:uniqueness => { scope: :company_id }

  ####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
	belongs_to 	:designation
	belongs_to 	:job_title
	belongs_to 	:grade
	belongs_to 	:salary_unit
	belongs_to 	:cost_center

  has_many    :temp_staff_attendances,  :dependent => :destroy

  def make_employee
    if self.is_converted == true
      system_setting = SystemSetting.find_by(:company_id => self.company_id)
      new_employee_code = 0
      if not system_setting.nil?
        new_employee_code = system_setting.get_employee_code_prefix(system_setting, self.company_id, self.location_id, self.branch_id)
      end
      employee = Employee.new
      employee.salutation             = self.salutation
      employee.first_name             = self.first_name
      employee.last_name              = self.last_name
      employee.father_name            = self.father_name
      employee.official_email         = self.official_email
      employee.official_mobile_number = self.official_mobile_number
      employee.personal_email         = self.personal_email
      employee.personal_number        = self.personal_number
      employee.date_of_birth          = self.date_of_birth.to_date
      employee.gender                 = self.gender
      employee.cnic_number            = self.cnic_number
      employee.blood_group            = self.blood_group
      employee.martial_status         = self.martial_status
      employee.gross_salary           = self.gross_salary
      employee.current_address        = self.current_address
      employee.company_id             = self.company_id
      employee.location_id            = self.location_id
      employee.branch_id              = self.branch_id
      employee.department_id          = self.department_id
      employee.sub_department_id      = self.sub_department_id
      employee.grade_id               = self.grade_id
      employee.designation_id         = self.designation_id
      employee.job_title_id           = self.job_title_id
      employee.salary_unit_id         = self.salary_unit_id
      employee.cost_center_id         = self.cost_center_id
      employee.joining_date           = self.joining_date.to_date
      employee.current_address        = self.current_address
      employee.employee_code          = new_employee_code.to_i.to_s
      employee.prev_employee_code     = self.temporary_staff_code.to_i.to_s
      employee.save
    end
  end

  def self.location_related_employee(temp_staff_list, location_id)
    temporary_staffs = temp_staff_list.where(:location_id => location_id)
    return temporary_staffs
  end

  def self.branch_related_employee(temp_staff_list, branch_id)
    temporary_staffs = temp_staff_list.where(:branch_id => branch_id)
    return temporary_staffs
  end

  def self.department_related_employee(temp_staff_list, department_id)
    temporary_staffs = temp_staff_list.where(:department_id => department_id)
    return temporary_staffs
  end

  def self.designation_related_employee(temp_staff_list, designation_id)
    temporary_staffs = temp_staff_list.where(:designation_id => designation_id)
    return temporary_staffs
  end

  def self.job_title_related_employee(temp_staff_list, job_title_id)
    temporary_staffs = temp_staff_list.where(:job_title_id => job_title_id)
    return temporary_staffs
  end

  def self.grade_related_employee(temp_staff_list, grade_id)
    temporary_staffs = temp_staff_list.where(:grade_id => grade_id)
    return temporary_staffs
  end

  def self.salary_unit_related_employee(temp_staff_list, salary_unit_id)
    temporary_staffs = temp_staff_list.where(:salary_unit_id => salary_unit_id)
    return temporary_staffs
  end

  def self.cost_center_related_employee(temp_staff_list, cost_center_id)
    temporary_staffs = temp_staff_list.where(:cost_center_id => cost_center_id)
    return temporary_staffs
  end

	def full_name
    "#{self.first_name} #{self.last_name}"
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

	def job_title_name
		if self.job_title.nil?
  		return "-"
  	else
  		return self.job_title.name
  	end
	end
		
	def grade_name
		if self.grade.nil?
  		return "-"
  	else
  		return self.grade.name
  	end
	end
		
  def designation_name
  	if self.designation.nil?
  		return "-"
  	else
  		return self.designation.name
  	end
  end

  def salary_unit_name
  	if self.salary_unit.nil?
  		return "-"
  	else
  		return self.salary_unit.name
  	end
  end

  def cost_center_name
  	if self.cost_center.nil?
  		return "-"
  	else
  		return self.cost_center.name
  	end
  end

end
