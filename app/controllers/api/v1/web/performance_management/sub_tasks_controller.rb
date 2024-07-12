class Api::V1::Web::PerformanceManagement::SubTasksController < ApplicationController

  before_action :set_sub_task, :only => [:show, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    fiscal_year = FiscalYear.find_by(:is_active => true)
    if current_user.employee.present?
      date_of_joining = @current_user.employee.joining_date.strftime("%Y-%m-%d")
      employee_status = ReportFormat.boolean_in_text_as_confirmed(@current_user.employee.on_probation)
      if  date_of_joining <= "2023-03-31" and employee_status == "Confirmed"
        @objective_setting = current_user.employee.objective_settings.where(fiscal_year_id: fiscal_year.id).last
        @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ',')) if @objective_setting
        render status:200, template: 'api/v1/web/performance_management/sub_tasks/index'
      else
        render json: {errors: 'You Are Not Eligible'}, status: :unprocessable_entity
      end
    end
  end

  def index_approval
    @objective_setting = ObjectiveSetting.find(params[:id])
    @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ',')) if @objective_setting
    # @tasks = Task.where(:employee_id => @objective_setting.employee_id, :fiscal_year_id => @objective_setting.fiscal_year_id).order('id ASC')
    if @tasks.present?
      render status:200, template: 'api/v1/web/performance_management/sub_tasks/index'
    end
  end

  def index_appraisal_approval
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    employee = Employee.find(params[:id])
    if not employee.present?
      employee = Employee.find_by_employee_code(params[:id])
      params[:id] = employee.id
    end
    @objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id).first
    if not @objective_setting.present?
      @objective_setting = ObjectiveSetting.where(:employee_id => employee.id, :fiscal_year_id => fiscal_id).first
    end
    @tasks = Task.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id).order('id ASC')
    if @tasks.present?
      render status:200, template: 'api/v1/web/performance_management/sub_tasks/index'
    else
      @tasks = Task.where(:employee_id => employee.id, :fiscal_year_id => fiscal_id).order('id ASC')
      render status:200, template: 'api/v1/web/performance_management/sub_tasks/index'
    end
  end

  def filter_data
    @task = Task.find(params[:id])
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    @objective_setting = ObjectiveSetting.where(:employee_id => @task.employee_id, :fiscal_year_id => fiscal_id).first
    render status:200, template: 'api/v1/web/performance_management/sub_tasks/show'
  end

  def filter_task_data
    task_ids = params[:task_id].split(',')
    sub_task = []
    @sub_task = []
    if (task_ids.count > 1)
      task_ids.each do |id|
        sub_task << SubTask.where(:task_id => id).order('id DESC')
      end
      sub_task.each do |id|
        @sub_task = @sub_task + id
      end
    else
      @sub_task = SubTask.where(:task_id => params[:task_id]).order('id DESC')
    end
    render status:200, template: 'api/v1/web/performance_management/sub_tasks/filter_data'
  end

  def submit_for_approval
    total_weight = 0
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    @objective_setting = @current_user.employee.objective_settings.where(fiscal_year_id: fiscal_year_id).last
    task = Task.where(id: @objective_setting.task_ids.try(:split, ',')) if @objective_setting
    if task.present?
      task.each do |t|
        total_weight = t.weight.to_i + total_weight
      end
    end
    # task = Task.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id)
    # if task.present?
    #   task.each do |t|
    #     total_weight = t.weight.to_i + total_weight
    #   end
    # else
    #   task = Task.where(:employee_id => @current_user.employee.employee_code, :fiscal_year_id => fiscal_year_id)
    #   if task.present?
    #     task.each do |t|
    #       total_weight = t.weight.to_i + total_weight
    #     end
    #   end
    # end
    if total_weight == 100
      objective_setting = ObjectiveSetting.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id).update(objective_setting_params)
      objective_setting.first.update(line_manager_approval: 'Approved')
      UserMailer.send_email_notification(current_user.email, objective_setting.last.employee.try(:line_manager).try(:user_account_email), 'Objective Setting Approval Requested', "#{objective_setting.last.employee.full_name} has submitted request for objective setting approval", current_user.email).deliver_now if objective_setting.last.employee.try(:line_manager).try(:user_account_email)
      render json:{}, status: :created
    else
      render json: {errors: 'Total weight is < 100'}, status: :unprocessable_entity
    end
  end

  def submit_for_approval_appraisal
    trr = 0
    ar = 0
    total_competencies = Competency.count
    total_task_rating = 0
    total_competency_rating = 0
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    task = Task.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id)
    appraisal = Appraisal.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id)
    comments = AppraisalComment.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id).first
    if task.present?
      task.each do |t|
        if t.employee_rating.present?
          trr = 0
          total_task_rating = total_task_rating + t.weighted_score.to_i
        else
          trr = 1
          break
        end
      end
    end
    if appraisal.present?
      appraisal.each do |t|
        if t.employee_rating.present?
          ar = 0
          total_competency_rating = total_competency_rating + t.employee_rating.to_i
        else
          ar = 1
          break
        end
      end
    end
    if trr == 0
      if ar == 0 or @current_user.employee.department_id == 21
        if comments.present?
          objective_setting = ObjectiveSetting.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id).first
          objective_setting.line_manager_appraisal_approval = "Approved"
          comments.line_manager_approval = "Approved"
          comments.total_emp_task_score = (total_task_rating * 0.70).round(2)
          comments.total_emp_competency_score = ((total_competency_rating / total_competencies).to_f * 0.30).round(2)
          objective_setting.update(objective_setting_params)
          comments.update(appraisal_comments_params)
          objective_setting.save
          comments.save
          render json:{}, status: :created
        else
          render json: {errors: 'Enter All Needs & Comments'}, status: :unprocessable_entity
        end
      else
        render json: {errors: 'Rate All Competencies First'}, status: :unprocessable_entity
      end
    else
      render json: {errors: 'Rate All Objectives First'}, status: :unprocessable_entity
    end
  end

  def save_comments
    if @current_user.employee.present?
      trr = 0
      ar = 0
      fiscal_year_id = FiscalYear.where(:is_active => true).first.id
      task = Task.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id)
      appraisal = Appraisal.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id)
      if task.present?
        task.each do |t|
          if t.employee_rating.present?
            trr = 0
          else
            trr = 1
            break
          end
        end
      end
      if appraisal.present?
        appraisal.each do |t|
          if t.employee_rating.present?
            ar = 0
          else
            ar = 1
            break
          end
        end
      end
      if trr == 0
        if ar == 0 or @current_user.employee.department_id == 21
          need = AppraisalComment.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id).first
          if need.present?
            need.employee_comments = params[:employee_comments]
            need.leadership = params[:leadership]
            need.functional = params[:functional]
            need.career_aspiration = params[:career_aspiration]
            need.update(appraisal_comments_params)
          else
            need = AppraisalComment.new appraisal_comments_params
            need.employee_comments = params[:employee_comments]
            need.leadership = params[:leadership]
            need.functional = params[:functional]
            need.career_aspiration = params[:career_aspiration]
            need.employee_id = current_user.employee.id
            need.fiscal_year_id = fiscal_year_id
            need.save
          end
        else
          render json: {errors: 'Rate All Competencies First'}, status: :unprocessable_entity
        end
      else
        render json: {errors: 'Rate All Objectives First'}, status: :unprocessable_entity
      end
    end
  end

  def save_comments_m
    if @current_user.employee.present?
      trr = 0
      ar = 0
      total_competencies = Competency.count
      total_task_rating = 0
      total_competency_rating = 0
      fiscal_year_id = FiscalYear.where(:is_active => true).first.id
      objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id).first
      appraisal = Appraisal.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id)
      task = Task.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id, :id => objective_setting.task_ids.try(:split, ','))
      if task.present?
        task.each do |t|
          if t.line_manager_rating.present?
            total_task_rating = total_task_rating + t.line_manager_weighted_score.to_i
            trr = 0
          else
            trr = 1
            break
          end
        end
      end
      if appraisal.present?
        appraisal.each do |t|
          if t.line_manager_rating.present?
            total_competency_rating = total_competency_rating + t.line_manager_rating.to_i
            ar = 0
          else
            ar = 1
            break
          end
        end
      end
      emp = Employee.where(:id => params[:id])
      if emp.present?
        if emp.last.department_id == 21
          params[:employee_id] = params[:id]
          params[:fiscal_year_id] = fiscal_year_id
        end
      end
      if trr == 0
        if ar == 0 or emp.last.department_id == 21
          need = AppraisalComment.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id).first
          if need.present?
            need.line_manager_comments = params[:line_manager_comments]
            need.total_line_manager_task_score = (total_task_rating * 0.80).round(2)
            need.total_line_manager_competency_score = ((total_competency_rating / total_competencies).to_f * 0.20).round(2)
            need.update(appraisal_comments_params)
          else
            need = AppraisalComment.new appraisal_comments_params
            need.line_manager_comments = params[:line_manager_comments]
            need.total_line_manager_task_score = (total_task_rating * 0.80).round(2)
            need.total_line_manager_competency_score = ((total_competency_rating / total_competencies).to_f * 0.20).round(2)
            need.save
          end
        else
          render json: {errors: 'Rate All Competencies First'}, status: :unprocessable_entity
        end
      else
        render json: {errors: 'Rate All Objectives First'}, status: :unprocessable_entity
      end
    end
  end

  def create
    if @current_user.employee.present?
      date_of_joining = @current_user.employee.joining_date.strftime("%Y-%m-%d")
      employee_status = ReportFormat.boolean_in_text_as_confirmed(@current_user.employee.on_probation)
      if  date_of_joining <= "2023-03-31" and employee_status == "Confirmed"
        errors = []
        total_weight = 0
        remaining_weight = 0
        fiscal_year_id = FiscalYear.where(:is_active => true).first.id
        task = data
        if task.present?
          task = Task.where(:employee_id => task.first.id, :fiscal_year_id => fiscal_year_id)
        end
        if task.present?
          task.each do |t|
            total_weight = t.weight.to_i + total_weight
          end
        end
        remaining_weight = 100 - total_weight
        end_date = FiscalYear.where(:is_active => true).first.end_date.to_date.strftime('%Y-%m-%d')
        due_date = params[:due_date].to_date.strftime('%Y-%m-%d')
        weight = params[:weight].to_i
        if weight <= remaining_weight
          if due_date <= end_date
            if weight > 0 and weight <= 100
              if params[:sub_task_slabs].present? and params[:sub_task_slabs].count > 0
                saved, errors[0] = add_new_task
                if saved
                  sub_task_slabs = params[:sub_task_slabs]
                  sub_task_slabs.each_with_index do |sub_task_slab, index|
                    new_sub_task_slab = SubTask.new
                    new_sub_task_slab.kpi = sub_task_slab.last['sub_task']
                    new_sub_task_slab.task_id = saved.id
                    unless new_sub_task_slab.save
                      saved = false
                      errors << "#{new_sub_task_slab.kpi.truncate(15)} #{new_sub_task_slab.errors.full_messages.join('')}"
                    end
                  end
                end
                if saved
                  data = ObjectiveSetting.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id)
                  if data.present?
                    c = ","
                    task_id = saved.id.to_s
                    sub_task_id = data.first.sub_task_ids
                    task_id = task_id + c + data.first.task_ids.to_s
                    SubTask.where(:task_id => saved.id).each do |id|
                      sub_task_id = sub_task_id + c + id.id.to_s
                    end
                    objective_setting = ObjectiveSetting.where(:employee_id => @current_user.employee.id, :fiscal_year_id => fiscal_year_id).update(objective_setting_params)
                    objective_setting.first.task_ids = task_id
                    objective_setting.first.sub_task_ids = sub_task_id
                    objective_setting.first.save
                  else
                    sub_task_ids = []
                    objective_setting = ObjectiveSetting.new(objective_setting_params)
                    objective_setting.employee_id = @current_user.employee.id
                    objective_setting.fiscal_year_id = fiscal_year_id
                    objective_setting.task_ids = saved.id
                    objective_setting.starting_weight = params[:weight].to_i
                    objective_setting.ending_weight = 100
                    employee = Employee.where(:id => @current_user.employee.id).first
                    if employee.present?
                      if employee.last_name.present?
                        objective_setting.employee_name = employee.first_name + " " + employee.last_name
                      else
                        objective_setting.employee_name = employee.first_name
                      end
                    end
                    SubTask.where(:task_id => saved.id).each do |id|
                      sub_task_ids << id.id
                    end
                    objective_setting.sub_task_ids = sub_task_ids.map(&:to_i).join(',')
                    objective_setting.save
                  end
                  render json:{}, status: :created
                else
                  render json: {errors: errors.join(', ')}, status: :unprocessable_entity
                end
              else
                render json: {errors: 'Add KPI'}, status: :unprocessable_entity
              end
            else
              render json: {errors: 'Weight Ranges 1-100'}, status: :unprocessable_entity
            end
          else
            render json: {errors: 'Due Date is Invalid'}, status: :unprocessable_entity
          end
        else
          render json: {errors: 'Weight Quota Consumed'}, status: :unprocessable_entity
        end
      else
        render json: {errors: 'You Are Not Eligible'}, status: :unprocessable_entity
      end
    else
      render json: {errors: 'Employee Not Found'}, status: :unprocessable_entity
    end
  end

  def show
    @task = Task.find(params[:id])
    render status:200, template: 'api/v1/web/performance_management/sub_tasks/show'
  end

  def update
    errors = []
    saved = true
    total_weight = 0
    if params[:sub_task_slabs].present? and params[:sub_task_slabs].count > 0
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
      if new_weight <= 100
        @task = Task.find(params['id'])
        unless @task.update(task_params)
          saved, errors[0] = @task.errors.full_messages
        end
        if saved
          sub_task_slabs = params[:sub_task_slabs]
          sub_task_slabs.each_with_index do |sub_task_slab, index|
            new_sub_task_slab = SubTask.find_by_id(sub_task_slab.last['slab_id']) || SubTask.new
            new_sub_task_slab.kpi = sub_task_slab.last['sub_task']
            new_sub_task_slab.task_id = @task.id
            unless new_sub_task_slab.save
              saved = false
              errors << "#{new_sub_task_slab.kpi.truncate(15)} #{new_sub_task_slab.errors.full_messages.join('')}"
            end
          end
        end
        if saved
          render json:{}, status: :created
        else
          render json: {errors: errors.join(', ')}, status: :unprocessable_entity
        end
      else
        remaining_weight = "Remaining weight-- " + (100-total_weight).to_s
        render json: {errors: remaining_weight}, status: :unprocessable_entity
      end
    else
      render json: {errors: 'Add KPI'}, status: :unprocessable_entity
    end
  end

  def destroy
    if @sub_task.destroy
      render json: {}, status: 204
    else
      render json: {errors: @sub_task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def add_new_task
    task = Task.new(task_params)
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    task.employee_id = @current_user.employee.id
    task.fiscal_year_id = fiscal_year_id
    # task.sr_number = params[:sr_number]
    if task.save
      [task, '']
    else
      [false , task.errors.full_messages]
    end
  end

  private

  def task_params
    params.permit(:goal, :weight, :due_date, :start_date, :employee_id, :fiscal_year_id)
  end

  def objective_setting_params
    params.permit(:starting_weight, :ending_weight, :employee_id, :fiscal_year_id, :task_ids, :sub_task_ids, :employee_name, :line_manager_appraisal_approval, :line_manager_approval)
  end

  def sub_task_params
    params.permit(:task_id)
  end

  def appraisal_comments_params
    params.permit(:employee_id, :fiscal_year_id, :employee_comments, :leadership, :functional, :career_aspiration, :total_emp_task_score, :total_emp_competency_score, :line_manager_comments, :total_line_manager_task_score, :total_line_manager_competency_score)
  end

  def set_sub_task
    @sub_task = SubTask.find(params[:id])
  end

  def appraisal_params
    params.permit(:competency_id, :employee_id, :fiscal_year_id, :title, :description)
  end

  def data
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if current_user.is_admin == true
      @employees = Employee.where(:company_id => current_user.employee.id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif current_user.is_department_head == true
      # @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.where(:id => current_user.employee.id)
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees.each do |e|
        @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
      end
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => current_user.employee.id).order('id DESC')
        @employees.each do |e|
          @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
        end
      else
        @employees = Employee.where(:id => current_user.employee.id).order('id DESC')
        @employees.each do |e|
          @tasks = Task.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
        end
      end
    end
  end

end
