class Api::V1::Web::Organization::CompaniesController < ApplicationController

	before_filter :set_company, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if (current_user.is_admin == true) or (current_user.is_dtl == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true)
      @companies = Company.where(:is_active => true).order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @companies = Company.where(:id => current_user.employee.company_id, :is_active => true).order('id DESC')
      else
        @companies = Company.where(:id => current_user.company_id, :is_active => true).order('id DESC')
      end
    else
      @companies = Company.where(:id => current_user.company_id, :is_active => true).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/companies/index.json.jbuilder'
  end

  def complete_list
    if (current_user.is_admin == true) or (current_user.is_dtl == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true)
      @companies = Company.all.order('id DESC')
    else
      @companies = Company.where(:id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/companies/index.json.jbuilder'
  end

  def org_chart
    @company = Company.find(params[:company_id])
    render status:200, template: 'api/v1/web/organization/companies/org_chart.json.jbuilder'
  end

  def employee_code_prefix
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    employee_code_prefix = system_setting.get_employee_code_prefix(system_setting, params[:company_id], params[:location_id], params[:branch_id])
    render status:200, json: {employee_code_prefix: employee_code_prefix}
  end

  def upload_logo
    @company = Company.find(params[:company_id])
    @company.avatar = params[:file]
    @company.save
    render json: "", status: :created
  end

  def create
    @company       = Company.new company_params
    if @company.save
      render json:{:company_id => @company.id}, status: 200
    else
      render json: {errors: @company.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/companies/show.json.jbuilder'
  end

  def update
    if @company.update(company_params)
      render json:{:company_id => @company.id}, status: 200
    else
      render json: {errors: @company.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @company.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @company.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def company_params
		params.permit(:name, :code, :short_name, :address, :description, :is_active, :employee_code_prefix, :ntn_number)
	end

  def set_company
    @company = Company.find(params[:id])
  end

end
