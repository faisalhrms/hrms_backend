class Api::V1::Web::AttendanceManagement::EmployeeArrearsController < ApplicationController

	before_filter :set_employee_arrear, :only => [:show, :update, :disabled_employee_arrear]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @employee_arrears = EmployeeArrear.all.order('id DESC')
    else
      @employee_arrears = EmployeeArrear.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/employee_arrears/index.json.jbuilder'
  end

  def create
    @employee_arrear       = EmployeeArrear.new employee_arrear_params
    @employee_arrear.arrear_type		= "Manual"
		@employee_arrear.start_date 		= params[:arrears_month].to_date
		@employee_arrear.end_date 			= params[:arrears_month].to_date
		@employee_arrear.arrears_month 	= params[:arrears_month].to_date
    if @employee_arrear.save
      render json:{}, status: :created
    else
      render json: {errors: @employee_arrear.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/employee_arrears/show.json.jbuilder'
  end

  def update
    if @employee_arrear.update(edit_employee_arrear_params)
      render json: {}, status: 204
    else
      render json: {errors: @employee_arrear.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def disabled_employee_arrear
  	@employee_arrear.status = true
  	if @employee_arrear.save
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_arrear.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_arrear_params
		params.permit(:employee_id, :arrear_days, :company_id, :arrear_kind)
	end

	def edit_employee_arrear_params
		params.permit(:employee_id, :arrear_days, :arrear_kind)
	end

  def set_employee_arrear
    @employee_arrear = EmployeeArrear.find(params[:id])
  end

end
