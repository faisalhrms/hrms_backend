class Api::V1::Web::AdminTool::EmailExecutionsController < ApplicationController

	before_action :set_email_execution, :only => [:show, :update, :destroy, :execute_email]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @email_executions = EmailExecution.all.order('id DESC')
    else
      @email_executions = EmailExecution.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/email_executions/index'
  end

  def filter_data
    @email_executions = EmailExecution.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/email_executions/index'
  end

  def create
    @email_execution       = EmailExecution.new email_execution_params
    if @email_execution.save
      render json:{}, status: :created
    else
      render json: {errors: @email_execution.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/email_executions/show'
  end

  def update
    if @email_execution.update(email_execution_params)
      render json: {}, status: 204
    else
      render json: {errors: @email_execution.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @email_execution.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @email_execution.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def execute_email
  	@email_execution.send_email
  	render json: {}, status: 204
  end

	private

	def email_execution_params
		params.permit(:company_id,	:location_id,	:branch_id,	:grade_id,	:name,	:email_template_id,	:trigger, :no_of_days)
	end

  def set_email_execution
    @email_execution = EmailExecution.find(params[:id])
  end

end
