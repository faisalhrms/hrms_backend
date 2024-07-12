class Api::V1::Web::Organization::SalaryUnitsController < ApplicationController

	before_action :set_salary_unit, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @salary_units = SalaryUnit.all.order('id DESC')
    else
      @salary_units = SalaryUnit.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/salary_units/index'
  end

  def filter_data
    if current_user.is_admin == true or current_user.is_company_head == true
      @salary_units = SalaryUnit.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    else
      if current_user.employee.nil?
        @salary_units = SalaryUnit.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
      else
        @salary_units = SalaryUnit.where(:id => current_user.employee.salary_unit_id, :is_active => true).order('id DESC')
      end
    end
    render status:200, template: 'api/v1/web/organization/salary_units/index'
  end

  def filter_data_user
    if current_user.is_admin == true or current_user.is_company_head == true
      @users = User.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    else
      @users = []
    end
    render status:200, template: 'api/v1/web/organization/salary_units/user'
  end

  def create
    @salary_unit       = SalaryUnit.new salary_unit_params
    if @salary_unit.save
      render json:{}, status: :created
    else
      render json: {errors: @salary_unit.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/salary_units/show'
  end

  def update
    if @salary_unit.update(salary_unit_params)
      render json: {}, status: 204
    else
      render json: {errors: @salary_unit.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @salary_unit.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @salary_unit.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def salary_unit_params
		params.permit(:company_id, :name, :is_active, :description)
	end

  def set_salary_unit
    @salary_unit = SalaryUnit.find(params[:id])
  end

end
