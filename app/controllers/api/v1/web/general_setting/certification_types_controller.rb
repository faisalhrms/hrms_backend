class Api::V1::Web::GeneralSetting::CertificationTypesController < ApplicationController

	before_filter :set_certification_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @certification_types = CertificationType.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/certification_types/index.json.jbuilder'
  end

  def active_list
    @certification_types = CertificationType.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/certification_types/index.json.jbuilder'
  end

  def create
    @certification_type       = CertificationType.new certification_type_params
    if @certification_type.save
      render json:{}, status: :created
    else
      render json: {errors: @certification_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/certification_types/show.json.jbuilder'
  end

  def update
    if @certification_type.update(certification_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @certification_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @certification_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @certification_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def certification_type_params
		params.permit(:name, :is_active, :description)
	end

  def set_certification_type
    @certification_type = CertificationType.find(params[:id])
  end

end
