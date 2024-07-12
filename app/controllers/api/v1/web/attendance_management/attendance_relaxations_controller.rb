class Api::V1::Web::AttendanceManagement::AttendanceRelaxationsController < ApplicationController

	before_action :set_attendance_relaxation, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_relaxations = AttendanceRelaxation.all.order('id DESC')
    else
      @attendance_relaxations = AttendanceRelaxation.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_relaxations/index'
  end

  def filter_data
    @attendance_relaxations = AttendanceRelaxation.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_relaxations/index'
  end

  def create
    @attendance_relaxation       = AttendanceRelaxation.new attendance_relaxation_params
    if @attendance_relaxation.save
    	save_or_update_attendance_relaxation_slabs
      render json:{}, status: :created
    else
      render json: {errors: @attendance_relaxation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_relaxations/show'
  end

  def update
  	if @attendance_relaxation.update(attendance_relaxation_params)
    	save_or_update_attendance_relaxation_slabs
      render json: {}, status: 204
    else
      render json: {errors: @attendance_relaxation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_relaxation.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_relaxation.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_relaxation_slab
  	relaxation_slab = AttendanceRelaxationSlab.find params[:relaxation_slab_id]
  	relaxation_slab.destroy
  	render json: {}, status: 204
  end

	private

	def attendance_relaxation_params
		params.permit(:company_id, :name, :code, :is_active, :description)
	end

  def set_attendance_relaxation
    @attendance_relaxation = AttendanceRelaxation.find(params[:id])
  end

  def save_or_update_attendance_relaxation_slabs
  	########## Slabs ##########
    if params[:relaxation_slabs].present?
      relaxation_slabs = params[:relaxation_slabs]
      if relaxation_slabs.count > 0
        Array.new(relaxation_slabs.count).each_index do |index|
          if relaxation_slabs[index.to_s][:slab_id].nil?
            new_relaxation_slab 										= @attendance_relaxation.attendance_relaxation_slabs.build
						new_relaxation_slab.attendance_deduction_id 		= relaxation_slabs[index.to_s][:attendance_deduction_id]
						new_relaxation_slab.fallback_id 								= relaxation_slabs[index.to_s][:fallback_id]
						new_relaxation_slab.start_minute 								= relaxation_slabs[index.to_s][:start_minute]
						new_relaxation_slab.end_minute 									= relaxation_slabs[index.to_s][:end_minute]
						new_relaxation_slab.save
          else
            edit_relaxation_slab 														=	@attendance_relaxation.attendance_relaxation_slabs.find relaxation_slabs[index.to_s][:slab_id]
            edit_relaxation_slab.attendance_deduction_id 		= relaxation_slabs[index.to_s][:attendance_deduction_id]
						edit_relaxation_slab.fallback_id 								= relaxation_slabs[index.to_s][:fallback_id]
						edit_relaxation_slab.start_minute 							= relaxation_slabs[index.to_s][:start_minute]
						edit_relaxation_slab.end_minute 								= relaxation_slabs[index.to_s][:end_minute]
						edit_relaxation_slab.save
          end
        end
      end
    end
  end

end
