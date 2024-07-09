class BenefitStructure < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to :company
	belongs_to :location
	belongs_to :grade
	belongs_to :employee_type

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

  def grade_name
		if self.grade.nil?
  		return "-"
  	else
  		return self.grade.name
  	end
	end

	def employee_type_name
    if self.employee_type.nil?
      return "-"
    else
      return self.employee_type.name
    end
  end

  def allocate_benefit_structure_to_employee
    if self.is_active == true
      Employee.where(:is_active => true, :company_id => self.company_id, :location_id => self.location_id, :grade_id => self.grade_id, :employee_type_id => self.employee_type_id).order('id DESC').each do |employee|
        if employee.social_security_impact_allowed == false
          employee.social_security_allowed        = self.social_security_allowed
          employee.social_security_eligibility    = self.social_security_eligibility
          employee.social_security_joining_salary = self.social_security_joining_salary
        end
        if employee.life_insurance_impact_allowed == false
          employee.life_insurance_allowed     = self.life_insurance_allowed
          employee.life_insurance_eligibility = self.life_insurance_eligibility
          employee.life_insurance_value       = self.life_insurance_value
        end
        if employee.health_insurance_impact_allowed == false
          employee.health_insurance_allowed     = self.health_insurance_allowed
          employee.health_insurance_plan        = self.health_insurance_plan
          employee.health_insurance_eligibility = self.health_insurance_eligibility
        end
        if employee.cell_phone_bill_impact_allowed == false
          employee.cell_phone_bill_allowed      = self.cell_phone_bill_allowed
          employee.cell_phone_bill_eligibility  = self.cell_phone_bill_eligibility
          employee.cell_phone_bill_limit        = self.cell_phone_bill_limit
          employee.cell_phone_bill_amount       = self.cell_phone_bill_amount
        end
        if employee.fuel_impact_allowed == false
          employee.fuel_allowed     = self.fuel_allowed
          employee.fuel_eligibility = self.fuel_eligibility
          employee.fuel_limit       = self.fuel_limit
          employee.fuel_value       = self.fuel_value
        end
        if employee.cell_phone_impact_allowed == false
          employee.cell_phone_allowed           = self.cell_phone_allowed
          employee.cell_phone_eligibility       = self.cell_phone_eligibility
          employee.cell_phone_entitlement_upto  = self.cell_phone_entitlement_upto
        end
        if employee.laptop_impact_allowed == false
          employee.laptop_allowed           = self.laptop_allowed
          employee.laptop_eligibility       = self.laptop_eligibility
          employee.laptop_entitlement_upto  = self.laptop_entitlement_upto
          employee.laptop_category          = self.laptop_category
        end
        if employee.velicle_impact_allowed == false
          employee.velicle_allowed      = self.velicle_allowed
          employee.velicle_eligibility  = self.velicle_eligibility
        end
        if employee.provident_fund_impact_allowed == false
          employee.provident_fund_allowed     = self.provident_fund_allowed
          employee.provident_fund_eligibility = self.provident_fund_eligibility
        end
        if employee.eobi_impact_allowed == false
          employee.eobi_allowed     = self.eobi_allowed
          employee.eobi_eligibility = self.eobi_eligibility
        end
        if employee.incentive_impact_allowed == false
          employee.incentive_allowed      = self.incentive_allowed
          employee.incentive_eligibility  = self.incentive_eligibility
        end
        if employee.vehicle_allowance_impact_allowed == false
          employee.vehicle_allowance_allowed          = self.vehicle_allowance_allowed
          employee.vehicle_allowance_eligibility      = self.vehicle_allowance_eligibility
          employee.vehicle_allowance_entitlement_upto = self.vehicle_allowance_entitlement_upto
        end
        if employee.maintenance_impact_allowed == false
          employee.maintenance_allowed          = self.maintenance_allowed
          employee.maintenance_eligibility      = self.maintenance_eligibility
          employee.maintenance_entitlement_upto = self.maintenance_entitlement_upto
        end
        if employee.travel_allowance_impact_allowed == false
          employee.travel_allowance_allowed           = self.travel_allowance_allowed
          employee.travel_allowance_eligibility       = self.travel_allowance_eligibility
          employee.travel_allowance_entitlement_upto  = self.travel_allowance_entitlement_upto
        end
        if employee.attendance_impact_allowed == false
          employee.is_overtime              = self.overtime_allowed
          employee.is_cpl                   = self.cpl_allowed
          employee.is_off_day_working       = self.off_day_allowed
          employee.regular_quota_encashment = self.regular_quota_encashment
          employee.holiday_quota_encashment = self.holiday_quota_encashment
          employee.is_regular_cpl           = self.is_regular_cpl
          employee.is_holiday_overtime      = self.is_holiday_overtime
          employee.approval_base_overtime   = self.approval_base_overtime
        end
        if employee.gratuity_impact_allowed == false
          employee.gratuity_allowed     = self.gratuity_allowed
          employee.gratuity_eligibility = self.gratuity_eligibility
        end
        if employee.lfa_impact_allowed == false
          employee.lfa_allowed      = self.lfa_allowed
          employee.lfa_eligibility  = self.lfa_eligibility
        end
        if employee.house_allowance_impact_allowed == false
          employee.house_allowance_allowed      = self.house_allowance_allowed
          employee.house_allowance_eligibility  = self.house_allowance_eligibility
        end
        if employee.bonus1_impact_allowed == false
          employee.bonus1_allowed     = self.bonus1_allowed
          employee.bonus1_eligibility = self.bonus1_eligibility
        end
        if employee.bonus2_impact_allowed == false
          employee.bonus2_allowed     = self.bonus2_allowed
          employee.bonus2_eligibility = self.bonus2_eligibility
        end
        if employee.bonus3_impact_allowed == false
          employee.bonus3_allowed     = self.bonus3_allowed
          employee.bonus3_eligibility = self.bonus3_eligibility
        end
        employee.save
      end
    end
    
  end

end
