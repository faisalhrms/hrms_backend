class Api::V1::Web::PayrollManagement::ProvidentFundsController < ApplicationController

	before_filter :set_provident_fund, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @provident_funds = ProvidentFund.all.order('id DESC')
    else
      @provident_funds = ProvidentFund.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/provident_funds/index.json.jbuilder'
  end

  def filter_data
    @provident_funds = ProvidentFund.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/provident_funds/index.json.jbuilder'
  end

  def create
    @provident_fund       = ProvidentFund.new provident_fund_params
    if @provident_fund.save
      render json:{}, status: :created
    else
      render json: {errors: @provident_fund.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/provident_funds/show.json.jbuilder'
  end

  def update
    if @provident_fund.update(provident_fund_params)
      render json: {}, status: 204
    else
      render json: {errors: @provident_fund.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @provident_fund.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @provident_fund.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def provident_fund_params
		params.permit(:company_id, :name, :is_active, :employee_value, :employee_fixed_amount, :employee_percentage, :employee_pay_item_id, :employer_value, :employer_fixed_amount, :employer_percentage, :employer_pay_item_id, :employer_taxable, :employer_amount_exceed, :employer_tax_percentage)
	end

  def set_provident_fund
    @provident_fund = ProvidentFund.find(params[:id])
  end

end
