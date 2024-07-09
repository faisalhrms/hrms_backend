class Api::V1::Web::AttendanceManagement::AttendanceOvertimesController < ApplicationController

	before_filter :set_attendance_overtime, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_overtimes = AttendanceOvertime.all.order('id DESC')
    else
      @attendance_overtimes = AttendanceOvertime.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_overtimes/index.json.jbuilder'
  end

  def filter_data
    @attendance_overtimes = AttendanceOvertime.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_overtimes/index.json.jbuilder'
  end

  def create
    @attendance_overtime       = AttendanceOvertime.new attendance_overtime_params
    if @attendance_overtime.save
    	save_or_update_attendance_overtime_slabs
      render json:{}, status: :created
    else
      render json: {errors: @attendance_overtime.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_overtimes/show.json.jbuilder'
  end

  def update
  	if @attendance_overtime.update(attendance_overtime_params)
    	save_or_update_attendance_overtime_slabs
      render json: {}, status: 204
    else
      render json: {errors: @attendance_overtime.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_overtime.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_overtime.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_overtime_slab
  	overtime_slab = AttendanceOvertimeSlab.find params[:overtime_slab_id]
  	overtime_slab.destroy
  	render json: {}, status: 204
  end

	private

	def attendance_overtime_params
		params.permit(:company_id, :name, :code, :is_active, :description, :overtime_after_office_end)
	end

  def set_attendance_overtime
    @attendance_overtime = AttendanceOvertime.find(params[:id])
  end

  def save_or_update_attendance_overtime_slabs
  	########## Slabs ##########
    if params[:overtime_slabs].present?
      overtime_slabs = params[:overtime_slabs]
      if overtime_slabs.count > 0
        Array.new(overtime_slabs.count).each_index do |index|
          if overtime_slabs[index.to_s][:slab_id].nil?
            new_relaxation_slab 										      = @attendance_overtime.attendance_overtime_slabs.build
						new_relaxation_slab.attendance_earning_id 		= overtime_slabs[index.to_s][:attendance_earning_id]
						new_relaxation_slab.min_minute 								= overtime_slabs[index.to_s][:min_minute]
						new_relaxation_slab.max_minute 								= overtime_slabs[index.to_s][:max_minute]
						new_relaxation_slab.save
          else
            edit_relaxation_slab 													=	@attendance_overtime.attendance_overtime_slabs.find overtime_slabs[index.to_s][:slab_id]
            edit_relaxation_slab.attendance_earning_id 		= overtime_slabs[index.to_s][:attendance_earning_id]
						edit_relaxation_slab.min_minute 							= overtime_slabs[index.to_s][:min_minute]
						edit_relaxation_slab.max_minute 							= overtime_slabs[index.to_s][:max_minute]
						edit_relaxation_slab.save
          end
        end
      end
    end
  end

end
