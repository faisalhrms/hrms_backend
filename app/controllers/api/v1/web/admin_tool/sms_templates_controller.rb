class Api::V1::Web::AdminTool::SmsTemplatesController < ApplicationController

	before_filter :set_sms_template, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @sms_templates = SmsTemplate.all.order('id DESC')
    else
      @sms_templates = SmsTemplate.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/sms_templates/index.json.jbuilder'
  end

  def active_list
    if current_user.is_admin == true
      @sms_templates = SmsTemplate.where(:is_active => true).order('id DESC')
    else
      @sms_templates = SmsTemplate.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/sms_templates/index.json.jbuilder'
  end

  def filter_data
    @sms_templates = SmsTemplate.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/sms_templates/index.json.jbuilder'
  end

  def manual_sms_template
    @sms_templates = SmsTemplate.where(:company_id => params[:company_id], :is_active => true, :trigger => "Manual").order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/sms_templates/index.json.jbuilder'
  end

  def create
    @sms_template       = SmsTemplate.new sms_template_params
    if @sms_template.save
      render json:{}, status: :created
    else
      render json: {errors: @sms_template.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/sms_templates/show.json.jbuilder'
  end

  def update
    if @sms_template.update(sms_template_params)
      render json: {}, status: 204
    else
      render json: {errors: @sms_template.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @sms_template.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @sms_template.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def sms_template_params
		params.permit(:company_id, :sms_configration_id, :name, :is_active, :is_exempted, :exempted_numbers, :trigger, :message)
	end

  def set_sms_template
    @sms_template = SmsTemplate.find(params[:id])
  end

end
