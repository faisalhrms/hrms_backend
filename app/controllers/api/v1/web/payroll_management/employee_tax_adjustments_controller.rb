class Api::V1::Web::PayrollManagement::EmployeeTaxAdjustmentsController < ApplicationController

	before_action :set_employee_tax_adjustment, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @employee_tax_adjustments = EmployeeTaxAdjustment.all.order('id DESC')
    else
      @employee_tax_adjustments = EmployeeTaxAdjustment.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_adjustments/index'
  end

  def filter_data
    @employee_tax_adjustments = EmployeeTaxAdjustment.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_adjustments/index'
  end

  def create
    @employee_tax_adjustment       = EmployeeTaxAdjustment.new employee_tax_adjustment_params
    allocate_date
    if @employee_tax_adjustment.save
      render json:{}, status: :created
    else
      render json: {errors: @employee_tax_adjustment.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_adjustments/show'
  end

  def update
    if @employee_tax_adjustment.update(employee_tax_adjustment_params)
    	allocate_date
      render json: {}, status: 204
    else
      render json: {errors: @employee_tax_adjustment.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @employee_tax_adjustment.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_tax_adjustment.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_tax_adjustment_params
		params.permit(:employee_id, :company_id, :amount, :reason, :is_active)
	end

  def set_employee_tax_adjustment
    @employee_tax_adjustment = EmployeeTaxAdjustment.find(params[:id])
  end

  def allocate_date
  	if params[:tax_adjustment_month].nil?
      @employee_tax_adjustment.tax_adjustment_month  						= nil
      @employee_tax_adjustment.tax_adjustment_formatted_month  	= ""
    else
      @employee_tax_adjustment.tax_adjustment_month  						= params[:tax_adjustment_month].to_date
      @employee_tax_adjustment.tax_adjustment_formatted_month  	= params[:tax_adjustment_month].to_date.strftime("%B %Y")
    end
  end

end
