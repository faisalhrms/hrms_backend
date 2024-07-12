class Api::V1::Web::PerformanceManagement::ObjectiveApprovalsController < ApplicationController

  before_action :set_objective_setting, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @objective_settings = ObjectiveSetting.all.order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/index'
  end

  def filter_data
    @objective_settings = ObjectiveSetting.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/index'
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
      @sub_task_data << kpi
    end
    # @employee = Employee.find_by_id(@objective_setting.employee_id)
    check_directory("#{Rails.public_path}/pdf")
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/reports/objective_setting/objective_setting_report.pdf.erb"),
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
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/show'
  end

  def update_approval
    objective_setting = ObjectiveSetting.find(params[:id])
    objective_setting.line_manager_approval = params[:status]
    comment = ObjectiveComment.new(body: params[:comments], user: current_user, objective_setting: objective_setting)
    comment.save unless params[:comments] == 'undefined'
    if objective_setting.update(objective_setting_params)
      if objective_setting.status == 'Approved'
        Competency.all.each do |competency|
          Appraisal.create(employee_id: objective_setting.employee_id, competency_id: competency.id, fiscal_year_id: FiscalYear.active.try(:id),
                            title: competency.title, description: competency.description)
        end
      end
      UserMailer.send_email_notification(current_user.email, objective_setting.employee.try(:user).try(:email), 'Objective Setting Approval', "Your objective setting has been #{objective_setting.status} by your line manager", current_user.email).deliver_now if objective_setting.employee.try(:user).try(:email)
      render json: {}, status: 204
    else
      render json: {errors: objective_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update_appraisal_approval
    trr = 0
    ar = 0
    total_task_rating = 0
    total_competency_rating = 0
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    employee = Employee.where(:id => params[:id]).first
    if not employee.present?
      employee = Employee.find_by_employee_code(params[:id])
    end
    comments = AppraisalComment.where(:employee_id => employee.id, :fiscal_year_id => fiscal_id).first
    if not comments.present?
      employee = Employee.where(:id => params[:id]).first
      comments = AppraisalComment.where(:employee_id => employee.id, :fiscal_year_id => fiscal_id).first
    end
    params[:id] = employee.id
    objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id).first
    comment = ObjectiveComment.new(body: params[:comments], user: current_user, objective_setting: objective_setting, comment_type: 2, employee_id: params[:id])
    task = Task.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id, :id => objective_setting.task_ids.try(:split, ','))
    appraisal = Appraisal.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id)
    if task.present?
      task.each do |t|
        if t.line_manager_rating.present?
          trr = 0
          total_task_rating = total_task_rating + t.line_manager_weighted_score.to_i
        else
          trr = 1
          break
        end
      end
    end
    if appraisal.present?
      appraisal.each do |t|
        if t.line_manager_rating.present?
          ar = 0
          total_competency_rating = total_competency_rating + t.line_manager_rating.to_i
        else
          ar = 1
          break
        end
      end
    end
    comment.save unless params[:comments] == 'undefined'
    if trr == 0
      if ar == 0 or employee.department_id == 21
        if not comments.present? and employee.department_id == 21
          render json: {errors: 'Enter IDP Comment First'}, status: :unprocessable_entity
        else
          if comments.line_manager_comments.present?
            objective_setting.appraisal_status = params[:appraisal_status]
            objective_setting.line_manager_appraisal_approval = params[:appraisal_status]
            if employee.line_manager_id == employee.hod_id
              objective_setting.hod_approval_status = params[:appraisal_status]
            end
            if objective_setting.update(objective_setting_params)
              # UserMailer.send_email_notification(current_user.email, objective_setting.employee.try(:user).try(:email), 'Objective Setting Approval', "Your objective setting has been #{objective_setting.status} by your line manager", current_user.email).deliver_now if objective_setting.employee.try(:user).try(:email)
              render json: {}, status: 204
            else
              render json: {errors: objective_setting.errors.full_messages}, status: :unprocessable_entity
            end
          else
            render json: {errors: 'Enter IDP Comment First'}, status: :unprocessable_entity
          end
        end
      else
        render json: {errors: 'Rate All Competencies First'}, status: :unprocessable_entity
      end
    else
      render json: {errors: 'Rate All Objectives First'}, status: :unprocessable_entity
    end
  end

  def update_hod_approval
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id).first
    comment = ObjectiveComment.new(body: params[:comments], user: current_user, objective_setting: objective_setting, comment_type: 3, employee_id: params[:id])
    comments = AppraisalComment.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id).first
    comment.save unless params[:comments] == 'undefined'
    objective_setting.hod_approval_status = params[:hod_approval_status]
    objective_setting.appraisal_status = params[:hod_approval_status]
    if objective_setting.update(objective_setting_params)
      # UserMailer.send_email_notification(current_user.email, objective_setting.employee.try(:user).try(:email), 'Objective Setting Approval', "Your objective setting has been #{objective_setting.status} by your line manager", current_user.email).deliver_now if objective_setting.employee.try(:user).try(:email)
      render json: {}, status: 204
    else
      render json: {errors: objective_setting.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def comments
    @objective_setting = ObjectiveSetting.find(params[:id])
    @comments = @objective_setting.objective_comments.where(:comment_type => 1).order(id: :desc)
    render status:200, template: 'api/v1/web/performance_management/objective_approvals/comments'
  end

  def appraisal_comments
    fiscal_id = FiscalYear.where(:is_active => true).first.id
    @objective_setting = ObjectiveSetting.where(:employee_id => params[:id], :fiscal_year_id => fiscal_id)
    @comments = ObjectiveComment.where(:employee_id => params[:id], :comment_type => 2).order(id: :desc)
    if @comments.present?
      render status:200, template: 'api/v1/web/performance_management/objective_approvals/comments'
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
    params.permit(:status, :line_manager_approval, :appraisal_status, :line_manager_appraisal_approval, :hod_approval_status)
  end

  def set_objective_setting
    @objective_setting = ObjectiveSetting.find(params[:id])
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
