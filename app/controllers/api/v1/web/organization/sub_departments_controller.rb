class Api::V1::Web::Organization::SubDepartmentsController < ApplicationController

	before_filter :set_sub_department, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @sub_departments = SubDepartment.all.order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @sub_departments = SubDepartment.where(:company_id => current_user.employee.company_id).order('id DESC')
      else
        department_ids = Department.where(:company_id => current_user.company_id).collect(&:id)
        @sub_departments = SubDepartment.where(:department_id => department_ids).order('id DESC')
      end
    elsif current_user.is_department_head == true
      if not current_user.employee.nil?
        @sub_departments = SubDepartment.where(:department_id => current_user.employee.department_id).order('id DESC')
      else
        @sub_departments = []
      end
    else
      @sub_departments = SubDepartment.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/sub_departments/index.json.jbuilder'
  end

  def filter_data
    if current_user.is_admin == true or current_user.is_company_head == true
      @sub_departments = SubDepartment.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    else
      if current_user.employee.nil?
        @sub_departments = SubDepartment.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
      else
        @sub_departments = SubDepartment.where(:id => current_user.employee.sub_department_id, :is_active => true).order('id DESC')
      end
    end
    render status:200, template: 'api/v1/web/organization/sub_departments/index.json.jbuilder'
  end

  def department_related_data
    if params[:department_id].blank?
      department_ids = []
    else
      department_ids = params[:department_id].split(',').map(&:to_i)
    end
    @sub_departments = SubDepartment.where(:department_id => department_ids, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/sub_departments/index.json.jbuilder'
  end

  def create
    @sub_department       = SubDepartment.new sub_department_params
    if @sub_department.save
      render json:{}, status: :created
    else
      render json: {errors: @sub_department.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/sub_departments/show.json.jbuilder'
  end

  def update
    if @sub_department.update(sub_department_params)
      render json: {}, status: 204
    else
      render json: {errors: @sub_department.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @sub_department.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @sub_department.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def sub_department_params
		params.permit(:company_id, :department_id,:name, :code, :description, :is_active)
	end

  def set_sub_department
    @sub_department = SubDepartment.find(params[:id])
  end

end
