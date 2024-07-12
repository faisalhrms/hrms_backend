class Api::V1::Web::PayrollManagement::EobisController < ApplicationController

	before_action :set_eobi, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @eobis = Eobi.all.order('id DESC')
    else
      @eobis = Eobi.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/eobis/index'
  end

  def filter_data
    @eobis = Eobi.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/eobis/index'
  end

  def create
    @eobi       = Eobi.new eobi_params
    if @eobi.save
      render json:{}, status: :created
    else
      render json: {errors: @eobi.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/eobis/show'
  end

  def update
    if @eobi.update(eobi_params)
      render json: {}, status: 204
    else
      render json: {errors: @eobi.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @eobi.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @eobi.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def eobi_params
		params.permit(:company_id, :name, :is_active, :employer_is_taxable, :employee_is_taxable, :employer_wage_rate, :employer_percentage, :employee_wage_rate, :employee_percentage)
	end

  def set_eobi
    @eobi = Eobi.find(params[:id])
  end

end
