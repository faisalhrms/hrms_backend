class Api::V1::Web::RosterManagement::TimeSlotsController < ApplicationController

	before_filter :set_time_slot, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @time_slots = TimeSlot.all.order('id DESC')
    else
      @time_slots = TimeSlot.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/roster_management/time_slots/index.json.jbuilder'
  end

  def filter_data
    @time_slots = TimeSlot.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/time_slots/index.json.jbuilder'
  end

  def location_related_time_slots
    @time_slots = TimeSlot.where(:location_id => params[:location_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/time_slots/index.json.jbuilder'
  end

  def branch_related_time_slots
    @time_slots = TimeSlot.where(:branch_id => params[:branch_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/time_slots/index.json.jbuilder'
  end

  def flexi_branch_related_time_slots
    @time_slots = TimeSlot.where(:branch_id => params[:branch_id], :is_active => true, :is_flexi => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/time_slots/index.json.jbuilder'
  end

  def employee_related_time_slots
    employee = Employee.find(params[:employee_id])
    @time_slots = TimeSlot.where(:branch_id => employee.branch_id, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/time_slots/index.json.jbuilder'
  end

  def create
    @time_slot       = TimeSlot.new time_slot_params
    @time_slot.start_time 				= params[:start_time]
		@time_slot.end_time 					= params[:end_time]
    @time_slot.actual_start_time 	= params[:start_time].to_datetime.strftime("%-l:%M %P")
		@time_slot.actual_end_time 		= params[:end_time].to_datetime.strftime("%-l:%M %P")
    if @time_slot.save
    	save_or_update_break_time
      render json:{}, status: :created
    else
      render json: {errors: @time_slot.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def bulk_save
    location = Location.find(params[:location_id].to_i)
    Branch.where(:location_id => params[:location_id].to_i).order('id ASC').each do |branch|
      time_slot = TimeSlot.new
      time_slot.company_id = params[:company_id]
      time_slot.location_id = location.id
      time_slot.branch_id = branch.id
      time_slot.name = params[:name]
      time_slot.code = params[:code]
      time_slot.start_buffer = params[:start_buffer]
      time_slot.end_buffer = params[:end_buffer]
      time_slot.is_active = params[:is_active]
      time_slot.description = params[:description]
      time_slot.is_flexi = params[:is_flexi]
      time_slot.total_working_minutes = params[:total_working_minutes]
      time_slot.start_time         = params[:start_time]
      time_slot.end_time           = params[:end_time]
      time_slot.actual_start_time  = params[:start_time].to_datetime.strftime("%-l:%M %P")
      time_slot.actual_end_time    = params[:end_time].to_datetime.strftime("%-l:%M %P")
      time_slot.save
    end
    render json:{}, status: :created
  end

  def show
    render status:200, template: 'api/v1/web/roster_management/time_slots/show.json.jbuilder'
  end

  def update
  	@time_slot.start_time 				= params[:start_time]
		@time_slot.end_time 					= params[:end_time]
  	@time_slot.actual_start_time 	= params[:start_time].to_datetime.strftime("%-l:%M %P")
		@time_slot.actual_end_time 		= params[:end_time].to_datetime.strftime("%-l:%M %P")
    if @time_slot.update(time_slot_params)
    	save_or_update_break_time
      render json: {}, status: 204
    else
      render json: {errors: @time_slot.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @time_slot.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @time_slot.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_break_time
  	break_time = BreakTime.find params[:break_time_id]
  	break_time.destroy
  	render json: {}, status: 204
  end

	private

	def time_slot_params
		params.permit(:company_id, :location_id, :branch_id, :name, :code, :start_buffer, :end_buffer, :is_active, :description, :is_flexi, :total_working_minutes)
	end

  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])
  end

  def save_or_update_break_time
  	########## Break Time ##########
    if params[:break_times].present?
      break_times = params[:break_times]
      if break_times.count > 0
        Array.new(break_times.count).each_index do |index|
          if break_times[index.to_s][:break_time_id].nil?
            new_break_time 										= @time_slot.break_times.build
						new_break_time.name 							= break_times[index.to_s][:name]
						new_break_time.code 							= break_times[index.to_s][:code]
						new_break_time.actual_start_time 	= break_times[index.to_s][:start_time].to_datetime.strftime("%-l:%M %P")
						new_break_time.actual_end_time 		= break_times[index.to_s][:end_time].to_datetime.strftime("%-l:%M %P")
						new_break_time.start_time 				= break_times[index.to_s][:start_time].to_datetime
						new_break_time.end_time 					= break_times[index.to_s][:end_time].to_datetime
						new_break_time.excluded 					= break_times[index.to_s][:excluded]
            new_break_time.save
          else
            edit_break_time 									= @time_slot.break_times.find break_times[index.to_s][:break_time_id]
						edit_break_time.name 							= break_times[index.to_s][:name]
						edit_break_time.code 							= break_times[index.to_s][:code]
						edit_break_time.actual_start_time = break_times[index.to_s][:start_time].to_datetime.strftime("%-l:%M %P")
						edit_break_time.actual_end_time 	= break_times[index.to_s][:end_time].to_datetime.strftime("%-l:%M %P")
						edit_break_time.start_time 				= break_times[index.to_s][:start_time].to_datetime
						edit_break_time.end_time 					= break_times[index.to_s][:end_time].to_datetime
						edit_break_time.excluded 					= break_times[index.to_s][:excluded]
            edit_break_time.save
          end
        end
      end
    end
  end

end
