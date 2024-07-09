class Api::V1::Web::AttendanceManagement::AttendanceDeductionsController < ApplicationController

	before_filter :set_attendance_deduction, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_deductions = AttendanceDeduction.all.order('id DESC')
    else
      @attendance_deductions = AttendanceDeduction.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_deductions/index.json.jbuilder'
  end

  def filter_data
    @attendance_deductions = AttendanceDeduction.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_deductions/index.json.jbuilder'
  end

  def create
    @attendance_deduction       = AttendanceDeduction.new attendance_deduction_params
    if @attendance_deduction.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_deduction.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_deductions/show.json.jbuilder'
  end

  def update
    if @attendance_deduction.update(attendance_deduction_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_deduction.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_deduction.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_deduction.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def attendance_deduction_params
		params.permit(:company_id, :attendance_type_id, :name, :deduction_from, :deduction_type, :exempted_in_month, :deduction_value, :description)
	end

  def set_attendance_deduction
    @attendance_deduction = AttendanceDeduction.find(params[:id])
  end

end
