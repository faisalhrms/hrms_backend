class Api::V1::Web::GeneralSetting::AssetTypesController < ApplicationController

	before_action :set_asset_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @asset_types = AssetType.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/asset_types/index'
  end

  def active_list
    @asset_types = AssetType.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/asset_types/index'
  end

  def create
    @asset_type       = AssetType.new asset_type_params
    if @asset_type.save
      render json:{}, status: :created
    else
      render json: {errors: @asset_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/asset_types/show'
  end

  def update
    if @asset_type.update(asset_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @asset_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @asset_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @asset_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def asset_type_params
		params.permit(:name, :is_active, :description)
	end

  def set_asset_type
    @asset_type = AssetType.find(params[:id])
  end

end
