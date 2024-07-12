class Api::V1::Web::GeneralSetting::QualficationTypesController < ApplicationController

	before_action :set_qualfication_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @qualfication_types = QualficationType.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/qualfication_types/index'
  end

  def active_list
    @qualfication_types = QualficationType.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/qualfication_types/index'
  end

  def create
    @qualfication_type       = QualficationType.new qualfication_type_params
    if @qualfication_type.save
      render json:{}, status: :created
    else
      render json: {errors: @qualfication_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/qualfication_types/show'
  end

  def update
    if @qualfication_type.update(qualfication_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @qualfication_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @qualfication_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @qualfication_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def qualfication_type_params
		params.permit(:name, :is_active, :description)
	end

  def set_qualfication_type
    @qualfication_type = QualficationType.find(params[:id])
  end

end
