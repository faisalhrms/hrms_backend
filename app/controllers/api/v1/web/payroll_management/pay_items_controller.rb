class Api::V1::Web::PayrollManagement::PayItemsController < ApplicationController

	before_filter :set_pay_item, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @pay_items = PayItem.all.order('id DESC')
    else
      @pay_items = PayItem.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/pay_items/index.json.jbuilder'
  end

  def filter_data
    @pay_items = PayItem.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/pay_items/index.json.jbuilder'
  end

  def filter_pay_item
    items_execution_details = ItemExecutionDetail.get_by_pay_execution(params[:pay_execution_ids].split(',')).allowed.collect(&:pay_item_id)
    @pay_items  	= PayItem.where(:id => items_execution_details).order('sort_order ASC')
    render status:200, template: 'api/v1/web/payroll_management/pay_items/index.json.jbuilder'
  end

  def non_static_pay_items
    @pay_items = PayItem.where(:company_id => params[:company_id], :is_static_item => false, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/pay_items/index.json.jbuilder'
  end

  def fixed_pay_items
    @pay_items = PayItem.where(:company_id => params[:company_id], :calculation_type => "Fixed", is_active: true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/pay_items/index.json.jbuilder'
  end

  def create
    @pay_item       = PayItem.new pay_item_params
    @pay_item.formula_with_code = params[:formula_with_code]
    if params[:bonus_date].nil?
      @pay_item.bonus_date = nil
    else
      @pay_item.bonus_date = params[:bonus_date].to_date
    end
    if @pay_item.save
      render json:{}, status: :created
    else
      render json: {errors: @pay_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/pay_items/show.json.jbuilder'
  end

  def update
  	@pay_item.formula_with_code = params[:formula_with_code]
    if params[:bonus_date].nil?
      @pay_item.bonus_date = nil
    else
      @pay_item.bonus_date = params[:bonus_date].to_date
    end
    if @pay_item.update(pay_item_params)
      render json: {}, status: 204
    else
      render json: {errors: @pay_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @pay_item.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @pay_item.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def pay_item_params
		params.permit(:company_id, :eligible_from, :name, :code, :item_type, :calculation_type, :is_active, :show_in_slip, :part_of_other, :is_taxable, :exempted_tax_percentage, :formula, :is_bonus, :bonus_month, :description, :sort_order, :part_of_gross_salary, :bonus_type, :prediction_tax_impact, :name_in_urdu, :is_urdu, :annualize)
	end

  def set_pay_item
    @pay_item = PayItem.find(params[:id])
  end

end
