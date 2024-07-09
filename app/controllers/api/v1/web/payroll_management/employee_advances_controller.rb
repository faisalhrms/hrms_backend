class Api::V1::Web::PayrollManagement::EmployeeAdvancesController < ApplicationController

	before_filter :set_employee_advance, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @employee_advances = EmployeeAdvance.all.order('id DESC')
    else
      @employee_advances = EmployeeAdvance.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/employee_advances/index.json.jbuilder'
  end

  def filter_data
    @employee_advances = EmployeeAdvance.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/employee_advances/index.json.jbuilder'
  end

  def create
    @employee_advance       = EmployeeAdvance.new employee_advance_params
    allocate_date
    if @employee_advance.save
      render json:{}, status: :created
    else
      render json: {errors: @employee_advance.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/employee_advances/show.json.jbuilder'
  end

  def update
    if @employee_advance.update(edit_employee_advance_params)
      render json: {}, status: 204
    else
      render json: {errors: @employee_advance.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @employee_advance.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_advance.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_advance_params
		params.permit(:company_id, :employee_id, :gross_salary, :advance_amount, :advance_percentage)
	end

	def edit_employee_advance_params
		params.permit(:is_cleared)
	end

  def set_employee_advance
    @employee_advance = EmployeeAdvance.find(params[:id])
  end

  def allocate_date
  	if params[:advance_date].nil?
  		@employee_advance.advance_date = nil
  	else
  		@employee_advance.advance_date = params[:advance_date].to_date
  	end
  	if params[:pay_back_date].nil?
  		@employee_advance.pay_back_date = nil
  		@employee_advance.pay_back_month = ""
  	else
  		@employee_advance.pay_back_date 	= params[:pay_back_date].to_date
  		@employee_advance.pay_back_month 	= params[:pay_back_date].to_date.strftime("%B %Y")
  	end
  end

end
