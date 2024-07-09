class Api::V1::Web::Organization::DepartmentAllocationsController < ApplicationController

	before_filter :set_department_allocation, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @department_allocations = DepartmentAllocation.all.order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @department_allocations = DepartmentAllocation.where(:company_id => current_user.employee.company_id).order('id DESC')
      else
        @department_allocations = DepartmentAllocation.where(:company_id => current_user.company_id).order('id DESC')
      end
    else
      @department_allocations = []
    end
    render status:200, template: 'api/v1/web/organization/department_allocations/index.json.jbuilder'
  end

  def filter_data
    @department_allocations = DepartmentAllocation.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/department_allocations/index.json.jbuilder'
  end

  def create
    @department_allocation       = DepartmentAllocation.new department_allocation_params
    if @department_allocation.save
    	save_or_update_allocated_departments
      render json:{}, status: :created
    else
      render json: {errors: @department_allocation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def fetch_department_data
  	@departments = Department.where(:company_id => params[:company_id], :is_active => true).order('id ASC')
  	render status:200, template: 'api/v1/web/organization/department_allocations/fetch_department_data.json.jbuilder'
  end

  def show
    render status:200, template: 'api/v1/web/organization/department_allocations/show.json.jbuilder'
  end

  def update
    if @department_allocation.update(department_allocation_params)
    	save_or_update_allocated_departments
      render json: {}, status: 204
    else
      render json: {errors: @department_allocation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @department_allocation.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @department_allocation.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def department_allocation_params
		params.permit(:company_id, :location_id, :branch_id, :name, :description)
	end

  def set_department_allocation
    @department_allocation = DepartmentAllocation.find(params[:id])
  end

  def save_or_update_allocated_departments
  	if params[:department_allocation_details].present?
      department_allocation_details = params[:department_allocation_details]
      if department_allocation_details.count > 0
        Array.new(department_allocation_details.count).each_index do |index|
          if department_allocation_details[index.to_s][:detail_id].nil?
            new_relaxation_slab 										      = @department_allocation.department_allocation_details.build
						new_relaxation_slab.department_id 						= department_allocation_details[index.to_s][:department_id]
						new_relaxation_slab.is_selected 							= department_allocation_details[index.to_s][:is_selected]
						new_relaxation_slab.save
          else
            edit_relaxation_slab 													=	@department_allocation.department_allocation_details.find department_allocation_details[index.to_s][:detail_id]
            edit_relaxation_slab.is_selected 							= department_allocation_details[index.to_s][:is_selected]
						edit_relaxation_slab.save
          end
        end
      end
    end
  end

end
