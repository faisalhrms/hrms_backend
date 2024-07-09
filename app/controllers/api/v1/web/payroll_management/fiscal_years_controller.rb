class Api::V1::Web::PayrollManagement::FiscalYearsController < ApplicationController

	before_filter :set_fiscal_year, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @fiscal_years = FiscalYear.all.order('id DESC')
    else
      @fiscal_years = FiscalYear.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/fiscal_years/index.json.jbuilder'
  end

  def filter_data
    @fiscal_years = FiscalYear.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/fiscal_years/index.json.jbuilder'
  end

  def filter_data_is_active
    @fiscal_years = FiscalYear.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/fiscal_years/index.json.jbuilder'
  end

  def create
    @fiscal_year       = FiscalYear.new fiscal_year_params
    allocate_date
    if @fiscal_year.save
      render json:{}, status: :created
    else
      render json: {errors: @fiscal_year.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/fiscal_years/show.json.jbuilder'
  end

  def update
    allocate_date
    if @fiscal_year.update(fiscal_year_params)
      render json: {}, status: 204
    else
      render json: {errors: @fiscal_year.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @fiscal_year.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @fiscal_year.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def fiscal_year_params
		params.permit(:company_id, :name, :is_active, :description)
	end

  def set_fiscal_year
    @fiscal_year = FiscalYear.find(params[:id])
  end

  def allocate_date
  	if params[:start_date].nil?
  		@fiscal_year.start_date = nil
  	else
  		@fiscal_year.start_date = params[:start_date].to_date
  	end
  	if params[:end_date].nil?
  		@fiscal_year.end_date = nil
  	else
  		@fiscal_year.end_date = params[:end_date].to_date
  	end
  end
  
end
