class Api::V1::Web::AdminTool::SmsConfigrationsController < ApplicationController

	before_filter :set_sms_configration, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @sms_configrations = SmsConfigration.all.order('id DESC')
    else
      @sms_configrations = SmsConfigration.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/sms_configrations/index.json.jbuilder'
  end

  def active_list
    if current_user.is_admin == true
      @sms_configrations = SmsConfigration.where(:is_active => true).order('id DESC')
    else
      @sms_configrations = SmsConfigration.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/sms_configrations/index.json.jbuilder'
  end

  def filter_data
    @sms_configrations = SmsConfigration.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/sms_configrations/index.json.jbuilder'
  end

  def create
    @sms_configration       = SmsConfigration.new sms_configration_params
    if @sms_configration.save
      render json:{}, status: :created
    else
      render json: {errors: @sms_configration.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/sms_configrations/show.json.jbuilder'
  end

  def update
    if @sms_configration.update(sms_configration_params)
      render json: {}, status: 204
    else
      render json: {errors: @sms_configration.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @sms_configration.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @sms_configration.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def sms_configration_params
		params.permit(:company_id, :name, :url, :user_name, :password, :show_password, :masking, :is_active)
	end

  def set_sms_configration
    @sms_configration = SmsConfigration.find(params[:id])
  end

end
