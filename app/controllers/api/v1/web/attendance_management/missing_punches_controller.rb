class Api::V1::Web::AttendanceManagement::MissingPunchesController < ApplicationController

	before_action :set_missing_punch, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @missing_punches = MissingPunch.all.order('id DESC')
    else
      @missing_punches = MissingPunch.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/missing_punches/index'
  end

  def filter_data
    @missing_punches = MissingPunch.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/missing_punches/index'
  end

  def create
    @missing_punch       = MissingPunch.new missing_punch_params
    if @missing_punch.save
      render json:{}, status: :created
    else
      render json: {errors: @missing_punch.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/missing_punches/show'
  end

  def update
  	if @missing_punch.update(missing_punch_params)
      render json: {}, status: 204
    else
      render json: {errors: @missing_punch.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @missing_punch.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @missing_punch.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def missing_punch_params
		params.permit(:company_id, :attendance_deduction_id, :fallback_id, :name, :code, :is_active, :description)
	end

  def set_missing_punch
    @missing_punch = MissingPunch.find(params[:id])
  end

end
