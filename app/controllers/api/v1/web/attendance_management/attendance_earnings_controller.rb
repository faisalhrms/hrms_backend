class Api::V1::Web::AttendanceManagement::AttendanceEarningsController < ApplicationController

	before_action :set_attendance_earning, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_earnings = AttendanceEarning.all.order('id DESC')
    else
      @attendance_earnings = AttendanceEarning.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_earnings/index'
  end

  def filter_data
    @attendance_earnings = AttendanceEarning.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_earnings/index'
  end

  def create
    @attendance_earning       = AttendanceEarning.new attendance_earning_params
    if params[:holiday_ids].nil?
      @attendance_earning.holiday_ids = nil
    else
      @attendance_earning.holiday_ids = params[:holiday_ids].map(&:to_i).join(',')
    end
    if @attendance_earning.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_earning.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_earnings/show'
  end

  def update
    if params[:holiday_ids].nil?
      @attendance_earning.holiday_ids = nil
    else
      @attendance_earning.holiday_ids = params[:holiday_ids].map(&:to_i).join(',')
    end
    if @attendance_earning.update(attendance_earning_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_earning.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_earning.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_earning.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def attendance_earning_params
		params.permit(:company_id, :name, :earning_from, :earning_type, :multiplex, :earning_value, :description, :multiplex_allowed, :upper_cap, :upper_cap_limit, :rest_upper_cap, :rest_upper_cap_limit, :regular_upper_cap, :regular_upper_cap_limit, :working_days)
	end

  def set_attendance_earning
    @attendance_earning = AttendanceEarning.find(params[:id])
  end

end
