class Api::V1::Web::PerformanceManagement::AppraisalApprovalsController < ApplicationController

  before_filter :set_appraisal_setting, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @appraisal_approvals = AppraisalApproval.where(:id => params[:id])
    # @appraisal_approvals = AppraisalApproval.where(:employee_id => employee_id.first.employee_id).order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/appraisal_approval/index.json.jbuilder'
  end

  # def filter_data
  #   @objective_settings = ObjectiveSetting.where(:is_active => true).order('id DESC')
  #   render status:200, template: 'api/v1/web/performance_management/objective_settings/index.json.jbuilder'
  # end

  def filter_approvals
    line_manager = Employee.where(:id => @current_user.id)
    line_manager_id = line_manager.first.line_manager_id
    employees = Employee.where(:line_manager_id => line_manager_id)
    appraisal_approval = []
    employees.each do |e|
      appraisal_approval = appraisal_approval + AppraisalApproval.where(:employee_id => e.id)
    end
    @appraisal_approvals = AppraisalApproval.all.order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/appraisal_approval/index.json.jbuilder'
  end

  def create
    @appraisal_approval = AppraisalApproval.new appraisal_approval_params
  end

  def export_appraisal_report
    employee_id = AppraisalApproval.where(:id => params[:id])
    @objective_setting = ObjectiveSetting.where(:employee_id => employee_id.first.employee_id)
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

  def export_annual_appraisal_report
    @employee_id = AppraisalApproval.where(:id => params[:id])
    @objective_setting = ObjectiveSetting.where(:employee_id => @employee_id.first.employee_id)
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
    check_directory("#{Rails.public_path}/pdf")
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/reports/appraisal/annual_report.pdf.erb"),
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
    render status:200, template: 'api/v1/web/performance_management/appraisal_approval/show.json.jbuilder'
  end

  def update
    if @appraisal_approval.update(appraisal_approval_params)
      render json: {}, status: 204
    else
      render json: {errors: @appraisal_approval.errors.full_messages}, status: :unprocessable_entity
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

  def appraisal_approval_params
    params.permit(:status, :comments)
  end

  def set_appraisal_setting
    @appraisal_approval = AppraisalApproval.find(params[:id])
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
