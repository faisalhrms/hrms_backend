class Api::V1::Web::PerformanceManagement::AppraisalsController < ApplicationController

  before_filter :set_appraisal, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @tasks = []
    fiscal_year = FiscalYear.where(:is_active => true)
    @tasks = data
    @objective_setting = data.first
    # if task_id.present?
    #   task_id = task_id.first.task_ids.split(',')
    # end
    # task_id.each do |task|
    #     @tasks = @tasks + Task.where(:id => task)
    # end
    render status:200, template: 'api/v1/web/performance_management/sub_tasks/tasks.json.jbuilder'
  end

  def index2
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if current_user.employee.present?
      @objective_setting = ObjectiveSetting.where(:employee_id => current_user.employee.id, :fiscal_year_id => fiscal_year_id).last
      if @objective_setting.present?
        if @objective_setting.status == "Approved"
          appraisals = []
          @appraisals = Appraisal.where(:employee_id => current_user.employee.id, :fiscal_year_id => fiscal_year_id).order(:id)
          @appraisals.pluck(:title).uniq.each do |title|
            check = @appraisals.where(:title => title)
            if check.count > 1
              appraisals << check.first
            else
              appraisals << check
            end
          end
          @appraisals = appraisals.flatten
          @comment = AppraisalComment.where(employee_id: @objective_setting.employee_id, fiscal_year_id: FiscalYear.active.try(:id)).last
          @tasks = Task.where(:employee_id => current_user.employee.id, :fiscal_year_id => fiscal_year_id).order('id ASC')
          render status:200, template: 'api/v1/web/performance_management/appraisals/index.json.jbuilder'
        end
      end
    end
  end

  def index3
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if current_user.employee.present?
      @objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id).last
      if @objective_setting.present?
        if @objective_setting.status == "Approved"
          appraisals = []
          @appraisals = Appraisal.where(:employee_id => params[:id], :fiscal_year_id => fiscal_year_id).order(:id)
          @appraisals.pluck(:title).uniq.each do |title|
            check = @appraisals.where(:title => title)
            if check.count > 1
              appraisals << check.first
            else
              appraisals << check
            end
          end
          @appraisals = appraisals.flatten
          @comment = AppraisalComment.where(employee_id: @objective_setting.employee_id, fiscal_year_id: FiscalYear.active.try(:id)).last
          @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ','))
          render status:200, template: 'api/v1/web/performance_management/appraisals/index.json.jbuilder'
        end
      else
        employee = Employee.find_by_employee_code(params[:id])
        @objective_setting = ObjectiveSetting.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year_id, :status => "Approved").last
        if @objective_setting.status == "Approved"
          appraisals = []
          @appraisals = Appraisal.where(:employee_id => employee.id, :fiscal_year_id => fiscal_year_id).order(:id)
          @appraisals.pluck(:title).uniq.each do |title|
            check = @appraisals.where(:title => title)
            if check.count > 1
              appraisals << check.first
            else
              appraisals << check
            end
          end
          @appraisals = appraisals.flatten
          @comment = AppraisalComment.where(employee_id: employee.id, fiscal_year_id: FiscalYear.active.try(:id)).last
          @tasks = Task.where(id: @objective_setting.task_ids.try(:split, ','))
          render status:200, template: 'api/v1/web/performance_management/appraisals/index.json.jbuilder'
        end
      end
    end
  end

  def filter_data
    @objective_settings = ObjectiveSetting.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/appraisals/index.json.jbuilder'
  end

  def filter_competency_data
    @appraisals = Appraisal.where(:id => params[:id])
    render status:200, template: 'api/v1/web/performance_management/appraisals/index.json.jbuilder'
  end

  def filter_objective_data
    objective_settings = ObjectiveSetting.where(:employee_id => @current_user.id).order('id DESC')
    task_ids = objective_settings.first.task_ids.split(',')
    @tasks = []
    task_ids.each do |id|
      @tasks = @tasks + Task.where(:id => id)
    end
    render status:200, template: 'api/v1/web/performance_management/tasks/index.json.jbuilder'
  end

  def filter_approvals
    line_manager = Employee.where(:id => @current_user.id)
    line_manager_id = line_manager.first.line_manager_id
    employees = Employee.where(:line_manager_id => line_manager_id)
    objective_setting = []
    employees.each do |e|
      objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id)
    end
    @objective_settings = ObjectiveSetting.all.order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/appraisals/index.json.jbuilder'
  end

  def create
    @objective_setting = ObjectiveSetting.new appraisal_params
    @objective_setting.task_ids = params[:task_ids].map(&:to_i).join(',')
    @objective_setting.sub_task_ids = params[:sub_task_ids].map(&:to_i).join(',')
    @objective_setting.employee_id = @current_user.id
    total_weight = 0
    task_ids = @objective_setting.task_ids.split(',')
    task_ids.each do |id|
      task = Task.where(:id => id)
      total_weight = total_weight + task.first.weight.to_i
    end
    # employee = Employee.where(:official_email => @current_user.email)
    fiscal_year = FiscalYear.where(:is_active => true)
    fiscal_id = fiscal_year.ids.map(&:inspect).first.to_i
    @objective_setting.fiscal_year_id = fiscal_id
    check_data = ObjectiveSetting.where(employee_id: @current_user.id, fiscal_year_id: fiscal_id)
    if check_data.present?
      render json: {errors: "Already Exist"}, status: :unprocessable_entity
    else
      if (total_weight <= 100)
        if @objective_setting.save
          render json:{}, status: :created
        else
          render json: {errors: @objective_setting.errors.full_messages}, status: :unprocessable_entity
        end
      else
        render json: {errors: "Total Weight > 100"}, status: :unprocessable_entity
      end
    end
  end

  def export_appraisal_report
    @objective_setting = ObjectiveSetting.where(:employee_id => current_user.id)
    @task_ids = @objective_setting.first.task_ids.split(',')
    @sub_task_ids = @objective_setting.first.sub_task_ids.split(',')
    @fiscal_year_data = FiscalYear.where(:id => @objective_setting.first.fiscal_year_id)
    @employee_data = Employee.where(:id => @objective_setting.first.employee_id)
    @designation = Designation.where(:id => @employee_data.first.designation_id)
    @grade = Grade.where(:id => @employee_data.first.grade_id)
    @department = Department.where(:id => @employee_data.first.department_id)
    @line_manager = Employee.where(:id => @employee_data.first.line_manager_id)
    @task_data = []
    @sub_task_data = []
    @total = 0
    @task_ids.each_with_index do |task_id, index|
      goals = Task.where(:id => task_id)
      @task_data << goals
      @total = @total + @task_data[index].first.weight.to_i
    end
    @sub_task_ids.each_with_index do |sub_task_id, index|
      kpi = SubTask.where(:id => sub_task_id)
      @sub_task_data = @sub_task_data + kpi
    end
    total_rating = 0
    total_score = 0
    s = 0
    @task_data.each do |goals|
    competency = Appraisal.where(:objective_id => @objective_setting.first.id, :task_id => goals.first.id)
    if competency.present?
          rating = Competency.where(:id => competency.first.competency_id)
    r = rating.first.rating
          total_rating = total_rating + r
     s = ((goals.first.weight.to_i/100.to_f)*rating.first.rating).round(2)
      total_score = total_score + s
      end
    end
    net_score =  (total_score*0.70).round(2)
    save_appraisal_approval(net_score, @employee_data.first.id, @objective_setting.first.id)
    check_directory("#{Rails.public_path}/pdf")
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/reports/appraisal/report.pdf.erb"),
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.2in',
        :right    => '0.2in'
      },
      dpi: 300,
      orientation: 'Portrait',
      page_size: 'A4'
    )
    file_name = "Objective_Setting_Report"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}
  end

  def show
    render status:200, template: 'api/v1/web/performance_management/appraisals/show.json.jbuilder'
  end

  def update
    @objective_setting.task_ids = params[:task_ids].map(&:to_i).join(',')
    @objective_setting.sub_task_ids = params[:sub_task_ids].map(&:to_i).join(',')
    if @objective_setting.update(appraisal_params)
      render json: {}, status: 204
    else
      render json: {errors: @objective_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def save_data
    task = Task.where(:id => params[:id]).first
    task.achievement_date = params[:achievement_date]
    task.employee_rating = params[:employee_rating]
    task.weighted_score = (task.weight.to_i/100.to_f).round(4)*params[:employee_rating].to_i
    if task.update(task_params)
      render json:{}, status: :created
    else
      render json: {errors: task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def save_manager_data
    task = Task.where(:id => params[:id]).first
    task.line_manager_rating = params[:line_manager_rating]
    task.line_manager_weighted_score = (task.weight.to_i/100.to_f).round(4)*params[:line_manager_rating].to_i
    if task.update(task_params)
      render json:{}, status: :created
    else
      render json: {errors: task.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def save_competency_data
    appraisal = Appraisal.find(params[:id])
    appraisals = Appraisal.where(:title => appraisal.title, :employee_id => appraisal.employee_id)
    appraisal.employee_rating = params[:employee_rating]
    if appraisal.update(appraisal_params)
      appraisals.update(:employee_rating => params[:employee_rating])
      render json:{}, status: :created
    else
      render json: {errors: appraisal.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def save_competency_data_m
    appraisal = Appraisal.find(params[:id])
    appraisal.line_manager_rating = params[:line_manager_rating]
    appraisals = Appraisal.where(:title => appraisal.title, :employee_id => appraisal.employee_id)
    if appraisal.update(appraisal_params)
      appraisals.update(:line_manager_rating => params[:line_manager_rating])
      render json:{}, status: :created
    else
      render json: {errors: appraisal.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def save_appraisal_approval(net_score, employee_id, objective_id)
    @appraisal_approval = AppraisalApproval.new appraisal_approval_params
    @appraisal_approval.objective_id = objective_id
    @appraisal_approval.net_score = net_score
    @appraisal_approval.employee_id = employee_id
    @appraisal_approval.save
  end

  def destroy
    if @objective_setting.destroy
      render json: {}, status: 204
    else
      render json: {errors: @objective_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def appraisal_params
    params.permit( :competency_id, :employee_id, :employee_rating, :line_manager_rating)
  end

  def appraisal_approval_params
    params.permit(:net_score, :objective_id, :employee_id)
  end

  def task_params
    params.permit(:employee_rating, :achievement_date, :weighted_score, :line_manager_rating, :line_manager_weighted_score)
  end

  def set_appraisal
    @appraisal = Appraisal.find(params[:id])
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

  def data
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if current_user.is_admin == true
      @employees = Employee.all.order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif current_user.is_department_head == true
      # @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.where(:id => current_user.employee.id)
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
      end
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => current_user.employee.id).order('id DESC')
        objective_setting = []
        @employees.each do |e|
          objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
        end
      else
        @employees = Employee.where(:id => current_user.employee.id).order('id DESC')
        objective_setting = []
        @employees.each do |e|
          objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id, :status => "Approved")
        end
      end
    end
    @objective_settings = objective_setting
  end

end
