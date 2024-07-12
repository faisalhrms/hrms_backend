class Api::V1::Web::AdminTool::EmailConfigrationsController < ApplicationController

	before_action :set_email_configration, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @email_configrations = EmailConfigration.all.order('id DESC')
    else
      @email_configrations = EmailConfigration.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/email_configrations/index'
  end

  def active_list
    if current_user.is_admin == true
      @email_configrations = EmailConfigration.where(:is_active => true).order('id DESC')
    else
      @email_configrations = EmailConfigration.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/email_configrations/index'
  end

  def filter_data
    @email_configrations = EmailConfigration.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/email_configrations/index'
  end

  def create
    @email_configration       = EmailConfigration.new email_configration_params
    if @email_configration.save
      render json:{}, status: :created
    else
      render json: {errors: @email_configration.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/email_configrations/show'
  end

  def update
    if @email_configration.update(email_configration_params)
      render json: {}, status: 204
    else
      render json: {errors: @email_configration.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @email_configration.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @email_configration.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def email_configration_params
		params.permit(:company_id, :name, :user_name, :email, :password, :outgoing_server_address, :outgoing_server_port, :domain, :is_active)
	end

  def set_email_configration
    @email_configration = EmailConfigration.find(params[:id])
  end

end
