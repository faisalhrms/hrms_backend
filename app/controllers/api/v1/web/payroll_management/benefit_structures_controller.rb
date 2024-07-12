class Api::V1::Web::PayrollManagement::BenefitStructuresController < ApplicationController

	before_action :set_benefit_structure, :only => [:show, :update, :destroy, :benefit_structure_allocation]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @benefit_structures = BenefitStructure.all.order('id DESC')
    else
      @benefit_structures = BenefitStructure.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/benefit_structures/index'
  end

  def filter_data
    @benefit_structures = BenefitStructure.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/benefit_structures/index'
  end

  def create
    @benefit_structure       = BenefitStructure.new benefit_structure_params
    if @benefit_structure.save
      render json:{}, status: :created
    else
      render json: {errors: @benefit_structure.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/benefit_structures/show'
  end

  def benefit_structure_allocation
    @benefit_structure.allocate_benefit_structure_to_employee
    render json: {}, status: 204
  end

  def update
    if @benefit_structure.update(benefit_structure_params)
      render json: {}, status: 204
    else
      render json: {errors: @benefit_structure.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @benefit_structure.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @benefit_structure.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def benefit_structure_params
		params.permit(:name, :code, :company_id, :location_id, :grade_id, :employee_type_id, :is_active, :description, :social_security_allowed, :social_security_eligibility, :social_security_joining_salary, :life_insurance_allowed, :life_insurance_eligibility, :life_insurance_value, :cell_phone_bill_allowed, :cell_phone_bill_eligibility, :cell_phone_bill_limit, :cell_phone_bill_amount, :fuel_allowed, :fuel_eligibility, :fuel_limit, :fuel_value, :cell_phone_allowed, :cell_phone_eligibility, :cell_phone_entitlement_upto, :laptop_allowed, :laptop_eligibility, :laptop_entitlement_upto, :laptop_category, :velicle_allowed, :velicle_eligibility, :provident_fund_allowed, :provident_fund_eligibility, :eobi_allowed, :eobi_eligibility, :incentive_allowed, :incentive_eligibility, :vehicle_allowance_allowed, :vehicle_allowance_eligibility, :vehicle_allowance_entitlement_upto, :maintenance_allowed, :maintenance_eligibility, :maintenance_entitlement_upto, :travel_allowance_allowed, :travel_allowance_eligibility, :travel_allowance_entitlement_upto, :attendance_allowed, :overtime_allowed, :cpl_allowed, :off_day_allowed, :bonus1_allowed, :bonus1_eligibility, :bonus2_allowed, :bonus2_eligibility, :bonus3_allowed, :bonus3_eligibility, :health_insurance_allowed, :health_insurance_plan, :health_insurance_eligibility, :gratuity_allowed, :gratuity_eligibility, :lfa_allowed, :lfa_eligibility, :house_allowance_allowed, :house_allowance_eligibility, :regular_quota_encashment, :holiday_quota_encashment, :is_regular_cpl, :is_holiday_overtime, :approval_base_overtime)
	end

  def set_benefit_structure
    @benefit_structure = BenefitStructure.find(params[:id])
  end

end
