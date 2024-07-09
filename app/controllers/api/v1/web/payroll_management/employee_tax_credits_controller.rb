class Api::V1::Web::PayrollManagement::EmployeeTaxCreditsController < ApplicationController

	before_filter :set_employee_tax_credit, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @employee_tax_credits = EmployeeTaxCredit.all.order('id DESC')
    else
      @employee_tax_credits = EmployeeTaxCredit.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_credits/index.json.jbuilder'
  end

  def filter_data
    @employee_tax_credits = EmployeeTaxCredit.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_credits/index.json.jbuilder'
  end

  def create
    @employee_tax_credit       = EmployeeTaxCredit.new employee_tax_credit_params
    allocate_date
    if @employee_tax_credit.save
      render json:{}, status: :created
    else
      render json: {errors: @employee_tax_credit.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_credits/show.json.jbuilder'
  end

  def update
    if @employee_tax_credit.update(employee_tax_credit_params)
    	allocate_date
      render json: {}, status: 204
    else
      render json: {errors: @employee_tax_credit.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @employee_tax_credit.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_tax_credit.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_tax_credit_params
		params.permit(:employee_id, :company_id, :fiscal_year_id, :fiscal_year_id, :tax_credit_amount, :tax_credit_type)
	end

  def set_employee_tax_credit
    @employee_tax_credit = EmployeeTaxCredit.find(params[:id])
  end

  def allocate_date
  	if params[:tax_credit_month].nil?
      @employee_tax_credit.tax_credit_month  						= nil
      @employee_tax_credit.tax_credit_formatted_month  	= ""
    else
      @employee_tax_credit.tax_credit_month  						= params[:tax_credit_month].to_date
      @employee_tax_credit.tax_credit_formatted_month  	= params[:tax_credit_month].to_date.strftime("%B %Y")
    end
  end

end
