class Api::V1::Web::RosterManagement::SubTimeSlotsController < ApplicationController

	before_action :set_sub_time_slot, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @sub_time_slots = SubTimeSlot.all.order('id DESC')
    else
      @sub_time_slots = SubTimeSlot.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/roster_management/sub_time_slots/index'
  end

  def filter_data
    @sub_time_slots = SubTimeSlot.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/sub_time_slots/index'
  end

  def location_related_sub_time_slots
    @sub_time_slots = SubTimeSlot.where(:location_id => params[:location_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/sub_time_slots/index'
  end

  def branch_related_sub_time_slots
    @sub_time_slots = SubTimeSlot.where(:branch_id => params[:branch_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/sub_time_slots/index'
  end

  def create
    @sub_time_slot       = SubTimeSlot.new sub_time_slot_params
    @sub_time_slot.start_time 				= params[:start_time]
		@sub_time_slot.end_time 					= params[:end_time]
    @sub_time_slot.actual_start_time 	= params[:start_time].to_datetime.strftime("%-l:%M %P")
		@sub_time_slot.actual_end_time 		= params[:end_time].to_datetime.strftime("%-l:%M %P")
    if @sub_time_slot.save
      render json:{}, status: :created
    else
      render json: {errors: @sub_time_slot.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def bulk_save
    location = Location.find(params[:location_id].to_i)
    TimeSlot.where(:location_id => params[:location_id].to_i, :is_flexi => true).order('id ASC').each do |time_slot|
      sub_time_slot = SubTimeSlot.new
      sub_time_slot.company_id = params[:company_id]
      sub_time_slot.location_id = location.id
      sub_time_slot.branch_id = time_slot.branch_id
      sub_time_slot.time_slot_id = time_slot.id
      sub_time_slot.name = params[:name]
      sub_time_slot.code = params[:code]
      sub_time_slot.start_buffer = params[:start_buffer]
      sub_time_slot.end_buffer 	= params[:end_buffer]
      sub_time_slot.is_active 	= params[:is_active]
      sub_time_slot.description = params[:description]
      sub_time_slot.total_working_minutes = params[:total_working_minutes]
      sub_time_slot.start_time         = params[:start_time]
      sub_time_slot.end_time           = params[:end_time]
      sub_time_slot.actual_start_time  = params[:start_time].to_datetime.strftime("%-l:%M %P")
      sub_time_slot.actual_end_time    = params[:end_time].to_datetime.strftime("%-l:%M %P")
      sub_time_slot.save
    end
    render json:{}, status: :created
  end

  def show
    render status:200, template: 'api/v1/web/roster_management/sub_time_slots/show'
  end

  def update
  	@sub_time_slot.start_time 				= params[:start_time]
		@sub_time_slot.end_time 					= params[:end_time]
  	@sub_time_slot.actual_start_time 	= params[:start_time].to_datetime.strftime("%-l:%M %P")
		@sub_time_slot.actual_end_time 		= params[:end_time].to_datetime.strftime("%-l:%M %P")
    if @sub_time_slot.update(sub_time_slot_params)
      render json: {}, status: 204
    else
      render json: {errors: @sub_time_slot.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @sub_time_slot.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @time_slot.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def sub_time_slot_params
		params.permit(:company_id, :location_id, :branch_id, :name, :code, :start_buffer, :end_buffer, :is_active, :description, :total_working_minutes, :time_slot_id)
	end

  def set_sub_time_slot
    @sub_time_slot = SubTimeSlot.find(params[:id])
  end

end
