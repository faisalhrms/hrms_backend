class Api::V1::Web::PerformanceManagement::ObjectiveSettingsController < ApplicationController

  before_action :set_objective_setting, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @objective_settings = data
    render status:200, template: 'api/v1/web/performance_management/objective_settings/index'
  end

  def employee_data
    objective_settings = data
    if objective_settings.present?
      @objective_setting = objective_settings.last
      @employee_data = Employee.where(:id => objective_settings.first.employee_id)
      @designation_data = Designation.where(:id => @employee_data.first.designation_id)
      @grade_data = Grade.where(:id => @employee_data.first.grade_id)
      @department_data = Department.where(:id => @employee_data.first.department_id)
      if @employee_data.first.line_manager_id.present?
        @line_manager_data = Employee.where(:id => @employee_data.first.line_manager_id)
      end
      render status:200, template: 'api/v1/web/performance_management/objective_settings/employee_data'
    else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
    end
  end

  def get_employee
    @employees = Employee.all.order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/objective_settings/employee'
  end

  def filter_data
    @objective_settings = ObjectiveSetting.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/objective_settings/index'
  end

  def filter_approvals
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    if current_user.is_admin == true
      @employees = Employee.all.order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_department_head == true
      # @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.where(:id => current_user.employee.id)
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        @employees = Employee.where("line_manager_id = :line_manager_id or id = :id", { line_manager_id: current_user.employee.id, id: current_user.employee.id })
        # @employees = Employee.where(:line_manager_id => current_user.employee.id).order('id DESC')
        objective_setting = []
        @employees.where.not(:id => @current_user.employee.id).each do |e|
          objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_approval => "Approved", :fiscal_year_id => fiscal_id)
        end
      end
    end
    @objective_settings = objective_setting
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/index'
  end

  def filter_appraisal_approvals
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    if current_user.is_admin == true
      @employees = Employee.all.order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_department_head == true
      # @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.where(:id => current_user.employee.id)
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.where.not(:id => @current_user.employee.id).each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        # @employees = Employee.where(:line_manager_id => current_user.employee.id).order('id DESC')
        @employees = Employee.where("line_manager_id = :line_manager_id or id = :id", { line_manager_id: current_user.employee.id, id: current_user.employee.id })
        objective_setting = []
        @employees.where.not(:id => @current_user.employee.id).each do |e|
          objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :line_manager_appraisal_approval => "Approved", :fiscal_year_id => fiscal_id)
        end
      end
    end
    @objective_settings = objective_setting
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/index'
  end

  def filter_hod_approvals
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    if current_user.is_admin == true
      @employees = Employee.all.order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_department_head == true
      # @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.where(:hod_id => current_user.employee.id)
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    elsif not current_user.employee.nil?
      @employees = Employee.where(:hod_id => current_user.employee.id).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :appraisal_status => "Approved", :fiscal_year_id => fiscal_id)
      end
    end
    @objective_settings = objective_setting
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/index'
  end

  def create
    @objective_setting = ObjectiveSetting.new objective_setting_params
    @objective_setting.task_ids = params[:task_ids].map(&:to_i).join(',')
    @objective_setting.sub_task_ids = params[:sub_task_ids].map(&:to_i).join(',')
    @objective_setting.employee_id = @current_user.employee.id
    employee_data = Employee.where(:id => @current_user.employee.id)
    @objective_setting.employee_name = employee_data.first.first_name + employee_data.first.last_name
    total_weight = 0
    task_ids = @objective_setting.task_ids.split(',')
    task_ids.each do |id|
      task = Task.where(:id => id)
      total_weight = total_weight + task.first.weight.to_i
    end
    # employee = Employee.where(:official_email => @current_user.email)
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    # fiscal_id = fiscal_year.ids.map(&:inspect).first.to_i
    @objective_setting.fiscal_year_id = fiscal_id
    check_data = ObjectiveSetting.where(employee_id: @current_user.employee.id, fiscal_year_id: fiscal_id)
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

  def export_objective_setting_report
    @objective_setting = ObjectiveSetting.find(params[:id])
    @task_ids = @objective_setting.task_ids.split(',')
    @sub_task_ids = @objective_setting.sub_task_ids.split(',')
    @fiscal_year_data = FiscalYear.where(:id => @objective_setting.fiscal_year_id)
    @employee_data = Employee.where(:id => @objective_setting.employee_id)
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
    # @objective_setting = ObjectiveSetting.find(params[:id])
    # @task_ids = @objective_setting.task_ids.split(',')
    # @sub_task_ids = @objective_setting.sub_task_ids.split(',')
    # @fiscal_year_data = FiscalYear.where(:id => @objective_setting.fiscal_year_id)
    # @employee_data = Employee.where(:id => @objective_setting.employee_id)
    # @designation = Designation.where(:id => @employee_data.first.designation_id)
    # @grade = Grade.where(:id => @employee_data.first.grade_id)
    # @department = Department.where(:id => @employee_data.first.department_id)
    # @line_manager = Employee.where(:id => @employee_data.first.line_manager_id)
    # @task_data = []
    # @sub_task_data = []
    # @total = 0
    # @task_ids.each_with_index do |task_id, index|
    #   goals = Task.where(:id => task_id)
    #   @task_data << goals
    #   @total = @total + @task_data[index].first.weight.to_i
    # end
    # @sub_task_ids.each_with_index do |sub_task_id, index|
    #   kpi = SubTask.where(:id => sub_task_id)
    #   @sub_task_data << kpi
    # end
    # @employee = Employee.find_by_id(@objective_setting.employee_id)
    check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/objective_setting/report.pdf.erb"),
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

  def bulk_department_allocation
    department_ids = params[:department_ids]
    if params[:attendance_structure_ids].present?
      attendance_structure_ids = params[:attendance_structure_ids].map(&:to_i)
      attendance_structure_ids.each do |single_value|
        attendance_structure = AttendanceStructure.find(single_value)
        attendance_structure.department_ids = "#{attendance_structure.department_ids},#{department_ids.join(',')}"
        attendance_structure.department_ids = attendance_structure.department_ids.split(',').map(&:to_i).uniq.join(',')
        attendance_structure.save
      end
    end
    render json: {}, status: 204
  end

  def show
    render status:200, template: 'api/v1/web/performance_management/objective_settings/show'
  end

  def update
    @objective_setting.task_ids = params[:task_ids].map(&:to_i).join(',')
    @objective_setting.sub_task_ids = params[:sub_task_ids].map(&:to_i).join(',')
    if @objective_setting.update(objective_setting_params)
      render json: {}, status: 204
    else
      render json: {errors: @objective_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @objective_setting.destroy
      render json: {}, status: 204
    else
      render json: {errors: @objective_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def objective_setting_params
    params.permit(:starting_weight, :ending_weight, :is_active, :employee_id, :fiscal_year_id, :employee_name)
  end

  def set_objective_setting
    @objective_setting = ObjectiveSetting.find(params[:id])
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
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => current_user.company_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif current_user.is_department_head == true
      # @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      @employees = Employee.where(:id => current_user.employee.id)
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      objective_setting = []
      @employees.each do |e|
        objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
      end
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        @employees = Employee.where(:id => current_user.employee.id)
        objective_setting = []
        @employees.each do |e|
          objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
        end
      else
        @employees = Employee.where(:id => current_user.employee.id).order('id DESC')
        objective_setting = []
        @employees.each do |e|
          objective_setting = objective_setting + ObjectiveSetting.where(:employee_id => e.id, :fiscal_year_id => fiscal_year_id)
        end
      end
    end
    @objective_settings = objective_setting
  end

end
