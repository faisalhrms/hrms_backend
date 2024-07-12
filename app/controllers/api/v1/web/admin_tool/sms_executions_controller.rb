class Api::V1::Web::AdminTool::SmsExecutionsController < ApplicationController

	before_action :set_sms_execution, :only => [:show, :update, :destroy, :execute_sms]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @sms_executions = SmsExecution.all.order('id DESC')
    else
      @sms_executions = SmsExecution.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/sms_executions/index'
  end

  def filter_data
    @sms_executions = SmsExecution.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/sms_executions/index'
  end

  def create
    @sms_execution       = SmsExecution.new sms_execution_params
    if @sms_execution.save
      render json:{}, status: :created
    else
      render json: {errors: @sms_execution.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/sms_executions/show'
  end

  def update
    if @sms_execution.update(sms_execution_params)
      render json: {}, status: 204
    else
      render json: {errors: @sms_execution.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @sms_execution.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @sms_execution.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def execute_sms
  	@sms_execution.send_sms
  	render json: {}, status: 204
  end

	private

	def sms_execution_params
		params.permit(:company_id,	:location_id,	:branch_id,	:grade_id,	:name,	:sms_template_id,	:trigger)
	end

  def set_sms_execution
    @sms_execution = SmsExecution.find(params[:id])
  end

end
