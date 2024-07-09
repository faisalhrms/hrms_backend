class Api::V1::Web::LeaveManagement::CplEarningsController < ApplicationController
	before_filter :set_employee_id, :only => [:get_cpl_earning, :create]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def get_cpl_earning
    employee_attendance = EmployeeAttendance.where(employee_id: params[:employee_id], attendance_date: params[:attendance_date].to_date, remarks: 'CPL Approval Pending').last
    attendance_data = {record_exists: false}
    if employee_attendance.present? and employee_attendance.in_time and employee_attendance.out_time
      attendance_data[:record_exists] = true
      attendance_data['in_time'] = employee_attendance.in_time if employee_attendance.in_time
      attendance_data['out_time'] = employee_attendance.out_time if employee_attendance.out_time
      served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
      attendance_data['served_hours'] = Time.at(served_hours * 60 * 60).utc.strftime('%H:%M')
    end
    render status:200, json: attendance_data
  end

  def create
    employee_attendance = EmployeeAttendance.where(employee_id: params[:employee_id], attendance_date: params[:attendance_date].to_date, remarks: 'CPL Approval Pending').last
    if employee_attendance.present?
      cpl_earning = CplEarning.new cpl_earning_params
      cpl_earning.employee_attendance = employee_attendance
      if cpl_earning.save
        render status: 200, json: {}
      else
        render status: :unprocessable_entity, json: {error: cpl_earning.errors.full_messages}
      end
    else
      render status: 404, json: {error: 'Record not found'}
    end
  end

  def index
    @cpl_earnings = current_user.employee ? CplEarning.where(employee_id: current_user.employee.id) : []
    render status:200, template: 'api/v1/web/leave_management/cpl_earnings/index'
  end

  def cancel_request
    request = CplEarning.find(params[:id])
    request.status = 'Cancelled'
    if request.save
      render json:{}, status: 200
    else
      render json: {errors: request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def set_employee_id
    params[:employee_id] = current_user.employee.id if params[:is_employee] == 'true'
  end

  def cpl_earning_params
    params.permit(:employee_id, :reason)
  end

end
