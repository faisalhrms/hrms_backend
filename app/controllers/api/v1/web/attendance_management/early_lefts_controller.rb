class Api::V1::Web::AttendanceManagement::EarlyLeftsController < ApplicationController

	before_action :set_early_left, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @early_lefts = EarlyLeft.all.order('id DESC')
    else
      @early_lefts = EarlyLeft.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/early_lefts/index'
  end

  def filter_data
    @early_lefts = EarlyLeft.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/early_lefts/index'
  end

  def create
    @early_left       = EarlyLeft.new early_left_params
    if @early_left.save
    	save_or_update_early_left_slabs
      render json:{}, status: :created
    else
      render json: {errors: @early_left.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/early_lefts/show'
  end

  def update
  	if @early_left.update(early_left_params)
    	save_or_update_early_left_slabs
      render json: {}, status: 204
    else
      render json: {errors: @early_left.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @early_left.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @early_left.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_early_left_slab
  	early_left_slab = EarlyLeftSlab.find params[:early_left_slab_id]
  	early_left_slab.destroy
  	render json: {}, status: 204
  end

	private

	def early_left_params
		params.permit(:company_id, :name, :code, :is_active, :description)
	end

  def set_early_left
    @early_left = EarlyLeft.find(params[:id])
  end

  def save_or_update_early_left_slabs
  	########## Slabs ##########
    if params[:early_left_slabs].present?
      early_left_slabs = params[:early_left_slabs]
      if early_left_slabs.count > 0
        Array.new(early_left_slabs.count).each_index do |index|
          if early_left_slabs[index.to_s][:slab_id].nil?
            new_early_left_slab 										= @early_left.early_left_slabs.build
						new_early_left_slab.attendance_deduction_id 		= early_left_slabs[index.to_s][:attendance_deduction_id]
						new_early_left_slab.fallback_id 								= early_left_slabs[index.to_s][:fallback_id]
						new_early_left_slab.start_minute 								= early_left_slabs[index.to_s][:start_minute]
						new_early_left_slab.end_minute 									= early_left_slabs[index.to_s][:end_minute]
						new_early_left_slab.save
          else
            edit_early_left_slab 														=	@early_left.early_left_slabs.find early_left_slabs[index.to_s][:slab_id]
            edit_early_left_slab.attendance_deduction_id 		= early_left_slabs[index.to_s][:attendance_deduction_id]
						edit_early_left_slab.fallback_id 								= early_left_slabs[index.to_s][:fallback_id]
						edit_early_left_slab.start_minute 							= early_left_slabs[index.to_s][:start_minute]
						edit_early_left_slab.end_minute 								= early_left_slabs[index.to_s][:end_minute]
						edit_early_left_slab.save
          end
        end
      end
    end
  end

end
