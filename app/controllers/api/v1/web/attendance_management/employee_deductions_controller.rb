class Api::V1::Web::AttendanceManagement::EmployeeDeductionsController < ApplicationController

	before_action :set_employee_deduction, :only => [:show, :update, :disabled_employee_deduction]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @employee_deductions = EmployeeDeduction.all.order('id DESC')
    else
      @employee_deductions = EmployeeDeduction.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/employee_deductions/index'
  end

  def create
    @employee_deduction       = EmployeeDeduction.new employee_deduction_params
    @employee_deduction.deduction_type		= "Manual"
		@employee_deduction.start_date 				= params[:deductions_month].to_date
		@employee_deduction.end_date 					= params[:deductions_month].to_date
		@employee_deduction.deductions_month 	= params[:deductions_month].to_date
    if @employee_deduction.save
      render json:{}, status: :created
    else
      render json: {errors: @employee_deduction.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/employee_deductions/show'
  end

  def update
    if @employee_deduction.update(edit_employee_deduction_params)
      render json: {}, status: 204
    else
      render json: {errors: @employee_deduction.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def disabled_employee_deduction
  	@employee_deduction.status = true
  	if @employee_deduction.save
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_deduction.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_deduction_params
		params.permit(:employee_id, :deduction_days, :company_id)
	end

	def edit_employee_deduction_params
		params.permit(:employee_id, :deduction_days)
	end

  def set_employee_deduction
    @employee_deduction = EmployeeDeduction.find(params[:id])
  end
  
end
