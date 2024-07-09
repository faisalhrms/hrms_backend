class Api::V1::Web::Organization::GradeAllocationsController < ApplicationController

	before_filter :set_grade_allocation, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @grade_allocations = GradeAllocation.all.order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @grade_allocations = GradeAllocation.where(:company_id => current_user.employee.company_id).order('id DESC')
      else
        @grade_allocations = GradeAllocation.where(:company_id => current_user.company_id).order('id DESC')
      end
    else
      @grade_allocations = []
    end
    render status:200, template: 'api/v1/web/organization/grade_allocations/index.json.jbuilder'
  end

  def filter_data
    @grade_allocations = GradeAllocation.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/grade_allocations/index.json.jbuilder'
  end

  def create
    @grade_allocation       = GradeAllocation.new grade_allocation_params
    if @grade_allocation.save
    	save_or_update_allocated_grades
      render json:{}, status: :created
    else
      render json: {errors: @grade_allocation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def fetch_grade_data
  	@grades = Grade.where(:company_id => params[:company_id], :is_active => true).order('id ASC')
  	render status:200, template: 'api/v1/web/organization/grade_allocations/fetch_grade_data.json.jbuilder'
  end

  def show
    render status:200, template: 'api/v1/web/organization/grade_allocations/show.json.jbuilder'
  end

  def update
    if @grade_allocation.update(grade_allocation_params)
    	save_or_update_allocated_grades
      render json: {}, status: 204
    else
      render json: {errors: @grade_allocation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @grade_allocation.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @grade_allocation.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def grade_allocation_params
		params.permit(:company_id, :location_id, :branch_id, :name, :description)
	end

  def set_grade_allocation
    @grade_allocation = GradeAllocation.find(params[:id])
  end

  def save_or_update_allocated_grades
  	if params[:grade_allocation_details].present?
      grade_allocation_details = params[:grade_allocation_details]
      if grade_allocation_details.count > 0
        Array.new(grade_allocation_details.count).each_index do |index|
          if grade_allocation_details[index.to_s][:detail_id].nil?
            new_relaxation_slab 							= @grade_allocation.grade_allocation_details.build
						new_relaxation_slab.grade_id 			= grade_allocation_details[index.to_s][:grade_id]
						new_relaxation_slab.is_selected 	= grade_allocation_details[index.to_s][:is_selected]
						new_relaxation_slab.save
          else
            edit_relaxation_slab 							=	@grade_allocation.grade_allocation_details.find grade_allocation_details[index.to_s][:detail_id]
            edit_relaxation_slab.is_selected	= grade_allocation_details[index.to_s][:is_selected]
						edit_relaxation_slab.save
          end
        end
      end
    end
  end

end
