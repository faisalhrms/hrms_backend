class Api::V1::Web::Organization::CostCentersController < ApplicationController

	before_filter :set_cost_center, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @cost_centers = CostCenter.all.order('id DESC')
    else
      @cost_centers = CostCenter.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/cost_centers/index.json.jbuilder'
  end

  def filter_data
    if (current_user.is_admin == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true) or (current_user.is_company_head == true)
      @cost_centers = CostCenter.where(:salary_unit_id => params[:salary_unit_id], :is_active => true).order('id DESC')  
    else
      if current_user.employee.nil?
        @cost_centers = CostCenter.where(:salary_unit_id => params[:salary_unit_id], :is_active => true).order('id DESC')  
      else
        @cost_centers = CostCenter.where(:id => current_user.employee.cost_center_id, :is_active => true).order('id DESC')
      end
    end
    render status:200, template: 'api/v1/web/organization/cost_centers/index.json.jbuilder'
  end

  def create
    @cost_center       = CostCenter.new cost_center_params
    if @cost_center.save
      render json:{}, status: :created
    else
      render json: {errors: @cost_center.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/cost_centers/show.json.jbuilder'
  end

  def update
    if @cost_center.update(cost_center_params)
      render json: {}, status: 204
    else
      render json: {errors: @cost_center.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @cost_center.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @cost_center.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def cost_center_params
		params.permit(:company_id, :salary_unit_id, :name, :is_active, :description)
	end

  def set_cost_center
    @cost_center = CostCenter.find(params[:id])
  end

end
