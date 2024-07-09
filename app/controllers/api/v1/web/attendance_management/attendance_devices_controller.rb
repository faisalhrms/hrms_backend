class Api::V1::Web::AttendanceManagement::AttendanceDevicesController < ApplicationController

	before_filter :set_attendance_device, :only => [:show, :update, :destroy, :fetch_device_data]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_devices = AttendanceDevice.all.order('id DESC')
    else
      @attendance_devices = AttendanceDevice.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_devices/index.json.jbuilder'
  end

  def filter_data
    @attendance_devices = AttendanceDevice.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_devices/index.json.jbuilder'
  end

  def create
    @attendance_device       = AttendanceDevice.new attendance_device_params
    if @attendance_device.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_device.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_devices/show.json.jbuilder'
  end

  def update
    if @attendance_device.update(attendance_device_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_device.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_device.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_device.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def fetch_device_data
    AttendanceMachineLog.fetch_attendance_machine_data(@attendance_device, params[:start_date], params[:end_date])
    render json: {}, status: 204
  end

  def bulk_fetch_device_data
    if params[:attendance_device_ids].nil?
      render json: {errors: "Please Select Device"}, status: :unprocessable_entity
    else
      attendance_device_ids = params[:attendance_device_ids].map(&:to_i)
      AttendanceDevice.where(:id => attendance_device_ids).order('id ASC').each do |attendance_device|
        AttendanceMachineLog.fetch_attendance_machine_data(attendance_device, params[:start_date], params[:end_date])
      end
      render json: {}, status: 204  
    end
  end

	private

	def attendance_device_params
		params.permit(:name, :code, :company_id, :is_active, :device_id, :device_type, :device_url, :description, :auto_fetch_allowed)
	end

  def set_attendance_device
    @attendance_device = AttendanceDevice.find(params[:id])
  end

end
