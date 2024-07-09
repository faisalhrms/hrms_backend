class Api::V1::Web::AdminTool::HolidayManagementsController < ApplicationController

	before_filter :set_holiday_management, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @holiday_managements = Holiday.all.order('id DESC')
    else
      @holiday_managements = Holiday.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/holiday_managements/index.json.jbuilder'
  end

  def active_list
    if current_user.is_admin == true
      @holiday_managements = Holiday.where(:is_active => true).order('id DESC')
    else
      @holiday_managements = Holiday.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/holiday_managements/index.json.jbuilder'
  end

  def filter_data
  	@holiday_managements = Holiday.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/holiday_managements/index.json.jbuilder'
  end

  def create
    @holiday_management       = Holiday.new holiday_management_params
    update_holiday_dates
    set_branch_ids
    if @holiday_management.save
      render json:{}, status: :created
    else
      render json: {errors: @holiday_management.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/holiday_managements/show.json.jbuilder'
  end

  def update
  	update_holiday_dates
    set_branch_ids
    if @holiday_management.update(holiday_management_params)
      render json: {}, status: 204
    else
      render json: {errors: @holiday_management.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @holiday_management.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @holiday_management.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def holiday_management_params
		params.permit(:company_id, :name, :code, :description, :is_active, :religion_id, :specific_religion, :location_id)
	end

  def set_holiday_management
    @holiday_management = Holiday.find(params[:id])
  end

  def update_holiday_dates
  	if params[:start_date].nil?
      @holiday_management.start_date = nil
    else
      @holiday_management.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @holiday_management.end_date = nil
    else
      @holiday_management.end_date = params[:end_date].to_date
    end
  end

  def set_branch_ids
    @holiday_management.branch_ids = params[:branch_ids].try(:map, &:to_i).try(:join, ',')
    if @holiday_management.branch_ids
      @holiday_management.location_wise = true
    end
  end
end
