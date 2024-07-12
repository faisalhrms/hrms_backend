class Api::V1::Web::EmployeeManagement::InterneesController < ApplicationController

	before_action :set_internee, :only => [:show, :update, :converted_to_employee]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def internee_index
    @internees = Internee.where(:company_id => params[:company_id]).order('id DESC')
    if not params[:location_id].blank?
      @internees = Internee.location_related_employee(@internees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @internees = Internee.branch_related_employee(@internees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @internees = Internee.department_related_employee(@internees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @internees = Internee.designation_related_employee(@internees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @internees = Internee.job_title_related_employee(@internees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @internees = Internee.grade_related_employee(@internees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @internees = Internee.salary_unit_related_employee(@internees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @internees = Internee.cost_center_related_employee(@internees, params[:cost_center_id].to_i)
    end
    render status:200, template: 'api/v1/web/employee_management/internees/index'
  end

  def filter_data
    @internees = Internee.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/internees/index'
  end

  def create
    @internee       = Internee.new internee_params
    if params[:date_of_birth].nil?
    	@internee.date_of_birth = nil
    else
    	@internee.date_of_birth = params[:date_of_birth].to_date
    end
    if params[:joining_date].nil?
    	@internee.joining_date = nil
    else
    	@internee.joining_date = params[:joining_date].to_date
    end
    if @internee.save
      render json:{}, status: :created
    else
      render json: {errors: @internee.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/employee_management/internees/show'
  end

  def converted_to_employee
    @internee.is_converted = true
    @internee.save
    @internee.make_employee
    render json: {}, status: 204
  end

  def update
  	if params[:date_of_birth].nil?
    	@internee.date_of_birth = nil
    else
    	@internee.date_of_birth = params[:date_of_birth].to_date
    end
    if params[:joining_date].nil?
    	@internee.joining_date = nil
    else
    	@internee.joining_date = params[:joining_date].to_date
    end
    if @internee.update(internee_params)
      render json: {}, status: 204
    else
      render json: {errors: @internee.errors.full_messages}, status: :unprocessable_entity
    end
  end

	private

	def internee_params
		params.permit(:salutation, :first_name, :last_name, :father_name, :official_email, :official_mobile_number, :personal_email, :personal_number, :gender, :cnic_number, :blood_group, :martial_status, :gross_salary, :current_address, :company_id, :location_id, :branch_id, :department_id, :grade_id, :designation_id, :job_title_id, :salary_unit_id, :cost_center_id, :internee_code, :is_active, :current_address, :sub_department_id)
	end

  def set_internee
    @internee = Internee.find(params[:id])
  end

end
