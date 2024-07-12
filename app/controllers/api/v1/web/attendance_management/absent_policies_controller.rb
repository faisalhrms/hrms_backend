class Api::V1::Web::AttendanceManagement::AbsentPoliciesController < ApplicationController

	before_action :set_absent_policy, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @absent_policies = AbsentPolicy.all.order('id DESC')
    else
      @absent_policies = AbsentPolicy.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/absent_policies/index'
  end

  def filter_data
    @absent_policies = AbsentPolicy.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/absent_policies/index'
  end

  def create
    @absent_policy       = AbsentPolicy.new absent_policy_params
    if @absent_policy.save
      render json:{}, status: :created
    else
      render json: {errors: @absent_policy.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/absent_policies/show'
  end

  def update
  	if @absent_policy.update(absent_policy_params)
      render json: {}, status: 204
    else
      render json: {errors: @absent_policy.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @absent_policy.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @absent_policy.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def absent_policy_params
		params.permit(:company_id, :attendance_deduction_id, :fallback_id, :name, :code, :is_active, :description)
	end

  def set_absent_policy
    @absent_policy = AbsentPolicy.find(params[:id])
  end

end
