class Api::V1::Web::PayrollManagement::PayitemExpressionsController < ApplicationController

	before_action :set_payitem_expression, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @payitem_expressions = PayitemExpression.all.order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/payitem_expressions/index'
  end

  def filter_data
    @payitem_expressions = PayitemExpression.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/payitem_expressions/index'
  end

  def create
    @payitem_expression       = PayitemExpression.new payitem_expression_params
    if @payitem_expression.save
      render json:{}, status: :created
    else
      render json: {errors: @payitem_expression.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/payitem_expressions/show'
  end

  def update
    if @payitem_expression.update(payitem_expression_params)
      render json: {}, status: 204
    else
      render json: {errors: @payitem_expression.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @payitem_expression.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @payitem_expression.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def payitem_expression_params
		params.permit(:name, :expression_value, :is_active, :description)
	end

  def set_payitem_expression
    @payitem_expression = PayitemExpression.find(params[:id])
  end

end
