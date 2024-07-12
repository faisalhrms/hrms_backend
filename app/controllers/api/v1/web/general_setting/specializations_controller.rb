class Api::V1::Web::GeneralSetting::SpecializationsController < ApplicationController

	before_action :set_specialization, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @specializations = Specialization.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/specializations/index'
  end

  def active_list
    @specializations = Specialization.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/specializations/index'
  end

  def create
    @specialization       = Specialization.new specialization_params
    if @specialization.save
      render json:{}, status: :created
    else
      render json: {errors: @specialization.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/specializations/show'
  end

  def update
    if @specialization.update(specialization_params)
      render json: {}, status: 204
    else
      render json: {errors: @specialization.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @specialization.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @specialization.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def specialization_params
		params.permit(:name, :is_active, :description)
	end

  def set_specialization
    @specialization = Specialization.find(params[:id])
  end

end
