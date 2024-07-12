class Api::V1::Web::Organization::AssetDetailsController < ApplicationController

	before_action :set_asset_detail, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @asset_details = AssetDetail.all.order('id DESC')
    else
      @asset_details = AssetDetail.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/asset_details/index'
  end

  def filter_data
    @asset_details = AssetDetail.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/asset_details/index'
  end

  def create
    @asset_detail       = AssetDetail.new asset_detail_params
    allocate_date
    if @asset_detail.save
      render json:{}, status: :created
    else
      render json: {errors: @asset_detail.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/asset_details/show'
  end

  def update
  	allocate_date
    if @asset_detail.update(asset_detail_params)
      render json: {}, status: 204
    else
      render json: {errors: @asset_detail.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @asset_detail.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @asset_detail.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def asset_detail_params
		params.permit(:company_id, :item_name, :item_type, :item_model, :item_amount, :maturity_period, :engine_capacity, :engine_number, :chase_number, :sim_number, :emi_number, :telecom_name, :card_limit, :card_number, :is_active, :description)
	end

  def set_asset_detail
    @asset_detail = AssetDetail.find(params[:id])
  end

  def allocate_date
  	if params[:purchase_date].nil?
  		@asset_detail.purchase_date = nil
  	else
  		@asset_detail.purchase_date = params[:purchase_date].to_date
  	end
  	if params[:expiry_date].nil?
  		@asset_detail.expiry_date = nil
  	else
  		@asset_detail.expiry_date = params[:expiry_date].to_date
  	end
  end

end
