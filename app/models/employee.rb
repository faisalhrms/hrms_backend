class Employee < ApplicationRecord

  MIN_GROSS_FOR_HEALTH_INSURANCE = 22000.0

	has_attached_file :avatar,
										:url => "#{ENV['APP_URL']}/system/:class/:attachment/:id/:style/:filename",
										:path => ":rails_root/public/system/:class/:attachment/:id/:style/:filename",
										:default_url => "#{ENV['APP_URL']}/system/profile-placeholder.jpg"

	validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif" ]


  has_attached_file :vaccinee,
                    :url => "#{ENV['APP_URL']}/system/vaccine_certificate/:id/:style/:filename",
                    :path => ":rails_root/public/system/vaccine_certificate/:id/:style/:filename",
                    :default_url => "#{ENV['APP_URL']}/system/profile-placeholder.jpg"

  validates_attachment_content_type :vaccinee, :content_type => ["application/pdf", "image/jpg", "image/jpeg", "image/png", "image/gif" ]


  ########## Validation ############
	validates :employee_code, 			:uniqueness => { scope: :company_id }

  ########## Validation ############
  # validate   :validate_cnic_number

  ########## Validation of CNIC Number ##########

  scope :get_by_company, -> (company_id) {where(company_id: company_id)}
  scope :active, -> {where(is_active: true)}
  scope :get_by_hiring_shift, -> (hiring_shift){where(hiring_shift_id: hiring_shift)}
  scope :get_by_employee_code, -> (employee_codes){where(employee_code: employee_codes)}
  scope :health_insurance_employees, -> {where('gross_salary > ?', MIN_GROSS_FOR_HEALTH_INSURANCE)}
  scope :struck_off, -> {where(is_struck_off: true)}
  scope :non_struck_off, -> {where(is_struck_off: false)}

  def validate_cnic_number
    count = 0
    if self.id.present?
      Employee.where.not(id:self.id).where(:is_active => true).each do |employee|
        if self.id != employee.id
          if employee.cnic_number.present?
            if not employee.cnic_number.nil?
              if employee.cnic_number.gsub('-','') == self.cnic_number.gsub('-','')
                count = count + 1
              end
            end
          end
        end
      end
    else
      Employee.where(:is_active => true).each do |employee|
        if self.id != employee.id
          if employee.cnic_number.present?
            if not employee.cnic_number.nil?
              if employee.cnic_number.gsub('-','') == self.cnic_number.gsub('-','')
                count = count + 1
              end
            end
          end
        end
      end
    end
    if count >= 1
      self.errors.add(:base, "CNIC Number Already Exist!")  
    end
  end

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
  belongs_to  :sub_department
  belongs_to 	:designation
	belongs_to 	:job_title
	belongs_to 	:grade
	belongs_to 	:salary_unit
	belongs_to 	:cost_center
	belongs_to 	:relationship
	belongs_to 	:religion_sect
	belongs_to 	:religion
  belongs_to  :employee_type
	belongs_to 	:user
	belongs_to	:country, 				foreign_key: :current_country_id, 	:class_name => "Country"
	belongs_to	:state, 					foreign_key: :current_state_id, 		:class_name => "State"
	belongs_to	:city, 						foreign_key: :current_city_id, 			:class_name => "City"
	belongs_to	:division, 				foreign_key: :current_division_id, 	:class_name => "Division"
	belongs_to	:district, 				foreign_key: :current_district_id, 	:class_name => "District"
	belongs_to	:tehsil, 					foreign_key: :current_tehsil_id, 		:class_name => "Tehsil"
	belongs_to	:line_manager, 		foreign_key: :line_manager_id, 			:class_name => "Employee"
  belongs_to	:head_of_department, 		foreign_key: :hod_id, 			:class_name => "Employee"
	belongs_to	:hire_shift, 		  foreign_key: :hiring_shift_id, 			:class_name => "GeneralType"

  belongs_to	:permanent_country, 				foreign_key: :permanent_country_id, 	:class_name => "Country"
  belongs_to	:permanent_state, 					foreign_key: :permanent_state_id, 		:class_name => "State"
  belongs_to	:permanent_city, 						foreign_key: :permanent_city_id, 			:class_name => "City"

	has_many		:leave_transaction_histories
  has_many    :sub_ordinates,                     foreign_key: :line_manager_id,      :class_name => "Employee"
	has_many 		:employee_relatives, 								:dependent => :destroy
	has_many 		:employee_next_of_kins, 						:dependent => :destroy
	has_many 		:employee_references, 							:dependent => :destroy
	has_many 		:employee_qualifications, 					:dependent => :destroy
  has_many    :employee_certifications,           :dependent => :destroy
	has_many 		:employee_experiences, 							:dependent => :destroy
	has_many 		:employee_trainings, 								:dependent => :destroy
  has_many    :employee_memberships,              :dependent => :destroy
  has_many    :employee_documents,                :dependent => :destroy
  has_many 		:employee_transaction_histories, 		:dependent => :destroy
	has_many		:leave_allocations, 								:dependent => :destroy
	has_many		:leave_requests, 										:dependent => :destroy
  has_many    :official_duties,                   :dependent => :destroy
  has_many    :relaxation_requests,               :dependent => :destroy
  has_many    :employee_sale_incentives,          :dependent => :destroy
  has_many    :fixed_pay_items,                   :dependent => :destroy
  has_many    :employee_loans,                    :dependent => :destroy
  has_many    :employee_advances,                 :dependent => :destroy
  has_many    :employee_tax_credits,              :dependent => :destroy
  has_many    :employee_taxable_incomes,          :dependent => :destroy
  has_many    :pay_invoices,                      :dependent => :destroy
  has_many    :request_flow_details,              :dependent => :destroy  
  has_many    :employee_rosters,                  :dependent => :destroy  
  has_many    :employee_attendances,              :dependent => :destroy

	has_many    :sender_approval_requests, 		foreign_key: :request_sender_id, 		:class_name => "ApprovalRequest", :dependent => :destroy
	has_many    :receiver_approval_requests, 	foreign_key: :request_receiver_id, 	:class_name => "ApprovalRequest", :dependent => :destroy
	has_many :objective_settings
	has_many :appraisals
	after_create		:create_user_account
	after_destroy 	:delete_user_account
  # after_update    :update_user_account

	def create_user_account
		########## Login Account Creation ##########
		if self.create_login == true
			if self.user.nil?
				new_user = User.create(:email => self.user_account_email, :password => self.user_account_password, :first_name => self.first_name, :last_name => self.last_name, :is_confirmed => true, :role_id => self.role_id, :is_admin => self.is_admin, :custom_right => self.custom_right, :is_company_head => self.is_company_head, :is_location_head => self.is_location_head, :is_branch_head => self.is_branch_head, :is_department_head => self.is_department_head, :company_id => self.company_id, :is_sub_department_head => self.is_sub_department_head)
				encrpted_password = BCrypt::Password.create(self.user_account_password)
				self.user_id = new_user.id
				self.user_account_password = encrpted_password
				self.save
			end
		end
		########## Auto Leave Allocation on new enroll employee ##########
    LeaveType.where(:company_id => self.company_id, :is_active => true, :location_id => self.location_id, :auto_allocation => true).each do |leave_type|
      grade_condition = true
      if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
        grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? self.grade_id
      end
      if grade_condition
        leave_allocation = LeaveAllocation.create(:location_id => self.location_id, :is_active => true, :company_id => self.company_id, :leave_type_id => leave_type.id, :employee_id => self.id)
        if not leave_allocation.nil?
          leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
          if not leave_transaction.nil?
            leave_transaction.leave_allocation_id = leave_allocation.id
            leave_transaction.save
          end
        end
      end
    end
    ########## Auto Benefit Allocation on new enroll employee ##########
    benefit_structure = BenefitStructure.find_by(:company_id => self.company_id, :location_id => self.location_id, :grade_id => self.grade_id, :employee_type_id => self.employee_type.id, :is_active => true)
    if not benefit_structure.nil?
      self.social_security_allowed            = benefit_structure.social_security_allowed
      self.social_security_eligibility        = benefit_structure.social_security_eligibility
      self.social_security_joining_salary     = benefit_structure.social_security_joining_salary
      self.life_insurance_allowed             = benefit_structure.life_insurance_allowed
      self.life_insurance_eligibility         = benefit_structure.life_insurance_eligibility
      self.life_insurance_value               = benefit_structure.life_insurance_value
      self.health_insurance_allowed           = benefit_structure.health_insurance_allowed
      self.health_insurance_plan              = benefit_structure.health_insurance_plan
      self.health_insurance_eligibility       = benefit_structure.health_insurance_eligibility
      self.cell_phone_bill_allowed            = benefit_structure.cell_phone_bill_allowed
      self.cell_phone_bill_eligibility        = benefit_structure.cell_phone_bill_eligibility
      self.cell_phone_bill_limit              = benefit_structure.cell_phone_bill_limit
      self.cell_phone_bill_amount             = benefit_structure.cell_phone_bill_amount
      self.fuel_allowed                       = benefit_structure.fuel_allowed
      self.fuel_eligibility                   = benefit_structure.fuel_eligibility
      self.fuel_limit                         = benefit_structure.fuel_limit
      self.fuel_value                         = benefit_structure.fuel_value
      self.cell_phone_allowed                 = benefit_structure.cell_phone_allowed
      self.cell_phone_eligibility             = benefit_structure.cell_phone_eligibility
      self.cell_phone_entitlement_upto        = benefit_structure.cell_phone_entitlement_upto
      self.laptop_allowed                     = benefit_structure.laptop_allowed
      self.laptop_eligibility                 = benefit_structure.laptop_eligibility
      self.laptop_entitlement_upto            = benefit_structure.laptop_entitlement_upto
      self.laptop_category                    = benefit_structure.laptop_category
      self.velicle_allowed                    = benefit_structure.velicle_allowed
      self.velicle_eligibility                = benefit_structure.velicle_eligibility
      self.provident_fund_allowed             = benefit_structure.provident_fund_allowed
      self.provident_fund_eligibility         = benefit_structure.provident_fund_eligibility
      self.eobi_allowed                       = benefit_structure.eobi_allowed
      self.eobi_eligibility                   = benefit_structure.eobi_eligibility
      self.incentive_allowed                  = benefit_structure.incentive_allowed
      self.incentive_eligibility              = benefit_structure.incentive_eligibility
      self.vehicle_allowance_allowed          = benefit_structure.vehicle_allowance_allowed
      self.vehicle_allowance_eligibility      = benefit_structure.vehicle_allowance_eligibility
      self.vehicle_allowance_entitlement_upto = benefit_structure.vehicle_allowance_entitlement_upto
      self.maintenance_allowed                = benefit_structure.maintenance_allowed
      self.maintenance_eligibility            = benefit_structure.maintenance_eligibility
      self.maintenance_entitlement_upto       = benefit_structure.maintenance_entitlement_upto
      self.travel_allowance_allowed           = benefit_structure.travel_allowance_allowed
      self.travel_allowance_eligibility       = benefit_structure.travel_allowance_eligibility
      self.travel_allowance_entitlement_upto  = benefit_structure.travel_allowance_entitlement_upto
      self.is_overtime                        = benefit_structure.overtime_allowed
      self.is_cpl                             = benefit_structure.cpl_allowed
      self.is_off_day_working                 = benefit_structure.off_day_allowed
      self.regular_quota_encashment           = benefit_structure.regular_quota_encashment
      self.holiday_quota_encashment           = benefit_structure.holiday_quota_encashment
      self.is_regular_cpl                     = benefit_structure.is_regular_cpl
      self.is_holiday_overtime                = benefit_structure.is_holiday_overtime
      self.bonus1_allowed                     = benefit_structure.bonus1_allowed
      self.bonus1_eligibility                 = benefit_structure.bonus1_eligibility
      self.bonus2_allowed                     = benefit_structure.bonus2_allowed
      self.bonus2_eligibility                 = benefit_structure.bonus2_eligibility
      self.bonus3_allowed                     = benefit_structure.bonus3_allowed
      self.bonus3_eligibility                 = benefit_structure.bonus3_eligibility
      self.gratuity_allowed                   = benefit_structure.gratuity_allowed
      self.gratuity_eligibility               = benefit_structure.gratuity_eligibility
      self.lfa_allowed                        = benefit_structure.lfa_allowed
      self.lfa_eligibility                    = benefit_structure.lfa_eligibility
      self.house_allowance_allowed            = benefit_structure.house_allowance_allowed
      self.house_allowance_eligibility        = benefit_structure.house_allowance_eligibility
      self.approval_base_overtime             = benefit_structure.approval_base_overtime
      self.save
    end
    Employee.create_employee_roster(self)
	end

  def update_user_account
    if self.is_active == false
      ########## De-Active User Account ##########
      if not self.user.nil?
        user = self.user
        user.is_active = false
        user.save
      end
      ########## De-Active Employee Leave ##########
      LeaveAllocation.where(:employee_id => self.id, :is_active => true).each do |leave_allocation|
        leave_allocation.is_active = false
        leave_allocation.save(:validate => false)
      end
    end
  end

  def self.create_employee_roster(employee)
    if not employee.roster_employee_id.nil?
      begin
        roster_employee = Employee.find(employee.roster_employee_id)
        employee_rosters = roster_employee.employee_rosters.where('roster_date >= ?', employee.joining_date.to_date)
        employee_rosters.each do |present_roster|
          new_roster = EmployeeRoster.new
          new_roster.employee_id  = employee.id
          new_roster.company_id   = employee.company_id
          new_roster.location_id  = employee.location_id
          new_roster.branch_id    = employee.branch_id
          new_roster.department_id  = employee.department_id
          new_roster.grade_id       = employee.grade_id
          new_roster.joining_date   = employee.joining_date.to_date
          new_roster.employee_code  = employee.employee_code
          new_roster.employee_name  = employee.full_name
          new_roster.location_name  = employee.location_name
          new_roster.branch_name    = employee.branch_name
          new_roster.department_name  = employee.department_name
          new_roster.grade_name       = employee.grade_name
          new_roster.time_slot_id   = present_roster.time_slot_id
          new_roster.roster_date    = present_roster.roster_date.to_date
          new_roster.start_time     = present_roster.start_time
          new_roster.end_time       = present_roster.end_time
          new_roster.is_flexi       = present_roster.is_flexi
          new_roster.is_rest_day    = present_roster.is_rest_day
          new_roster.formated_start_time  = present_roster.formated_start_time
          new_roster.formated_end_time    = present_roster.formated_end_time
          new_roster.start_buffer   = present_roster.start_buffer
          new_roster.end_buffer     = present_roster.end_buffer
          new_roster.is_transfer    = false
          new_roster.is_edited      = false
          new_roster.save
        end
      rescue ActiveRecord::RecordNotFound
        puts "\n\n Roster Employee Not Found \n\n"
      end
    end
  end


  def self.effective_gross_salary(employee, pay_invoice)
    gross_salary = employee.gross_salary
    if employee.company.effective_gross
      transaction_histories = employee.employee_transaction_histories.where(transaction_type: "Gross Salary").where("transaction_date >= ? and transaction_date <= ?", pay_invoice.pay_month.to_time.beginning_of_month, pay_invoice.pay_month.to_time.end_of_month)
      if transaction_histories.present?
        transaction_history = transaction_histories.last
        joining_days = 1
        if employee.joining_date.to_date.month == pay_invoice.pay_month.to_time.month
          joining_days = employee.joining_date.to_date.day
        end
        old_gross = ((transaction_history.transaction_date.to_date.day - joining_days) * transaction_history.old_gross_salary) / EmployeeTransactionHistory::MONTH_DAYS
        new_gross = ((transaction_history.transaction_date.to_date.end_of_month.day - transaction_history.transaction_date.to_date.day + 1) * transaction_history.new_gross_salary) / EmployeeTransactionHistory::MONTH_DAYS
        gross_salary = old_gross + new_gross
      end
    end
    gross_salary
  end


	def delete_user_account
		########## Delete Login Account ##########
		if not self.user.nil?
			self.user.destroy
		end
	end

	def verify_user_account
		if self.create_login == true
      if self.user.nil?
        user_account = User.create(:email => self.user_account_email, :password => self.user_account_password, :first_name => self.first_name, :last_name => self.last_name, :is_confirmed => true, :role_id => self.role_id, :is_admin => self.is_admin, :custom_right => self.custom_right, :is_company_head => self.is_company_head, :is_location_head => self.is_location_head, :is_branch_head => self.is_branch_head, :is_department_head => self.is_department_head, :company_id => self.company_id)
        if not user_account.nil?
          encrpted_password = BCrypt::Password.create(self.user_account_password)
          self.user_id = user_account.id
          self.user_account_password = encrpted_password
          self.save
        end
      end
    end
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

  def shop_id_name
    if self.branch.nil?
      return "-"
    else
      return self.branch.shop_id
    end
  end

	def department_name
		if self.department.nil?
  		return "-"
  	else
  		return self.department.name
  	end
	end

  def sub_department_name
    if self.sub_department.nil?
      return "-"
    else
      return self.sub_department.name
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

  def permanent_country_name
  	if self.permanent_country.nil?
  		return "-"
  	else
  		return self.permanent_country.name
  	end
  end
  def country_name
    if self.country.nil?
      return "-"
    else
      return self.country.name
    end
  end

  def state_name
  	if self.state.nil?
  		return "-"
  	else
  		return self.state.name
  	end
  end
  def permanent_state_name
    if self.permanent_state.nil?
      return "-"
    else
      return self.permanent_state.name
    end
  end

  def city_name
  	if self.city.nil?
  		return "-"
  	else
  		return self.city.name
  	end
  end
  def permanent_city_name
    if self.permanent_city.nil?
      return "-"
    else
      return self.permanent_city.name
    end
  end

  def division_name
  	if self.division.nil?
  		return "-"
  	else
  		return self.division.name
  	end
  end

  def district_name
  	if self.district.nil?
  		return "-"
  	else
  		return self.district.name
  	end
  end

  def tehsil_name
  	if self.tehsil.nil?
  		return "-"
  	else
  		return self.tehsil.name
  	end
  end

  def line_manager_name
  	if self.line_manager.nil?
  		return "-"
  	else
  		self.line_manager.full_name
  	end
  end

  def hod_name
    head_of_department.try(:full_name) || '-'
  end

  def line_manager_employee_code
    if self.line_manager.nil?
      return "-"
    else
      self.line_manager.employee_code
    end
  end

  def religion_sect_name
  	if self.religion_sect.nil?
  		return "-"
  	else
  		return self.religion_sect.name
  	end
  end

  def religion_name
  	if self.religion.nil?
  		return "-"
  	else
  		return self.religion.name
  	end
  end

  def employee_type_name
    if self.employee_type.nil?
      return "-"
    else
      return self.employee_type.name
    end
  end

  def employee_type_option
    return false
  end

  def relationship_name
    if self.relationship.nil?
      return "-"
    else
      return self.relationship.name
    end
  end

  def role_name
    if self.user.nil?
      return "-"
    else
      if self.user.role.nil?
        return "-"
      else
        return self.user.role.name  
      end
    end
  end

  def hiring_shift
    self.hire_shift.try(:name) || '-'
  end

  def incentives
    pay_item = PayItem.where(name: "Incentive")
    fixed_pay_amount = FixedPayItem.find_by(employee_id: self.id, is_active: true, pay_item_id: pay_item.ids)
    if fixed_pay_amount.nil?
      0.0
    else
      fixed_pay_amount.item_amount
    end
  end

  class << self
    def heirarical_sub_ordinates(sub_ordinates_ids, current_employee_id)
      sub_ordinates_ids << Employee.find(current_employee_id).sub_ordinates.where.not(id:current_employee_id).map(&:id)
      sub_ordinates_ids.flatten!.uniq!
      Employee.find(current_employee_id).sub_ordinates.where.not(id:current_employee_id).map(&:id).each do |employee_id|
        if Employee.find(employee_id).sub_ordinates.where.not(id:current_employee_id).count > 0
          Employee.heirarical_sub_ordinates(sub_ordinates_ids,employee_id)
        end
      end
      sub_ordinates_ids
    end

    def location_related_employee(employee_list, location_id)
       employee_list.where(:location_id => location_id)
    end

    def branch_related_employee(employee_list, branch_id)
       employee_list.where(:branch_id => branch_id)
    end

    def department_related_employee(employee_list, department_id)
       employee_list.where(:department_id => department_id)
    end

    def sub_department_related_employee(employee_list, sub_department_id)
       employee_list.where(:sub_department_id => sub_department_id)
    end

    def designation_related_employee(employee_list, designation_id)
       employee_list.where(:designation_id => designation_id)
    end

    def job_title_related_employee(employee_list, job_title_id)
       employee_list.where(:job_title_id => job_title_id)
    end

    def grade_related_employee(employee_list, grade_id)
       employee_list.where(:grade_id => grade_id)
    end

    def salary_unit_related_employee(employee_list, salary_unit_id)
       employee_list.where(:salary_unit_id => salary_unit_id)
    end

    def cost_center_related_employee(employee_list, cost_center_id)
       employee_list.where(:cost_center_id => cost_center_id)
    end

    def employee_type_related_employee(employee_list, employee_type_id)
      employees = employee_list.where(:employee_type_id => employee_type_id)
      return employees
    end

    def get_by_range(employee_list, start_id, end_id)
      employee_list.where(employee_code: [start_id..end_id])
    end

    def line_manager_related_employee(employee_list, line_manager_id)
       employee_list.where(:line_manager_id => line_manager_id)
    end

    ########### Filter Department Head For Approval Request ###########
    def deparment_head(requested_employee)
      Employee.find_by(:company_id => requested_employee.company_id, :department_id => requested_employee.department_id, :is_department_head => true)
    end

    ########### Multiple Branch Level Permission Set ###########
    def multiple_branch_data(employees, login_user)
      if login_user.multi_branch_allowed == true
        extracted_ids = Employee.where(:branch_id => login_user.branch_ids.split(',').map(&:to_i), :is_active => true).collect(&:id)
        combined_ids = extracted_ids
        employee_ids = combined_ids.flatten.uniq
        Employee.where(:id => employee_ids)
      else
        employees
      end
    end

    ########### Multiple Branch Level Permission Set ###########
    def multiple_branch_data_in_active(employees, login_user)
      if login_user.multi_branch_allowed == true
        extracted_ids = Employee.where(:branch_id => login_user.branch_ids.split(',').map(&:to_i), :is_active => false).collect(&:id)
        combined_ids = extracted_ids
        employee_ids = combined_ids.flatten.uniq
        Employee.where(:id => employee_ids)
      else
        employees
      end
    end

    ########### Auto Leave Allocation when employee complete one year service ###########
    def leave_allocation_when_employee_experience
      LeaveType.where(:company_id => self.company_id, :is_active => true, :location_id => self.location_id, :auto_allocation => true).each do |leave_type|
        grade_condition = true
        if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
          grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? self.grade_id
        end
        if grade_condition && leave_type.min_experience_to_availed_leave > 0 && leave_type.tenure == 'Annually'
          leave_allocation = LeaveAllocation.create(:location_id => self.location_id, :is_active => true, :company_id => self.company_id, :leave_type_id => leave_type.id, :employee_id => self.id)
          if not leave_allocation.nil?
            leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
            if not leave_transaction.nil?
              leave_transaction.leave_allocation_id = leave_allocation.id
              leave_transaction.save
            end
          end
        end
      end
    end

    def filter_employee_data(current_user, conditions)
      if current_user.employee.present?
        if current_user.is_location_head
          conditions[:location_id] = current_user.employee.location_id
        elsif current_user.is_branch_head
          conditions[:location_id] = current_user.employee.location_id
          conditions[:branch_id] = current_user.employee.branch_id
        elsif current_user.is_department_head
          conditions[:location_id] = current_user.employee.location_id
          conditions[:branch_id] = current_user.employee.branch_id
          conditions[:department_id] = current_user.employee.department_id
        elsif current_user.all_company_department
          conditions[:company_id] = current_user.company_id
          conditions[:department_id] = current_user.employee.department_id
        end
      end
    end

    def filter_employee_by_params(params, conditions)
      if params[:location_id].present?
        conditions[:location_id] = params[:location_id].to_i
      end
      if params[:branch_id].present?
        conditions[:branch_id] = params[:branch_id].to_i
      end
      if params[:department_id].present?
        conditions[:department_id] = params[:department_id].to_i
      end
      if params[:line_manager_id].present?
        conditions[:line_manager_id] = params[:line_manager_id].to_i
      end
      if params[:hod_id].present?
        conditions[:hod_id] = params[:hod_id].to_i
      end
    end
  end
end
