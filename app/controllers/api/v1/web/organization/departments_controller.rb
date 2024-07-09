class Api::V1::Web::Organization::DepartmentsController < ApplicationController

	before_filter :set_department, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @departments = Department.all.order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @departments = Department.where(:company_id => current_user.employee.company_id).order('id DESC')
      else
        @departments = Department.where(:company_id => current_user.company_id).order('id DESC')
      end
    elsif current_user.is_department_head == true
      if not current_user.employee.nil?
        @departments = Department.where(:id => current_user.employee.department_id).order('id DESC')
      else
        @departments = []
      end
    elsif not current_user.employee.nil?
      @departments = Department.where(:company_id => current_user.employee.company_id).order('id DESC')
    else
      @departments = []
    end
    render status:200, template: 'api/v1/web/organization/departments/index.json.jbuilder'
  end

  def filter_data
    if (current_user.is_admin == true) or (current_user.is_dtl == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true)
      @departments = Department.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @departments = Department.where(:company_id => current_user.employee.company_id, :is_active => true).order('id DESC')
        filter_location_wise_department('company_head', current_user.employee)
      else
        @departments = Department.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
      end
    elsif current_user.is_location_head == true
      if not current_user.employee.nil?
        @departments = Department.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
        filter_location_wise_department('location_head', current_user.employee)
      else
        @departments = []
      end
    elsif current_user.is_branch_head == true  
      if not current_user.employee.nil?
        @departments = Department.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
        filter_location_wise_department('branch_head', current_user.employee)
      else
        @departments = []
      end
    elsif current_user.is_department_head == true
      if not current_user.employee.nil?
        @departments = Department.where(:id => current_user.employee.department_id, :is_active => true).order('id DESC')
      else
        @departments = []
      end
    elsif not current_user.employee.nil?
      @departments = Department.where(:id => current_user.employee.department_id, :is_active => true).order('id DESC')
    else
      @departments = []
    end
    render status:200, template: 'api/v1/web/organization/departments/index.json.jbuilder'
  end

  def salary_dashboard_filters
    if current_user.is_admin == true
      @departments = Department.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    else
      @departments = []
    end
    render status:200, template: 'api/v1/web/organization/departments/index.json.jbuilder'
  end

  def create
    @department       = Department.new department_params
    if @department.save
      render json:{}, status: :created
    else
      render json: {errors: @department.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/departments/show.json.jbuilder'
  end

  def update
    if @department.update(department_params)
      render json: {}, status: 204
    else
      render json: {errors: @department.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @department.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @department.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def department_params
		params.permit(:company_id, :name, :code, :description, :is_active)
	end

  def set_department
    @department = Department.find(params[:id])
  end

  def filter_location_wise_department(filter_selection, employee)
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      if system_setting.location_wise_department == true
        if filter_selection == "company_head"
          department_allocations = DepartmentAllocation.where(:company_id => employee.company_id)
          department_ids = DepartmentAllocation.collect_department_id(department_allocations)
          @departments = @departments.where(:id => department_ids)
        elsif filter_selection == "location_head"
          department_allocations = DepartmentAllocation.where(:company_id => employee.company_id, :location_id => employee.location_id)
          department_ids = DepartmentAllocation.collect_department_id(department_allocations)
          @departments = @departments.where(:id => department_ids)
        elsif filter_selection == "branch_head"
          department_allocations = DepartmentAllocation.where(:company_id => employee.company_id, :location_id => employee.location_id, :branch_id => employee.branch_id)
          department_ids = DepartmentAllocation.collect_department_id(department_allocations)
          @departments = @departments.where(:id => department_ids)
        end
      end  
    end
  end

end
