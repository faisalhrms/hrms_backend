class Api::V1::Web::PerformanceManagement::TasksController < ApplicationController

  before_filter :set_task, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if @current_user.employee.present?
      @objective_setting = ObjectiveSetting.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id, :status => "Approved").first
      if @objective_setting.present?
        @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ','))
        # @tasks = Task.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
        render status:200, template: 'api/v1/web/performance_management/tasks/index.json.jbuilder'
      end
    end
  end

  def index2
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if @current_user.employee.present?
      @objective_setting = ObjectiveSetting.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id, :status => "Approved").last
      if @objective_setting.present?
        @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ','))
        render status:200, template: 'api/v1/web/performance_management/tasks/index.json.jbuilder'
      end
    end
  end

  def index3
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    @objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id, :status => "Approved").last
    if @objective_setting.present?
      @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ','))
    else
      employee = Employee.find_by_employee_code(params[:id])
      @objective_setting = ObjectiveSetting.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year_id, :status => "Approved").last
      @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ','))
    end
    render status:200, template: 'api/v1/web/performance_management/tasks/index.json.jbuilder'
  end

  def complete_list_task
    @tasks = Task.all.order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/tasks/index.json.jbuilder'
  end

  def org_chart
    @company = Company.find(params[:company_id])
    render status:200, template: 'api/v1/web/organization/companies/org_chart.json.jbuilder'
  end


  def create
    @task       = Task.new task_params
    if @task.save
      render json:{:task_id => @task.id}, status: 200
    else
      render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/performance_management/tasks/show.json.jbuilder'
  end

  # def update
  #   if @task.update(task_params)
  #     render json:{:task_id => @task.id}, status: 200
  #   else
  #     render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
  #   end
  # end
  #

  def update
    total_weight = 0
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    task_weight = Task.where(:id => params[:id])
    task = Task.where(:employee_id => task_weight.first.employee_id, :fiscal_year_id => fiscal_year_id)
    if task.present?
      task.each do |t|
        total_weight = t.weight.to_i + total_weight
      end
    end
    wg = params[:weight].to_i - task_weight.first.weight.to_i
    new_weight = total_weight.to_i + wg
    if total_weight <= 100
      if new_weight <= 100
        objective_setting = ObjectiveSetting.where(:employee_id => task.first.employee_id).first
        objective_setting.update(objective_params)
        objective_setting.line_manager_approval = "Pending"
        if @task.update(task_params)
          render json:{:task_id => @task.id}, status: 200
        else
          render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
        end
      else
        remaining_weight = "Remaining weight-- " + (100-total_weight).to_s
        render json: {errors: remaining_weight}, status: :unprocessable_entity
      end
    else
      render json: {errors: 'Total Weight Consumed'}, status: :unprocessable_entity
    end
  end

  # def destroy
  #   if @task.destroy
  #     render json: {}, status: 204
  #   else
  #     render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
  #   end
  # end

  def destroy
    employee_id = Task.where(:id => params[:id]).first
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    objective_setting = ObjectiveSetting.where(:employee_id => employee_id.employee_id, :fiscal_year_id => fiscal_year_id)
    task_ids = ""
    stid = []
    sub_task_ids = ""
    c = ","
    if objective_setting.present?
      objective_setting.first.task_ids.split(',').each do |id|
        if id.to_i != params[:id].to_i
          task_ids = id + c + task_ids
        end
      end
      # sub_task = SubTask.where(:task_id => params[:id].to_i)
      # sub_task.each do |sb|
      #   stid << sb.id.to_i
      # end
      # objective_setting.first.sub_task_ids.split(',').each do |sid|
      #   stid.each do |s|
      #     if sid.to_i != s.to_i
      #       sub_task_ids = sid + c + sub_task_ids
      #     end
      #   end
      # end
      objective_setting.first.update(objective_params)
      objective_setting.first.task_ids = task_ids.chomp(',')
      # objective_setting.first.sub_task_ids = sub_task_ids.chomp(',')
    end
    if @task.destroy
      render json: {}, status: 204
    else
      render json: {errors: @task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.permit(:goal, :weight, :due_date)
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def objective_params
    params.permit(:task_ids, :sub_task_ids, :line_manager_approval)
  end

end
