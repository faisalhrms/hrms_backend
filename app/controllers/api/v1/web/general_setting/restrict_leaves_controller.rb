class Api::V1::Web::GeneralSetting::RestrictLeavesController < ApplicationController

	before_action :set_restrict_leave, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @restrict_leaves = RestrictLeave.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/restrict_leaves/index'
  end

  def create
    @restrict_leave = RestrictLeave.new restrict_leave_params
    @restrict_leave.user_ids =  params[:user_id].map(&:to_i).join(',')
    if @restrict_leave.save
      render json:{}, status: :created
    else
      render json: {errors: @restrict_leave.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    @users = User.where(company_id: @restrict_leave.company_id)
    render status:200, template: 'api/v1/web/general_setting/restrict_leaves/show'
  end

  def update
    @restrict_leave.user_ids              = params[:user_ids].map(&:to_i).join(',')
    if @restrict_leave.update(restrict_leave_params)
      render json: {}, status: 204
    else
      render json: {errors: @restrict_leave.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @restrict_leave.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @restrict_leave.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def restrict_leave_params
		params.permit(:leave_days, :is_active, :approval_days, :notification, :receiver_email, :user_ids, :company_id)
	end

  def set_restrict_leave
    @restrict_leave = RestrictLeave.find(params[:id])
  end

end
