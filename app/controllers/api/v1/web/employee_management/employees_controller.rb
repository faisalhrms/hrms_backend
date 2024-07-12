class Api::V1::Web::EmployeeManagement::EmployeesController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:fetch_companies, :fetch_designations, :fetch_departments, :fetch_locations, :fetch_employees]
  before_action :set_employee, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  ####### Index #########

  def current_employee
    @employees = Employee.includes(:designation, :department, :location, :branch, :grade).where(:company_id => params[:company_id], :is_active => true, is_struck_off: false).order('id DESC')
    filter_employee_data_on_request
    render status:200, template: 'api/v1/web/employee_management/employees/index'
  end

  def subordinate_employee
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true).order('id DESC')
        filter_employee_data_on_request
        @employees = Employee.multiple_branch_data(@employees, current_user)
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true).order('id DESC')
        filter_employee_data_on_request
        @employees = Employee.multiple_branch_data(@employees, current_user)
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true).order('id DESC')
        filter_employee_data_on_request
        @employees = Employee.multiple_branch_data(@employees, current_user)
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true).order('id DESC')
        filter_employee_data_on_request
        @employees = Employee.multiple_branch_data(@employees, current_user)
      elsif current_user.is_sub_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true).order('id DESC')
        filter_employee_data_on_request
        @employees = Employee.multiple_branch_data(@employees, current_user)
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true).order('id DESC')
        filter_employee_data_on_request
        @employees = Employee.multiple_branch_data(@employees, current_user)
      else
        @employees = []
      end
    else
      @employees = []
    end
    @employees = Employee.multiple_branch_data(@employees, current_user)
    render status:200, template: 'api/v1/web/employee_management/employees/index'
  end

  def archive_employee
    @employees = Employee.where("company_id = ? AND (is_active = ? OR is_struck_off = ?)", params[:company_id], false, true).order('id DESC')
    filter_employee_data_on_request
    @employees = Employee.multiple_branch_data_in_active(@employees, current_user)
    render status:200, template: 'api/v1/web/employee_management/employees/index'
  end

  def line_manager_list
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :is_line_manager => true).order('id DESC')
    filter_employee_data_on_request
    render status:200, template: 'api/v1/web/employee_management/employees/index'
  end

  def head_of_department_list
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :is_department_head => true).order('id DESC')
    filter_employee_data_on_request
    render status:200, template: 'api/v1/web/employee_management/employees/index'
  end

  def combine_filter_data
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end 
    if not params[:employee_type_id].blank?
      @employees = Employee.employee_type_related_employee(@employees, params[:employee_type_id].to_i)
    end 
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'   
  end

  def employee_change_list
    is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
    filter_employee_data_on_request
    render status:200, template: 'api/v1/web/employee_management/employees/index'
  end

  def filter_subordinate_employee
    if not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        employee_ids = Employee.where(:line_manager_id => current_user.employee.id, :is_active => true).collect(&:id)
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids).order('id DESC')
      else
        @employees = []
      end
    else
      @employees = []
    end
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end



  def filter_data
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    if not current_user.employee.nil?
      if current_user.is_admin == true
        @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_company_head == true
        @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => params[:company_id], :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_sub_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      else
        @employees = Employee.where(:id => current_user.employee.id, :excluded_from_reports => false)
      end
    end
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  def filter_location_data
    @employees = Employee.where(:location_id => params[:location_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    if not current_user.employee.nil?
      if current_user.is_admin == true
        @employees = Employee.where(:location_id => params[:location_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_company_head == true
        @employees = Employee.where(:location_id => params[:location_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_sub_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      else
        @employees = Employee.where(:id => current_user.employee.id, :excluded_from_reports => false)
      end
    end
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  def filter_combine_data
    @employees = Employee.where(:location_id => params[:location_id], :employee_type_id => params[:employee_type_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  def filter_permanent_data
    @employees = Employee.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  def filter_branch_data
    @employees = Employee.where(:branch_id => params[:branch_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  def filter_department_data
    @employees = Employee.where(:department_id => params[:department_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  def filter_langguage_date
    @employee = Employee.find(params[:id])
    render status:200, template: 'api/v1/web/employee_management/employees/show'
  end

  def filter_incharge_data
    @employees = Employee.where(:is_incharge => true, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data'
  end

  # def employee_combine_information
  #   @employee = Employee.find(params[:employee_id])
  #   render status:200, template: 'api/v1/web/employee_management/employees/employee_combine_information'
  # end

  def employee_combine_information
    if current_user.is_admin == true
      employees = Employee.all.order('id DESC')  
    elsif current_user.is_company_head == true
      employees = Employee.where(:company_id => current_user.company_id).order('id DESC')  
    elsif not current_user.employee.nil?
      if current_user.is_location_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
      elsif current_user.is_branch_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
      elsif current_user.is_department_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.all_company_department == true
        employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.is_sub_department_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
      else
        employees = Employee.where(:id => current_user.employee.id).order('id DESC')
      end
    else
      employees = []
    end
    if employees.collect(&:id).include?(params[:employee_id].to_i) == true
      @employee = Employee.find(params[:employee_id])
      render status:200, template: 'api/v1/web/employee_management/employees/employee_combine_information'
    else
      render status:404, json: {message: "No Record Found"}
    end
  end

  def get_employees
    query = params[:query].downcase
    if current_user.is_admin == true
      @employees = Employee.where(:is_active => true, :excluded_from_reports => false)
    elsif current_user.is_company_head == true
      @employees = Employee.where(:is_active => true, :company_id => current_user.company_id, :excluded_from_reports => false)
    else
      if not current_user.employee.nil?
        if current_user.is_location_head == true
          @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        elsif current_user.is_branch_head == true
          @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        elsif current_user.is_department_head == true
          @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        elsif current_user.all_company_department == true
          @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        elsif current_user.is_sub_department_head == true
          @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        elsif current_user.employee.is_line_manager == true
          sub_ordinates_ids = []
          employee_ids = []
          employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
          employee_ids = employee_ids.flatten.uniq
          employee_ids << current_user.employee.id
          @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
        else        
          @employees = Employee.where(:is_active => true, :id => current_user.employee.id, :excluded_from_reports => false)  
        end
      else
        @employees = []
      end
    end
    if @employees.count > 0
      @employees = @employees.where("first_name ILIKE ? OR last_name ILIKE ? OR employee_code ILIKE ? OR concat(first_name, ' ', last_name) ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")  
    end
    render status:200, template: 'api/v1/web/employee_management/employees/get_employees'
  end

  def get_subordinate_employees
    query = params[:query].downcase
    if current_user.is_admin == true
      @employees = Employee.where(:is_active => true, :excluded_from_reports => false)
    elsif current_user.is_company_head == true
      @employees = Employee.where(:is_active => true, :company_id => current_user.company_id, :excluded_from_reports => false)
    elsif not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        filter_employee_data_on_request
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        filter_employee_data_on_request
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        filter_employee_data_on_request
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        filter_employee_data_on_request
      elsif current_user.is_sub_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
        filter_employee_data_on_request
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
        filter_employee_data_on_request
      else
        @employees = []
      end
    else
      @employees = []
    end
    @employees = Employee.multiple_branch_data(@employees, current_user)
    if @employees.count > 0
      @employees = @employees.where("first_name ILIKE ? OR last_name ILIKE ? OR employee_code ILIKE ? OR concat(first_name, ' ', last_name) ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")  
    end
    render status:200, template: 'api/v1/web/employee_management/employees/get_employees'
  end

  ####### Picture or File Attachment #########

  def upload_logo
    @employee = Employee.find(params[:employee_id])
    @employee.avatar = params[:file]
    @employee.save
    render json: "", status: :created
  end

  def upload_vaccine
    @employee = Employee.find(params[:employee_id])
    @employee.vaccinee = params[:file]
    @employee.save
    render json: "", status: :created
  end


  def upload_qualification_attachment
    @qualification = EmployeeQualification.find(params[:qualification_id])
    @qualification.avatar = params[:file]
    @qualification.save
    render json: "", status: :created
  end

  def upload_experience_attachment
    @experience = EmployeeExperience.find(params[:experience_id])
    @experience.avatar = params[:file]
    @experience.save
    render json: "", status: :created
  end


  def upload_training_attachment
    @training = EmployeeTraining.find(params[:training_id])
    @training.avatar = params[:file]
    @training.save
    render json: "", status: :created
  end

  def upload_certification_attachment
    @certification = EmployeeCertification.find(params[:certification_id])
    @certification.avatar = params[:file]
    @certification.save
    render json: "", status: :created
  end

  def upload_membership_attachment
    @membership = EmployeeMembership.find(params[:membership_id])
    @membership.avatar = params[:file]
    @membership.save
    render json: "", status: :created
  end
  def upload_documents_attachment
    @document_list = EmployeeDocument.find(params[:document_id])
    @document_list.avatar = params[:file]
    @document_list.save
    render json: "", status: :created
  end
  ####### Creation #########

  def create
    @employee       = Employee.new employee_params
    if params[:date_of_birth].nil?
      @employee.date_of_birth = nil
    else
      @employee.date_of_birth = params[:date_of_birth].to_date
    end
    if params[:old_joining_date].nil?
      @employee.old_joining_date = nil
    else
      @employee.old_joining_date = params[:old_joining_date].to_date
    end
    if params[:joining_date].nil?
      @employee.joining_date = nil
    else
      @employee.joining_date = params[:joining_date].to_date
    end
    if @employee.on_probation == false
      @employee.confirmation_date     = @employee.joining_date
      @employee.confimration_due_date = @employee.joining_date
    else
      if params[:confimration_due_date].nil?
        @employee.confimration_due_date = nil
      else
        @employee.confimration_due_date = params[:confimration_due_date].to_date
      end
    end
    if params[:contract_start_date].nil?
      @employee.contract_start_date = nil
    else
      @employee.contract_start_date = params[:contract_start_date].to_date
    end
    if params[:contract_end_date].nil?
      @employee.contract_end_date = nil
    else
      @employee.contract_end_date = params[:contract_end_date].to_date
    end
    if params[:cnic_expiry_date].nil?
      @employee.cnic_expiry_date = nil
    else
      @employee.cnic_expiry_date = params[:cnic_expiry_date].to_date
    end
    if params[:group_id].present?
      if params[:group_id].class == String
        @employee.group_id = params[:group_id]
      else
        @employee.group_id = params[:group_id].join(",")
      end
    end
    if params[:employee_type_id] == "7" and params[:group_id].present? and params[:is_incharge] == "false"
      group = Piecerate.find(params[:group_id].to_i)
      line = Piecerate.find(group.line_id.to_i)
      total_employees = Employee.where(:group_id => params[:group_id], :is_incharge => false).count
      if total_employees < group.total_machines
        @employee.line_id = group.line_id
        @employee.category_id = group.category_id
        @employee.floor_id = line.floor_id
        @employee.save
        render json: {}, status: 204
      else
        render json: {errors: "Total Machines Consumed"}, status: :unprocessable_entity
      end
    else
      if @employee.save
        render json: {}, status: 204
      else
        render json: {errors: @employee.errors.full_messages}, status: :unprocessable_entity
      end
    end

  end

  ####### View #########

  # def show
  #   render status:200, template: 'api/v1/web/employee_management/employees/show'
  # end

  def show
    if current_user.is_admin == true
      employees = Employee.all.order('id DESC')  
    elsif current_user.is_company_head == true
      employees = Employee.where(:company_id => current_user.company_id).order('id DESC')  
    elsif not current_user.employee.nil?
      if current_user.is_location_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
      elsif current_user.is_branch_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
      elsif current_user.is_department_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.all_company_department == true
        employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.is_sub_department_head == true
        employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
      else
        employees = Employee.where(:id => current_user.employee.id).order('id DESC')
      end
    else
      employees = []
    end
    employees = Employee.multiple_branch_data(employees, current_user)
    # if employees.collect(&:id).include?(params[:id].to_i) == true
      
    # else 
    #   render status:404, json: {message: "No Record Found"}
    # end
    render status:200, template: 'api/v1/web/employee_management/employees/show'
  end

  def get_updated_confimration_due_date
    confimration_due_date = nil
    employee = Employee.find(params[:employee_id])
    if not employee.nil?
      confimration_due_date = employee.confimration_due_date
      confimration_due_date = confimration_due_date.to_date + params[:probation_extension_days].to_i.day
    end
    render status:200, json: {confimration_due_date: ReportFormat.date_format(confimration_due_date)}
  end

  def fetch_location
    if not current_user.employee.nil?
      location_id = current_user.employee.location_id
      render status:200, json: {:location_id => location_id}
    else
      render status:422, json: {:message => "You are not a employee"}
    end
  end

  def fetch_employee
    if not current_user.employee.nil?
      employee_id = current_user.employee.id
      render status:200, json: {:employee_id => employee_id, :company_id => current_user.employee.company_id}
    else
      render status:200, json: {:employee_id => nil, :company_id => current_user.company_id}
    end
  end


  ####### Save #########

  def update
    if params[:vehicle_assignment_date].nil?
      @employee.vehicle_assignment_date = nil
    else
      @employee.vehicle_assignment_date = params[:vehicle_assignment_date].to_date
    end

    if params[:date_of_birth].nil?
      @employee.date_of_birth = nil
    else
      @employee.date_of_birth = params[:date_of_birth].to_date
    end

    # @employee.languages = params[:languages].try(:join, ',')

    if params[:old_joining_date].nil?
      @employee.old_joining_date = nil
    else
      @employee.old_joining_date = params[:old_joining_date].to_date
    end
    if params[:cnic_expiry_date].nil?
      @employee.cnic_expiry_date = nil
    else
      @employee.cnic_expiry_date = params[:cnic_expiry_date].to_date
    end
    if params[:group_id].present?
      if params[:group_id].class == String
        @employee.group_id = params[:group_id]
      else
        @employee.group_id = params[:group_id].join(",")
      end
    end
    employee_other_benefit_dates
    update_employee_tags
    @employee.update(hiring_shift_id: params[:hiring_shift]) if params[:hiring_shift].present?
    if params[:employee_type_id] == "7" or params[:employee_type_id] == "8" and params[:group_id].present? and params[:is_incharge] == "false"
      if params[:group_id].present? and not params[:group_id].to_i == 0
        group = Piecerate.find(params[:group_id].to_i)
        if group.present?
          line = Piecerate.find(group.line_id.to_i)
          @employee.line_id = group.line_id
          @employee.category_id = group.category_id
          @employee.floor_id = line.floor_id
          total_employees = Employee.where(:group_id => params[:group_id], :is_incharge => false).count
          if total_employees < group.total_machines or total_employees > group.total_machines
            if @employee.update(edit_employee_params)
              @employee.verify_user_account
              render json:{:employee_id => @employee.id}, status: 200
            else
              render json: {errors: @employee.errors.full_messages}, status: :unprocessable_entity
            end
          else
            render json: {errors: "Total Machines Consumed"}, status: :unprocessable_entity
          end
        else
          @employee.group_id = nil
          @employee.incharge_id = nil
          @employee.line_id = nil
          @employee.floor_id = nil
          @employee.category_id = nil
          if @employee.update(edit_employee_params)
            @employee.verify_user_account
            render json:{:employee_id => @employee.id}, status: 200
          else
            render json: {errors: @employee.errors.full_messages}, status: :unprocessable_entity
          end
        end
      else
        @employee.group_id = nil
        @employee.incharge_id = nil
        @employee.line_id = nil
        @employee.floor_id = nil
        @employee.category_id = nil
        if @employee.update(edit_employee_params)
          @employee.verify_user_account
          render json:{:employee_id => @employee.id}, status: 200
        else
          render json: {errors: @employee.errors.full_messages}, status: :unprocessable_entity
        end
      end
    else
      if @employee.update(edit_employee_params)
        @employee.verify_user_account
        render json:{:employee_id => @employee.id}, status: 200
      else
        render json: {errors: @employee.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

  def save_relative
    @employee = Employee.find(params[:employee_id])
    if params[:employee_relative_id].present?
      @relative = EmployeeRelative.find (params[:employee_relative_id])
      if params[:date_of_enrollment].nil?
        @relative.date_of_enrollment = nil
      else
        @relative.date_of_enrollment = params[:date_of_enrollment].to_date
      end
      if params[:date_of_birth].nil?
        @relative.date_of_birth = nil
      else
        @relative.date_of_birth = params[:date_of_birth].to_date
      end
      @relative.update(relative_params)
    else
      @relative = @employee.employee_relatives.build(relative_params)
      if params[:date_of_enrollment].nil?
        @relative.date_of_enrollment = nil
      else
        @relative.date_of_enrollment = params[:date_of_enrollment].to_date
      end
      if params[:date_of_birth].nil?
        @relative.date_of_birth = nil
      else
        @relative.date_of_birth = params[:date_of_birth].to_date
      end
      @relative.save
    end
    render json: {}, status: 204
  end

  def save_next_of_kin
    @employee = Employee.find(params[:employee_id])
    if params[:employee_next_of_kin_id].present?
      @next_of_kin = EmployeeNextOfKin.find (params[:employee_next_of_kin_id])
      @next_of_kin.update(next_of_kin_params)
    else
      @next_of_kin = @employee.employee_next_of_kins.build(next_of_kin_params)
      @next_of_kin.save
    end
    render json: {}, status: 204
  end

  def save_reference
    @employee = Employee.find(params[:employee_id])
    if params[:employee_reference_id].present?
      @reference = EmployeeReference.find (params[:employee_reference_id])
      @reference.update(reference_params)
    else
      @reference = @employee.employee_references.build(reference_params)
      @reference.save
    end
    render json: {}, status: 204
  end

  def save_qualification
    @employee = Employee.find(params[:employee_id])
    if params[:employee_qualification_id].present?
      @qualification = EmployeeQualification.find (params[:employee_qualification_id])
      assign_qualification_dates
      @qualification.update(qualification_params)
    else
      @qualification = @employee.employee_qualifications.build(qualification_params)
      assign_qualification_dates
      @qualification.save
    end
    
    
    render json:{:qualification_id => @qualification.id}, status: 200
  end


  def save_experience
    @employee = Employee.find(params[:employee_id])
    if params[:employee_experience_id].present?
      @experience = EmployeeExperience.find (params[:employee_experience_id])
      assign_experience_dates
      @experience.update(experience_params)
    else
      @experience = @employee.employee_experiences.build(experience_params)
      assign_experience_dates
      @experience.save
    end
    render json:{:experience_id => @experience.id}, status: 200
  end

  def save_membership
    @employee = Employee.find(params[:employee_id])
    if params[:employee_membership_id].present?
      @membership = EmployeeMembership.find (params[:employee_membership_id])
      @membership.update(membership_params)
    else
      @membership = @employee.employee_memberships.build(membership_params)
      @membership.save
    end
    render json:{:membership_id => @membership.id}, status: 200
  end

  def save_document
    @employee = Employee.find(params[:employee_id])
    if params[:employee_document_id].present?
      @document_list = EmployeeDocument.find (params[:employee_document_id])
      @document_list.update(document_params)
    else
      @document_list = @employee.employee_documents.build(document_params)
      @document_list.save
    end
    render json:{:document_id => @document_list.id}, status: 200
  end

  def save_training
    @employee = Employee.find(params[:employee_id])
    if params[:employee_training_id].present?
      @training = EmployeeTraining.find (params[:employee_training_id])
      assign_training_dates
      @training.update(training_params)
    else
      @training = @employee.employee_trainings.build(training_params)
      assign_training_dates
      @training.save
    end
    render json:{:training_id => @training.id}, status: 200
  end

  def save_certification
    @employee = Employee.find(params[:employee_id])
    if params[:employee_certification_id].present?
      @certification = EmployeeCertification.find (params[:employee_certification_id])
      assign_certification_dates
      @certification.update(certification_params)
    else
      @certification = @employee.employee_certifications.build(certification_params)
      assign_certification_dates
      @certification.save
    end
    render json:{:certification_id => @certification.id}, status: 200
  end

  ####### Deletion #########

  def destroy
  	if @employee.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def remove_relative
    @relative = EmployeeRelative.find (params[:id])
    if @relative.destroy
      render json: {}, status: 204
    else
      render json: {errors: @relative.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_next_of_kin
    @next_of_kin = EmployeeNextOfKin.find (params[:id])
    if @next_of_kin.destroy
      render json: {}, status: 204
    else
      render json: {errors: @next_of_kin.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_reference
    @reference = EmployeeReference.find (params[:id])
    if @reference.destroy
      render json: {}, status: 204
    else
      render json: {errors: @reference.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_qualification
    @qualification = EmployeeQualification.find (params[:id])
    if @qualification.destroy
      render json: {}, status: 204
    else
      render json: {errors: @qualification.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_experience
    @experience = EmployeeExperience.find (params[:id])
    if @experience.destroy
      render json: {}, status: 204
    else
      render json: {errors: @experience.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_training
    @training = EmployeeTraining.find (params[:id])
    if @training.destroy
      render json: {}, status: 204
    else
      render json: {errors: @training.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_certification
    @certification = EmployeeCertification.find (params[:id])
    if @certification.destroy
      render json: {}, status: 204
    else
      render json: {errors: @certification.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_membership
    @membership = EmployeeMembership.find (params[:id])
    if @membership.destroy
      render json: {}, status: 204
    else
      render json: {errors: @membership.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def remove_document
    @document_list = EmployeeDocument.find (params[:id])
    if @document_list.destroy
      render json: {}, status: 204
    else
      render json: {errors: @document_list.errors.full_messages}, status: :unprocessable_entity
    end
  end
  ####### Downloading Document #########

  def download_employee_info_file
    if params[:employee_id].present?
      if params[:file_type] == "Employee Tag Info"
        employee_tag_info_pdf_file(params[:employee_id])
      elsif params[:file_type] == "Employee Joining Info"
        employee_joining_info_pdf_file(params[:employee_id])
      elsif params[:file_type] == "Employee Next Of Kin Info"
        employee_next_of_kin_info_pdf_file(params[:employee_id])
      elsif params[:file_type] == "Employee Personal Info"
        employee_personal_info_pdf_file(params[:employee_id])
      elsif params[:file_type] == "Employee Asset Hand"
        employee_asset_pdf_file(params[:employee_id])
      elsif params[:file_type] == "Employee Mode of Collection Settlement"
        employee_mode_of_collection_settlement_pdf_file(params[:employee_id])
      elsif params[:file_type] == "Employee Clearance Form"
        employee_clearance_form(params[:employee_id])
      elsif params[:file_type] == "Employee Exit Interview Form"
        exit_interview_form(params[:employee_id])
      elsif params[:file_type] == "Employee Card"
        employee_card_pdf(params[:employee_id])
      end
    else
      render json: {}, status: 204
    end
  end

  def employee_tag_info_pdf_file(employee_id)
    @employee = Employee.find(employee_id)
    time = Time.now
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_tag_info.pdf.erb"),
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 500,
      orientation: 'Landscape'
    )
    
    file_name = "#{@employee.full_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_joining_info_pdf_file(employee_id)
    @employee = Employee.find(employee_id)
    time = Time.now
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_joining_info.pdf.erb"),
      footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 320
    )
    
    file_name = "#{@employee.full_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_next_of_kin_info_pdf_file(employee_id)
    @employee = Employee.find(employee_id)

    time = Time.now
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_next_of_kin_info.pdf.erb"),
      footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 320
    )
    
    file_name = "#{@employee.full_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_personal_info_pdf_file(employee_id)
    @employee = Employee.find(employee_id) 
    time = Time.now 
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_personal_info.pdf.erb"),
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 320
    )
    
    file_name = "#{@employee.full_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_asset_pdf_file(employee_id)
    @employee = Employee.find(employee_id)
    time = Time.now
    
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_asset_info.pdf.erb"),
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 320
    )
    
    file_name = "#{@employee.full_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_mode_of_collection_settlement_pdf_file(employee_id)
    @employee = Employee.find(employee_id)
    time = Time.now
    
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/mode_of_collection_settlement.pdf.erb"),
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 320
    )
    
    file_name = "#{@employee.first_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_clearance_form(employee_id)
    @employee = Employee.find(employee_id)
    time = Time.now
    
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_clearance_form.pdf.erb"),
      dpi: 320
    )

    file_name = "#{@employee.first_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def exit_interview_form(employee_id)
    @employee = Employee.find(employee_id)
    time = Time.now
    
    url_path = ""
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/exit_interview_form.pdf.erb"),
      dpi: 320
    )

    file_name = "#{@employee.first_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def employee_card_pdf(employee_id)
    employee = Employee.find(employee_id)
    @employees = [employee]
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_card.pdf.erb"),
        :margin => {
            :top      => '0.5in',
            :bottom   => '0.5in',
            :left     => '0.5in',
            :right    => '0.5in'
        },
        dpi: 320
    )
    file_name = "employee_card_#{employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def download_employee_cards
    @employees = Employee.includes(:designation, :department, :location, :branch, :grade).where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    filter_employee_data_on_request
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/employee_management/employees/employee_pdf_formats/employee_card.pdf.erb"),
        :margin => {
            :top      => '0.1in',
            :bottom   => '0.1in',
            :left     => '0.5in',
            :right    => '0.5in'
        },
        dpi: 320
    )
    file_name = "bulk_employee_cards"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def download_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["salutation", "first_name", "last_name", "father_name", "official_email", "official_mobile_number", "date_of_birth", "gender", "cnic_number", "blood_group", "martial_status", "company", "location", "branch", "department", "designation", "job_title", "grade", "salary_unit", "cost_center", "joining_date", "employee_code", "prev_employee_code", "on_probation", "is_line_manager", "is_active", "gross_salary", "current_address", "current_country", "current_state", "current_city", "confirmation_date", "line_manager"]
      csv << ["Mr.", "Hamza", "Mujeeb", "Mujeeb", "hamza.mujeeb@abc.com.pk", "03001234567", "01/12/2018", "Male", "35206-3976777-7", "AB+", "Single", "SRL", "Head Office", "Tricon Office", "IT", "Manager", "IT Integration", "G-7", "STM7", "ABC", "01/06/2013", "1001", "11002200", "TRUE", "TRUE", "TRUE", 19000, "House # 420 ABC Block XYZ Town", "Pakistan", "Punjab", "Lahore", "", ""]
      csv << ["Ms.", "Atiqa", "Saleem", "Saleem", "atiqa.saleem@abc.com.pk", "03000212345", "01/12/2018", "Female", "35206-3976777-7", "A+", "Single", "STML", "Head Office", "7-A/K", "IT", "Manager", "IT Integration", "G-7", "STM7", "ABC", "01/11/2012", "1002", "11002200", "TRUE", "TRUE", "TRUE", 99000, "House # 420 ABC Block XYZ Town", "Pakistan", "Punjab", "Lahore", "", ""]
      csv << ["Mr.", "Tayyab", "Zahid", "Zahid", "khawaja.tayyab@abc.com.pk", "03000342351", "01/12/2018", "Male", "35206-3976777-7", "AB+", "Married", "ABC", "Head Office", "Head Office", "IT", "Manager", "IT Integration", "G-7", "STM7", "ABC", "01/10/2017", "1003", "11002200", "FALSE", "FALSE", "FALSE", 50000, "House # 420 ABC Block XYZ Town", "Pakistan", "Punjab", "Lahore", "01/11/2013", ""]
      csv << ["Mr.", "Ahsan", "Ali", "Ali", "ahsan.ali@abc.com.pk", "03000123456", "01/12/2018", "Male", "35206-3976777-7", "AB+", "Married", "XYZ", "Head Office", "Head Office", "IT", "Manager", "IT Integration", "G-7", "STM7", "ABC", "01/12/2016", "1004", "11002200", "TRUE", "TRUE", "TRUE", 199000, "House # 420 ABC Block XYZ Town", "Pakistan", "Punjab", "Lahore", "", "1001"]
    end
    render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import_employee
    response_messages = []
    file = params[:file]
    employee_data = SmarterCSV.process(file.tempfile)
    employee_data.each_with_index do |employee_detail,index|
      remarks = []
      valid_data = true
      company = Company.find_by(:name => employee_detail[:company])
      if company.nil?
        valid_data = false
        remarks << "Company not found"
      end
      if valid_data == true
        location = Location.find_by(:name => employee_detail[:location], :company_id => company.id)
        if location.nil?
          valid_data = false
          remarks << "Location not found"
        end
        employee_type = EmployeeType.find_by(:name => employee_detail[:employee_type])
        if employee_type.nil?
          valid_data = false
          remarks << "Employee type not found"
        end
        branch = Branch.find_by(:name => employee_detail[:branch], :company_id => company.id)
        if branch.nil?
          valid_data = false
          remarks << "Branch not found"
        end
        department = Department.find_by(:name => employee_detail[:department], :company_id => company.id)
        if department.nil?
          valid_data = false
          remarks << "Department not found"
        end
        designation = Designation.find_by(:name => employee_detail[:designation], :company_id => company.id)
        if designation.nil?
          valid_data = false
          remarks << "Designation not found"
        end
        grade = Grade.find_by(:name => employee_detail[:grade], :company_id => company.id)
        if grade.nil?
          valid_data = false
          remarks << "Grade not found"
        end
        job_title = JobTitle.find_by(:name => employee_detail[:job_title], :company_id => company.id)
        if job_title.nil?
          valid_data = false
          remarks << "Job Title not found"
        end
        salary_unit = SalaryUnit.find_by(:name => employee_detail[:salary_unit], :company_id => company.id)
        if salary_unit.nil?
          valid_data = false
          remarks << "Salary Unit not found"
        end
        cost_center = CostCenter.find_by(:name => employee_detail[:cost_center], :company_id => company.id)
        if cost_center.nil?
          valid_data = false
          remarks << "Cost Center not found"
        end
        country = Country.find_by(:name => employee_detail[:current_country])
        if country.nil?
          valid_data = false
          remarks << "Country not found"
        end
        state = State.find_by(:name => employee_detail[:current_state])
        if state.nil?
          valid_data = false
          remarks << "State not found"
        end
        city = City.find_by(:name => employee_detail[:current_city])
        if city.nil?
          valid_data = false
          remarks << "City not found"
        end
      end
      if valid_data == true
        if employee_detail[:line_manager].to_i != 0
          line_manager = Employee.find_by(:employee_code => employee_detail[:line_manager], :company_id => company.id)
          if line_manager.nil?
            valid_data = false
            remarks << "Line Manager Not Found"
          end
        end
      end
      if employee_detail[:employee_type] == "Piece Rate" or employee_detail[:employee_type] == "Test Piece Rate"
        if employee_detail[:group_id].present?
          group_id = employee_detail[:group_id]
        end
        if employee_detail[:incharge_id].present?
          incharge_id = employee_detail[:incharge_id]
        end
      end
      if not employee_detail[:cnic_expiry_date].present?
        valid_data = false
        remarks << "CNIC Expiry Date Not Found"
      end
      if not employee_detail[:mother_name].present?
        valid_data = false
        remarks << "Mother Name Not Found"
      end
      if valid_data == true
        employee = Employee.find_by(:employee_code => employee_detail[:employee_code], :company_id => company.id)
        if employee.nil?
          # remarks << "New Employee saved"
          employee = Employee.new
          employee.salutation = employee_detail[:salutation]
          employee.first_name = employee_detail[:first_name]
          employee.last_name = employee_detail[:last_name]
          employee.father_name = employee_detail[:father_name]
          employee.mother_name = employee_detail[:mother_name]
          employee.official_email = employee_detail[:official_email]
          employee.official_mobile_number = employee_detail[:official_mobile_number]
          if employee_detail[:date_of_birth].nil?
            employee.date_of_birth = nil
          else
            employee.date_of_birth = employee_detail[:date_of_birth].to_date
          end
          employee.gender = employee_detail[:gender]
          employee.cnic_number = employee_detail[:cnic_number]
          employee.cnic_expiry_date = employee_detail[:cnic_expiry_date]
          employee.blood_group = employee_detail[:blood_group]
          employee.martial_status = employee_detail[:martial_status]
          employee.company_id = company.id
          employee.location_id = location.id
          employee.employee_type_id = employee_type.id
          employee.branch_id = branch.id
          employee.department_id = department.id
          employee.designation_id = designation.id
          employee.job_title_id = job_title.id
          employee.grade_id = grade.id
          employee.salary_unit_id = salary_unit.id
          employee.cost_center_id = cost_center.id
          if employee_detail[:joining_date].nil?
            employee.joining_date = nil
          else
            employee.joining_date = employee_detail[:joining_date].to_date
          end
          employee.employee_code = employee_detail[:employee_code]
          employee.prev_employee_code = employee_detail[:prev_employee_code]
          if employee_detail[:on_probation].downcase == "true"
            employee.on_probation = true
          else
            employee.on_probation = false
          end
          if employee_detail[:is_line_manager].downcase == "true"
            employee.is_line_manager = true
          else
            employee.is_line_manager = false
          end
          if employee_detail[:is_active].downcase == "true"
            employee.is_active = true
          else
            employee.is_active = false
          end
          employee.gross_salary = employee_detail[:gross_salary].to_f
          employee.current_address = employee_detail[:current_address]
          if employee_detail[:confirmation_date].nil?
            employee.confirmation_date = nil
          else
            employee.confirmation_date = employee_detail[:confirmation_date].to_date
          end
          if line_manager.nil?
            employee.line_manager = nil
          else
            employee.line_manager_id = line_manager.id
          end
          if employee_type.id.to_s == "7" or employee_type.id.to_s == "8"
            if incharge_id.present?
              employee.incharge_id = incharge_id
            end
            if group_id.present?
              group = Piecerate.find(group_id.to_i)
              line = Piecerate.find(group.line_id.to_i)
              employee.group_id = group_id
              employee.line_id = group.line_id
              employee.category_id = group.category_id
              employee.floor_id = line.floor_id
            end
          end
          if employee.save
            remarks << "New Employee saved"  
          else
            remarks << employee.errors.full_messages.join(',')
          end
        else
          # remarks << "Exiting Employee Updated"
          employee.salutation = employee_detail[:salutation]
          employee.first_name = employee_detail[:first_name]
          employee.last_name = employee_detail[:last_name]
          employee.father_name = employee_detail[:father_name]
          employee.mother_name = employee_detail[:mother_name]
          employee.official_email = employee_detail[:official_email]
          employee.official_mobile_number = employee_detail[:official_mobile_number]
          if employee_detail[:date_of_birth].nil?
            employee.date_of_birth = nil
          else
            employee.date_of_birth = employee_detail[:date_of_birth].to_date
          end
          employee.gender = employee_detail[:gender]
          employee.cnic_number = employee_detail[:cnic_number]
          employee.cnic_expiry_date = employee_detail[:cnic_expiry_date]
          employee.blood_group = employee_detail[:blood_group]
          employee.martial_status = employee_detail[:martial_status]
          employee.company_id = company.id
          employee.location_id = location.id
          employee.employee_type_id = employee_type.id
          employee.branch_id = branch.id
          employee.department_id = department.id
          employee.designation_id = designation.id
          employee.job_title_id = job_title.id
          employee.grade_id = grade.id
          employee.salary_unit_id = salary_unit.id
          employee.cost_center_id = cost_center.id
          if employee_detail[:joining_date].nil?
            employee.joining_date = nil
          else
            employee.joining_date = employee_detail[:joining_date].to_date
          end
          employee.employee_code = employee_detail[:employee_code]
          employee.prev_employee_code = employee_detail[:prev_employee_code]
          if employee_detail[:on_probation].downcase == "true"
            employee.on_probation = true
          else
            employee.on_probation = false
          end
          if employee_detail[:is_line_manager].downcase == "true"
            employee.is_line_manager = true
          else
            employee.is_line_manager = false
          end
          if employee_detail[:is_active].downcase == "true"
            employee.is_active = true
          else
            employee.is_active = false
          end
          employee.gross_salary = employee_detail[:gross_salary].to_f
          employee.current_address = employee_detail[:current_address]
          if employee_detail[:confirmation_date].nil?
            employee.confirmation_date = nil
          else
            employee.confirmation_date = employee_detail[:confirmation_date].to_date
          end
          if line_manager.nil?
            employee.line_manager = nil
          else
            employee.line_manager = line_manager
          end
          if employee_type.id.to_s == "7" or employee_type.id.to_s == "8"
            if incharge_id.present?
              employee.incharge_id = incharge_id
            end
            if group_id.present?
              group = Piecerate.find(group_id.to_i)
              line = Piecerate.find(group.line_id.to_i)
              employee.group_id = group_id
              employee.line_id = group.line_id
              employee.category_id = group.category_id
              employee.floor_id = line.floor_id
            end
          end
          if employee.save
            remarks << "Exiting Employee Updated"
          else  
            remarks << employee.errors.full_messages.join(',')
          end
        end
      end
      temp_obj = {
        employee_code: employee_detail[:employee_code],
        remarks: remarks.join(',')
      }
      response_messages << temp_obj
    end
    render json:{:response_messages => response_messages}, status: 200
  end

  def fetch_employees
    if params[:token] == Rails.application.secrets.secret_key_base
      @employees = Employee.all
      render json: @employees
    end
  end

  def fetch_companies
    if params[:token] == Rails.application.secrets.secret_key_base
      @companies =Company.all
      render json: @companies
    end
  end

  def fetch_locations
    if params[:token] == Rails.application.secrets.secret_key_base
      @locations = Location.all
      render json: @locations
    end
  end

  def fetch_departments
    if params[:token] == Rails.application.secrets.secret_key_base
      @departments = Department.all
      render json: @departments
    end
  end

  def fetch_designations
    if params[:token] == Rails.application.secrets.secret_key_base
      @designations = Designation.all
      render json: @designations
    end
  end

	private

	def employee_params
		params.permit(:salutation, :first_name, :last_name, :father_name, :official_email, :official_mobile_number, :gender, :cnic_number, :blood_group, :martial_status, :company_id, :location_id, :branch_id, :department_id, :designation_id, :job_title_id, :grade_id, :salary_unit_id, :cost_center_id, :employee_code, :prev_employee_code, :on_probation, :is_line_manager, :is_active, :create_login, :relationship_id, :emergency_contact_name, :payment_method, :tax_exempted, :salary_exempted, :bank_name, :bank_branch_name, :bank_branch_code, :bank_account_title, :bank_account_number, :gross_salary, :is_admin, :custom_right, :role_id, :is_company_head, :is_location_head, :is_branch_head, :is_department_head, :user_account_email, :user_account_password, :emergency_contact_name, :emergency_contact_email, :emergency_contact_phone, :personal_email, :personal_number, :line_manager_id, :sub_department_id, :employee_type_id, :is_sub_department_head, :roster_employee_id, :is_contractual, :line_id, :floor_id, :incharge_id, :category_id, :group_id, :is_incharge,:mother_name, :cnic_expiry_date)
	end

  def edit_employee_params
    params.permit(:salutation, :first_name, :last_name, :father_name, :official_email, :official_mobile_number, :gender, :cnic_number, :blood_group, :martial_status, :is_line_manager, :create_login, :relationship_id, :emergency_contact_name, :payment_method, :tax_exempted, :salary_exempted, :bank_name, :bank_branch_name, :bank_branch_code, :bank_account_title, :bank_account_number, :is_admin, :custom_right, :role_id, :is_company_head, :is_location_head, :is_branch_head, :is_department_head, :user_account_email, :user_account_password, :emergency_contact_name, :emergency_contact_email, :emergency_contact_phone, :current_address, :current_country_id, :current_state_id, :current_city_id, :is_line_manager, :current_division_id, :current_district_id, :current_tehsil_id, :religion_sect_id, :religion_id, :personal_email, :personal_number, :is_overtime, :is_off_day_working, :is_cpl, :attendance_exempted, :hold_salary, :social_security_allowed, :social_security_eligibility, :social_security_joining_salary, :life_insurance_allowed, :life_insurance_eligibility, :life_insurance_value, :cell_phone_bill_allowed, :cell_phone_bill_eligibility, :cell_phone_bill_limit, :cell_phone_bill_amount, :fuel_allowed, :fuel_eligibility, :fuel_limit, :fuel_value, :cell_phone_allowed, :cell_phone_eligibility, :cell_phone_entitlement_upto, :laptop_allowed, :laptop_eligibility, :laptop_entitlement_upto, :laptop_category, :actual_laptop_value, :velicle_allowed, :velicle_eligibility, :provident_fund_allowed, :provident_fund_eligibility, :eobi_allowed, :eobi_eligibility, :incentive_allowed, :incentive_eligibility, :vehicle_allowance_allowed, :vehicle_allowance_eligibility, :vehicle_allowance_entitlement_upto, :maintenance_allowed, :maintenance_eligibility, :maintenance_entitlement_upto, :travel_allowance_allowed, :travel_allowance_eligibility, :travel_allowance_entitlement_upto, :social_security_impact_allowed, :life_insurance_impact_allowed, :cell_phone_bill_impact_allowed, :fuel_impact_allowed, :cell_phone_impact_allowed, :laptop_impact_allowed, :velicle_impact_allowed, :provident_fund_impact_allowed, :eobi_impact_allowed, :incentive_impact_allowed, :vehicle_allowance_impact_allowed, :maintenance_impact_allowed, :travel_allowance_impact_allowed, :attendance_impact_allowed, :vehicle_value, :bonus1_impact_allowed, :bonus1_allowed, :bonus1_eligibility, :bonus2_impact_allowed, :bonus2_allowed, :bonus2_eligibility, :bonus3_impact_allowed, :bonus3_allowed, :bonus3_eligibility, :back_date_eobi_impact, :back_date_pf_impact, :back_date_allowance_impact, :security_number, :health_insurance_impact_allowed, :health_insurance_allowed, :health_insurance_plan, :health_insurance_eligibility, :confimration_due_date, :gratuity_impact_allowed, :gratuity_allowed, :gratuity_eligibility, :lfa_impact_allowed, :lfa_allowed, :lfa_eligibility, :house_allowance_impact_allowed, :house_allowance_allowed, :house_allowance_eligibility, :permanent_address, :file_number, :family_number, :late_exempted, :regular_quota_encashment, :holiday_quota_encashment, :is_regular_cpl, :is_holiday_overtime, :eobi_number, :nationality, :vehicle_name, :vehicle_model, :laptop_name, :laptop_model, :cell_phone_name, :cell_phone_model, :ntn_number, :customize_tax, :tax_criteria, :fixed_tax_rate, :excluded_from_reports, :approval_base_overtime, :is_medical_allowance, :hiring_shift_id, :fuel_card_number, :velicle_two_allowed, :velicle_two_eligibility, :vehicle_two_name, :vehicle_two_model, :vehicle_two_value, :fuel_company_name,:vaccinated,:spouse_name,:whatsapp_number,:linkedln_url,:disability,:marriage_date,:languages_level,:inter_level,:expert_level,:languages,:language_second,:language_third,:skills_software,:skills_level,:skills_second,:second_level,:skills_third,:third_level,:criminal_record,:passport_number,:passport_expiry,:license_number,:license_expiry,:disability_needs,:permanent_country_id,:permanent_state_id,:permanent_city_id, :line_id, :floor_id, :incharge_id, :category_id, :group_id, :is_incharge,:category, :mother_name, :cnic_expiry_date)
  end

  def relative_params
    params.permit(:relative_name, :relationship_id, :email, :contact_number, :gender, :cnic_number, :is_dependent, :address, :same_as_employee_address, :same_as_employee_permanent_address, :insurance_allowed, :martial_status,:deceased,:covid_vaccination)
  end

  def next_of_kin_params
    params.permit(:employee_relative_id, :relationship_id, :relative_age, :percentage, :guardian_id)
  end

  def reference_params
    params.permit(:reference_type, :name, :email, :contact_number, :organization, :designation, :address)
  end

  def qualification_params
    params.permit(:institute_name, :program_name, :specialization_name, :status, :status_text, :gpa_or_percentage, :qualification_level, :qualfication_type_id, :qualification_program_id, :specialization_id)
  end

  def experience_params
    params.permit(:organization, :job_title, :left_reason, :salary,:department,:other_benefits)
  end

  def membership_params
    params.permit(:employee_memberships, :position_title, :institute_name, :remarks,:start_date, :end_date )
  end

  def document_params
    params.permit(:employee_documents, :document_name, :document_remarks,)
  end

  def training_params
    params.permit(:organization, :name, :training_type, :percentage)
  end

  def certification_params
    params.permit(:certification_authority, :name, :certification_type, :percentage)
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def assign_qualification_dates
    if params[:start_date].nil?
      @qualification.start_date = nil
    else
      @qualification.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @qualification.end_date = nil
    else
      @qualification.end_date = params[:end_date].to_date
    end
  end

  def assign_experience_dates
    if params[:start_date].nil?
      @experience.start_date = nil
    else
      @experience.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @experience.end_date = nil
    else
      @experience.end_date = params[:end_date].to_date
    end
  end

  # def assign_membership_dates
  #   if params[:start_date].nil?
  #     @membership.start_date = nil
  #   else
  #     @experience.start_date = params[:start_date].to_date
  #   end
  #   if params[:end_date].nil?
  #     @experience.end_date = nil
  #   else
  #     @experience.end_date = params[:end_date].to_date
  #   end
  # end

  def assign_training_dates
    if params[:start_date].nil?
      @training.start_date = nil
    else
      @training.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @training.end_date = nil
    else
      @training.end_date = params[:end_date].to_date
    end
  end

  def assign_certification_dates
    if params[:start_date].nil?
      @certification.start_date = nil
    else
      @certification.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @certification.end_date = nil
    else
      @certification.end_date = params[:end_date].to_date
    end
  end

  def filter_employee_data_on_request
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end    
    if not params[:employee_type_id].blank?
      @employees = Employee.employee_type_related_employee(@employees, params[:employee_type_id].to_i)
    end
    if params[:start_id].present? and params[:end_id].present?
      @employees = Employee.get_by_range(@employees, params[:start_id].to_i, params[:end_id].to_i)
    end
    @employees = @employees.includes(:branch, :department, :grade, :location, :designation, :job_title)
  end

  def update_employee_tags
    tags = []
    if params[:tags].present?
      if params[:tags].count
        Array.new(params[:tags].count).each_index do |index|
          tags << params[:tags][index.to_s]["text"]
        end
      end
    end
    @employee.tags = tags.join(',')
  end

  def employee_other_benefit_dates
    if params[:social_security_other_date].nil?
      @employee.social_security_other_date = nil
    else
      @employee.social_security_other_date = params[:social_security_other_date].to_date
    end
    if params[:life_insurance_other_date].nil?
      @employee.life_insurance_other_date = nil
    else
      @employee.life_insurance_other_date = params[:life_insurance_other_date].to_date
    end
    if params[:cell_phone_bill_other_date].nil?
      @employee.cell_phone_bill_other_date = nil
    else
      @employee.cell_phone_bill_other_date = params[:cell_phone_bill_other_date].to_date
    end
    if params[:fuel_other_date].nil?
      @employee.fuel_other_date = nil
    else
      @employee.fuel_other_date = params[:fuel_other_date].to_date
    end
    if params[:cell_phone_other_date].nil?
      @employee.cell_phone_other_date = nil
    else
      @employee.cell_phone_other_date = params[:cell_phone_other_date].to_date
    end
    if params[:laptop_other_date].nil?
      @employee.laptop_other_date = nil
    else
      @employee.laptop_other_date = params[:laptop_other_date].to_date
    end
    if params[:velicle_other_date].nil?
      @employee.velicle_other_date = nil
    else
      @employee.velicle_other_date = params[:velicle_other_date].to_date
    end
    if params[:velicle_two_other_date].nil?
      @employee.velicle_two_other_date = nil
    else
      @employee.velicle_two_other_date = params[:velicle_two_other_date].to_date
    end
    if params[:vehicle_two_assignment_date].nil?
      @employee.vehicle_two_assignment_date = nil
    else
      @employee.vehicle_two_assignment_date = params[:vehicle_two_assignment_date].to_date
    end
    if params[:provident_fund_other_date].nil?
      @employee.provident_fund_other_date = nil
    else
      @employee.provident_fund_other_date = params[:provident_fund_other_date].to_date
    end
    if params[:eobi_other_date].nil?
      @employee.eobi_other_date = nil
    else
      @employee.eobi_other_date = params[:eobi_other_date].to_date
    end
    if params[:incentive_other_date].nil?
      @employee.incentive_other_date = nil
    else
      @employee.incentive_other_date = params[:incentive_other_date].to_date
    end
    if params[:vehicle_allowance_other_date].nil?
      @employee.vehicle_allowance_other_date = nil
    else
      @employee.vehicle_allowance_other_date = params[:vehicle_allowance_other_date].to_date
    end
    if params[:maintenance_other_date].nil?
      @employee.maintenance_other_date = nil
    else
      @employee.maintenance_other_date = params[:maintenance_other_date].to_date
    end
    if params[:travel_allowance_other_date].nil?
      @employee.travel_allowance_other_date = nil
    else
      @employee.travel_allowance_other_date = params[:travel_allowance_other_date].to_date
    end
    if params[:bonus1_other_date].nil?
      @employee.bonus1_other_date = nil
    else
      @employee.bonus1_other_date = params[:bonus1_other_date].to_date
    end
    if params[:bonus2_other_date].nil?
      @employee.bonus2_other_date = nil
    else
      @employee.bonus2_other_date = params[:bonus2_other_date].to_date
    end
    if params[:bonus3_other_date].nil?
      @employee.bonus3_other_date = nil
    else
      @employee.bonus3_other_date = params[:bonus3_other_date].to_date
    end
    if params[:health_insurance_other_date].nil?
      @employee.health_insurance_other_date = nil
    else
      @employee.health_insurance_other_date = params[:health_insurance_other_date].to_date
    end
    if params[:gratuity_other_date].nil?
      @employee.gratuity_other_date = nil
    else
      @employee.gratuity_other_date = params[:gratuity_other_date].to_date
    end
    if params[:lfa_other_date].nil?
      @employee.lfa_other_date = nil
    else
      @employee.lfa_other_date = params[:lfa_other_date].to_date
    end
    if params[:house_allowance_other_date].nil?
      @employee.house_allowance_other_date = nil
    else
      @employee.house_allowance_other_date = params[:house_allowance_other_date].to_date
    end
    if params[:laptop_assignment_date].nil?
      @employee.laptop_assignment_date = nil
    else
      @employee.laptop_assignment_date = params[:laptop_assignment_date].to_date
    end
    if params[:cell_assignment_date].nil?
      @employee.cell_assignment_date = nil
    else
      @employee.cell_assignment_date = params[:cell_assignment_date].to_date
    end
  end

end
