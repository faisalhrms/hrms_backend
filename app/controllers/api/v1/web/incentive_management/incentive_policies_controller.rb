class Api::V1::Web::IncentiveManagement::IncentivePoliciesController < ApplicationController

	before_action :set_incentive_policy, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @incentive_policies = IncentivePolicy.all.order('id DESC')
    else
      @incentive_policies = IncentivePolicy.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/incentive_management/incentive_policies/index'
  end

  def filter_data
    @incentive_policies = IncentivePolicy.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/incentive_management/incentive_policies/index'
  end

  def create
    @incentive_policy       = IncentivePolicy.new incentive_policy_params
    if @incentive_policy.save
    	save_or_update_incentive_slabs
      render json:{}, status: :created
    else
      render json: {errors: @incentive_policy.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/incentive_management/incentive_policies/show'
  end

  def update
  	if @incentive_policy.update(incentive_policy_params)
    	save_or_update_incentive_slabs
      render json: {}, status: 204
    else
      render json: {errors: @incentive_policy.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @incentive_policy.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @incentive_policy.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_incentive_slab
  	incentive_slab = IncentiveSlab.find params[:incentive_slab_id]
  	incentive_slab.destroy
  	render json: {}, status: 204
  end

	private

	def incentive_policy_params
		params.permit(:company_id, :name, :code, :is_active, :description)
	end

  def set_incentive_policy
    @incentive_policy = IncentivePolicy.find(params[:id])
  end

  def save_or_update_incentive_slabs
  	########## Slabs ##########
    if params[:incentive_slabs].present?
      incentive_slabs = params[:incentive_slabs]
      if incentive_slabs.count > 0
        Array.new(incentive_slabs.count).each_index do |index|
          if incentive_slabs[index.to_s][:slab_id].nil?
            new_slab 										      	= @incentive_policy.incentive_slabs.build
						new_slab.min_target_sale_percentage 		= incentive_slabs[index.to_s][:min_target_sale_percentage]
						new_slab.max_target_sale_percentage 		= incentive_slabs[index.to_s][:max_target_sale_percentage]
						new_slab.sale_incentive_percentage 			= incentive_slabs[index.to_s][:sale_incentive_percentage]
						new_slab.save
          else
            edit_slab 													=	@incentive_policy.incentive_slabs.find incentive_slabs[index.to_s][:slab_id]
            edit_slab.min_target_sale_percentage 		= incentive_slabs[index.to_s][:min_target_sale_percentage]
						edit_slab.max_target_sale_percentage 		= incentive_slabs[index.to_s][:max_target_sale_percentage]
						edit_slab.sale_incentive_percentage 		= incentive_slabs[index.to_s][:sale_incentive_percentage]
						edit_slab.save
          end
        end
      end
    end
  end

end
