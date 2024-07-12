class Api::V1::Web::AdminTool::SystemSettingsController < ApplicationController

	before_action :set_system_setting, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @system_settings = SystemSetting.all.order('id DESC')
    else
      @system_settings = SystemSetting.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/system_settings/index'
  end

  def filter_data
    @system_settings = SystemSetting.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/system_settings/index'
  end

  def create
    @system_setting       = SystemSetting.new system_setting_params
    if params[:od_start_date].nil?
      @system_setting.od_start_date = nil
    else
      @system_setting.od_start_date = params[:od_start_date].to_date
    end
    if params[:od_end_date].nil?
      @system_setting.od_end_date = nil
    else
      @system_setting.od_end_date = params[:od_end_date].to_date
    end
    if @system_setting.save
      render json:{}, status: :created
    else
      render json: {errors: @system_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def leave_request_setting
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      render status:200, json: {:full_day_leave => system_setting.full_day_leave, :half_day_leave => system_setting.half_day_leave, :short_day_leave => system_setting.short_day_leave}
    else
      render status:200, json: {:full_day_leave => false, :half_day_leave => false, :short_day_leave => false}
    end
  end

  def arrear_setting
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      render status:200, json: {:arrear_overtime => system_setting.arrear_overtime, :arrear_new_joiner => system_setting.arrear_new_joiner, :arrear_off_day_payment => system_setting.arrear_off_day_payment}
    else
      render status:200, json: {:arrear_overtime => false, :arrear_new_joiner => false, :arrear_off_day_payment => false}
    end
  end

  def get_confirmation_due_date
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      if system_setting.confirmation_type == "Day"
        confirmation_due_date = (params[:joining_date].to_date + system_setting.confirmation_days.to_i.days).to_date
        render status:200, json: {:confirmation_due_date => confirmation_due_date}
      elsif system_setting.confirmation_type == "Month"
        confirmation_due_date = (params[:joining_date].to_date + system_setting.no_of_month.to_i.month - system_setting.subtracted_days.to_i.days).to_date
        render status:200, json: {:confirmation_due_date => confirmation_due_date}
      else 
        render status:200, json: {:confirmation_due_date => params[:joining_date].to_date}
      end
    else
      render status:200, json: {:confirmation_due_date => params[:joining_date].to_date}
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/system_settings/show'
  end

  def update
    if params[:od_start_date].nil?
      @system_setting.od_start_date = nil
    else
      @system_setting.od_start_date = params[:od_start_date].to_date
    end
    if params[:od_end_date].nil?
      @system_setting.od_end_date = nil
    else
      @system_setting.od_end_date = params[:od_end_date].to_date
    end
    if @system_setting.update(system_setting_params)
      render json: {}, status: 204
    else
      render json: {errors: @system_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @system_setting.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @system_setting.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def system_setting_params
		params.permit(:company_id, :name, :employee_prefix_code_usage, :is_employee_code_changeable, :live_leave_earning, :live_leave_deduction, :auto_arrear, :od_upper_cap_allowed, :od_upper_cap_limit, :full_day_leave, :half_day_leave, :short_day_leave, :confirmation_days, :confirmation_type, :no_of_month, :subtracted_days, :location_wise_department, :location_wise_grade, :back_date_calculation, :advance_leave_allowed, :advance_leave_limit, :auto_attendance_fetching, :auto_attendance_process, :schedule_time, :attendance_days, :in_process_leave_allowed, :overtime_execption, :pay_deduction_on_missing_in, :other_remarks_on_time_card, :arrear_overtime, :arrear_new_joiner, :arrear_off_day_payment, :od_restriction, :od_message, :hide_religion, :hide_religion_sect, :leverage_minutes)
	end

  def set_system_setting
    @system_setting = SystemSetting.find(params[:id])
  end

end
