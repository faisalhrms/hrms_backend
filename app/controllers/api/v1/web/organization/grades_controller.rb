class Api::V1::Web::Organization::GradesController < ApplicationController

	before_action :set_grade, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @grades = Grade.all.order('sort_order ASC')
    else
      @grades = Grade.where(:company_id => current_user.company_id).order('sort_order ASC')
    end
    render status:200, template: 'api/v1/web/organization/grades/index'
  end

  def filter_data
    if (current_user.is_admin == true) or (current_user.is_dtl == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true)
      @grades = Grade.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @grades = Grade.where(:company_id => current_user.employee.company_id, :is_active => true).order('id DESC')
        filter_location_wise_grade('company_head', current_user.employee)
      else
        @grades = Grade.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
      end
    elsif current_user.is_location_head == true
      if not current_user.employee.nil?
        @grades = Grade.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
        filter_location_wise_grade('location_head', current_user.employee)
      else
        @grades = []
      end
    elsif current_user.is_branch_head == true  
      if not current_user.employee.nil?
        @grades = Grade.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
        filter_location_wise_grade('branch_head', current_user.employee)
      else
        @grades = []
      end
    elsif current_user.multi_branch_allowed == true  
      if not current_user.employee.nil?
        @grades = Grade.where(:company_id => current_user.employee.company_id, :is_active => true).order('id DESC')
        filter_location_wise_grade('location_head', current_user.employee)
      else
        @grades = Grade.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
      end
    elsif not current_user.employee.nil?
      @grades = Grade.where(:id => current_user.employee.grade_id, :is_active => true).order('id DESC')
    else
      @grades = []
    end
    render status:200, template: 'api/v1/web/organization/grades/index'
  end

  def create
    @grade       = Grade.new grade_params
    if @grade.save
      render json:{}, status: :created
    else
      render json: {errors: @grade.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/grades/show'
  end

  def update
    if @grade.update(grade_params)
      render json: {}, status: 204
    else
      render json: {errors: @grade.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @grade.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @grade.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def grade_params
		params.permit(:name, :code, :company_id, :currency_title, :is_active, :description, :sort_order, :management_type, :management_tier)
	end

  def set_grade
    @grade = Grade.find(params[:id])
  end

  def filter_location_wise_grade(filter_selection, employee)
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      if system_setting.location_wise_grade == true
        if filter_selection == "company_head"
          grade_allocations = GradeAllocation.where(:company_id => employee.company_id)
          grade_ids = GradeAllocation.collect_grade_id(grade_allocations)
          @grades = @grades.where(:id => grade_ids)
        elsif filter_selection == "location_head"
          grade_allocations = GradeAllocation.where(:company_id => employee.company_id, :location_id => employee.location_id)
          grade_ids = GradeAllocation.collect_grade_id(grade_allocations)
          @grades = @grades.where(:id => grade_ids)
        elsif filter_selection == "branch_head"
          grade_allocations = GradeAllocation.where(:company_id => employee.company_id, :location_id => employee.location_id, :branch_id => employee.branch_id)
          grade_ids = GradeAllocation.collect_grade_id(grade_allocations)
          @grades = @grades.where(:id => grade_ids)
        end
      end  
    end
  end

end
