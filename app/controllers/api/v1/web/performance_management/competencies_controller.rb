class Api::V1::Web::PerformanceManagement::CompetenciesController < ApplicationController

  before_filter :set_competency, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @competencies = Competency.all.order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/competencies/index.json.jbuilder'
    # if current_user.is_admin == true
    #   @companies = Company.where(:is_active => true).order('id DESC')
    # elsif current_user.is_company_head == true
    #   if not current_user.employee.nil?
    #     @companies = Company.where(:id => current_user.employee.company_id, :is_active => true).order('id DESC')
    #   else
    #     @companies = Company.where(:id => current_user.company_id, :is_active => true).order('id DESC')
    #   end
    # else
    #   @companies = Company.where(:id => current_user.company_id, :is_active => true).order('id DESC')
    # end
    # render status:200, template: 'api/v1/web/organization/companies/index.json.jbuilder'
  end

  # def complete_list_task
  #   @tasks = Task.all.order('id DESC')
  #   render status:200, template: 'api/v1/web/performance_management/competencies/index.json.jbuilder'
  # end

  def org_chart
    @company = Company.find(params[:company_id])
    render status:200, template: 'api/v1/web/organization/companies/org_chart.json.jbuilder'
  end

  # def employee_code_prefix
  #   system_setting = SystemSetting.find_by(:company_id => params[:company_id])
  #   employee_code_prefix = system_setting.get_employee_code_prefix(system_setting, params[:company_id], params[:location_id], params[:branch_id])
  #   render status:200, json: {employee_code_prefix: employee_code_prefix}
  # end

  # def upload_logo
  #   @company = Company.find(params[:company_id])
  #   @company.avatar = params[:file]
  #   @company.save
  #   render json: "", status: :created
  # end

  def create
    @competency       = Competency.new competency_params
    if @competency.save
      render json:{:competency_id => @competency.id}, status: 200
    else
      render json: {errors: @competency.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/performance_management/competencies/show.json.jbuilder'
  end

  def update
    if @task.update(competency_params)
      render json:{:task_id => @task.id}, status: 200
    else
      render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @task.destroy
      render json: {}, status: 204
    else
      render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def competency_params
    params.permit(:title, :description, :rating)
  end

  def set_competency
    @competency = Competency.find(params[:id])
  end

end
