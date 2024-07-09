class Api::V1::Web::GeneralSetting::EmployeeTypesController < ApplicationController

	before_filter :set_employee_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @employee_types = EmployeeType.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/employee_types/index.json.jbuilder'
  end

  def active_list
    @employee_types = EmployeeType.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/employee_types/index.json.jbuilder'
  end

  def create
    @employee_type       = EmployeeType.new employee_type_params
    if @employee_type.save
      render json:{}, status: :created
    else
      render json: {errors: @employee_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/employee_types/show.json.jbuilder'
  end

  def update
    if @employee_type.update(employee_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @employee_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @employee_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_type_params
		params.permit(:name, :is_active, :description)
	end

  def set_employee_type
    @employee_type = EmployeeType.find(params[:id])
  end
  
end
