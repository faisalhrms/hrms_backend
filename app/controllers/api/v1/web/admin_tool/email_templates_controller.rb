class Api::V1::Web::AdminTool::EmailTemplatesController < ApplicationController

	before_action :set_email_template, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @email_templates = EmailTemplate.all.order('id DESC')
    else
      @email_templates = EmailTemplate.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/email_templates/index'
  end

  def filter_data
    @email_templates = EmailTemplate.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/email_templates/index'
  end

  def manual_email_template
    @email_templates = EmailTemplate.where(:company_id => params[:company_id], :is_active => true, :trigger => "Manual").order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/email_templates/index'
  end

  def create
    @email_template       = EmailTemplate.new email_template_params
    if @email_template.save
      render json:{}, status: :created
    else
      render json: {errors: @email_template.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/email_templates/show'
  end

  def update
    if @email_template.update(email_template_params)
      render json: {}, status: 204
    else
      render json: {errors: @email_template.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @email_template.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @email_template.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def email_template_params
		params.permit(:company_id, :email_configration_id, :name, :subject, :trigger, :cc_address, :is_cc, :message, :is_active, :is_exempted, :exempted_address)
	end

  def set_email_template
    @email_template = EmailTemplate.find(params[:id])
  end

end
