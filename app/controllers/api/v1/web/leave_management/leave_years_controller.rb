class Api::V1::Web::LeaveManagement::LeaveYearsController < ApplicationController

	before_action :set_leave_year, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @leave_years = LeaveYear.all.order('id DESC')
    else
      @leave_years = LeaveYear.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/leave_management/leave_years/index'
  end

  def filter_data
    @leave_years = LeaveYear.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/leave_management/leave_years/index'
  end

  def create
    @leave_year       = LeaveYear.new leave_year_params
    allocate_date
    if @leave_year.save
      render json:{}, status: :created
    else
      render json: {errors: @leave_year.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/leave_management/leave_years/show'
  end

  def update
    allocate_date
    if @leave_year.update(leave_year_params)
      render json: {}, status: 204
    else
      render json: {errors: @leave_year.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @leave_year.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @leave_year.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def leave_year_params
		params.permit(:company_id, :name, :is_active, :description)
	end

  def set_leave_year
    @leave_year = LeaveYear.find(params[:id])
  end

  def allocate_date
  	if params[:start_date].nil?
  		@leave_year.start_date = nil
  	else
  		@leave_year.start_date = params[:start_date].to_date
  	end
  	if params[:end_date].nil?
  		@leave_year.end_date = nil
  	else
  		@leave_year.end_date = params[:end_date].to_date
  	end
  end

end
